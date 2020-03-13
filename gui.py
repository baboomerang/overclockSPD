import curses

stdscr = curses.initscr()
sh, sw = stdscr.getmaxyx()
curses.noecho()
curses.cbreak()          #implicitly called by default, redeclaring for the user

def main(stdscr):
    spdmenu = curses.newwin(sh, sw, 0, 0)
    spdmenu.keypad(True)
    curses.curs_set(0)
    spdmenu.addstrt(sh, 0, "Hello world!")

    while True:
        spdmenu.refresh()
        key = spdmenu.getch()

def curseexit():
    curses.endwin()
    quit()


wrapper(main)
