# $NetBSD: buildlink3.mk,v 1.1.1.1 2004/06/06 08:02:49 agc Exp $
# XXX
# XXX This file was created automatically using createbuildlink-3.4.
# XXX After this file as been verified as correct, the comment lines
# XXX beginning with "XXX" should be removed.  Please do not commit
# XXX unverified buildlink[23].mk files.
# XXX
# XXX Packages that only install static libraries or headers should
# XXX include the following line:
# XXX
# XXX	BUILDLINK_DEPMETHOD.libopendaap?=	build

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
LIBOPENDAAP_BUILDLINK3_MK:=	${LIBOPENDAAP_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	libopendaap
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nlibopendaap}
BUILDLINK_PACKAGES+=	libopendaap

.if !empty(LIBOPENDAAP_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.libopendaap+=	libopendaap>=0.2.1
BUILDLINK_PKGSRCDIR.libopendaap?=	../../local/libopendaap
.endif	# LIBOPENDAAP_BUILDLINK3_MK


BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
