# $NetBSD: buildlink.mk,v 1.1.1.1 2001/06/29 11:47:12 rh Exp $
#
# This Makefile fragment is included by packages that use libxml2.
#
# To use this Makefile fragment, simply:
#
# (1) Optionally define BUILDLINK_DEPENDS.libxml2 to the dependency pattern
#     for the version of libxml2 desired.
# (2) Include this Makefile fragment in the package Makefile,
# (3) Add ${BUILDLINK_DIR}/include to the front of the C preprocessor's header
#     search path, and
# (4) Add ${BUILDLINK_DIR}/lib to the front of the linker's library search
#     path.

.if !defined(LIBXML2_BUILDLINK_MK)
LIBXML2_BUILDLINK_MK=	# defined

BUILDLINK_DEPENDS.libxml2?=	libxml2>=2.3.12
DEPENDS+=	${BUILDLINK_DEPENDS.libxml2}:../../textproc/libxml2

BUILDLINK_PREFIX.libxml2=	${LOCALBASE}
BUILDLINK_FILES.libxml2=	include/libxml2/libxml/*
BUILDLINK_FILES.libxml2+=	lib/libxml2.*
BUILDLINK_FILES.libxml2+=	lib/xml2Conf.sh

.include "../../devel/zlib/buildlink.mk"
.include "../../converters/libiconv/buildlink.mk"

BUILDLINK_TARGETS.libxml2=	libxml2-buildlink
BUILDLINK_TARGETS.libxml2+=	libxml2-buildlink-config-wrapper
BUILDLINK_TARGETS+=		${BUILDLINK_TARGETS.libxml2}

BUILDLINK_CONFIG.libxml2=		${LOCALBASE}/bin/xml2-config
BUILDLINK_CONFIG_WRAPPER.libxml2=	${BUILDLINK_DIR}/bin/xml2-config

.if defined(USE_CONFIG_WRAPPER) && defined(GNU_CONFIGURE)
CONFIGURE_ENV+=		XML2_CONFIG="${BUILDLINK_CONFIG_WRAPPER.libxml2}"
.endif

pre-configure: ${BUILDLINK_TARGETS.libxml2}
libxml2-buildlink: _BUILDLINK_USE
libxml2-buildlink-config-wrapper: _BUILDLINK_CONFIG_WRAPPER_USE

.include "../../mk/bsd.buildlink.mk"

.endif	# LIBXML2_BUILDLINK_MK
