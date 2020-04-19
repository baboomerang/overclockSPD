import curses
from curses import wrapper

s = curses.initscr()
sh, sw = s.getmaxyx()
curses.noecho()
curses.cbreak()

menu = ['Edit SPD/XMP dump', 'Read SPD/XMP from RAM', 'Write SPD/XMP to RAM']

def print_menu(scr, key_value):
    scr.clear()

    for row_index, row in enumerate(menu):
        x = sw//2 - len(row)//2
        y = sh//2 - len(menu)//2 + row_index

        if row_index == key_value:
            scr.attron(curses.color_pair(1))
            scr.addstr(y, x, row)
            scr.attroff(curses.color_pair(1))
        else:
            scr.addstr(y, x, row)

    scr.refresh()


def main(s):
    curses.curs_set(0)
    curses.init_pair(1, curses.COLOR_BLACK, curses.COLOR_WHITE)

    w = curses.newwin(sh, sw, 0, 0)
    w.keypad(True)
    w.attron(curses.color_pair(1))

    key = 0
    index = 0
    print_menu(w, index)

    while True:
        key = w.getch()
        w.clear()
        if key == curses.KEY_LEFT and index > 0:
            index -= 1;
        elif key == curses.KEY_RIGHT and index < (len(menu) - 1):
            index += 1;
        elif key == curses.KEY_ENTER:
            w.clear()
            w.addstr(0, 0, "You pressed {}".format(menu[index]))
            w.refresh()
            w.getch()

        print_menu(w, index)
        w.refresh()


    curses.nocbreak()
    s.keypad(False)
    curses.echo()
    curses.endwin()

wrapper(main) #used for debug purposes only

#if __name__ == "__main__":
#        main(s)

