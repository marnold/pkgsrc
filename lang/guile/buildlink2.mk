# $NetBSD: buildlink2.mk,v 1.1.2.1 2002/06/23 23:04:32 jlam Exp $

.if !defined(GUILE_BUILDLINK2_MK)
GUILE_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=		guile
BUILDLINK_DEPENDS.guile?=	guile>=1.4
BUILDLINK_PKGSRCDIR.guile?=	../../lang/guile

EVAL_PREFIX+=		BUILDLINK_PREFIX.guile=guile
BUILDLINK_PREFIX.guile_DEFAULT=	${X11PREFIX}
BUILDLINK_FILES.guile+=	include/guile/*
BUILDLINK_FILES.guile+=	include/guile-readline/*
BUILDLINK_FILES.guile+=	include/libguile.h
BUILDLINK_FILES.guile+=	include/libguile/*
BUILDLINK_FILES.guile+=	lib/libguile.*
BUILDLINK_FILES.guile+=	lib/libguilereadline.*

USE_GNU_READLINE=	# defined

.include "../../devel/readline/buildlink2.mk"

BUILDLINK_TARGETS+=	guile-buildlink

guile-buildlink: _BUILDLINK_USE

.endif	# GUILE_BUILDLINK2_MK
