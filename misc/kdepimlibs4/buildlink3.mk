# $NetBSD: buildlink3.mk,v 1.24.2.1 2012/10/03 12:08:45 spz Exp $

BUILDLINK_TREE+=	kdepimlibs

.if !defined(KDEPIMLIBS_BUILDLINK3_MK)
KDEPIMLIBS_BUILDLINK3_MK:=

BUILDLINK_API_DEPENDS.kdepimlibs+=	kdepimlibs4>=4.0.0
BUILDLINK_ABI_DEPENDS.kdepimlibs+=	kdepimlibs4>=4.8.4nb6
BUILDLINK_PKGSRCDIR.kdepimlibs?=	../../misc/kdepimlibs4

.include "../../mk/bsd.fast.prefs.mk"

.include "../../databases/openldap-client/buildlink3.mk"
.include "../../devel/boost-libs/buildlink3.mk"
.if ${OPSYS} == "Linux"
.include "../../devel/libuuid/buildlink3.mk"
.endif
.include "../../mail/akonadi/buildlink3.mk"
.include "../../security/cyrus-sasl/buildlink3.mk"
.include "../../security/gpgme/buildlink3.mk"
.include "../../x11/kdelibs4/buildlink3.mk"
.endif # KDEPIMLIBS_BUILDLINK3_MK

BUILDLINK_TREE+=	-kdepimlibs
