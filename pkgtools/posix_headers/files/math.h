/* $NetBSD: math.h,v 1.1.1.1 2007/04/24 19:35:46 tnn Exp $ */
#ifndef _PKGSRC_MATH_H_
#define _PKGSRC_MATH_H_
#include "/usr/include/math.h"
#ifdef __hpux
/* Floatified math functions are not available. */
#define floorf(x)	((float)floor (x))
#define ceilf(x)	((float)ceil (x))
#define sinf(x)		((float)sin (x))
#define cosf(x)		((float)cos (x))
#define tanf(x)		((float)tan (x))
#define asinf(x)	((float)asin (x))
#define acosf(x)	((float)acos (x))
#define atanf(x)	((float)atan (x))
#define atan2f(x,y)	((float)atan2 (x, y))
#define sqrtf(x)	((float)sqrt (y))
#endif /* __hpux */
#endif /* _PKGSRC_MATH_H_ */
