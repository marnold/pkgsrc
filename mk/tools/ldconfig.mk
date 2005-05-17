# $NetBSD: ldconfig.mk,v 1.1.2.2 2005/05/17 18:29:46 tv Exp $
#
# Depending on whether the platform has ldconfig, we cause
# ${TOOLS_DIR}/bin/ldconfig to be either the correct ldconfig tool or
# a no-op.
#
.if !defined(TOOLS_PLATFORM.ldconfig)
TOOLS_NOOP+=			ldconfig
.else
TOOLS_CREATE+=			ldconfig
TOOLS_REAL_CMD.ldconfig=	${TOOLS_PLATFORM.ldconfig}
.endif

# Make ${LDCONFIG} call "ldconfig" through the PATH, which should find
# the one under ${TOOLS_DIR}.
#
LDCONFIG?=	ldconfig
