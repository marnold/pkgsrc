# $NetBSD: buildlink2.mk,v 1.1.2.1 2002/06/23 23:04:08 jlam Exp $

.if !defined(SDL_TTF_BUILDLINK2_MK)
SDL_TTF_BUILDLINK2_MK=	# defined

.include "../../mk/bsd.buildlink.mk"

BUILDLINK_PACKAGES+=		SDL_ttf
BUILDLINK_DEPENDS.SDL_ttf?=	SDL_ttf>=2.0.3
BUILDLINK_PKGSRCDIR.SDL_ttf?=	../../devel/SDL_ttf

EVAL_PREFIX+=			BUILDLINK_PREFIX.SDL_ttf=SDL_ttf
BUILDLINK_PREFIX.SDL_ttf_DEFAULT=	${LOCALBASE}
BUILDLINK_FILES.SDL_ttf=	include/SDL/SDL_ttf.h
BUILDLINK_FILES.SDL_ttf+=	lib/libSDL_ttf-*
BUILDLINK_FILES.SDL_ttf+=	lib/libSDL_ttf.*

.include "../../devel/SDL/buildlink2.mk"
.include "../../graphics/freetype2/buildlink2.mk"

BUILDLINK_TARGETS+=	SDL_ttf-buildlink

SDL_ttf-buildlink: _BUILDLINK_USE

.endif	# SDL_TTF_BUILDLINK2_MK
