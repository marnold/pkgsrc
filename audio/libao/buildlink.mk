# $NetBSD: buildlink.mk,v 1.3.2.2 2002/08/22 11:09:43 jlam Exp $
#
# This Makefile fragment is included by packages that use libao.
#
# To use this Makefile fragment, simply:
#
# (1) Optionally define BUILDLINK_DEPENDS.libao to the dependency pattern
#     for the version of libao desired.
# (2) Include this Makefile fragment in the package Makefile,
# (3) Add ${BUILDLINK_DIR}/include to the front of the C preprocessor's header
#     search path, and
# (4) Add ${BUILDLINK_DIR}/lib to the front of the linker's library search
#     path.

.if !defined(LIBAO_BUILDLINK_MK)
LIBAO_BUILDLINK_MK=	# defined

.include "../../mk/bsd.buildlink.mk"

BUILDLINK_DEPENDS.libao?=	libao>=0.8.3
DEPENDS+=		${BUILDLINK_DEPENDS.libao}:../../audio/libao

EVAL_PREFIX+=		BUILDLINK_PREFIX.libao=libao
BUILDLINK_PREFIX.libao=	${LOCALBASE}
BUILDLINK_FILES.libao=	include/ao/ao.h
BUILDLINK_FILES.libao+=	include/ao/os_types.h
BUILDLINK_FILES.libao+=	lib/libao.*
BUILDLINK_FILES.libao+=	lib/ao/*

BUILDLINK_TARGETS.libao=libao-buildlink
BUILDLINK_TARGETS+=	${BUILDLINK_TARGETS.libao}

pre-configure: ${BUILDLINK_TARGETS.libao}
libao-buildlink: _BUILDLINK_USE

.endif	# LIBAO_BUILDLINK_MK
