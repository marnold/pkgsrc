# $NetBSD: bsd.options.mk,v 1.9.4.5 2005/05/17 18:29:44 tv Exp $
#
# This Makefile fragment provides boilerplate code for standard naming
# conventions for handling per-package build options.
#
# Before including this file, the following variables can be defined:
#
#	PKG_SUPPORTED_OPTIONS (must be defined)
#		This is a list of build options supported by the package.
#		This variable should be set in a package Makefile.  E.g.,
#
#			PKG_SUPPORTED_OPTIONS=	kerberos ldap ssl
#
#	PKG_OPTION_VAR (must be defined)
#               The variable the user can set to enable or disable
#		options specifically for this package.
#
#	PKG_SUGGESTED_OPTIONS (defaults to empty)
#		This is a list of build options which are enabled by default.
#
#	PKG_OPTION_LEGACY_VARS
#               This is a list of USE_VARIABLE:option pairs that
#		map legacy /etc/mk.conf variables to their option
#		counterparts.
#		
#
# Optionally, the user may define the following variables in /etc/mk.conf:
#
#	PKG_DEFAULT_OPTIONS
#               This variable can be used to override default
#		options for every package.  Options listed in this
#		variable will be enabled in every package that
#		supports them.  If you prefix an option with `-',
#		it will be disabled in every package.
#
#	${PKG_OPTIONS_VAR}
#		This variable can be used to override default
#		options and options listed in PKG_DEFAULT_OPTIONS.
#		The syntax is the same as PKG_DEFAULT_OPTIONS.
#
# After including this file, the following variables are defined:
#
#	PKG_OPTIONS
#		This is the list of the selected build options, properly
#		filtered to remove unsupported and duplicate options.
#
# Example usage:
#
# -------------8<-------------8<-------------8<-------------8<-------------
# PKG_SUPPORTED_OPTIONS=	foo ldap sasl
# PKG_SUGGESTED_OPTIONS=		foo
# PKG_OPTIONS_LEGACY_VARS+=	WIBBLE_USE_OPENLDAP:ldap
# PKG_OPTIONS_LEGACY_VARS+=	WIBBLE_USE_SASL2:sasl
#
# .include "../../mk/bsd.options.mk"
#
# # Package-specific option-handling
#
# ###
# ### FOO support
# ###
# .if !empty(PKG_OPTIONS:Mfoo)
# CONFIGURE_ARGS+=	--enable-foo
# .endif

# ###
# ### LDAP support
# ###
# .if !empty(PKG_OPTIONS:Mldap)
# .  include "../../databases/openldap/buildlink3.mk"
# CONFIGURE_ARGS+=	--enable-ldap=${BUILDLINK_PREFIX.openldap}
# .endif
#
# ###
# ### SASL authentication
# ###
# .if !empty(PKG_OPTIONS:Msasl)
# .  include "../../security/cyrus-sasl2/buildlink3.mk"
# CONFIGURE_ARGS+=	--enable-sasl=${BUILDLINK_PREFIX.sasl}
# .endif
# -------------8<-------------8<-------------8<-------------8<-------------

.include "../../mk/bsd.prefs.mk"

# Define PKG_OPTIONS, no matter if we have an error or not, to suppress
# further make(1) warnings.
PKG_OPTIONS=		# empty

# Check for variable definitions required before including this file.
.if !defined(PKG_SUPPORTED_OPTIONS)
PKG_FAIL_REASON+=	"bsd.options.mk: PKG_SUPPORTED_OPTIONS is not defined."
.elif !defined(PKG_OPTIONS_VAR)
PKG_FAIL_REASON+=	"bsd.options.mk: PKG_OPTIONS_VAR is not defined."
.else # process the rest of the file

# include deprecated variable to options mapping
.include "${.CURDIR}/../../mk/defaults/obsolete.mk"

.for _m_ in ${PKG_OPTIONS_LEGACY_VARS}
.if !empty(PKG_SUPPORTED_OPTIONS:M${_m_:C/.*://}) && defined(${_m_:C/:.*//}) && !empty(${_m_:C/:.*//}:M[yY][eE][sS])
_PKG_LEGACY_OPTIONS+=${_m_:C/.*://}
_DEPRECATED_WARNING+="Deprecated variable "${_m_:C/:.*//:Q}" used, use PKG_DEFAULT_OPTIONS+="${_m_:C/.*://:Q}" instead."
.endif
.endfor

#
# process options from generic to specific
#
PKG_OPTIONS:=	# empty
.for _o_ in ${PKG_SUGGESTED_OPTIONS} ${_PKG_LEGACY_OPTIONS} \
	${PKG_DEFAULT_OPTIONS} ${${PKG_OPTIONS_VAR}}
_opt_:=		${_o_}
#  ,--- this variable is a work around for a bug documented in the
#  |    regress/make-quoting package, testcase bug1.
_popt_:=	${_o_:C/^-//}	# popt == plain option
.  if !empty(_opt_:M-*)
PKG_OPTIONS:=	${PKG_OPTIONS:N${_popt_}}
.  elif !empty(PKG_SUPPORTED_OPTIONS:M${_popt_})
PKG_OPTIONS:=	${PKG_OPTIONS} ${_popt_}
.  endif
.endfor
PKG_OPTIONS:=	${PKG_OPTIONS:O:u}

_PKG_OPTIONS_WORDWRAP_FILTER=						\
	${AWK} '							\
		BEGIN { printwidth = 40; line = "" }			\
		{							\
			if (length(line) > 0)				\
				line = line" "$$0;			\
			else						\
				line = $$0;				\
			if (length(line) > 40) {			\
				print "	"line;				\
				line = "";				\
			}						\
		}							\
		END { if (length(line) > 0) print "	"line }		\
	'

.PHONY: describe-options
describe-options:
	@${ECHO} The following options are supported by this package:
.for _opt_ in ${PKG_SUPPORTED_OPTIONS:O}
	@${ECHO} "	"${_opt_:Q}"	"`${SED} -n "s/^"${_opt_:Q}"	//p" ../../mk/defaults/options.description`
.endfor
	@${ECHO}
	@${ECHO} "These options are enabled by default: "${PKG_SUGGESTED_OPTIONS:O:Q}
	@${ECHO} "These options are currently enabled: "${PKG_OPTIONS:O:Q}

.PHONY: show-options
show-options:
	@${ECHO} "available: "${PKG_SUPPORTED_OPTIONS:O:Q}
	@${ECHO} "default: "${PKG_SUGGESTED_OPTIONS:O:Q}
	@${ECHO} "enabled: "${PKG_OPTIONS:O:Q}

.if defined(PKG_SUPPORTED_OPTIONS)
.PHONY: supported-options-message
pre-extract: supported-options-message
supported-options-message:
.  if !empty(PKG_SUPPORTED_OPTIONS)
	@${ECHO} "=========================================================================="
	@${ECHO} "The supported build options for this package are:"
	@${ECHO} ""
	@${ECHO} ${PKG_SUPPORTED_OPTIONS:O:Q} | ${XARGS} -n 1 | ${_PKG_OPTIONS_WORDWRAP_FILTER}
.    if !empty(PKG_OPTIONS)
	@${ECHO} ""
	@${ECHO} "The currently selected options are:"
	@${ECHO} ""
	@${ECHO} ${PKG_OPTIONS:O:Q} | ${XARGS} -n 1 | ${_PKG_OPTIONS_WORDWRAP_FILTER}
.    endif
	@${ECHO} ""
	@${ECHO} "You can select which build options to use by setting PKG_DEFAULT_OPTIONS"
	@${ECHO} "or the following variable.  Its current value is shown:"
	@${ECHO} ""
.    if !defined(${PKG_OPTIONS_VAR})
	@${ECHO} "	${PKG_OPTIONS_VAR} (not defined)"
.    else
	@${ECHO} "	${PKG_OPTIONS_VAR} = ${${PKG_OPTIONS_VAR}}"
.    endif
.    if defined(_DEPRECATED_WARNING)
	@${ECHO}
	@for l in ${_DEPRECATED_WARNING}; \
	do \
		${ECHO} "$$l"; \
	done
.    endif
	@${ECHO} ""
	@${ECHO} "=========================================================================="
.  endif
.endif

.endif # defined(PKG_OPTIONS_VAR) && defined(PKG_SUPPORTED_OPTIONS)
