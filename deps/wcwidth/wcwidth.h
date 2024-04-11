// https://raw.githubusercontent.com/termux/wcwidth/master/wcwidth.h
#ifndef WCWIDTH_H_INCLUDED
#define WCWIDTH_H_INCLUDED

#include <stdlib.h>

#ifdef __cplusplus
extern "C"
#endif
int wcwidth(wchar_t ucs);

#endif
