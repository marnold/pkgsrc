# $NetBSD: buildlink3.mk,v 1.1.1.1 2009/10/02 21:27:09 markd Exp $

BUILDLINK_TREE+=	kdepimlibs

.if !defined(KDEPIMLIBS_BUILDLINK3_MK)
KDEPIMLIBS_BUILDLINK3_MK:=

BUILDLINK_API_DEPENDS.kdepimlibs+=	kdepimlibs4>=4.0.0
BUILDLINK_ABI_DEPENDS.kdepimlibs?=	kdepimlibs4>=4.0.0nb1
BUILDLINK_PKGSRCDIR.kdepimlibs?=	../../misc/kdepimlibs4

.include "../../databases/openldap-client/buildlink3.mk"
.include "../../devel/boost-libs/buildlink3.mk"
.include "../../mail/akonadi/buildlink3.mk"
.include "../../security/cyrus-sasl/buildlink3.mk"
.include "../../security/gpgme/buildlink3.mk"
.include "../../x11/kdelibs4/buildlink3.mk"
.endif # KDEPIMLIBS_BUILDLINK3_MK

BUILDLINK_TREE+=	-kdepimlibs
