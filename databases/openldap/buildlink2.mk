# $NetBSD: buildlink2.mk,v 1.1.2.2 2002/06/21 23:00:27 jlam Exp $

.if !defined(OPENLDAP_BUILDLINK2_MK)
OPENLDAP_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=		openldap
BUILDLINK_DEPENDS.openldap?=	openldap-2.0.*
BUILDLINK_PKGSRCDIR.openldap?=	../../databases/openldap

EVAL_PREFIX+=	BUILDLINK_PREFIX.openldap=openldap
BUILDLINK_PREFIX.openldap_DEFAULT=	${LOCALBASE}
BUILDLINK_FILES.openldap=	include/disptmpl.h
BUILDLINK_FILES.openldap+=	include/lber.h
BUILDLINK_FILES.openldap+=	include/lber_types.h
BUILDLINK_FILES.openldap+=	include/ldap.h
BUILDLINK_FILES.openldap+=	include/ldap_cdefs.h
BUILDLINK_FILES.openldap+=	include/ldap_features.h
BUILDLINK_FILES.openldap+=	include/ldap_schema.h
BUILDLINK_FILES.openldap+=	include/srchpref.h
BUILDLINK_FILES.openldap+=	lib/liblber.*
BUILDLINK_FILES.openldap+=	lib/libldap.*

USE_PTHREAD=		native

.include "../../mk/bsd.prefs.mk"

.if ${OPSYS} == SunOS
.  include "../../databases/db/buildlink2.mk"
.endif

.include "../../mk/pthread.buildlink2.mk"

.if defined(USE_SASL) && (${USE_SASL} == "YES")
.  include "../../security/cyrus-sasl/buildlink2.mk"
.endif

BUILDLINK_TARGETS+=	openldap-buildlink

openldap-buildlink: _BUILDLINK_USE

.endif	# OPENLDAP_BUILDLINK2_MK
