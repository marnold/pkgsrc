# $NetBSD: buildlink2.mk,v 1.1.2.1 2002/06/23 23:04:48 jlam Exp $

.if !defined(XBAE_BUILDLINK2_MK)
XBAE_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=		Xbae
BUILDLINK_DEPENDS.Xbae?=	Xbae>=4.8.4
BUILDLINK_PKGSRCDIR.Xbae?=	../../x11/Xbae

EVAL_PREFIX+=			BUILDLINK_PREFIX.Xbae=Xbae
BUILDLINK_PREFIX.Xbae_DEFAULT=	${X11PREFIX}
BUILDLINK_FILES.Xbae=		include/Xbae/*
BUILDLINK_FILES.Xbae+=		lib/libXbae.*

.include "../../mk/motif.buildlink2.mk"

BUILDLINK_TARGETS+=	Xbae-buildlink

Xbae-buildlink: _BUILDLINK_USE

.endif	# XBAE_BUILDLINK2_MK
