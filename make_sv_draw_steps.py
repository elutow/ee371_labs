#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Prints out the SystemVerilog for drawing the cursor based on a PNG template
"""

import argparse
import math

import wand.image

_STEP_NO_COLOR = """{step}: begin
    next_x = $clog2(WIDTH)'({x});
    next_y = $clog2(HEIGHT)'({y});
end"""

_STEP_COLOR = """{step}: begin
    next_x = $clog2(WIDTH)'({x});
    next_y = $clog2(HEIGHT)'({y});
    next_color = {color};
end"""

_STATE_DRAW_FINAL = """{step}: begin
    next_x = x;
    next_y = y;
    next_step = step;
    if (x != cursor_x || y != cursor_y) begin
        next_step = 0;
        ns = STATE_ERASE;
    end
end
default: begin
    next_x = 'x;
    next_y = 'x;
    next_step = 'x;
    $error("Default of STATE_DRAW reached!");
end"""

_STATE_ERASE_FINAL = """{step}: begin
    next_x = x;
    next_y = y;
    next_step = step;
    ns = STATE_INIT;
end
default: begin
    next_x = 'x;
    next_y = 'x;
    next_step = 'x;
    $error("Default of STATE_ERASE reached!");
end"""

def _get_dim_expr(var_name, diff_val):
    if diff_val < 0:
        return "{} - 'd{}".format(var_name, abs(diff_val))
    elif diff_val > 0:
        return "{} + 'd{}".format(var_name, diff_val)
    return var_name

def _get_transform(current_coords, new_coords):
    curr_x, curr_y = current_coords
    new_x, new_y = new_coords
    diff_x, diff_y = (new_x - curr_x, new_y - curr_y)
    return _get_dim_expr('x', diff_x), _get_dim_expr('y', diff_y)

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('png', help='The PNG file to read')
    args = parser.parse_args()

    color_coordinates = list()
    black_coordinates = list()

    with wand.image.Image(filename=args.png) as img:
        width, height = img.width, img.height
        print('width, height = {}, {}'.format(width, height))
        blob = img.make_blob(format='RGBA')

    origin_color = 'COLOR_NONE'
    for cursor in range(0, width*height*4, 4):
        r = blob[cursor]
        g = blob[cursor+1]
        b = blob[cursor+2]
        a = blob[cursor+3]
        if a == 0:
            continue
        # (x, y)
        current_coords = (cursor // 4 % width, cursor // 4 // width)
        if (r, g, b) == (0, 0, 0):
            black_coordinates.append(current_coords)
            if current_coords == (0, 0):
                origin_color = 'COLOR_BLACK'
        else:
            color_coordinates.append(current_coords)
            if current_coords == (0, 0):
                origin_color = None

    # Set current coordinates to the cursor location.
    # These coordinates will not be reset until drawing AND erasing are done
    current_coords = (0, 0)

    # Draw color coordinates
    with open('cursor_renderer_draw_steps.sv', 'w') as sv_file:
        step = 0
        print('// Color drawing', file=sv_file)
        for new_coords in color_coordinates:
            x_expr, y_expr = _get_transform(current_coords, new_coords)
            print(_STEP_NO_COLOR.format(
                step=step,
                x=x_expr,
                y=y_expr
            ), file=sv_file)
            step += 1
            current_coords = new_coords

        # Draw black coordinates
        print('// Black drawing', file=sv_file)
        for new_coords in black_coordinates:
            x_expr, y_expr = _get_transform(current_coords, new_coords)
            print(_STEP_COLOR.format(
                step=step,
                x=x_expr,
                y=y_expr,
                color='COLOR_BLACK'
            ), file=sv_file)
            step += 1
            current_coords = new_coords
        x_expr, y_expr = _get_transform(current_coords, (0, 0))
        if origin_color:
            print(_STEP_COLOR.format(
                step=step,
                x=x_expr,
                y=y_expr,
                color=origin_color), file=sv_file)
        else:
            print(_STEP_NO_COLOR.format(
                step=step,
                x=x_expr,
                y=y_expr), file=sv_file)
        current_coords = (0, 0)
        step += 1
        print(_STATE_DRAW_FINAL.format(step=step), file=sv_file)

    # Erase coordinates
    erase_coordinates = list()
    erase_coordinates.extend(color_coordinates)
    erase_coordinates.extend(black_coordinates)
    erase_coordinates.sort()
    step = 0
    with open('cursor_renderer_erase_steps.sv', 'w') as sv_file:
        print('// Erase', file=sv_file)
        for new_coords in erase_coordinates:
            x_expr, y_expr = _get_transform(current_coords, new_coords)
            print(_STEP_NO_COLOR.format(
                step=step,
                x=x_expr,
                y=y_expr
            ), file=sv_file)
            step += 1
            current_coords = new_coords
        print(_STATE_ERASE_FINAL.format(step=step), file=sv_file)

    print('Total number of steps:', step+1)

if __name__ == '__main__':
    main()
