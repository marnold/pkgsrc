# $NetBSD: buildlink2.mk,v 1.1.2.1 2002/06/23 23:03:55 jlam Exp $

.if !defined(LIBCDAUDIO_BUILDLINK2_MK)
LIBCDAUDIO_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=			libcdaudio
BUILDLINK_DEPENDS.libcdaudio?=		libcdaudio>=0.99.4nb1
BUILDLINK_PKGSRCDIR.libcdaudio?=	../../audio/libcdaudio

EVAL_PREFIX+=	BUILDLINK_PREFIX.libcdaudio=libcdaudio
BUILDLINK_PREFIX.libcdaudio_DEFAULT=	${LOCALBASE}
BUILDLINK_FILES.libcdaudio=		include/cdaudio.h
BUILDLINK_FILES.libcdaudio+=		lib/libcdaudio.*

BUILDLINK_TARGETS+=	libcdaudio-buildlink

libcdaudio-buildlink: _BUILDLINK_USE

.endif	# LIBCDAUDIO_BUILDLINK2_MK
