# $NetBSD: buildlink.mk,v 1.11.2.2 2002/08/22 11:12:23 jlam Exp $
#
# This Makefile fragment is included by packages that use OpenSSL.
#
# To use this Makefile fragment, simply:
#
# (1) Optionally define USE_OPENSSL_VERSION to the mininum OpenSSL version
#     number in <openssl/opensslv.h>, i.e. 0x0090600fL, etc.
# (2) Include this Makefile fragment in the package Makefile,
# (3) Add ${BUILDLINK_DIR}/include to the front of the C preprocessor's header
#     search path, and
# (4) Add ${BUILDLINK_DIR}/lib to the front of the linker's library search
#     path.

.if !defined(OPENSSL_BUILDLINK_MK)
OPENSSL_BUILDLINK_MK=	# defined

.include "../../mk/bsd.buildlink.mk"

# OpenSSL version numbers from <openssl/opensslv.h>
OPENSSL_VERSION_095A=		0x0090581fL
OPENSSL_VERSION_096=		0x0090600fL
OPENSSL_VERSION_096A=		0x0090601fL
OPENSSL_VERSION_096B=		0x0090602fL
OPENSSL_VERSION_096D=		0x0090604fL
OPENSSL_VERSION_096E=		0x0090605fL
OPENSSL_VERSION_096F=		0x0090606fL
OPENSSL_VERSION_096G=		0x0090607fL
# Check for a usable installed version of OpenSSL. Version must be greater
# than 0.9.6f, or else contain a fix for the 2002-07-30 security advisory.
# If a usable version isn't present, then use the pkgsrc OpenSSL package.
#
.include "../../mk/bsd.prefs.mk"
.if ${OPSYS} == "Darwin"
_OPENSSLV_H=		/usr/local/include/openssl/opensslv.h
_SSL_H=			/usr/local/include/openssl/ssl.h
.else
_OPENSSLV_H=		/usr/include/openssl/opensslv.h
_SSL_H=			/usr/include/openssl/ssl.h
.endif

_NEED_OPENSSL=		YES
.if exists(${_OPENSSLV_H}) && exists(${_SSL_H})
_IN_TREE_OPENSSL_HAS_FIX!=					\
		${AWK} 'BEGIN { ans = "NO" }			\
		/SSL_R_SSL2_CONNECTION_ID_TOO_LONG/ { ans = "YES" }	\
		END { print ans; exit 0 }' ${_SSL_H}

. if ${_IN_TREE_OPENSSL_HAS_FIX} == "YES"
USE_OPENSSL_VERSION?=		${OPENSSL_VERSION_096F}
. else
USE_OPENSSL_VERSION?=		${OPENSSL_VERSION_096G}
. endif

_OPENSSL_VERSION!=	${AWK} '/.*OPENSSL_VERSION_NUMBER.*/ { print $$3 }' \
				${_OPENSSLV_H}

_VALID_SSL_VERSIONS=	${OPENSSL_VERSION_096F}		# OpenSSL 0.9.6f
# There never was a package for this; only the in-tree openssl had it.
#BUILDLINK_DEPENDS.openssl=	openssl>=0.9.6f

. if ${USE_OPENSSL_VERSION} == ${OPENSSL_VERSION_096G}	# OpenSSL 0.9.6g
_VALID_SSL_VERSIONS=	${OPENSSL_VERSION_096G}
BUILDLINK_DEPENDS.openssl=	openssl>=0.9.6g
. else
_VALID_SSL_VERSIONS+=	${OPENSSL_VERSION_096G}
. endif

. for PATTERN in ${_VALID_SSL_VERSIONS}
.  if ${_OPENSSL_VERSION:M${PATTERN}} != ""
_NEED_OPENSSL=		NO
.  endif
. endfor

.else

# Last case to consider.... there is no in-tree openssl!
BUILDLINK_DEPENDS.openssl=	openssl>=0.9.6g

.endif  # exists(${_OPENSSLV_H}) && exists(${_SSL_H})

.if ${_NEED_OPENSSL} == "YES"
BUILDLINK_DEPENDS.openssl?=	openssl>=0.9.6g
DEPENDS+=	${BUILDLINK_DEPENDS.openssl}:../../security/openssl
EVAL_PREFIX+=	BUILDLINK_PREFIX.openssl=openssl
BUILDLINK_PREFIX.openssl_DEFAULT=	${LOCALBASE}
SSLBASE=			${BUILDLINK_PREFIX.openssl}
.else
. if ${OPSYS} == "Darwin"
BUILDLINK_PREFIX.openssl=	/usr/local
SSLBASE=			/usr/local
. else
BUILDLINK_PREFIX.openssl=	/usr
SSLBASE=			/usr
. endif
.endif

.if defined(PKG_SYSCONFDIR.openssl)
SSLCERTS=			${PKG_SYSCONFDIR.openssl}/certs
.elif ${OPSYS} == "NetBSD"
SSLCERTS=			/etc/openssl/certs
.else
SSLCERTS=			${PKG_SYSCONFBASE}/openssl/certs
.endif
BUILD_DEFS+=			SSLBASE SSLCERTS

BUILDLINK_FILES.openssl=	bin/openssl
BUILDLINK_FILES.openssl+=	include/openssl/*
BUILDLINK_FILES.openssl+=	lib/libRSAglue.*
BUILDLINK_FILES.openssl+=	lib/libcrypto.*
BUILDLINK_FILES.openssl+=	lib/libssl.*

.if defined(USE_RSAREF2) && ${USE_RSAREF2} == YES
.include "../../security/rsaref/buildlink.mk"
.endif

BUILDLINK_TARGETS.openssl=	openssl-buildlink
BUILDLINK_TARGETS+=		${BUILDLINK_TARGETS.openssl}

pre-configure: ${BUILDLINK_TARGETS.openssl}
openssl-buildlink: _BUILDLINK_USE

.endif	# OPENSSL_BUILDLINK_MK
