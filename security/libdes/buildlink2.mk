# $NetBSD: buildlink2.mk,v 1.1.2.1 2002/06/23 23:04:40 jlam Exp $

.if !defined(LIBDES_BUILDLINK2_MK)
LIBDES_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=		libdes
BUILDLINK_DEPENDS.libdes?=	libdes-4.04b
BUILDLINK_PKGSRCDIR.libdes?=	../../security/libdes

EVAL_PREFIX+=				BUILDLINK_PREFIX.libdes=libdes
BUILDLINK_PREFIX.libdes_DEFAULT=	${LOCALBASE}

BUILDLINK_FILES.libdes=		include/libdes.h
BUILDLINK_FILES.libdes+=	lib/libdes.a

BUILDLINK_TARGETS+=	libdes-buildlink

libdes-buildlink: _BUILDLINK_USE

.endif	# LIBDES_BUILDLINK2_MK
