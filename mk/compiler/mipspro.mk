# $NetBSD: mipspro.mk,v 1.26.2.2 2004/11/30 15:06:35 tv Exp $

.if !defined(COMPILER_MIPSPRO_MK)
COMPILER_MIPSPRO_MK=	defined

.include "../../mk/bsd.prefs.mk"

MIPSPROBASE?=	/usr

# LANGUAGES.<compiler> is the list of supported languages by the compiler.
# _LANGUAGES.<compiler> is ${LANGUAGES.<compiler>} restricted to the ones
# requested by the package in USE_LANGUAGES.
# 
LANGUAGES.mipspro=	c c++
_LANGUAGES.mipspro=	# empty
.for _lang_ in ${USE_LANGUAGES}
_LANGUAGES.mipspro+=	${LANGUAGES.mipspro:M${_lang_}}
.endfor

_MIPSPRO_DIR=		${WRKDIR}/.mipspro
_MIPSPRO_VARS=		# empty
.if exists(${MIPSPROBASE}/bin/cc)
_MIPSPRO_VARS+=		CC
_MIPSPRO_CC=		${_MIPSPRO_DIR}/bin/cc
_ALIASES.CC=		cc
CCPATH=			${MIPSPROBASE}/bin/cc
PKG_CC:=		${_MIPSPRO_CC}
.  if !empty(CC:M*gcc)
CC:=			${PKG_CC:T}	# ${CC} should be named "cc".
.  endif
.endif
.if exists(${MIPSPROBASE}/bin/CC)
_MIPSPRO_VARS+=		CXX
_MIPSPRO_CXX=		${_MIPSPRO_DIR}/bin/CC
_ALIASES.CXX=		CC c++
CXXPATH=		${MIPSPROBASE}/bin/CC
PKG_CXX:=		${_MIPSPRO_CXX}
.  if !empty(CXX:M*g++)
CXX:=			${PKG_CXX:T}	 # ${CXX} should be named "CC"
.  endif
.endif
_COMPILER_STRIP_VARS+=	${_MIPSPRO_VARS}

.if exists(${CCPATH})
# MIPSpro Compilers: Version 7.3.1.2m
CC_VERSION_STRING!=	${CCPATH} -version 2>&1 || ${TRUE}
CC_VERSION!=		${CCPATH} -version 2>&1 | ${GREP} '^MIPSpro'
.else
CC_VERSION_STRING?=	${CC_VERSION}
CC_VERSION?=		MIPSpro Compilers
.endif

# MIPSPro linker option used to set the rpath.
_LINKER_RPATH_FLAG=	-rpath

# MIPSPro passes rpath directives to the linker using "-Wl,-rpath,".
_COMPILER_RPATH_FLAG=	-Wl,${_LINKER_RPATH_FLAG},

# MIPSPro supports compiling/linking objects for several ABIs: n32, o32,
# and 64 bit.
#
_COMPILER_ABI_FLAG.32=	-n32	# ABI == "32" is an alias for ABI == "n32"
_COMPILER_ABI_FLAG.o32=	# empty
_COMPILER_ABI_FLAG.n32=	-n32
_COMPILER_ABI_FLAG.64=	-64

# Prepend the path to the compiler to the PATH.
.if !empty(_LANGUAGES.mipspro)
PREPEND_PATH+=	${_MIPSPRO_DIR}/bin
.endif

# Create compiler driver scripts in ${WRKDIR}.
.for _var_ in ${_MIPSPRO_VARS}
.  if !target(${_MIPSPRO_${_var_}})
override-tools: ${_MIPSPRO_${_var_}}        
${_MIPSPRO_${_var_}}:
	${_PKG_SILENT}${_PKG_DEBUG}${MKDIR} ${.TARGET:H}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	(${ECHO} '#!${TOOLS_SHELL}';					\
	 ${ECHO} 'exec ${MIPSPROBASE}/bin/${.TARGET:T} "$$@"';		\
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

.if defined(ABI)
MABIFLAG=       -${ABI:C/^32$/n&/}
CFLAGS+=        ${MABIFLAG}
LDFLAGS+=       ${MABIFLAG}
.endif

.endif	# COMPILER_MIPSPRO_MK
