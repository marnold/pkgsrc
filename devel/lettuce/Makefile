# $NetBSD: Makefile,v 1.5 2014/01/25 10:30:01 wiz Exp $

DISTNAME=	lettuce-0.2.18
CATEGORIES=	devel
MASTER_SITES=	http://pypi.python.org/packages/source/l/lettuce/

MAINTAINER=	reed@reedmedia.net
HOMEPAGE=	http://lettuce.it/
COMMENT=	Behaviour-driven development test tool
LICENSE=	gnu-gpl-v3

REPLACE_PYTHON=	lettuce/bin.py lettuce/plugins/autopdb.py
PYTHON_VERSIONS_INCOMPATIBLE=	33 # not yet ported as of 0.2.18

.include "../../lang/python/application.mk"
.include "../../lang/python/egg.mk"
.include "../../mk/bsd.pkg.mk"
