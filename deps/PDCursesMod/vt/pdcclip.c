#ifdef _WIN32
   #include <windows.h>
   #undef MOUSE_MOVED
   #include <pdcurses_curspriv.h>
   #include "../common/winclip.c"
#else
   #include "../common/pdcclip.c"
#endif
