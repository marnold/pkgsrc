# $NetBSD: Makefile,v 1.91 2014/04/12 06:45:31 wiz Exp $

DISTNAME=	easytag-2.2.0
CATEGORIES=	audio
MASTER_SITES=	${MASTER_SITE_GNOME:=sources/easytag/2.2/}
EXTRACT_SUFX=	.tar.xz

MAINTAINER=	wiz@NetBSD.org
HOMEPAGE=	http://projects.gnome.org/easytag/
COMMENT=	GTK+ tag editor for MP3, Ogg Vorbis files, and others
LICENSE=	gnu-gpl-v2

BUILD_DEPENDS+=	itstool-[0-9]*:../../textproc/itstool

GNU_CONFIGURE=		yes
USE_LANGUAGES=		c c++
USE_PKGLOCALEDIR=	yes
USE_TOOLS+=		gmake intltool pkg-config xgettext

.include "options.mk"

.include "../../audio/id3lib/buildlink3.mk"
.include "../../audio/taglib/buildlink3.mk"
.include "../../graphics/hicolor-icon-theme/buildlink3.mk"
.include "../../x11/gtk3/buildlink3.mk"
.include "../../sysutils/desktop-file-utils/desktopdb.mk"
.include "../../mk/bsd.pkg.mk"
