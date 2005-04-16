# $NetBSD: buildlink3.mk,v 1.5.2.1 2005/04/16 19:47:33 salo Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
KDELIBS_BUILDLINK3_MK:=	${KDELIBS_BUILDLINK3_MK}+

.include "../../mk/bsd.prefs.mk"

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	kdelibs
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nkdelibs}
BUILDLINK_PACKAGES+=	kdelibs

.if !empty(KDELIBS_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.kdelibs+=	kdelibs>=3.2.0
BUILDLINK_RECOMMENDED.kdelibs?=	kdelibs>=3.3.2nb9
BUILDLINK_PKGSRCDIR.kdelibs?=	../../x11/kdelibs3

.include "../../x11/kdelibs3/dirs.mk"
.endif	# KDELIBS_BUILDLINK3_MK

.if defined(USE_CUPS) && (${USE_CUPS} == "YES")
.  include "../../print/cups/buildlink3.mk"
.endif
.include "../../archivers/bzip2/buildlink3.mk"
.include "../../audio/arts/buildlink3.mk"
.include "../../audio/libaudiofile/buildlink3.mk"
.include "../../devel/pcre/buildlink3.mk"
.include "../../graphics/jpeg/buildlink3.mk"
.include "../../graphics/libart2/buildlink3.mk"
.include "../../graphics/tiff/buildlink3.mk"
.include "../../security/openssl/buildlink3.mk"
.include "../../textproc/aspell/buildlink3.mk"
.include "../../textproc/libxml2/buildlink3.mk"
.include "../../textproc/libxslt/buildlink3.mk"
.include "../../x11/qt3-libs/buildlink3.mk"
.include "../../mk/krb5.buildlink3.mk"
.include "../../mk/ossaudio.buildlink3.mk"

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
