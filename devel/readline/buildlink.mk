# $NetBSD: buildlink.mk,v 1.17.2.1 2002/08/22 11:11:07 jlam Exp $
#
# This Makefile fragment is included by packages that use readline().
#
# To use this Makefile fragment, simply:
#
# (1) Optionally define USE_GNU_READLINE to force use of GNU readline.
# (2) Optionally define BUILDLINK_DEPENDS.readline to the dependency pattern
#     for the version of GNU readline desired.
# (3) Add ${BUILDLINK_DIR}/include to the front of the C preprocessor's header
#     search path, and
# (4) Add ${BUILDLINK_DIR}/lib to the front of the linker's library search
#     path.
#
# NOTE:	You may need to do some more work to get libedit recognized over
#	libreadline, especially by GNU configure scripts.

.if !defined(READLINE_BUILDLINK_MK)
READLINE_BUILDLINK_MK=	# defined

.include "../../mk/bsd.buildlink.mk"

BUILDLINK_DEPENDS.readline?=	readline>=2.2

.if defined(USE_GNU_READLINE)
_NEED_GNU_READLINE=	YES
.else
.  if exists(/usr/include/readline.h) || \
      exists(/usr/include/readline/readline.h)
_NEED_GNU_READLINE=	NO
.  else
_NEED_GNU_READLINE=	YES
.  endif
#
# This catch-all for SunOS is probably too broad, but better to err on
# the safe side.  We can narrow down the match when we have better
# information.
#
_INCOMPAT_READLINE=	SunOS-*-*
INCOMPAT_READLINE?=	# empty
.  for _pattern_ in ${_INCOMPAT_READLINE} ${INCOMPAT_READLINE}
.    if !empty(MACHINE_PLATFORM:M${_pattern_})
_NEED_GNU_READLINE=	YES
.    endif
.  endfor
.endif

.if ${_NEED_GNU_READLINE} == "YES"
DEPENDS+=		${BUILDLINK_DEPENDS.readline}:../../devel/readline
EVAL_PREFIX+=		BUILDLINK_PREFIX.readline=readline
BUILDLINK_PREFIX.readline_DEFAULT=	${LOCALBASE}
.else
BUILDLINK_PREFIX.readline=		/usr
.endif
BUILDLINK_PREFIX.history=		${BUILDLINK_PREFIX.readline}

BUILDLINK_FILES.readline=	include/readline.h
BUILDLINK_FILES.readline+=	include/readline/*
BUILDLINK_FILES.readline+=	lib/libreadline.*

BUILDLINK_FILES.history=	include/history.h
BUILDLINK_FILES.history+=	lib/libhistory.*

.if ${_NEED_GNU_READLINE} == "NO"
_BLNK_LIBEDIT_LIST!=		${ECHO} /usr/lib/libedit.*
.  if ${_BLNK_LIBEDIT_LIST} != "/usr/lib/libedit.*"
BUILDLINK_FILES.readline+=	lib/libedit.*
BUILDLINK_TRANSFORM.readline=	-e "s|/readline.h|/readline/readline.h|g"
BUILDLINK_TRANSFORM.readline+=	-e "s|libedit|libreadline|g"
REPLACE_LIBNAMES_SED+=		-e "s|-lreadline|-ledit|g"

BUILDLINK_FILES.history+=	lib/libedit.*
BUILDLINK_TRANSFORM.history=	-e "s|/history.h|/readline/history.h|g"
BUILDLINK_TRANSFORM.history+=	-e "s|libedit|libhistory|g"
REPLACE_LIBNAMES_SED+=		-e "s|-lhistory|-ledit|g"
.  endif
.endif

BUILDLINK_TARGETS.readline=	readline-buildlink
BUILDLINK_TARGETS.history=	history-buildlink
BUILDLINK_TARGETS+=		${BUILDLINK_TARGETS.readline}
BUILDLINK_TARGETS+=		${BUILDLINK_TARGETS.history}

pre-configure: ${BUILDLINK_TARGETS.readline}
pre-configure: ${BUILDLINK_TARGETS.history}
readline-buildlink: _BUILDLINK_USE
history-buildlink: _BUILDLINK_USE

.endif	# READLINE_BUILDLINK_MK
