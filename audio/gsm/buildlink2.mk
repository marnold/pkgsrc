# $NetBSD: buildlink2.mk,v 1.1.2.1 2002/06/23 23:03:52 jlam Exp $

.if !defined(GSM_BUILDLINK2_MK)
GSM_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=		gsm
BUILDLINK_DEPENDS.gsm?=		gsm>=1.0.10
BUILDLINK_PKGSRCDIR.gsm?=	../../audio/gsm

EVAL_PREFIX+=		BUILDLINK_PREFIX.gsm=gsm
BUILDLINK_PREFIX.gsm_DEFAULT=	${LOCALBASE}
BUILDLINK_FILES.gsm=	include/gsm.h
BUILDLINK_FILES.gsm+=	include/gsm/*
BUILDLINK_FILES.gsm+=	lib/libgsm.*

BUILDLINK_TARGETS+=	gsm-buildlink

gsm-buildlink: _BUILDLINK_USE

.endif	# GSM_BUILDLINK2_MK
