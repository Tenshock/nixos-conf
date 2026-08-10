import weakref

from kitty.fast_data_types import add_timer


baselines = {}
closing_tabs = set()
dirty_tabs = set()
settling_windows = set()


def tab_for(window):
    return window.tabref()


def is_managed(tab):
    return any(window.user_vars.get("kitty_tab_slot") for window in tab)


def initialize_first_slot(window):
    tab = tab_for(window)
    if tab is None or is_managed(tab):
        return

    tab_manager = tab.tab_manager_ref()
    if tab_manager is not None and len(tab_manager) == 1:
        tab.set_title("1")
        window.set_user_var("kitty_tab_slot", "1")


def terminal_state(window):
    return window.as_text(
        add_history=True,
        add_wrap_markers=True,
        add_cursor=True,
    )


def settle(window_ref, previous=None, attempts=0):
    window = window_ref()
    if window is None:
        return

    tab = tab_for(window)
    if tab is None or tab.id in dirty_tabs:
        settling_windows.discard(window.id)
        return

    current = terminal_state(window)
    if current == previous or attempts >= 15:
        baselines[window.id] = current
        settling_windows.discard(window.id)
        return

    add_timer(
        lambda timer_id: settle(window_ref, current, attempts + 1),
        0.1,
        False,
    )


def begin_settling(window):
    if window.id in baselines or window.id in settling_windows:
        return
    settling_windows.add(window.id)
    window_ref = weakref.ref(window)
    add_timer(lambda timer_id: settle(window_ref), 0.1, False)


def delete_if_pristine(boss, window_ref, attempts=0):
    def retry():
        if attempts < 20:
            add_timer(
                lambda timer_id: delete_if_pristine(boss, window_ref, attempts + 1),
                0.1,
                False,
            )

    window = window_ref()
    if window is None:
        return

    tab = tab_for(window)
    if tab is None or not is_managed(tab):
        return

    if tab.id in closing_tabs:
        return

    tab_manager = tab.tab_manager_ref()
    if tab_manager is None:
        return

    if tab.id in dirty_tabs or len(tab) > 1:
        return

    # Creating a missing target tab is asynchronous. Focus can leave this
    # window before the new tab becomes active or even enters the manager.
    if tab_manager.active_tab is tab or len(tab_manager) <= 1:
        retry()
        return

    baseline = baselines.get(window.id)
    if baseline is None:
        retry()
        return

    if terminal_state(window) != baseline:
        dirty_tabs.add(tab.id)
        return

    closing_tabs.add(tab.id)
    boss.close_tab_no_confirm(tab)


def on_resize(boss, window, data):
    initialize_first_slot(window)
    tab = tab_for(window)
    if tab is not None and len(tab) > 1:
        dirty_tabs.add(tab.id)
    begin_settling(window)


def on_cmd_startstop(boss, window, data):
    if not data.get("is_start"):
        return
    tab = tab_for(window)
    if tab is not None:
        dirty_tabs.add(tab.id)


def on_set_user_var(boss, window, data):
    if data.get("key") == "kitty_cleanup_requested" and data.get("value") is not None:
        window_ref = weakref.ref(window)
        add_timer(
            lambda timer_id: delete_if_pristine(boss, window_ref),
            0,
            False,
        )


def on_focus_change(boss, window, data):
    if data.get("focused"):
        begin_settling(window)
        return

    window_ref = weakref.ref(window)
    add_timer(
        lambda timer_id: delete_if_pristine(boss, window_ref),
        0,
        False,
    )


def on_close(boss, window, data):
    baselines.pop(window.id, None)
    settling_windows.discard(window.id)
