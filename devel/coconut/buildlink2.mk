# $NetBSD: buildlink2.mk,v 1.1.1.1 2002/10/16 08:58:43 rh Exp $
#
# This Makefile fragment is included by packages that use coconut.
#
# This file was created automatically using createbuildlink 2.2.
#

.if !defined(COCONUT_BUILDLINK2_MK)
COCONUT_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=			coconut
BUILDLINK_DEPENDS.coconut?=		coconut>=0.3.0
BUILDLINK_PKGSRCDIR.coconut?=		../../devel/coconut

EVAL_PREFIX+=	BUILDLINK_PREFIX.coconut=coconut
BUILDLINK_PREFIX.coconut_DEFAULT=	${LOCALBASE}
BUILDLINK_FILES.coconut+=	include/coconut/*.h
BUILDLINK_FILES.coconut+=	include/coconut/gl/*.h
BUILDLINK_FILES.coconut+=	include/coconut/gnet/*.h
BUILDLINK_FILES.coconut+=	include/coconut/gtk/*.h
BUILDLINK_FILES.coconut+=	lib/libcoconut.*
BUILDLINK_FILES.coconut+=	lib/libcoconut_gl.*
BUILDLINK_FILES.coconut+=	lib/libcoconut_gnet.*
BUILDLINK_FILES.coconut+=	lib/libcoconut_gtk.*

.include "../../graphics/gtkglext/buildlink2.mk"
.include "../../textproc/libxml2/buildlink2.mk"
.include "../../textproc/libxslt/buildlink2.mk"
.include "../../devel/ncurses/buildlink2.mk"
.include "../../devel/papaya/buildlink2.mk"
.include "../../devel/popt/buildlink2.mk"
.include "../../net/gnet/buildlink2.mk"

BUILDLINK_TARGETS+=	coconut-buildlink

coconut-buildlink: _BUILDLINK_USE

.endif	# COCONUT_BUILDLINK2_MK
