# $NetBSD: options.mk,v 1.11.4.1 2005/11/01 21:51:26 salo Exp $

PKG_OPTIONS_VAR=	PKG_OPTIONS.fetchmail
PKG_SUPPORTED_OPTIONS=	inet6 kerberos4 kerberos gssapi ssl
PKG_OPTIONS_OPTIONAL_GROUPS=	socks
PKG_OPTIONS_GROUP.socks=	socks4 socks5

PKG_SUGGESTED_OPTIONS= ssl

.include "../../mk/bsd.options.mk"

###
### IPv6 support.
###
.if !empty(PKG_OPTIONS:Minet6)
CONFIGURE_ARGS+=	--enable-inet6
.endif

###
### Authentication via GSSAPI (currently only over Kerberos V) support.
###
.if !empty(PKG_OPTIONS:Mgssapi)
CONFIGURE_ARGS+=	--with-gssapi=${KRB5BASE}
.else
CONFIGURE_ARGS+=	--with-gssapi=no
.endif

###
### KPOP (POP3 + Kerberos IV) support.
###
.if !empty(PKG_OPTIONS:Mkerberos4)
PKG_USE_KERBEROS=	yes
CONFIGURE_ARGS+=	--with-kerberos=yes
.  if empty(MACHINE_PLATFORM:MNetBSD-1.[0-4]*-i386)
REPLACE_KERBEROS_LIBS=	yes
.  endif
.else
CONFIGURE_ARGS+=	--with-kerberos=no
.endif

###
### Kerberos V support.
###
.if !empty(PKG_OPTIONS:Mkerberos) || !empty(PKG_OPTIONS:Mgssapi)
.  include "../../mk/krb5.buildlink3.mk"
PKG_USE_KERBEROS=	yes
CONFIGURE_ARGS+=        --with-kerberos5=${KRB5BASE}
.else
CONFIGURE_ARGS+=        --with-kerberos5=no
.endif

###
### Support POP3 and IMAP over SSL.
###
.if !empty(PKG_OPTIONS:Mssl)
.  include "../../security/openssl/buildlink3.mk"
CONFIGURE_ARGS+=	--with-ssl=${SSLBASE}
.else
CONFIGURE_ARGS+=	--without-ssl
.endif

###
### Include SOCKS firewall support
###
.if !empty(PKG_OPTIONS:Msocks4)
.include "../../net/socks4/buildlink3.mk"
CONFIGURE_ARGS+=	--with-socks=${BUILDLINK_PREFIX.socks4}
.endif
.if !empty(PKG_OPTIONS:Msocks5)
.include "../../net/socks5/buildlink3.mk"
CONFIGURE_ARGS+=	--with-socks5=${BUILDLINK_PREFIX.socks5}
.endif
