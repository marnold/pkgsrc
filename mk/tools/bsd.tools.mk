# $NetBSD: bsd.tools.mk,v 1.23.2.2 2005/05/17 18:29:46 tv Exp $
#
# This Makefile fragment creates tools under ${TOOLS_DIR} that are
# found before similarly-named tools in the system path.
#
#    TOOLS_CREATE is a whitespace-separated list of tools for which a
#       corresponding tool is created.  Either a wrapper script or a
#       symlink is created depending on the tool that is being
#	overridden.
#
# The following variables specify the details of each <tool>:
#
#    TOOLS_CMD.<tool> is the path to the tool under ${TOOLS_DIR}.  This
#	variable is optional, and if left unspecified it defaults to
#	${TOOLS_DIRS}/bin/<tool>.
#
#    TOOLS_ALIASES.<tool> is a whitespace-separated list of names for
#	which <tool> should also be created under ${TOOLS_DIR}.
#
#    TOOLS_REAL_CMD.<tool> is the path to the actual command that is
#	invoked when ${TOOLS_CMD.<tool>} is called.  If <tool> should
#	be a symlink, then this variable is required and should be a
#	full path.  If <tool> should be a wrapper, then this variable
#	is required unless TOOLS_REAL_CMDLINE.<tool> is defined (see
#	below).
#
# The following variables specify further details of each <tool> and
# if set, cause a wrapper script to be created.
#
#    TOOLS_REAL_ARGS.<tool> additional arguments that are passed to the
#	real command ahead of any command-line arguments.  This variable
#	is optional.
#
#    TOOLS_REAL_CMDLINE.<tool> specifies the full command-line to invoke
#	in the wrapper script when <tool> is called.  This variable is
#	optional, and if left unspecified, then this is built up from
#	TOOLS_REAL_CMD.<tool> and TOOLS_REAL_ARGS.<tool> by default.
#
# The following variables provide shortcuts for creating certain classes
# of tools:
#
#    TOOLS_NOOP is a list of tools that do nothing and return true.
#
#    TOOLS_BROKEN is a list of tools that do nothing and return false.
#
#    TOOLS_GNU_MISSING is a list of tools for which the GNU missing
#	script is invoked in place of the real tool.  This is used
#	primarily to hide GNU auto* tools.
#

.if !defined(BSD_TOOLS_MK)
BSD_TOOLS_MK=	defined

.include "../../mk/bsd.prefs.mk"

# Prepend ${TOOLS_DIR}/bin to the PATH so that our scripts are found
# first when searching for executables.
#
TOOLS_DIR=	${WRKDIR}/.tools
PREPEND_PATH+=	${TOOLS_DIR}/bin

TOOLS_SHELL?=		${SH}
_TOOLS_WRAP_LOG=	${WRKLOG}

.PHONY: do-tools override-tools
do-tools: override-tools
override-tools: .OPTIONAL

USE_TOOLS?=		# empty

# Include the other mk/tools/*.mk files here that help specify the
# wrappers and symlinks that will be created by this file.  Order
# matters!
#
.include "../../mk/tools/automake.mk"
.include "../../mk/tools/autoconf.mk"
.include "../../mk/tools/texinfo.mk"
.include "../../mk/tools/ldconfig.mk"
.include "../../mk/tools/rpcgen.mk"
.include "../../mk/tools/strip.mk"
.include "../../mk/tools/replace.mk"
.include "../../mk/tools/perl.mk"
.include "../../mk/tools/make.mk"

######################################################################

.for _t_ in ${TOOLS_NOOP}
TOOLS_CREATE+=			${_t_}
TOOLS_REAL_CMDLINE.${_t_}?=	exit 0
.endfor
.undef _t_

.for _t_ in ${TOOLS_BROKEN}
TOOLS_CREATE+=			${_t_}
TOOLS_REAL_CMDLINE.${_t_}?=	exit 1
.endfor
.undef _t_

.for _t_ in ${TOOLS_GNU_MISSING}
TOOLS_CREATE+=			${_t_}
TOOLS_REAL_CMD.${_t_}?=		${PKGSRCDIR}/mk/gnu-config/missing
TOOLS_REAL_CMDLINE.${_t_}?=	${TOOLS_REAL_CMD.${_t_}} ${_t_:T:C/-[0-9].*$//}
.endfor
.undef _t_

######################################################################

# These tools are used in the targets that actually create the wrappers
# and symlinks.  We define them here so that as a fallback, we'll just
# use the ones in the PATH.  This makes the tools framework more
# standalone.

CHMOD?=         chmod
ECHO?=          echo
FALSE?=         false
LN?=            ln
MKDIR?=         mkdir -p

######################################################################

# If the command line was defined, then we create a wrapper.
# If the real command isn't a full path, then we create a wrapper.
# If some command arguments were given, then we create a wrapper.
# Otherwise, we create a symlink.
#
# By default, the tool in ${TOOLS_DIR} will be in the "bin" directory
# and will be called <tool>.
#
# The default wrapper script will invoke the real command, followed
# by any arguments specified in TOOLS_REAL_ARGS.*, followed by any
# command-line arguments passed to the wrapper script.
#
.for _t_ in ${TOOLS_CREATE}
TOOLS_CMD.${_t_}?=		${TOOLS_DIR}/bin/${_t_}
TOOLS_REAL_CMD.${_t_}?=		${FALSE}
TOOLS_REAL_CMDLINE_DFLT.${_t_}= \
	${TOOLS_REAL_CMD.${_t_}} ${TOOLS_REAL_ARGS.${_t_}} "$$@"

override-tools: ${TOOLS_CMD.${_t_}}

${TOOLS_CMD.${_t_}}:
	${_PKG_SILENT}${_PKG_DEBUG}${TEST} -d ${.TARGET:H:Q} ||		\
		${MKDIR} ${.TARGET:H:Q}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	if ${TEST} -n ${TOOLS_REAL_CMDLINE.${_t_}:Q}""; then		\
		create=wrapper;						\
		cmdline=${TOOLS_REAL_CMDLINE.${_t_}:Q};			\
	elif ${TEST} -n ${TOOLS_REAL_CMD.${_t_}:Q}""; then		\
		if ${TEST} -n ${TOOLS_REAL_ARGS.${_t_}:Q}""; then	\
			create=wrapper;					\
			cmdline=${TOOLS_REAL_CMDLINE_DFLT.${_t_}:Q};	\
		else							\
			case ${TOOLS_REAL_CMD.${_t_}:Q}"" in		\
			/*)	create=symlink ;;			\
			*)	create=wrapper;				\
				cmdline=${TOOLS_REAL_CMDLINE_DFLT.${_t_}:Q}; \
			esac;						\
		fi;							\
	else								\
		create=symlink;						\
	fi;								\
	case "$$create" in						\
	wrapper)							\
		{ ${ECHO} '#!'${TOOLS_SHELL:Q};				\
		  ${ECHO} 'wrapperlog="$${TOOLS_WRAPPER_LOG-'${_TOOLS_WRAP_LOG:Q}'}"'; \
		  ${ECHO} '${ECHO} "[*] "'${.TARGET:Q}'" $$@" >> $$wrapperlog'; \
		  ${ECHO} "${ECHO} \"<.> $$cmdline\" >> \$$wrapperlog"; \
		  ${ECHO} "$$cmdline";					\
		} > ${.TARGET:Q};					\
		${CHMOD} +x ${.TARGET:Q};				\
		;;							\
	*)								\
		${LN} -fs ${TOOLS_REAL_CMD.${_t_}:Q} ${.TARGET:Q};	\
		;;							\
	esac
.  for _a_ in ${TOOLS_ALIASES.${_t_}}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	${TEST} ${.TARGET:Q} = ${.TARGET:H:Q}/${_a_} ||			\
		${LN} -fs ${.TARGET:T:Q} ${.TARGET:H:Q}/${_a_}
.  endfor
.  undef _a_
.endfor
.undef _t_

.endif	# BSD_TOOLS_MK
