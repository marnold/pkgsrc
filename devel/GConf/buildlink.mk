# $NetBSD: buildlink.mk,v 1.7.2.1 2002/06/23 18:43:39 jlam Exp $
#
# This Makefile fragment is included by packages that use gconf.
#
# To use this Makefile fragment, simply:
#
# (1) Optionally define BUILDLINK_DEPENDS.gconf to the dependency pattern
#     for the version of gconf desired.
# (2) Include this Makefile fragment in the package Makefile,
# (3) Add ${BUILDLINK_DIR}/include to the front of the C preprocessor's header
#     search path, and
# (4) Add ${BUILDLINK_DIR}/lib to the front of the linker's library search
#     path.

.if !defined(GCONF_BUILDLINK_MK)
GCONF_BUILDLINK_MK=	# defined

.include "../../mk/bsd.buildlink.mk"

BUILDLINK_DEPENDS.gconf?=	GConf>=1.0.7nb1
DEPENDS+=	${BUILDLINK_DEPENDS.gconf}:../../devel/GConf

EVAL_PREFIX+=			BUILDLINK_PREFIX.gconf=GConf
BUILDLINK_PREFIX.gconf_DEFAULT=	${X11PREFIX}
BUILDLINK_FILES.gconf=		include/gconf/1/gconf/*
BUILDLINK_FILES.gconf+=		lib/libgconf-*

REPLACE_BUILDLINK_SED+=	\
	-e "s|-I${BUILDLINK_DIR}/\(include/gconf/\)|-I${BUILDLINK_PREFIX.gconf}/\1|g"
BUILDLINK_CONFIG_WRAPPER_SED+=	\
	-e "s|-I${BUILDLINK_PREFIX.gconf}/\(include/gconf/\)|-I${BUILDLINK_DIR}/\1|g"

.include "../../databases/db3/buildlink.mk"
.include "../../devel/gettext-lib/buildlink.mk"
.include "../../devel/oaf/buildlink.mk"

BUILDLINK_TARGETS.gconf=	gconf-buildlink
BUILDLINK_TARGETS.gconf+=	gconf-buildlink-config-wrapper
BUILDLINK_TARGETS+=		${BUILDLINK_TARGETS.gconf}

BUILDLINK_CONFIG.gconf=	${BUILDLINK_PREFIX.gconf}/bin/gconf-config
BUILDLINK_CONFIG_WRAPPER.gconf=${BUILDLINK_DIR}/bin/gconf-config
REPLACE_BUILDLINK_SED+=	\
	-e "s|${BUILDLINK_CONFIG_WRAPPER.gconf}|${BUILDLINK_CONFIG.gconf}|g"

.if defined(USE_CONFIG_WRAPPER)
GCONF_CONFIG?=		${BUILDLINK_CONFIG_WRAPPER.gconf}
CONFIGURE_ENV+=		GCONF_CONFIG="${GCONF_CONFIG}"
MAKE_ENV+=		GCONF_CONFIG="${GCONF_CONFIG}"
.endif

pre-configure: ${BUILDLINK_TARGETS.gconf}
gconf-buildlink: _BUILDLINK_USE
gconf-buildlink-config-wrapper: _BUILDLINK_CONFIG_WRAPPER_USE

.endif	# GCONF_BUILDLINK_MK
