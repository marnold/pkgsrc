# $NetBSD: xlc.mk,v 1.2.2.3 2004/11/30 15:06:35 tv Exp $

.if !defined(COMPILER_XLC_MK)
COMPILER_XLC_MK=	defined

.include "../../mk/bsd.prefs.mk"

XLCBASE?=	/opt/ibmcmp/vacpp/6.0

# LANGUAGES.<compiler> is the list of supported languages by the compiler.
# _LANGUAGES.<compiler> is ${LANGUAGES.<compiler>} restricted to the ones
# requested by the package in USE_LANGUAGES.
#
LANGUAGES.xlc=		c c++
_LANGUAGES.xlc=		# empty
.for _lang_ in ${USE_LANGUAGES}
_LANGUAGES.xlc+=	${LANGUAGES.xlc:M${_lang_}}
.endfor

_XLC_DIR=	${WRKDIR}/.xlc
_XLC_VARS=	# empty
.if exists(${XLCBASE}/bin/xlc)
_XLC_VARS+=	CC
_XLC_CC=	${_XLC_DIR}/bin/xlc
_ALIASES.CC=	cc xlc
CCPATH=		${XLCBASE}/bin/xlc
PKG_CC:=	${_XLC_CC}
.  if !empty(CC:M*gcc)
CC:=		${PKG_CC:T}	# ${CC} should be named "xlc".
.  endif
.endif
.if exists(${XLCBASE}/bin/xlc++)
_XLC_VARS+=	CXX
_XLC_CXX=	${_XLC_DIR}/bin/xlc++
_ALIASES.CXX=	c++ xlc++
CXXPATH=	${XLCBASE}/bin/xlc++
PKG_CXX:=	${_XLC_CXX}
.  if !empty(CXX:M*g++)
CXX:=		${PKG_CXX:T}	# ${CXX} should be named "xlc++".
.  endif
.endif
_COMPILER_STRIP_VARS+=	${_XLC_VARS}

.if exists(${CCPATH})
CC_VERSION_STRING!=	${CCPATH} -V 2>&1 | ${GREP} 'IBM XL C.*for' | ${SED} -e 's/^ *//' || ${TRUE}
CC_VERSION=		${CC_VERSION_STRING}
.else
CC_VERSION_STRING?=	${CC_VERSION}
CC_VERSION?=		IBM XL C
.endif

# Prepend the path to the compiler to the PATH.
.if !empty(_LANGUAGES.xlc)
PREPEND_PATH+=	${_XLC_DIR}/bin
.endif

# Most packages assume alloca is available without #pragma alloca, so
# make it the default.
CFLAGS+=-ma

# Create compiler driver scripts in ${WRKDIR}.
.for _var_ in ${_XLC_VARS}
.  if !target(${_XLC_${_var_}})
override-tools: ${_XLC_${_var_}}        
${_XLC_${_var_}}:
	${_PKG_SILENT}${_PKG_DEBUG}${MKDIR} ${.TARGET:H}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	(${ECHO} '#!${TOOLS_SHELL}';					\
	 ${ECHO} 'exec ${XLCBASE}/bin/${.TARGET:T} "$$@"';		\
	) > ${.TARGET}
	${_PKG_SILENT}${_PKG_DEBUG}${CHMOD} +x ${.TARGET}
.    for _alias_ in ${_ALIASES.${_var_}:S/^/${.TARGET:H}\//}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	if [ ! -x "${_alias_}" ]; then					\
		${LN} -f ${.TARGET} ${_alias_};				\
	fi
.    endfor
.  endif
.endfor

.endif	# COMPILER_XLC_MK
