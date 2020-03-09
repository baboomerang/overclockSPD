import curses

def init():
    stdscr = curses.initscr()
    sh, sw = stdscr.getmaxyx()
    curses.noecho()
    curses.cbreak()          #implicitly called by default, redeclaring for the user

def main(stdscr):
    spdmenu = curses.newwin(sh, sw, 0, 0)
    spdmenu.keypad(True)
    curses.curs_set(0)

    while True:
        key = spdmenu.getch()










curses.endwin()
quit()
