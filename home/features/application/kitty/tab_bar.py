import os

from kitty.tab_bar import as_rgb, draw_title as draw_tab_title


def display_path(path):
    home = os.environ.get("HOME")
    if not home:
        return path

    home = os.path.normpath(home)
    path = os.path.normpath(path)
    if path == home:
        return "~"
    if path.startswith(home + os.sep):
        return "~" + path[len(home) :]
    return path


def draw_title(data):
    return display_path(data["tab"].active_wd)


def draw_tab(
    draw_data,
    screen,
    tab,
    before,
    max_tab_length,
    index,
    is_last,
    extra_data,
):
    tab_background = screen.cursor.bg
    tab_foreground = screen.cursor.fg
    bar_background = as_rgb(int(draw_data.default_bg))

    screen.cursor.bg = bar_background
    screen.cursor.fg = tab_background
    screen.draw("")

    screen.cursor.bg = tab_background
    screen.cursor.fg = tab_foreground
    screen.draw(" ")

    title_start = screen.cursor.x
    title_length = max(1, max_tab_length - 5)
    draw_tab_title(draw_data, screen, tab, index, title_length)
    if screen.cursor.x - title_start > title_length:
        screen.cursor.x = title_start + title_length - 1
        screen.draw("…")

    screen.draw(" ")
    screen.cursor.bg = bar_background
    screen.cursor.fg = tab_background
    screen.draw("")

    screen.cursor.fg = 0
    screen.draw(" ")
    return screen.cursor.x
