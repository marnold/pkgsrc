# $NetBSD: buildlink2.mk,v 1.1.2.1 2002/06/21 23:00:23 jlam Exp $

.if !defined(PHP4_BUILDLINK2_MK)
PHP4_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=		php4
BUILDLINK_DEPENDS.php4?=	php>=4.1.0
BUILDLINK_PKGSRCDIR.php4?=	../../www/php4

# This adds a build-dependency as php4 has no libraries.
BUILDLINK_DEPMETHOD.php4?=	build

EVAL_PREFIX+=			BUILDLINK_PREFIX.php4=php
BUILDLINK_PREFIX.php4_DEFAULT=	${LOCALBASE}
BUILDLINK_FILES.php4=		include/php/*/*/*.h
BUILDLINK_FILES.php4+=		include/php/*/*.h
BUILDLINK_FILES.php4+=		include/php/*.h

BUILDLINK_TARGETS+=		php4-buildlink

php4-buildlink: _BUILDLINK_USE

.endif	# PHP4_BUILDLINK2_MK
