# $NetBSD: buildlink3.mk,v 1.1.1.1 2004/07/06 20:35:16 drochner Exp $
# XXX
# XXX This file was created automatically using createbuildlink-3.4.
# XXX After this file as been verified as correct, the comment lines
# XXX beginning with "XXX" should be removed.  Please do not commit
# XXX unverified buildlink[23].mk files.
# XXX
# XXX Packages that only install static libraries or headers should
# XXX include the following line:
# XXX
# XXX	BUILDLINK_DEPMETHOD.libgnomecanvasmm20?=	build

BUILDLINK_DEPTH:=			${BUILDLINK_DEPTH}+
LIBGNOMECANVASMM20_BUILDLINK3_MK:=	${LIBGNOMECANVASMM20_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	libgnomecanvasmm20
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nlibgnomecanvasmm20}
BUILDLINK_PACKAGES+=	libgnomecanvasmm20

.if !empty(LIBGNOMECANVASMM20_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.libgnomecanvasmm20+=	libgnomecanvasmm20>=2.0.1
BUILDLINK_PKGSRCDIR.libgnomecanvasmm20?=	../../graphics/libgnomecanvasmm20
.endif	# LIBGNOMECANVASMM20_BUILDLINK3_MK

.include "../../graphics/libgnomecanvas/buildlink3.mk"
.include "../../x11/gtkmm/buildlink3.mk"

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
