# $NetBSD: buildlink2.mk,v 1.1.2.1 2002/06/23 23:03:57 jlam Exp $

.if !defined(MUSICBRAINZ_BUILDLINK2_MK)
MUSICBRAINZ_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=			musicbrainz
BUILDLINK_DEPENDS.musicbrainz?=		musicbrainz>=1.1.0
BUILDLINK_PKGSRCDIR.musicbrainz?=	../../audio/musicbrainz

EVAL_PREFIX+=			BUILDLINK_PREFIX.musicbrainz=musicbrainz
BUILDLINK_PREFIX.musicbrainz_DEFAULT=	${LOCALBASE}
BUILDLINK_FILES.musicbrainz=	include/musicbrainz/*
BUILDLINK_FILES.musicbrainz+=	include/musicbrainz/*/*
BUILDLINK_FILES.musicbrainz+=	lib/libmusicbrainz.*

BUILDLINK_TARGETS+=	musicbrainz-buildlink

musicbrainz-buildlink: _BUILDLINK_USE

.endif	# MUSICBRAINZ_BUILDLINK2_MK
