# $NetBSD: buildlink2.mk,v 1.1.2.2 2002/06/06 06:54:46 jlam Exp $
#
# This Makefile fragment is included by packages that use libcups.
#
# To use this Makefile fragment, simply:
#
# (1) Optionally define BUILDLINK_DEPENDS.cups to the dependency pattern
#     for the version of cups desired.
# (2) Include this Makefile fragment in the package Makefile.

.if !defined(CUPS_BUILDLINK2_MK)
CUPS_BUILDLINK2_MK=	# defined

.include "../../mk/bsd.buildlink2.mk"

BUILDLINK_DEPENDS.cups?=	cups>=1.1.14nb1
DEPENDS+=	${BUILDLINK_DEPENDS.cups}:../../print/cups

EVAL_PREFIX+=	BUILDLINK_PREFIX.cups=cups
BUILDLINK_PREFIX.cups_DEFAULT=	${LOCALBASE}
BUILDLINK_FILES.cups=	include/cups/*
BUILDLINK_FILES.cups+=	lib/libcups.*
BUILDLINK_FILES.cups+=	lib/libcupsimage.*

BUILDLINK_TARGETS+=	cups-buildlink

cups-buildlink: _BUILDLINK_USE

.endif	# CUPS_BUILDLINK2_MK
