# $NetBSD: buildlink2.mk,v 1.1.2.3 2002/06/21 23:00:40 jlam Exp $

.if !defined(LIBXML_BUILDLINK2_MK)
LIBXML_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=		libxml
BUILDLINK_DEPENDS.libxml?=	libxml>=1.8.11
BUILDLINK_PKGSRCDIR.libxml?=	../../textproc/libxml

EVAL_PREFIX+=	BUILDLINK_PREFIX.libxml=libxml
BUILDLINK_PREFIX.libxml_DEFAULT=	${LOCALBASE}
BUILDLINK_FILES.libxml=		include/gnome-xml/*
BUILDLINK_FILES.libxml+=	lib/libxml.*
BUILDLINK_FILES.libxml+=	lib/xmlConf.sh

.include "../../devel/zlib/buildlink2.mk"

BUILDLINK_TARGETS+=		libxml-buildlink

libxml-buildlink: _BUILDLINK_USE

.endif	# LIBXML_BUILDLINK2_MK
