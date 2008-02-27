# $NetBSD: buildlink3.mk,v 1.1.1.1 2008/02/27 13:48:28 obache Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
M17N_LIB_BUILDLINK3_MK:=	${M17N_LIB_BUILDLINK3_MK}+

.if ${BUILDLINK_DEPTH} == "+"
BUILDLINK_DEPENDS+=	m17n-lib
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nm17n-lib}
BUILDLINK_PACKAGES+=	m17n-lib
BUILDLINK_ORDER:=	${BUILDLINK_ORDER} ${BUILDLINK_DEPTH}m17n-lib

.if ${M17N_LIB_BUILDLINK3_MK} == "+"
BUILDLINK_API_DEPENDS.m17n-lib+=	m17n-lib>=1.5.1
BUILDLINK_PKGSRCDIR.m17n-lib?=	../../devel/m17n-lib
.endif	# M17N_LIB_BUILDLINK3_MK

pkgbase := m17n-lib
.include "../../mk/pkg-build-options.mk"

.if !empty(PKG_BUILD_OPTIONS.m17n-lib:Manthy)
.include "../../inputmethod/anthy/buildlink3.mk"
.endif

.if !empty(PKG_BUILD_OPTIONS.m17n-lib:Mx11)
.include "../../fonts/Xft2/buildlink3.mk"
.include "../../fonts/fontconfig/buildlink3.mk"
.include "../../graphics/freetype2/buildlink3.mk"
.include "../../graphics/gd/buildlink3.mk"
.include "../../graphics/libotf/buildlink3.mk"
.include "../../x11/libICE/buildlink3.mk"
.include "../../x11/libSM/buildlink3.mk"
.include "../../x11/libX11/buildlink3.mk"
.include "../../x11/libXt/buildlink3.mk"
.endif

.if !empty(PKG_BUILD_OPTIONS.m17n-lib:Mlibthai)
.include "../../devel/libthai/buildlink3.mk"
.endif

.include "../../converters/fribidi/buildlink3.mk"
.include "../../converters/libiconv/buildlink3.mk"
.include "../../devel/gettext-lib/buildlink3.mk"
.include "../../misc/m17n-db/buildlink3.mk"
.include "../../textproc/libxml2/buildlink3.mk"

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH:S/+$//}
