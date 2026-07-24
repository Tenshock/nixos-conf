import os

from kitty.fast_data_types import get_boss, get_options
from kitty.rgb import color_as_sgr
from kitty.tab_bar import as_rgb, draw_title as draw_tab_title

GIT_FOLDER_ICON = ""


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


def git_root(path):
    path = os.path.abspath(path)
    while True:
        if os.path.exists(os.path.join(path, ".git")):
            return path

        parent = os.path.dirname(path)
        if parent == path:
            return None
        path = parent


def active_tab_foreground_escape():
    return f"\x1b[38{color_as_sgr(get_options().active_tab_foreground)}m"


def is_active_tab(data):
    boss = get_boss()
    active_tab = boss.active_tab if boss else None
    return active_tab is not None and active_tab.id == data["tab"].tab_id


def draw_title(data):
    path = data["tab"].active_wd
    active = is_active_tab(data)
    root = git_root(path)
    if root:
        folder = os.path.basename(root)
        if active:
            return f"{GIT_FOLDER_ICON}{active_tab_foreground_escape()} {folder}"
        return f"{GIT_FOLDER_ICON} {folder}"

    title = display_path(path)
    if active:
        return f"{active_tab_foreground_escape()}{title}"
    return title


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
