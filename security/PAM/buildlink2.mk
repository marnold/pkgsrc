# $NetBSD: buildlink2.mk,v 1.1.2.3 2002/06/21 23:00:37 jlam Exp $

.if !defined(PAM_BUILDLINK2_MK)
PAM_BUILDLINK2_MK=	# defined

.include "../../mk/bsd.prefs.mk"

BUILDLINK_DEPENDS.pam?=		PAM>=0.75
BUILDLINK_PKGSRCDIR.pam?=	../../security/PAM

.if exists(/usr/include/security/pam_appl.h)
_NEED_PAM=		NO
.else
_NEED_PAM=		YES
.endif

.if ${_NEED_PAM} == "YES"

BUILDLINK_PACKAGES+=	pam
EVAL_PREFIX+=	BUILDLINK_PREFIX.pam=PAM
BUILDLINK_PREFIX.pam_DEFAULT=	${LOCALBASE}

BUILDLINK_FILES.pam=	include/security/*
BUILDLINK_FILES.pam+=	lib/libpam.*
BUILDLINK_FILES.pam+=	lib/libpamc.*
BUILDLINK_FILES.pam+=	lib/libpam_misc.*

BUILDLINK_TARGETS+=	pam-buildlink

pam-buildlink: _BUILDLINK_USE

.else

# The PAM libraries are usually in /lib on Linux systems while the headers
# are in /usr/include.
#
BUILDLINK_PREFIX.pam=		/usr
BUILDLINK_PREFIX.pam-inc=	/usr
BUILDLINK_FILES.pam-inc=	include/security/*
BUILDLINK_PREFIX.pam-lib=	/
BUILDLINK_FILES.pam-lib+=	lib/libpam.*
BUILDLINK_FILES.pam-lib+=	lib/libpamc.*
BUILDLINK_FILES.pam-lib+=	lib/libpam_misc.*

BUILDLINK_TARGETS+=	pam-inc-buildlink
BUILDLINK_TARGETS+=	pam-lib-buildlink

pam-inc-buildlink: _BUILDLINK_USE
pam-lib-buildlink: _BUILDLINK_USE

.endif	# _NEED_PAM
.endif	# PAM_BUILDLINK2_MK
