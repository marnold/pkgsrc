# $NetBSD: tools.mk,v 1.4.2.3 2003/08/16 09:08:50 jlam Exp $
#
# This Makefile creates a ${TOOLS_DIR} directory and populates the bin
# subdir with tools that hide the ones outside of ${TOOLS_DIR}.

.if !defined(TOOLS_MK)
TOOLS_MK=	# defined

# Prepend ${TOOLS_DIR}/bin to the PATH so that our scripts are found
# first when search for executables.
#
TOOLS_DIR=	${WRKDIR}/.tools
PATH:=		${TOOLS_DIR}/bin:${PATH}

TOOLS_SHELL?=		${SH}
_TOOLS_WRAP_LOG=	${WRKLOG}

.PHONY: do-tools
.if !target(do-tools)
do-tools: override-tools
.endif

.PHONY: override-tools
override-tools: # empty

# Create shell scripts in ${TOOLS_DIR}/bin that simply return an error
# status for each of the GNU auto* tools, which should cause GNU configure
# scripts to think that they can't be found.
#
AUTOMAKE_OVERRIDE?=	yes
_GNU_MISSING=		${.CURDIR}/../../mk/gnu-config/missing
_HIDE_PROGS.autoconf=	bin/autoconf	bin/autoconf-2.13		\
			bin/autoheader	bin/autoheader-2.13		\
			bin/autom4te					\
			bin/autoreconf	bin/autoreconf-2.13		\
			bin/autoscan	bin/autoscan-2.13		\
			bin/autoupdate	bin/autoupdate-2.13		\
			bin/ifnames	bin/ifnames-2.13
_HIDE_PROGS.automake=	bin/aclocal	bin/aclocal-1.4			\
					bin/aclocal-1.5			\
					bin/aclocal-1.6			\
					bin/aclocal-1.7			\
			bin/automake	bin/automake-1.4		\
					bin/automake-1.5		\
					bin/automake-1.6		\
					bin/automake-1.7

.if empty(AUTOMAKE_OVERRIDE:M[nN][oO])
.  for _autotool_ in autoconf automake
.    for _prog_ in ${_HIDE_PROGS.${_autotool_}}
override-tools: ${TOOLS_DIR}/${_prog_}
${TOOLS_DIR}/${_prog_}: ${_GNU_MISSING}
	${_PKG_SILENT}${_PKG_DEBUG}${MKDIR} ${.TARGET:H}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	( ${ECHO} '#!${TOOLS_SHELL}';				\
	  ${ECHO} 'exec ${_GNU_MISSING} ${_prog_:T:C/-[0-9].*$//}'	\
	) > ${.TARGET}
	${_PKG_SILENT}${_PKG_DEBUG}${CHMOD} +x ${.TARGET}
.    endfor
.  endfor
.endif	# AUTOMAKE_OVERRIDE != NO

# Create an install-info script that is a "no operation" command,
# as registration of info files is handled by the INSTALL script.
#
CONFIGURE_ENV+=	INSTALL_INFO="${TOOLS_DIR}/bin/install-info"
MAKE_ENV+=	INSTALL_INFO="${TOOLS_DIR}/bin/install-info"

override-tools: ${TOOLS_DIR}/bin/install-info
${TOOLS_DIR}/bin/install-info:
	${_PKG_SILENT}${_PKG_DEBUG}${MKDIR} ${.TARGET:H}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	( ${ECHO} '#!${TOOLS_SHELL}';				\
	  ${ECHO} 'wrapperlog="$${TOOLS_WRAPPER_LOG-${_TOOLS_WRAP_LOG}}"'; \
	  ${ECHO} '${ECHO} "==> No-op install-info $$*" >> $$wrapperlog' \
	) > ${.TARGET}
	${_PKG_SILENT}${_PKG_DEBUG}${CHMOD} +x ${.TARGET}

# Create a makeinfo script that will invoke the right makeinfo
# command if USE_MAKEINFO is 'yes' or will exit on error if not.
#
CONFIGURE_ENV+=	MAKEINFO="${TOOLS_DIR}/bin/makeinfo"
MAKE_ENV+=	MAKEINFO="${TOOLS_DIR}/bin/makeinfo"

override-tools: ${TOOLS_DIR}/bin/makeinfo
.if empty(USE_MAKEINFO:M[nN][oO])
${TOOLS_DIR}/bin/makeinfo:
	${_PKG_SILENT}${_PKG_DEBUG}${MKDIR} ${.TARGET:H}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	( ${ECHO} "#!${TOOLS_SHELL}";				\
	  ${ECHO} 'wrapperlog="$${TOOLS_WRAPPER_LOG-${_TOOLS_WRAP_LOG}}"'; \
	  ${ECHO} '${ECHO} "${MAKEINFO} $$*" >> $$wrapperlog';		\
	  ${ECHO} 'exec ${MAKEINFO} "$$@"'				\
	) > ${.TARGET}
	${_PKG_SILENT}${_PKG_DEBUG}${CHMOD} +x ${.TARGET}
.else # !USE_MAKEINFO
${TOOLS_DIR}/bin/makeinfo: ${_GNU_MISSING}
	${_PKG_SILENT}${_PKG_DEBUG}${MKDIR} ${.TARGET:H}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	( ${ECHO} "#!${TOOLS_SHELL}";				\
	  ${ECHO} 'wrapperlog="$${TOOLS_WRAPPER_LOG-${_TOOLS_WRAP_LOG}}"'; \
	  ${ECHO} '${ECHO} "==> Error: makeinfo $$*" >> $$wrapperlog';	\
	  ${ECHO} 'exit 1'						\
	) >  ${.TARGET}
	${_PKG_SILENT}${_PKG_DEBUG}${CHMOD} +x ${.TARGET}
.endif # USE_MAKEINFO

# Handle platforms with broken tools in the base system, e.g. sed, awk.
#
# Symlink the suitable versions of tools into ${TOOLS_DIR}/bin (if they
# exist in the base system) and allow packages to force the use of
# pkgsrc GNU tools when they are not present in the base system by
# defining e.g. USE_GNU_TOOLS+="awk sed".  Version numbers are not
# considered.

_TOOLS=		awk grep sed

# These platforms already have GNU versions of the tools in the base
# system, so no need to pull in the pkgsrc versions; we will use these
# instead.
#
_TOOLS_OPSYS_HAS_GNU.awk+=	FreeBSD-*-* Linux-*-* NetBSD-*-* OpenBSD-*-*
_TOOLS_OPSYS_HAS_GNU.grep+=	Darwin-*-* FreeBSD-*-* Linux-*-*
_TOOLS_OPSYS_HAS_GNU.grep+=	NetBSD-*-* OpenBSD-*-*
_TOOLS_OPSYS_HAS_GNU.sed+=	Linux-*-*

# These platforms have GNUish versions of the tools available in the base
# system, which we already define as ${AWK}, ${SED}, etc. (refer to
# defs.*.mk for the definitions), so no need to pull in the pkgsrc
# versions; we will use these instead.
#
_TOOLS_REPLACE_OPSYS.awk+=	SunOS-*-*
_TOOLS_REPLACE_OPSYS.grep+=	SunOS-*-*
_TOOLS_REPLACE_OPSYS.sed+=	# empty

# These platforms have completely unusable versions of these tools, and
# no suitable replacement is available.
#
_TOOLS_OPSYS_INCOMPAT.awk+=	# empty
_TOOLS_OPSYS_INCOMPAT.grep+=	# empty
_TOOLS_OPSYS_INCOMPAT.sed+=	# empty

# Default to not requiring GNU tools.
.for _tool_ in ${_TOOLS}
_TOOLS_NEED_GNU.${_tool_}?=	NO
_TOOLS_REPLACE.${_tool_}?=	NO
_TOOLS_OVERRIDE.${_tool_}?=	NO
.endfor

.for _tool_ in ${USE_GNU_TOOLS}
#
# What GNU tools did the package or user ask for, and does the base
# system already have it?
#
_TOOLS_NEED_GNU.${_tool_}=	YES
.  for _pattern_ in ${_TOOLS_OPSYS_HAS_GNU.${_tool_}}
.    if !empty(MACHINE_PLATFORM:M${_pattern_})
_TOOLS_NEED_GNU.${_tool_}=	NO
.    endif
.  endfor
#
# Do we know the base system tool is broken?
#
.  for _pattern_ in ${_TOOLS_OPSYS_INCOMPAT.${_tool_}}
.    if !empty(MACHINE_PLATFORM:M${_pattern_})
_TOOLS_NEED_GNU.${_tool_}=	YES
.    endif
.  endfor
#
# Are we using a GNUish system tool in place of the needed GNU tool?
#
.  for _pattern_ in ${_TOOLS_REPLACE_OPSYS.${_tool_}}
.    if !empty(MACHINE_PLATFORM:M${_pattern_})
TOOLS_REPLACE.${_tool_}=	YES
.    endif
.  endfor
.endfor	# USE_GNU_TOOLS

.if ${_TOOLS_REPLACE.awk} == "YES"
_TOOLS_OVERRIDE.awk=	YES
_TOOLS_PROGNAME.awk=	${AWK}
.endif
.if (${_TOOLS_NEED_GNU.awk} == "YES") && empty(PKGPATH:Mlang/gawk)
BUILD_DEPENDS+=		gawk>=3.1.1:../../lang/gawk
_TOOLS_OVERRIDE.awk=	YES
_TOOLS_PROGNAME.awk=	${LOCALBASE}/bin/${GNU_PROGRAM_PREFIX}awk
AWK:=			${_TOOLS_PROGNAME.awk}
.endif

.if ${_TOOLS_REPLACE.grep} == "YES"
_TOOLS_OVERRIDE.grep=	YES
_TOOLS_PROGNAME.grep=	${GREP}
.endif
.if (${_TOOLS_NEED_GNU.grep} == "YES") && empty(PKGPATH:Mtextproc/grep)
BUILD_DEPENDS+=		grep>=2.5.1:../../textproc/grep
_TOOLS_OVERRIDE.grep=	YES
_TOOLS_PROGNAME.grep=	${LOCALBASE}/bin/${GNU_PROGRAM_PREFIX}grep
GREP:=			${_TOOLS_PROGNAME.grep}
.endif

.if ${_TOOLS_REPLACE.sed} == "YES"
_TOOLS_OVERRIDE.sed=	YES
_TOOLS_PROGNAME.sed=	${SED}
.endif
.if (${_TOOLS_NEED_GNU.sed} == "YES") && empty(PKGPATH:Mtextproc/gsed)
BUILD_DEPENDS+=		gsed>=3.0.2:../../textproc/gsed
_TOOLS_OVERRIDE.sed=	YES
_TOOLS_PROGNAME.sed=	${LOCALBASE}/bin/${GNU_PROGRAM_PREFIX}sed
SED:=			${_TOOLS_PROGNAME.sed}
.endif

# If _TOOLS_OVERRIDE.<tool> is actually set to "YES", then we override
# the tool with the one specified in _TOOLS_PROGNAME.<tool>.
#
.for _tool_ in ${_TOOLS}
.  if ${_TOOLS_OVERRIDE.${_tool_}} == "YES"
override-tools: ${TOOLS_DIR}/bin/${_tool_}

${TOOLS_DIR}/bin/${_tool_}:
	${_PKG_SILENT}${_PKG_DEBUG}					\
	src="${_TOOLS_PROGNAME.${_tool_}}";				\
	if [ -x $$src -a ! -f ${.TARGET} ]; then			\
		${MKDIR} ${.TARGET:H};					\
		${LN} -sf $$src ${.TARGET};				\
	fi
.  endif
.endfor

.endif	# TOOLS_MK
