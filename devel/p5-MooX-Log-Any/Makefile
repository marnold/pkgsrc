# $NetBSD: Makefile,v 1.1 2014/02/23 15:51:56 sno Exp $

DISTNAME=	MooX-Log-Any-0.001
PKGNAME=	p5-${DISTNAME}
CATEGORIES=	devel perl5
MASTER_SITES=	${MASTER_SITE_PERL_CPAN:=../../authors/id/C/CA/CAZADOR/}

MAINTAINER=	pkgsrc-users@NetBSD.org
HOMEPAGE=	https://metacpan.org/release/MooX-Log-Any
COMMENT=	Role to add Log::Any
LICENSE=	${PERL5_LICENSE}

DEPENDS+=	p5-Log-Any-[0-9]*:../../devel/p5-Log-Any
DEPENDS+=	p5-Moo-[0-9]*:../../devel/p5-Moo

USE_LANGUAGES=	# empty
PERL5_PACKLIST=	auto/MooX/Log/Any/.packlist
PERL5_REQD+=	5.6.2	# Test::More >= 0
PERL5_REQD+=	5.8.8	# ExtUtils::MakeMaker >= 6.30

pre-configure:
	find ${WRKSRC} -name "*~" -type f | xargs rm

.include "../../lang/perl5/module.mk"
.include "../../mk/bsd.pkg.mk"
