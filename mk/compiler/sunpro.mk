# $NetBSD: sunpro.mk,v 1.22.2.2 2004/11/30 15:06:35 tv Exp $

.if !defined(COMPILER_SUNPRO_MK)
COMPILER_SUNPRO_MK=	defined

.include "../../mk/bsd.prefs.mk"

SUNWSPROBASE?=	/opt/SUNWspro

# LANGUAGES.<compiler> is the list of supported languages by the compiler.
# _LANGUAGES.<compiler> is ${LANGUAGES.<compiler>} restricted to the ones
# requested by the package in USE_LANGUAGES.
#
LANGUAGES.sunpro=	c c++
_LANGUAGES.sunpro=	# empty
.for _lang_ in ${USE_LANGUAGES}
_LANGUAGES.sunpro+=	${LANGUAGES.sunpro:M${_lang_}}
.endfor

_SUNPRO_DIR=	${WRKDIR}/.sunpro
_SUNPRO_VARS=	# empty
.if exists(${SUNWSPROBASE}/bin/cc)
_SUNPRO_VARS+=	CC
_SUNPRO_CC=	${_SUNPRO_DIR}/bin/cc
_ALIASES.CC=	cc
CCPATH=		${SUNWSPROBASE}/bin/cc
PKG_CC:=	${_SUNPRO_CC}
.  if !empty(CC:M*gcc)
CC:=		${PKG_CC:T}	# ${CC} should be named "cc".
.  endif
.endif
.if exists(${SUNWSPROBASE}/bin/CC)
_SUNPRO_VARS+=	CXX
_SUNPRO_CXX=	${_SUNPRO_DIR}/bin/CC
_ALIASES.CXX=	CC c++
CXXPATH=	${SUNWSPROBASE}/bin/CC
PKG_CXX:=	${_SUNPRO_CXX}
.  if !empty(CXX:M*g++)
CXX:=		${PKG_CXX:T}	# ${CXX} should be named "CC".
.  endif
.endif
_COMPILER_STRIP_VARS+=	${_SUNPRO_VARS}

# SunPro passes rpath directives to the linker using "-R".
_LINKER_RPATH_FLAG=	-R

# SunPro passes rpath directives to the linker using "-R".
_COMPILER_RPATH_FLAG=	-R

# SunPro compiler must be passed certain flags to compile/link 64-bit code.
_COMPILER_ABI_FLAG.64=	-xtarget=ultra -xarch=v9

.if exists(${CCPATH})
CC_VERSION_STRING!=	${CCPATH} -V 2>&1 || ${TRUE}
CC_VERSION!=		${CCPATH} -V 2>&1 | ${GREP} '^cc'
.else
CC_VERSION_STRING?=	${CC_VERSION}
CC_VERSION?=		cc: Sun C
.endif

# Prepend the path to the compiler to the PATH.
.if !empty(_LANGUAGES.sunpro)
PREPEND_PATH+=	${_SUNPRO_DIR}/bin
.endif

# Create compiler driver scripts in ${WRKDIR}.
.for _var_ in ${_SUNPRO_VARS}
.  if !target(${_SUNPRO_${_var_}})
override-tools: ${_SUNPRO_${_var_}}        
${_SUNPRO_${_var_}}:
	${_PKG_SILENT}${_PKG_DEBUG}${MKDIR} ${.TARGET:H}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	(${ECHO} '#!${TOOLS_SHELL}';					\
	 ${ECHO} 'exec ${SUNWSPROBASE}/bin/${.TARGET:T} "$$@"';		\
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

.endif	# COMPILER_SUNPRO_MK
