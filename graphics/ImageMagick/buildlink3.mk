# $NetBSD: buildlink3.mk,v 1.9.6.1 2006/01/28 23:39:04 seb Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
IMAGEMAGICK_BUILDLINK3_MK:=	${IMAGEMAGICK_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	ImageMagick
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:NImageMagick}
BUILDLINK_PACKAGES+=	ImageMagick

.if !empty(IMAGEMAGICK_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.ImageMagick+=		ImageMagick>=5.5.7.11nb1
BUILDLINK_RECOMMENDED.ImageMagick+=	ImageMagick>=6.2.3.0
BUILDLINK_PKGSRCDIR.ImageMagick?=	../../graphics/ImageMagick
.endif	# IMAGEMAGICK_BUILDLINK3_MK

.include "../../archivers/bzip2/buildlink3.mk"
.include "../../graphics/jasper/buildlink3.mk"
.include "../../graphics/lcms/buildlink3.mk"
.include "../../graphics/libexif/buildlink3.mk"
.include "../../graphics/libwmf/buildlink3.mk"
.include "../../graphics/tiff/buildlink3.mk"

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
