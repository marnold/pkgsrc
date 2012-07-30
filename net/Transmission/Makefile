# $NetBSD: Makefile,v 1.78.4.1 2012/07/30 22:12:18 tron Exp $

PKGNAME=		${DISTNAME:C:t:T:}

pre-configure:
	touch ${WRKSRC}/po/Makefile

CONFIGURE_ARGS+=	--without-gtk

.include "../../net/Transmission/Makefile.common"

.include "../../mk/bsd.pkg.mk"
