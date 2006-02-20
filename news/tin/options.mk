# $NetBSD: options.mk,v 1.4.2.2 2006/02/20 13:37:13 salo Exp $

PKG_OPTIONS_VAR=	PKG_OPTIONS.tin
PKG_SUPPORTED_OPTIONS=	curses icu inet6 tin-use-inn-spool
# untested
#PKG_SUPPORTED_OPTIONS+=	socks
# remove after 2006Q1
PKG_OPTIONS_LEGACY_VARS=	TIN_USE_INN_SPOOL:tin-use-inn-spool

.include "../../mk/bsd.options.mk"

.if !empty(PKG_OPTIONS:Mcurses)
CONFIGURE_ARGS+=	--with-screen=curses
.endif

.if !empty(PKG_OPTIONS:Micu)
.include "../../textproc/icu/buildlink3.mk"
.endif

.if !empty(PKG_OPTIONS:Minet6)
CONFIGURE_ARGS+=	--enable-ipv6
.endif

.if !empty(PKG_OPTIONS:Mtin-use-inn-spool)
INN_DATA_DIR?=  /var/news
CONFIGURE_ARGS+=	--with-inews-dir=${PREFIX}/inn/bin \
			--with-libdir=${INN_DATA_DIR}/db \
			--with-spooldir=${INN_DATA_DIR}/spool/articles \
			--with-nov-dir=${INN_DATA_DIR}/spool/overview
.else
CONFIGURE_ARGS+=	--enable-nntp-only
.endif

.if !empty(PKG_OPTIONS:Msocks)
.include "../../net/socks5/buildlink3.mk"
CONFIGURE_ARGS+=	--with-socks5=${BUILDLINK_PREFIX.socks5}
.endif
