# $NetBSD: Makefile,v 1.7 2014/04/10 05:39:15 obache Exp $

DISTNAME=	ffmpeg2theora-0.29
PKGREVISION=	2
CATEGORIES=	multimedia
MASTER_SITES=	http://v2v.cc/~j/ffmpeg2theora/downloads/
EXTRACT_SUFX=	.tar.bz2

MAINTAINER=	pkgsrc-users@NetBSD.org
HOMEPAGE=	http://v2v.cc/~j/ffmpeg2theora/
COMMENT=	Simple converter to create Ogg Theora files
LICENSE=	gnu-gpl-v3

USE_TOOLS+=		pkg-config
BUILD_DEPENDS+=		scons>=1.3.1:../../devel/scons

INSTALLATION_DIRS+=	bin ${PKGMANDIR}/man1

SCONS=		${PREFIX}/bin/scons
SCONS_ARGS=	-C ${WRKSRC} destdir=${DESTDIR:Q} prefix=${PREFIX:Q}
SCONS_ARGS+=	APPEND_CCFLAGS=${CFLAGS:Q}
SCONS_ARGS+=	APPEND_LINKFLAGS=${LDFLAGS:Q}

do-build:
	cd ${WRKSRC} && ${SETENV} ${MAKE_ENV} ${SCONS} ${SCONS_ARGS}

do-install:
	${INSTALL_PROGRAM} ${WRKSRC}/ffmpeg2theora ${DESTDIR}${PREFIX}/bin
	${INSTALL_MAN} ${WRKSRC}/ffmpeg2theora.1 \
	  ${DESTDIR}${PREFIX}/${PKGMANDIR}/man1

.include "../../audio/libvorbis/buildlink3.mk"
.include "../../multimedia/ffmpeg2/buildlink3.mk"
.include "../../multimedia/libogg/buildlink3.mk"
.include "../../multimedia/libtheora/buildlink3.mk"

.include "../../mk/bsd.pkg.mk"
