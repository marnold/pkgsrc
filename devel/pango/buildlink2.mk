# $NetBSD: buildlink2.mk,v 1.1.2.2 2002/08/22 21:04:23 jlam Exp $

.if !defined(PANGO_BUILDLINK2_MK)
PANGO_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=		pango
BUILDLINK_DEPENDS.pango?=	pango>=1.0.3
BUILDLINK_PKGSRCDIR.pango?=	../../devel/pango

EVAL_PREFIX+=		BUILDLINK_PREFIX.pango=pango
BUILDLINK_PREFIX.pango_DEFAULT=	${LOCALBASE}
BUILDLINK_FILES.pango=	include/pango-1.0/*/*
BUILDLINK_FILES.pango+=	include/pango-1.0/*
BUILDLINK_FILES.pango+=	lib/libpango*-1.0.*

.include "../../devel/pkgconfig/buildlink2.mk"

BUILDLINK_TARGETS+=	pango-buildlink

pango-buildlink: _BUILDLINK_USE

.endif	# PANGO_BUILDLINK2_MK
