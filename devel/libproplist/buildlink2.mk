# $NetBSD: buildlink2.mk,v 1.1.2.1 2002/06/23 23:04:14 jlam Exp $

.if !defined(LIBPROPLIST_BUILDLINK2_MK)
LIBPROPLIST_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=			libproplist
BUILDLINK_DEPENDS.libproplist?=		libproplist>=0.10.1
BUILDLINK_PKGSRCDIR.libproplist?=	../../devel/libproplist

EVAL_PREFIX+=			BUILDLINK_PREFIX.libproplist=libproplist
BUILDLINK_PREFIX.libproplist_DEFAULT=	${LOCALBASE}
BUILDLINK_FILES.libproplist=	include/proplist.h
BUILDLINK_FILES.libproplist+=	lib/libPropList.*

BUILDLINK_TARGETS+=	libproplist-buildlink

libproplist-buildlink: _BUILDLINK_USE

.endif	# LIBPROPLIST_BUILDLINK2_MK
