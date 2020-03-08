#include <ncurses.h>
char getInput();

int main(int argc, char ** argv) {

    initscr();

    getch();

    endwin();

}

char getInput() {
    int c = getch();
    return getch();
}
