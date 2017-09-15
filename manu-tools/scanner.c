#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <fcntl.h>
#include <dirent.h>
//https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/linux/input.h
#include <linux/input.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/select.h>
#include <sys/time.h>
#include <termios.h>
#include <signal.h>
#include <regex.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <stdarg.h>

#define DAEMON



char *socket_path="\0led";
//https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/uapi/linux/input-event-codes.h
#include "input-event-codes.h"
//#include "hashmap.h"


char scannerString[200]="";
char pcServer[200]="";
int pcc=0;
struct input_event ev[64];
int type,kvalue,code=0;
//https://stackoverflow.com/questions/1371460/state-machines-tutorials
int new_entry(void);
int gathering(void);
int exit_state(void);
int _printf(const char *fmt,...);

/* array and enum below must be in sync! */
int (* state[])(void) = { new_entry, gathering, exit_state};
enum state_codes { entry, gather, end};
enum shiftstates { up, down};
enum ret_codes { ok, fail, repeat};
enum ledmode{led_needscanner,led_foundscanner,led_havecurlserver,led_success,led_verify,led_erase,led_reboot,led_failure,led_burningeeprom,led_failedcurlfetch}currentLedState,lastLedState;
enum shiftstates shiftstate;
struct transition {
    enum state_codes src_state;
    enum ret_codes   ret_code;
    enum state_codes dst_state;
};
/* transitions from end state aren't needed */
struct transition state_transitions[] = {
    {entry, ok,     gather},
    {gather,  ok,     entry},
    {gather,  repeat,  gather},
    {gather,  fail,   end},
    {entry, fail,   end},
    {end,   ok,      end},
    {end,   fail,    end},
    {end,   repeat,  end}
};

#define EXIT_STATE end
#define ENTRY_STATE entry



char _LOOKUPCODE(int in){
    if (shiftstate==up){
        switch (in) {
            case KEY_RESERVED:
            return '%';
            break;
            case KEY_ESC:
            return '%';
            break;
            case KEY_1:
            return '1';
            break;
            case KEY_2:
            return '2';
            break;
            case KEY_3:
            return '3';
            break;
            case KEY_4:
            return '4';
            break;
            case KEY_5:
            return '5';
            break;
            case KEY_6:
            return '6';
            break;
            case KEY_7:
            return '7';
            break;
            case KEY_8:
            return '8';
            break;
            case KEY_9:
            return '9';
            break;
            case KEY_0:
            return '0';
            break;
            case KEY_MINUS:
            return '-';
            break;
            case KEY_EQUAL:
            return '=';
            break;
            case KEY_BACKSPACE:
            return '%';
            break;
            case KEY_TAB:
            return '%';
            break;
            case KEY_Q:
            return 'q';
            break;
            case KEY_W:
            return 'w';
            break;
            case KEY_E:
            return 'e';
            break;
            case KEY_R:
            return 'r';
            break;
            case KEY_T:
            return 't';
            break;
            case KEY_Y:
            return 'y';
            break;
            case KEY_U:
            return 'u';
            break;
            case KEY_I:
            return 'i';
            break;
            case KEY_O:
            return 'o';
            break;
            case KEY_P:
            return 'p';
            break;
            case KEY_LEFTBRACE:
            return '[';
            break;
            case KEY_RIGHTBRACE:
            return ']';
            break;
            case KEY_ENTER:
      return '%';  //28
      break;
      case KEY_LEFTCTRL:
      return '%';
      break;
      case KEY_A:
      return 'a';
      break;
      case KEY_S:
      return 's';
      break;
      case KEY_D:
      return 'd';
      break;
      case KEY_F:
      return 'f';
      break;
      case KEY_G:
      return 'g';
      break;
      case KEY_H:
      return 'h';
      break;
      case KEY_J:
      return 'j';
      break;
      case KEY_K:
      return 'k';
      break;
      case KEY_L:
      return 'l';
      break;
      case KEY_SEMICOLON:
      return ';';
      break;
      case KEY_APOSTROPHE:
      return '\'';
      break;
      case KEY_GRAVE:
      return '`';
      break;
      case KEY_LEFTSHIFT:
      return '%';
      break;
      case KEY_BACKSLASH:
      return '\\';
      break;
      case KEY_Z:
      return 'z';
      break;
      case KEY_X:
      return 'x';
      break;
      case KEY_C:
      return 'c';
      break;
      case KEY_V:
      return 'v';
      break;
      case KEY_B:
      return 'b';
      break;
      case KEY_N:
      return 'n';
      break;
      case KEY_M:
      return 'm';
      break;
      case KEY_COMMA:
      return ',';
      break;
      case KEY_DOT:
      return '.';
      break;
      case KEY_SLASH:
      return '/';
      break;
      case KEY_RIGHTSHIFT:
      return '%';
      break;
      case KEY_KPASTERISK:
      return '*';
      break;
      case KEY_LEFTALT:
      return '%';
      break;
      case KEY_SPACE:
      return ' ';
      break;
      case KEY_CAPSLOCK:
      return '%';
      break;
      case KEY_F1:
      return '%';
      break;
      case KEY_F2:
      return '%';
      break;
      case KEY_F3:
      return '%';
      break;
      case KEY_F4:
      return '%';
      break;
      case KEY_F5:
      return '%';
      break;
      case KEY_F6:
      return '%';
      break;
      case KEY_F7:
      return '%';
      break;
      case KEY_F8:
      return '%';
      break;
      case KEY_F9:
      return '%';
      break;
      case KEY_F10:
      return '%';
      break;
      case KEY_NUMLOCK:
      return '%';
      break;
      case KEY_SCROLLLOCK:
      return '%';
      break;
      case KEY_KP7:
      return '%';
      break;
      case KEY_KP8:
      return '%';
      break;
      case KEY_KP9:
      return '%';
      break;
      case KEY_KPMINUS:
      return '-';
      break;
      case KEY_KP4:
      return '%';
      break;
      case KEY_KP5:
      return '%';
      break;
      case KEY_KP6:
      return '%';
      break;
      case KEY_KPPLUS:
      return '+';
      break;
      case KEY_KP1:
      return '%';
      break;
      case KEY_KP2:
      return '%';
      break;
      case KEY_KP3:
      return '%';
      break;
      case KEY_KP0:
      return '%';
      break;
      case KEY_KPDOT:
      return '%';
      break;
      case KEY_ZENKAKUHANKAKU:
      return '%';
      break;
      case KEY_102ND:
      return '%';
      break;
      case KEY_F11:
      return '%';
      break;
      case KEY_F12:
      return '%';
      break;
      case KEY_RO:
      return '%';
      break;
      case KEY_KATAKANA:
      return '%';
      break;
      case KEY_HIRAGANA:
      return '%';
      break;
      case KEY_HENKAN:
      return '%';
      break;
      case KEY_KATAKANAHIRAGANA:
      return '%';
      break;
      case KEY_MUHENKAN:
      return '%';
      break;
      case KEY_KPJPCOMMA:
      return '%';
      break;
      case KEY_KPENTER:
      return '%';
      break;
      case KEY_RIGHTCTRL:
      return '%';
      break;
      case KEY_KPSLASH:
      return '%';
      break;
      case KEY_SYSRQ:
      return '%';
      break;
      case KEY_RIGHTALT:
      return '%';
      break;
      case KEY_LINEFEED:
      return '%';
      break;
      case KEY_HOME:
      return '%';
      break;
      case KEY_UP:
      return '%';
      break;
      case KEY_PAGEUP:
      return '%';
      break;
      case KEY_LEFT:
      return '%';
      break;
      case KEY_RIGHT:
      return '%';
      break;
      case KEY_END:
      return '%';
      break;
      case KEY_DOWN:
      return '%';
      break;
      case KEY_PAGEDOWN:
      return '%';
      break;
      case KEY_INSERT:
      return '%';
      break;
      case KEY_DELETE:
      return '%';
      break;
      case KEY_MACRO:
      return '%';
      break;
      case KEY_MUTE:
      return '%';
      break;
      case KEY_VOLUMEDOWN:
      return '%';
      break;
      case KEY_VOLUMEUP:
      return '%';
      break;
      case KEY_POWER:
      return '%';
      break;
      case KEY_KPEQUAL:
      return '%';
      break;
      case KEY_KPPLUSMINUS:
      return '%';
      break;
      case KEY_PAUSE:
      return '%';
      break;
      case KEY_SCALE:
      return '%';
      break;
      case KEY_KPCOMMA:
      return '%';
      break;
      case KEY_HANGEUL:
      return '%';
      break;
      case KEY_HANJA:
      return '%';
      break;
      case KEY_YEN:
      return '%';
      break;
      case KEY_LEFTMETA:
      return '%';
      break;
      case KEY_RIGHTMETA:
      return '%';
      break;
      case KEY_COMPOSE:
      return '%';
      break;
      case KEY_STOP:
      return '%';
      break;
      case KEY_AGAIN:
      return '%';
      break;
      case KEY_PROPS:
      return '%';
      break;
      case KEY_UNDO:
      return '%';
      break;
      case KEY_FRONT:
      return '%';
      break;
      case KEY_COPY:
      return '%';
      break;
      case KEY_OPEN:
      return '%';
      break;
      case KEY_PASTE:
      return '%';
      break;
      case KEY_FIND:
      return '%';
      break;
      case KEY_CUT:
      return '%';
      break;
      case KEY_HELP:
      return '%';
      break;
      case KEY_MENU:
      return '%';
      break;
      case KEY_CALC:
      return '%';
      break;
      case KEY_SETUP:
      return '%';
      break;
      case KEY_SLEEP:
      return '%';
      break;
      case KEY_WAKEUP:
      return '%';
      break;
      case KEY_FILE:
      return '%';
      break;
      case KEY_SENDFILE:
      return '%';
      break;
      case KEY_DELETEFILE:
      return '%';
      break;
      case KEY_XFER:
      return '%';
      break;
      case KEY_PROG1:
      return '%';
      break;
      case KEY_PROG2:
      return '%';
      break;
      case KEY_WWW:
      return '%';
      break;
      case KEY_MSDOS:
      return '%';
      break;
      case KEY_COFFEE:
      return '%';
      break;
      case KEY_ROTATE_DISPLAY:
      return '%';
      break;
      case KEY_CYCLEWINDOWS:
      return '%';
      break;
      case KEY_MAIL:
      return '%';
      break;
      case KEY_BOOKMARKS:
      return '%';
      break;
      case KEY_COMPUTER:
      return '%';
      break;
      case KEY_BACK:
      return '%';
      break;
      case KEY_FORWARD:
      return '%';
      break;
      case KEY_CLOSECD:
      return '%';
      break;
      case KEY_EJECTCD:
      return '%';
      break;
      case KEY_EJECTCLOSECD:
      return '%';
      break;
      case KEY_NEXTSONG:
      return '%';
      break;
      case KEY_PLAYPAUSE:
      return '%';
      break;
      case KEY_PREVIOUSSONG:
      return '%';
      break;
      case KEY_STOPCD:
      return '%';
      break;
      case KEY_RECORD:
      return '%';
      break;
      case KEY_REWIND:
      return '%';
      break;
      case KEY_PHONE:
      return '%';
      break;
      case KEY_ISO:
      return '%';
      break;
      case KEY_CONFIG:
      return '%';
      break;
      case KEY_HOMEPAGE:
      return '%';
      break;
      case KEY_REFRESH:
      return '%';
      break;
      case KEY_EXIT:
      return '%';
      break;
      case KEY_MOVE:
      return '%';
      break;
      case KEY_EDIT:
      return '%';
      break;
      case KEY_SCROLLUP:
      return '%';
      break;
      case KEY_SCROLLDOWN:
      return '%';
      break;
      case KEY_KPLEFTPAREN:
      return '%';
      break;
      case KEY_KPRIGHTPAREN:
      return '%';
      break;
      case KEY_NEW:
      return '%';
      break;
      case KEY_REDO:
      return '%';
      break;
      case KEY_F13:
      return '%';
      break;
      case KEY_F14:
      return '%';
      break;
      case KEY_F15:
      return '%';
      break;
      case KEY_F16:
      return '%';
      break;
      case KEY_F17:
      return '%';
      break;
      case KEY_F18:
      return '%';
      break;
      case KEY_F19:
      return '%';
      break;
      case KEY_F20:
      return '%';
      break;
      case KEY_F21:
      return '%';
      break;
      case KEY_F22:
      return '%';
      break;
      case KEY_F23:
      return '%';
      break;
      case KEY_F24:
      return '%';
      break;
      case KEY_PLAYCD:
      return '%';
      break;
      case KEY_PAUSECD:
      return '%';
      break;
      case KEY_PROG3:
      return '%';
      break;
      case KEY_PROG4:
      return '%';
      break;
      case KEY_DASHBOARD:
      return '%';
      break;
      case KEY_SUSPEND:
      return '%';
      break;
      case KEY_CLOSE:
      return '%';
      break;
      case KEY_PLAY:
      return '%';
      break;
      case KEY_FASTFORWARD:
      return '%';
      break;
      case KEY_BASSBOOST:
      return '%';
      break;
      case KEY_PRINT:
      return '%';
      break;
      case KEY_HP:
      return '%';
      break;
      case KEY_CAMERA:
      return '%';
      break;
      case KEY_SOUND:
      return '%';
      break;
      case KEY_QUESTION:
      return '%';
      break;
      case KEY_EMAIL:
      return '%';
      break;
      case KEY_CHAT:
      return '%';
      break;
      case KEY_SEARCH:
      return '%';
      break;
      case KEY_CONNECT:
      return '%';
      break;
      case KEY_FINANCE:
      return '%';
      break;
      case KEY_SPORT:
      return '%';
      break;
      case KEY_SHOP:
      return '%';
      break;
      case KEY_ALTERASE:
      return '%';
      break;
      case KEY_CANCEL:
      return '%';
      break;
      case KEY_BRIGHTNESSDOWN:
      return '%';
      break;
      case KEY_BRIGHTNESSUP:
      return '%';
      break;
      case KEY_MEDIA:
      return '%';
      break;
      case KEY_SWITCHVIDEOMODE:
      return '%';
      break;
      case KEY_KBDILLUMTOGGLE:
      return '%';
      break;
      case KEY_KBDILLUMDOWN:
      return '%';
      break;
      case KEY_KBDILLUMUP:
      return '%';
      break;
      case KEY_SEND:
      return '%';
      break;
      case KEY_REPLY:
      return '%';
      break;
      case KEY_FORWARDMAIL:
      return '%';
      break;
      case KEY_SAVE:
      return '%';
      break;
      case KEY_DOCUMENTS:
      return '%';
      break;
      case KEY_BATTERY:
      return '%';
      break;
      case KEY_BLUETOOTH:
      return '%';
      break;
      case KEY_WLAN:
      return '%';
      break;
      case KEY_UWB:
      return '%';
      break;
      case KEY_UNKNOWN:
      return '%';
      break;
      case KEY_VIDEO_NEXT:
      return '%';
      break;
      case KEY_VIDEO_PREV:
      return '%';
      break;
      case KEY_BRIGHTNESS_CYCLE:
      return '%';
      break;
      case KEY_BRIGHTNESS_AUTO:
      return '%';
      break;
      case KEY_DISPLAY_OFF:
      return '%';
      break;
      case KEY_WWAN:
      return '%';
      break;
      case KEY_RFKILL:
      return '%';
      break;
      case KEY_MICMUTE:
      return '%';
      break;
}
}
else {
  switch (in) {
      case KEY_RESERVED:
      return '%';
      break;
      case KEY_ESC:
      return '%';
      break;
      case KEY_1:
      return '!';
      break;
      case KEY_2:
      return '@';
      break;
      case KEY_3:
      return '#';
      break;
      case KEY_4:
      return '$';
      break;
      case KEY_5:
      return '%';
      break;
      case KEY_6:
      return '^';
      break;
      case KEY_7:
      return '&';
      break;
      case KEY_8:
      return '*';
      break;
      case KEY_9:
      return '(';
      break;
      case KEY_0:
      return ')';
      break;
      case KEY_MINUS:
      return '_';
      break;
      case KEY_EQUAL:
      return '+';
      break;
      case KEY_BACKSPACE:
      return '%';
      break;
      case KEY_TAB:
      return '%';
      break;
      case KEY_Q:
      return 'Q';
      break;
      case KEY_W:
      return 'W';
      break;
      case KEY_E:
      return 'E';
      break;
      case KEY_R:
      return 'R';
      break;
      case KEY_T:
      return 'T';
      break;
      case KEY_Y:
      return 'Y';
      break;
      case KEY_U:
      return 'U';
      break;
      case KEY_I:
      return 'I';
      break;
      case KEY_O:
      return 'O';
      break;
      case KEY_P:
      return 'P';
      break;
      case KEY_LEFTBRACE:
      return '{';
      break;
      case KEY_RIGHTBRACE:
      return '}';
      break;
      case KEY_ENTER:
      return '%';  //28
      break;
      case KEY_LEFTCTRL:
      return '%';
      break;
      case KEY_A:
      return 'A';
      break;
      case KEY_S:
      return 'S';
      break;
      case KEY_D:
      return 'D';
      break;
      case KEY_F:
      return 'F';
      break;
      case KEY_G:
      return 'G';
      break;
      case KEY_H:
      return 'H';
      break;
      case KEY_J:
      return 'J';
      break;
      case KEY_K:
      return 'K';
      break;
      case KEY_L:
      return 'L';
      break;
      case KEY_SEMICOLON:
      return ':';
      break;
      case KEY_APOSTROPHE:
      return '"';
      break;
      case KEY_GRAVE:
      return '~';
      break;
      case KEY_LEFTSHIFT:
      return '%';
      break;
      case KEY_BACKSLASH:
      return '|';
      break;
      case KEY_Z:
      return 'Z';
      break;
      case KEY_X:
      return 'X';
      break;
      case KEY_C:
      return 'C';
      break;
      case KEY_V:
      return 'V';
      break;
      case KEY_B:
      return 'B';
      break;
      case KEY_N:
      return 'N';
      break;
      case KEY_M:
      return 'M';
      break;
      case KEY_COMMA:
      return '<';
      break;
      case KEY_DOT:
      return '>';
      break;
      case KEY_SLASH:
      return '?';
      break;
      case KEY_RIGHTSHIFT:
      return '%';
      break;
      case KEY_KPASTERISK:
      return '*';
      break;
      case KEY_LEFTALT:
      return '%';
      break;
      case KEY_SPACE:
      return ' ';
      break;
      case KEY_CAPSLOCK:
      return '%';
      break;
      case KEY_F1:
      return '%';
      break;
      case KEY_F2:
      return '%';
      break;
      case KEY_F3:
      return '%';
      break;
      case KEY_F4:
      return '%';
      break;
      case KEY_F5:
      return '%';
      break;
      case KEY_F6:
      return '%';
      break;
      case KEY_F7:
      return '%';
      break;
      case KEY_F8:
      return '%';
      break;
      case KEY_F9:
      return '%';
      break;
      case KEY_F10:
      return '%';
      break;
      case KEY_NUMLOCK:
      return '%';
      break;
      case KEY_SCROLLLOCK:
      return '%';
      break;
      case KEY_KP7:
      return '%';
      break;
      case KEY_KP8:
      return '%';
      break;
      case KEY_KP9:
      return '%';
      break;
      case KEY_KPMINUS:
      return '-';
      break;
      case KEY_KP4:
      return '%';
      break;
      case KEY_KP5:
      return '%';
      break;
      case KEY_KP6:
      return '%';
      break;
      case KEY_KPPLUS:
      return '+';
      break;
      case KEY_KP1:
      return '%';
      break;
      case KEY_KP2:
      return '%';
      break;
      case KEY_KP3:
      return '%';
      break;
      case KEY_KP0:
      return '%';
      break;
      case KEY_KPDOT:
      return '%';
      break;
      case KEY_ZENKAKUHANKAKU:
      return '%';
      break;
      case KEY_102ND:
      return '%';
      break;
      case KEY_F11:
      return '%';
      break;
      case KEY_F12:
      return '%';
      break;
      case KEY_RO:
      return '%';
      break;
      case KEY_KATAKANA:
      return '%';
      break;
      case KEY_HIRAGANA:
      return '%';
      break;
      case KEY_HENKAN:
      return '%';
      break;
      case KEY_KATAKANAHIRAGANA:
      return '%';
      break;
      case KEY_MUHENKAN:
      return '%';
      break;
      case KEY_KPJPCOMMA:
      return '%';
      break;
      case KEY_KPENTER:
      return '%';
      break;
      case KEY_RIGHTCTRL:
      return '%';
      break;
      case KEY_KPSLASH:
      return '%';
      break;
      case KEY_SYSRQ:
      return '%';
      break;
      case KEY_RIGHTALT:
      return '%';
      break;
      case KEY_LINEFEED:
      return '%';
      break;
      case KEY_HOME:
      return '%';
      break;
      case KEY_UP:
      return '%';
      break;
      case KEY_PAGEUP:
      return '%';
      break;
      case KEY_LEFT:
      return '%';
      break;
      case KEY_RIGHT:
      return '%';
      break;
      case KEY_END:
      return '%';
      break;
      case KEY_DOWN:
      return '%';
      break;
      case KEY_PAGEDOWN:
      return '%';
      break;
      case KEY_INSERT:
      return '%';
      break;
      case KEY_DELETE:
      return '%';
      break;
      case KEY_MACRO:
      return '%';
      break;
      case KEY_MUTE:
      return '%';
      break;
      case KEY_VOLUMEDOWN:
      return '%';
      break;
      case KEY_VOLUMEUP:
      return '%';
      break;
      case KEY_POWER:
      return '%';
      break;
      case KEY_KPEQUAL:
      return '%';
      break;
      case KEY_KPPLUSMINUS:
      return '%';
      break;
      case KEY_PAUSE:
      return '%';
      break;
      case KEY_SCALE:
      return '%';
      break;
      case KEY_KPCOMMA:
      return '%';
      break;
      case KEY_HANGEUL:
      return '%';
      break;
      case KEY_HANJA:
      return '%';
      break;
      case KEY_YEN:
      return '%';
      break;
      case KEY_LEFTMETA:
      return '%';
      break;
      case KEY_RIGHTMETA:
      return '%';
      break;
      case KEY_COMPOSE:
      return '%';
      break;
      case KEY_STOP:
      return '%';
      break;
      case KEY_AGAIN:
      return '%';
      break;
      case KEY_PROPS:
      return '%';
      break;
      case KEY_UNDO:
      return '%';
      break;
      case KEY_FRONT:
      return '%';
      break;
      case KEY_COPY:
      return '%';
      break;
      case KEY_OPEN:
      return '%';
      break;
      case KEY_PASTE:
      return '%';
      break;
      case KEY_FIND:
      return '%';
      break;
      case KEY_CUT:
      return '%';
      break;
      case KEY_HELP:
      return '%';
      break;
      case KEY_MENU:
      return '%';
      break;
      case KEY_CALC:
      return '%';
      break;
      case KEY_SETUP:
      return '%';
      break;
      case KEY_SLEEP:
      return '%';
      break;
      case KEY_WAKEUP:
      return '%';
      break;
      case KEY_FILE:
      return '%';
      break;
      case KEY_SENDFILE:
      return '%';
      break;
      case KEY_DELETEFILE:
      return '%';
      break;
      case KEY_XFER:
      return '%';
      break;
      case KEY_PROG1:
      return '%';
      break;
      case KEY_PROG2:
      return '%';
      break;
      case KEY_WWW:
      return '%';
      break;
      case KEY_MSDOS:
      return '%';
      break;
      case KEY_COFFEE:
      return '%';
      break;
      case KEY_ROTATE_DISPLAY:
      return '%';
      break;
      case KEY_CYCLEWINDOWS:
      return '%';
      break;
      case KEY_MAIL:
      return '%';
      break;
      case KEY_BOOKMARKS:
      return '%';
      break;
      case KEY_COMPUTER:
      return '%';
      break;
      case KEY_BACK:
      return '%';
      break;
      case KEY_FORWARD:
      return '%';
      break;
      case KEY_CLOSECD:
      return '%';
      break;
      case KEY_EJECTCD:
      return '%';
      break;
      case KEY_EJECTCLOSECD:
      return '%';
      break;
      case KEY_NEXTSONG:
      return '%';
      break;
      case KEY_PLAYPAUSE:
      return '%';
      break;
      case KEY_PREVIOUSSONG:
      return '%';
      break;
      case KEY_STOPCD:
      return '%';
      break;
      case KEY_RECORD:
      return '%';
      break;
      case KEY_REWIND:
      return '%';
      break;
      case KEY_PHONE:
      return '%';
      break;
      case KEY_ISO:
      return '%';
      break;
      case KEY_CONFIG:
      return '%';
      break;
      case KEY_HOMEPAGE:
      return '%';
      break;
      case KEY_REFRESH:
      return '%';
      break;
      case KEY_EXIT:
      return '%';
      break;
      case KEY_MOVE:
      return '%';
      break;
      case KEY_EDIT:
      return '%';
      break;
      case KEY_SCROLLUP:
      return '%';
      break;
      case KEY_SCROLLDOWN:
      return '%';
      break;
      case KEY_KPLEFTPAREN:
      return '%';
      break;
      case KEY_KPRIGHTPAREN:
      return '%';
      break;
      case KEY_NEW:
      return '%';
      break;
      case KEY_REDO:
      return '%';
      break;
      case KEY_F13:
      return '%';
      break;
      case KEY_F14:
      return '%';
      break;
      case KEY_F15:
      return '%';
      break;
      case KEY_F16:
      return '%';
      break;
      case KEY_F17:
      return '%';
      break;
      case KEY_F18:
      return '%';
      break;
      case KEY_F19:
      return '%';
      break;
      case KEY_F20:
      return '%';
      break;
      case KEY_F21:
      return '%';
      break;
      case KEY_F22:
      return '%';
      break;
      case KEY_F23:
      return '%';
      break;
      case KEY_F24:
      return '%';
      break;
      case KEY_PLAYCD:
      return '%';
      break;
      case KEY_PAUSECD:
      return '%';
      break;
      case KEY_PROG3:
      return '%';
      break;
      case KEY_PROG4:
      return '%';
      break;
      case KEY_DASHBOARD:
      return '%';
      break;
      case KEY_SUSPEND:
      return '%';
      break;
      case KEY_CLOSE:
      return '%';
      break;
      case KEY_PLAY:
      return '%';
      break;
      case KEY_FASTFORWARD:
      return '%';
      break;
      case KEY_BASSBOOST:
      return '%';
      break;
      case KEY_PRINT:
      return '%';
      break;
      case KEY_HP:
      return '%';
      break;
      case KEY_CAMERA:
      return '%';
      break;
      case KEY_SOUND:
      return '%';
      break;
      case KEY_QUESTION:
      return '%';
      break;
      case KEY_EMAIL:
      return '%';
      break;
      case KEY_CHAT:
      return '%';
      break;
      case KEY_SEARCH:
      return '%';
      break;
      case KEY_CONNECT:
      return '%';
      break;
      case KEY_FINANCE:
      return '%';
      break;
      case KEY_SPORT:
      return '%';
      break;
      case KEY_SHOP:
      return '%';
      break;
      case KEY_ALTERASE:
      return '%';
      break;
      case KEY_CANCEL:
      return '%';
      break;
      case KEY_BRIGHTNESSDOWN:
      return '%';
      break;
      case KEY_BRIGHTNESSUP:
      return '%';
      break;
      case KEY_MEDIA:
      return '%';
      break;
      case KEY_SWITCHVIDEOMODE:
      return '%';
      break;
      case KEY_KBDILLUMTOGGLE:
      return '%';
      break;
      case KEY_KBDILLUMDOWN:
      return '%';
      break;
      case KEY_KBDILLUMUP:
      return '%';
      break;
      case KEY_SEND:
      return '%';
      break;
      case KEY_REPLY:
      return '%';
      break;
      case KEY_FORWARDMAIL:
      return '%';
      break;
      case KEY_SAVE:
      return '%';
      break;
      case KEY_DOCUMENTS:
      return '%';
      break;
      case KEY_BATTERY:
      return '%';
      break;
      case KEY_BLUETOOTH:
      return '%';
      break;
      case KEY_WLAN:
      return '%';
      break;
      case KEY_UWB:
      return '%';
      break;
      case KEY_UNKNOWN:
      return '%';
      break;
      case KEY_VIDEO_NEXT:
      return '%';
      break;
      case KEY_VIDEO_PREV:
      return '%';
      break;
      case KEY_BRIGHTNESS_CYCLE:
      return '%';
      break;
      case KEY_BRIGHTNESS_AUTO:
      return '%';
      break;
      case KEY_DISPLAY_OFF:
      return '%';
      break;
      case KEY_WWAN:
      return '%';
      break;
      case KEY_RFKILL:
      return '%';
      break;
      case KEY_MICMUTE:
      return '%';
      break;
}
}

}

int getSO_ERROR(int fd) {
   int err = 1;
   socklen_t len = sizeof err;
   if (-1 == getsockopt(fd, SOL_SOCKET, SO_ERROR, (char *)&err, &len))
      _printf("fatalerror\n");
if (err)
      errno = err;              // set errno to the socket SO_ERROR
return err;
}


int s;

void connectLED(void){
      int t, len;
      memset(&s,0,sizeof(s));
      memset(&t,0,sizeof(t));
      memset(&len,0,sizeof(len));
      struct sockaddr_un remote;
      char str[100];
      memset(str,'\0',sizeof(str));
      if ((s = socket(AF_UNIX, SOCK_STREAM, 0)) == -1) {
            perror("socket");
            exit(1);
      }
      _printf("Trying to connect...\n");

      remote.sun_family = AF_UNIX;
//strcpy(remote.sun_path, SOCK_PATH);

      if (*socket_path == '\0') {
            memset(remote.sun_path, '\0', sizeof(remote.sun_path));
            *remote.sun_path = '\0';
            strncpy(remote.sun_path+1, socket_path+1, sizeof(remote.sun_path)-2);
      } else {
            strncpy(remote.sun_path, socket_path, sizeof(remote.sun_path)-1);
      }
//strcpy(remote.sun_path, socket_path);

      len = strlen(remote.sun_path) + sizeof(remote.sun_family);
//if (connect(s, (struct sockaddr *)&remote, len) == -1) {
      if (connect(s, (struct sockaddr *)&remote, sizeof(remote)) == -1) {
            perror("connect fail");
            exit(1);
      }

      _printf("Connected.\n");
}

void disconnectLED(void){
      if (s >= 0) {
getSO_ERROR(s); // first clear any errors, which can cause close to fail
if (shutdown(s, SHUT_RDWR) < 0) // secondly, terminate the 'reliable' delivery
if (errno != ENOTCONN && errno != EINVAL) // SGI causes EINVAL
      perror("shutdown");
if (close(s) < 0) // finally call close()
      perror("close");
}
}
void messageLed(enum ledmode inled){
      lastLedState=currentLedState;
      currentLedState=inled;
      char str[100];
      memset(str,'\0',sizeof(str));
// while(_printf("> "), fgets(str, 100, stdin), !feof(stdin)) {
//strip(str);
      switch (inled) {
            case led_needscanner:
            _printf("led setting to: led_needscanner\n");
            strcpy(str,"9 blink 11 0 0 75 0 0 0 75"); 
            break;
            case led_foundscanner:
            _printf("led setting to: led_foundscanner\n");
            strcpy(str,"9 blink 11 0 0 250 0 0 0 750"); 
            break;
            case led_erase:
            _printf("led setting to: erase\n");
            strcpy(str,"9 blink 0 0 12 75 0 0 0 75"); 
            break;
            case led_reboot:
            _printf("led setting to: led_reboot\n");
            strcpy(str,"4 solid 0 0 0"); 
            break;
            case led_havecurlserver:
            _printf("led setting to: led_havecurlserver\n");
            strcpy(str,"9 blink 0 0 12 250 0 0 0 750"); 
            break;
            case led_failedcurlfetch:
            _printf("led setting to: led_failedcurlfetch\n");
            strcpy(str,"9 blink 0 0 12 500 12 0 0 500"); 
            break;
            case led_burningeeprom:
            case led_verify:
            _printf("led setting to: led_verify\n");
            strcpy(str,"9 blink 0 12 0 75 0 0 0 75"); 
            break;
            case led_success:
            _printf("led setting to: led_success\n");
            strcpy(str, "4 solid 0 10 0");
            break;
            case led_failure:
            _printf("led setting to: led_failure\n");
            strcpy(str, "4 solid 10 0 0");
            break;
      }
      if (send(s, str, strlen(str), 0) == -1) {
            perror("send");
            _printf("could't do my send, lets exit");
            exit(1);
      }
      else {
            _printf("I sent the command (%s)\n",str);
      }

}


char _KEY(int key){
    _printf("key");
}
void _RECORD(int pos){
    char thiscode=_LOOKUPCODE(pos);
    _printf("_Recording %i (%c)\n",pos,thiscode);
    pcc++;
    scannerString[pcc]=thiscode;
    _printf("pc: %s\n",scannerString);
}



void _PCFOUND(void){
      regex_t regexHTTP_PCDIR,regexCLEAR,regexVERIFY,regexREBOOT,regexERASE;
      int http_pcdir,ierase,ireboot,iverify,iclear,failure;
      char curlcmd[100],filename[35],eetoolcmd[100],filepath[100],exitcmd[100];
      sprintf(exitcmd, "init 6");
      http_pcdir = regcomp(&regexHTTP_PCDIR, "`PCSERV_", 0);
      ierase=regcomp(&regexERASE,"`ERASE",0);
      ireboot=regcomp(&regexREBOOT,"`REBOOT",0);
      iverify=regcomp(&regexVERIFY,"`VERIFY",0);
      iclear=regcomp(&regexCLEAR,"`CLEAR",0);
      char *token;
      const char s[2] = "_";                                                    

      if (http_pcdir+ierase+ireboot+iclear) {
            fprintf(stderr, "Could not compile command regex's\n");
            exit(1);
      }
      char regexERROR[100];
      int lens=strlen(scannerString);
      _printf("PC Found: (%s) len: %i\n",scannerString,lens);

      if (scannerString[0]=='`'){
            _printf("command string found%s\n",scannerString);
            http_pcdir = regexec(&regexHTTP_PCDIR, scannerString, 0, NULL, 0);
            ierase = regexec(&regexERASE, scannerString, 0, NULL, 0);
            ireboot = regexec(&regexREBOOT, scannerString, 0, NULL, 0);
            iverify = regexec(&regexVERIFY, scannerString, 0, NULL, 0);
            iclear = regexec(&regexCLEAR, scannerString, 0, NULL, 0);
            
            /* ACTION FOR PCSERV_*/
            if (!http_pcdir) {
                  _printf("Matched PCSERV_\n");
                  token = strtok(scannerString, s);
                  token = strtok(NULL, s);
                  strcpy(pcServer,token);
                  messageLed(led_havecurlserver);
            }
            else if (http_pcdir == REG_NOMATCH) {
            }
            else {
                  regerror(http_pcdir, &regexHTTP_PCDIR, regexERROR, sizeof(regexERROR));
                  fprintf(stderr, "regexHTTP_PCDIR match failed: %s\n", regexERROR);
                  exit(1);
            }
            /* ACTION FOR ERASE*/
            if (!ierase) {
                  _printf("Matched ERASE_\n");
                  messageLed(led_erase);
                  sprintf(eetoolcmd,"/wigwag/system/bin/eetool erase all");
                  failure=system(eetoolcmd);
                  if (strlen(pcServer)){
                        messageLed(led_havecurlserver);
                  }
                  else{
                        messageLed(led_foundscanner);
                  }
            }
            else if (ierase == REG_NOMATCH) {
            }
            else {
                  regerror(ierase, &regexERASE, regexERROR, sizeof(regexERROR));
                  fprintf(stderr, "regexERASE match failed: %s\n", regexERROR);
                  exit(1);
            }
            /* ACTION FOR VERIFY_*/
            if (!iverify) {
                  _printf("Matched VERIFY\n");
                  messageLed(led_verify);
                  messageLed(lastLedState);
            }
            else if (iverify == REG_NOMATCH) {
            }
            else {
                  regerror(iverify, &regexVERIFY, regexERROR, sizeof(regexERROR));
                  fprintf(stderr, "regexVERIFY match failed: %s\n", regexERROR);
                  exit(1);
            }
            /* ACTION FOR REBOOT*/
            if (!ireboot) {
                  _printf("Matched REBOOT\n");
                  messageLed(led_reboot);
                  system(exitcmd);
            }
            else if (ireboot == REG_NOMATCH) {
            }
            else {
                  regerror(ireboot, &regexREBOOT, regexERROR, sizeof(regexERROR));
                  fprintf(stderr, "regexREBOOT match failed: %s\n", regexERROR);
                  exit(1);
            }
            /* ACTION FOR CLEAR*/
            if (!iclear) {

            }
            else if (iclear == REG_NOMATCH) {
            }
            else {
                  regerror(iclear, &regexCLEAR, regexERROR, sizeof(regexERROR));
                  fprintf(stderr, "regexCLEAR match failed: %s\n", regexERROR);
                  exit(1);
            }

/* Free memory allocated to the pattern buffer by regcomp() */
            regfree(&regexHTTP_PCDIR);
            regfree(&regexREBOOT);
            regfree(&regexERASE);
            regfree(&regexCLEAR);
            regfree(&regexVERIFY);
      }
      else if (lens==25) {
            sprintf(filename, "%s.json", scannerString);
            sprintf(filepath, "/tmp/%s",filename);
            sprintf(curlcmd,"curl -o %s %s%s",filepath,pcServer,filename);
            sprintf(eetoolcmd,"/wigwag/system/bin/eetool set /tmp/%s",filename);
            _printf ("curl command: (%s)\n",curlcmd);
            _printf ("eetool command: (%s)\n",eetoolcmd);
//    strcpy(filename, scannerString);
//    _printf("filename: %s\n",filename);
//    strcat(filename,".json");
//    _printf("filename: %s\n",filename);
//    strcpy( command, "curl -o /tmp/");
//    _printf("cmd: %s\n",command);
//    strcat(command,filename);
//    strcat (command,pcServer);
//    strcat (command,filename);
// // strcat(command," /tmp/");
//    _printf("getstring:%s\n",command);
            system(curlcmd);
//    command[0]='\0';
//    strcpy(filepath,"/tmp/");
//    strcat(filepath,filename);
//    strcpy(command, "eetool set ");
//    strcat (command,filepath);
//    _printf("eetool command: %s\n",command);
            if (access(filepath,F_OK)!=-1) {
                  messageLed(led_burningeeprom);
                  failure=system(eetoolcmd);
                  _printf("Did I have a failure:%i\n",failure);
                  if (!failure){
                        system(exitcmd);
                        messageLed(led_success);
                  }
                  else {
                       messageLed(led_failure);
                 }
           }
           else {
            _printf("file (%s) does not exist\n",filepath);
            messageLed(led_failedcurlfetch);
      }
}
new_entry();
}
int new_entry(void){
    _printf("State: new_entry\n");
    memset(&scannerString[0], 0, sizeof(scannerString));
    pcc=-1;
    return ok;
}

int gathering(void){
    _printf("State: gathering\n");
    _printf("t:%d, v:%d, c:%d\n",type,kvalue,code);
    if (type==1 && kvalue==1 && code==KEY_LEFTSHIFT){
        _printf("LS down\n");
        shiftstate=down;
        _printf("shiftsate: %i\n",shiftstate);
  }
  else if (type==1 && kvalue==0 && code==KEY_LEFTSHIFT){
        shiftstate=up;
        _printf("LS up\n");
        _printf("shiftsate: %i\n",shiftstate);
  }
  else if (type==1 && kvalue==1 && code==KEY_ENTER){
        _printf("Enter down\n");
  }
  else if (type==1 && kvalue==0 && code==KEY_ENTER){
        _printf("Enter up, taking action\n");
        _PCFOUND();
        return repeat;
  }
  else if (type==1 && kvalue==1 && code==KEY_KPENTER){
        _printf("Enter down\n");
  }
  else if (type==1 && kvalue==0 && code==KEY_KPENTER){
        _printf("Enter up, taking action\n");
        _PCFOUND();
        return repeat;
  }
  else if (type==1 && kvalue==1){
        _printf("recording (%i) while the shift key is %i\n",code,shiftstate);
        _RECORD(code);
  }
  return repeat;
}

int exit_state(void){
    _printf("State: exit_state\n");
    return ok;
}

lookup_transitions(enum state_codes cur_state, enum ret_codes rc)
{
#if 0
    switch (cur_state) {
        case entry:
            cur_state = ((rc == ok) ? (foo) : (end));
            break;
        case foo:
            cur_state = ((rc == ok) ? (bar) : ((rc == fail) ? (end) : (foo)));
            break;
        default:
            cur_state = ((rc == ok) ? (end) : ((rc == fail) ? (end) : (foo)));
            break;
    }

    return cur_state;
#else
    char arr_size = (sizeof(state_transitions) / sizeof(state_transitions[0])); /* This can be shifted to main function to avoid redundant job. */
    char count;

    for (count = 0; count < arr_size; count++) {
        if ((state_transitions[count].src_state == cur_state) && (state_transitions[count].ret_code == rc)) {
            return (state_transitions[count].dst_state);
      }
}
#endif
}

FILE *logfile;


int _printf(const char *fmt,...){
  int n;
  va_list ap;
  char *logfilename = "/wigwag/log/scanner.log";
  logfile = fopen(logfilename, "a");
  if (logfile == NULL) {
        fprintf(stderr, "Can't open log file %s\n", logfilename);
        return 1;
  }
  va_start(ap, fmt);
  n = fprintf(logfile, fmt, ap);
  va_end(ap);
  fclose(logfile);

  return n;
}
void handler (int sig){
    _printf ("nexiting...(%d)n", sig);
    exit (0);
}

void perror_exit (char *error){
    perror (error);
    handler (9);
}

int daemonize(void){
      pid_t process_id = 0;
      pid_t sid = 0;
// Create child process
      process_id = fork();
// Indication of fork() failure
      if (process_id < 0)
      {
            printf("fork failed!\n");
// Return failure in exit status
            return 1;
      }
// PARENT PROCESS. Need to kill it.
      if (process_id > 0)
      {
            printf("process_id of child process %d \n", process_id);
// return success in exit status
            exit(0);
      }
//unmask the file mode
      umask(0);
//set new session
      sid = setsid();
      if(sid < 0)
      {
// Return failure
            return 1;
      }
// Change the current working directory to root.
      chdir("/");
// Close stdin. stdout and stderr
      close(STDIN_FILENO);
      close(STDOUT_FILENO);
      close(STDERR_FILENO);
      sleep(1);
      return 0;
}

int main (int argc, char *argv[]) {
      char *device = NULL;
      if (argv[1] == NULL){
            printf("Please specify (on the command line) the path to the dev event interface device\nAssuming /dev/input/event1\n");
            device="/dev/input/event1";
      }
      #ifdef DAEMON
      if (daemonize()){
            printf("failed to daemonize \n");
            exit(1);
      }
      printf("rolling\n");
      #endif


      _printf("giving it a shot");

      connectLED();
      int fd, rd, value, size = sizeof (struct input_event);
      char device_name[256] = "Unknown";
      _printf ("entered main\n");
      enum state_codes cur_state = entry;
      enum ret_codes rc;
      int (* state_function)(void);
      regex_t regex;
      int reti; 
      char msgbuf[100];
      int splithalf=0;


  //Setup check
      if ((getuid ()) != 0){
        _printf ("You are not root! This may not work...n\n");
  }
  else{
        _printf ("you are root, moving on\n");
  }
  if (argc > 1){
        _printf ("multiple args\n");
        device = argv[1];
  }
  else {
        _printf ("single arg\n");
  }
  while (1){
        if (access(device,F_OK)==-1) {
            _printf("No device to play with\n");
            messageLed(led_needscanner);
            sleep(2);
      }
      while ( access( device, F_OK ) != -1 ) {
  //Open Device
            if ((fd = open (device, O_RDONLY)) == -1){
                _printf ("%s is not a vaild device.n", device);
          }
          else{
            messageLed(led_foundscanner);
            _printf ("I am ready, %s is a valid device\n",device);
      }
      ioctl (fd, EVIOCGNAME (sizeof (device_name)), device_name);
      _printf ("Reading From : %s (%s)\n", device, device_name);



  /* Compile regular expression */
      reti = regcomp(&regex, "^Symbol Technologies.*", 0);
  //reti = regcomp(&regex, ".*", 0);
      if (reti) {
          fprintf(stderr, "Could not compile regex\n");
          exit(1);
    }

    reti = regexec(&regex, device_name, 0, NULL, 0);
    if (!reti) {
          puts("Match");
          splithalf=1;
   // _printf("mydev:%s\n",device_name);
    }
    else if (reti == REG_NOMATCH) {
          puts("No match");
    }
    else {
          regerror(reti, &regex, msgbuf, sizeof(msgbuf));
          fprintf(stderr, "Regex match failed: %s\n", msgbuf);
          exit(1);
    }

/* Free memory allocated to the pattern buffer by regcomp() */
    regfree(&regex);

  //Print Device Name
    if (device_name)

          rc = new_entry();
    cur_state=lookup_transitions(cur_state,rc);    
    _printf("ENTERING WHILE LOOP\n");

      //while (1){
    for (;;) {
          if ((rd = read (fd, ev, size * 64)) < size){
              _printf("device not here\n");
              break;
        //perror_exit ("read()\n");     
        }
        kvalue=ev[1].value;
        type=ev[1].type;
        code=ev[1].code;
        _printf("\n[0]type: %d\n",ev[0].type);
        _printf("[0]kvalue: %d\n",ev[0].value);
        _printf("[0]code: %d\n",ev[0].code);
        _printf("[1]type: %d\n",type);
        _printf("[1]kvalue: %d\n",kvalue);
        _printf("[1]code: %d\n",code);
        _printf("[2]type: %d\n",ev[2].type);
        _printf("[2]kvalue: %d\n",ev[2].value);
        _printf("[2]code: %d\n",ev[2].code);
        _printf("[3]type: %d\n",ev[3].type);
        _printf("[3]kvalue: %d\n",ev[3].value);
        _printf("[3]code: %d\n",ev[3].code);
  #if 1
        _printf("current-state: %d\n",cur_state);
        state_function = state[cur_state];
        rc = state_function();
        if (end == cur_state){
              break;
        }
        cur_state = lookup_transitions(cur_state, rc);
        if (splithalf){
              kvalue=ev[3].value;
              type=ev[3].type;
              code=ev[3].code;
              _printf("current-state: %d\n",cur_state);
              state_function = state[cur_state];
              rc = state_function();
              if (end == cur_state){
                  break;
            }
            cur_state = lookup_transitions(cur_state, rc);
      }
  #endif

}

    //_printf("I am getting somewhere\n");

    // if (ev[1].code == KEY_B ){
    //   __printf("key b pressed\n");
    // }


    // kvalue = ev[1].kvalue;
    // 
      // __printf("ev[0]: type[%d]\n",(ev[0].type));
      // __printf("ev[0]: kvalue[%d]\n",(ev[0].kvalue));
      // __printf ("ev[0]: Code[%d]\n", (ev[0].code));
      // __printf("ev[1]: type[%d]\n",(ev[1].type));
      // __printf("ev[1]: kvalue[%d]\n",(ev[1].kvalue));
      // _printf ("ev[1]: Code[%d]\n", (ev[1].code));


    // if (ev[0].kvalue == 1 && ev[0].type == EV_KEY){ // Only read the key press event
     // _printf("keys?\n");
    //   _printf (“Code[%d]n”, (ev[0].code));
      //if (kvalue != ' ' && ev[1].kvalue == 1 && ev[1].type == 1){ // Only read the key press event
     // }
      //}
}
}
disconnectLED();

return 0;
} 
