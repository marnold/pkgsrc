# $NetBSD: buildlink2.mk,v 1.1.2.1 2002/06/23 23:04:33 jlam Exp $

.if !defined(IMAP_UW_BUILDLINK2_MK)
IMAP_UW_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=		imap-uw
BUILDLINK_DEPENDS.imap-uw?=	imap-uw>=2001.1
BUILDLINK_PKGSRCDIR.imap-uw?=	../../mail/imap-uw

EVAL_PREFIX+=			BUILDLINK_PREFIX.imap-uw=imap-uw
BUILDLINK_PREFIX.imap-uw_DEFAULT=	${LOCALBASE}
BUILDLINK_FILES.imap-uw=	include/c-client/*
BUILDLINK_FILES.imap-uw+=	lib/libc-client.*
BUILDLINK_FILES.imap-uw+=	lib/libc-client_pic.*
BUILDLINK_FILES.imap-uw+=	lib/libimapuw.*

BUILDLINK_TARGETS+=	imap-uw-buildlink

imap-uw-buildlink: _BUILDLINK_USE

.endif	# IMAP_UW_BUILDLINK2_MK
