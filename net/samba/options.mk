# $NetBSD: options.mk,v 1.12.4.1 2006/04/02 14:16:16 salo Exp $

# Recommended package options for various setups:
#
#   Standalone Samba server		cups
#   Domain Member server		cups ldap winbind
#   Active Directory Member server	ads cups winbind
#   Domain Controller			ldap winbind
#
PKG_OPTIONS_VAR=	PKG_OPTIONS.samba
PKG_SUPPORTED_OPTIONS=	ads cups ldap ldap-compat mysql pam pgsql	\
			winbind xml

.include "../../mk/bsd.options.mk"

SAMBA_PASSDB_BACKENDS:=	# empty
SAMBA_STATIC_MODULES:=	# empty

###
### Allow Samba to join as a member server of an Active Directory domain.
###
.if !empty(PKG_OPTIONS:Mads)
.  include "../../mk/krb5.buildlink3.mk"
.  if empty(PKG_OPTIONS:Mldap)
PKG_OPTIONS+=		ldap
.  endif
CONFIGURE_ARGS+=	--with-ads
CONFIGURE_ARGS+=	--with-krb5=${KRB5BASE:Q}
.else
CONFIGURE_ARGS+=	--without-ads
CONFIGURE_ARGS+=	--without-krb5
.endif

###
### Native CUPS support for providing printing services.
###
.if !empty(PKG_OPTIONS:Mcups)
.  include "../../print/cups/buildlink3.mk"
CONFIGURE_ARGS+=	--enable-cups
PLIST_SUBST+=		CUPS=

post-install: samba-cups-install
samba-cups-install:
	${INSTALL_DATA_DIR} ${PREFIX}/libexec/cups/backend
	cd ${PREFIX}/libexec/cups/backend && ${LN} -fs ../../../bin/smbspool smb
.else
CONFIGURE_ARGS+=	--disable-cups
PLIST_SUBST+=		CUPS="@comment "
.endif

###
### Support Samba-2.x LDAP password and account databases.
###
.if !empty(PKG_OPTIONS:Mldap-compat)
.  if empty(PKG_OPTIONS:Mldap)
PKG_OPTIONS+=		ldap
.  endif
CONFIGURE_ARGS+=	--with-ldapsam
.endif

###
### Support LDAP authentication and storage of Samba account information.
###
.if !empty(PKG_OPTIONS:Mldap)
.  include "../../databases/openldap/buildlink3.mk"
CONFIGURE_ARGS+=	--with-ldap
.else
CONFIGURE_ARGS+=	--without-ldap
.endif

###
### Support using a MySQL database as a "passdb backend" for password
### and account information storage.
###
.if !empty(PKG_OPTIONS:Mmysql)
.  include "../../mk/mysql.buildlink3.mk"
SAMBA_PASSDB_BACKENDS:=	${SAMBA_PASSDB_BACKENDS},mysql
SAMBA_STATIC_MODULES:=	${SAMBA_STATIC_MODULES},pdb_mysql
.endif

###
### Support PAM authentication and build smbpass and winbind PAM modules.
###
.if !empty(PKG_OPTIONS:Mpam)
.  include "../../security/PAM/module.mk"
CONFIGURE_ARGS+=	--with-pam
CONFIGURE_ARGS+=	--with-pam_smbpass
PLIST_SUBST+=		PAM_SMBPASS=lib/security/pam_smbpass.so
PLIST_SUBST+=		PAM=

post-install: samba-pam-smbpass-install
samba-pam-smbpass-install:
	${INSTALL_LIB_DIR} ${PAM_INSTMODULEDIR}
	${INSTALL_LIB} ${WRKSRC}/bin/pam_smbpass.so ${PAM_INSTMODULEDIR}
	${INSTALL_DATA_DIR} ${DOCDIR}
	${INSTALL_DATA} ${WRKSRC}/pam_smbpass/README			\
		${DOCDIR}/README.pam_smbpass
	${INSTALL_DATA_DIR} ${EGDIR}/pam_smbpass
	cd ${WRKSRC}/pam_smbpass/samples; for f in [a-z]*; do		\
		${INSTALL_DATA} $${f} ${EGDIR}/pam_smbpass/$${f};	\
	done
.else
PLIST_SUBST+=		PAM_SMBPASS="@comment no PAM smbpass module"
PLIST_SUBST+=		PAM="@comment "
.endif

###
### Support using a PostgreSQL database as a "passdb backend" for password
### and account information storage.
###
.if !empty(PKG_OPTIONS:Mpgsql)
.  include "../../mk/pgsql.buildlink3.mk"
SAMBA_PASSDB_BACKENDS:=	${SAMBA_PASSDB_BACKENDS},pgsql
SAMBA_STATIC_MODULES:=	${SAMBA_STATIC_MODULES},pdb_pgsql
.endif

###
### Support querying a PDC for domain user and group information, e.g.,
### through NSS or PAM.
###
.if !empty(PKG_OPTIONS:Mwinbind)
CONFIGURE_ARGS+=	--with-winbind

SAMBA_STATIC_MODULES:=	${SAMBA_STATIC_MODULES},idmap_rid
.  if !empty(PKG_OPTIONS:Mads)
SAMBA_STATIC_MODULES:=	${SAMBA_STATIC_MODULES},idmap_ad
.  endif

WINBINDD_RCD_SCRIPT=	winbindd
PLIST_SUBST+=		WINBIND=

# Install the PAM winbind module if we're also building with PAM support.
.  if empty(PKG_OPTIONS:Mpam)
PLIST_SUBST+=	PAM_WINBIND="@comment no PAM winbind module"
.  else
PLIST_SUBST+=	PAM_WINBIND=lib/security/pam_winbind.so

post-install: samba-pam-winbind-install
samba-pam-winbind-install:
	${INSTALL_LIB_DIR} ${PAM_INSTMODULEDIR}
	${INSTALL_LIB} ${WRKSRC}/nsswitch/pam_winbind.so ${PAM_INSTMODULEDIR}
.  endif

# Install the NSS winbind module if it exists.
PLIST_SUBST+=		NSS_WINBIND=${NSS_WINBIND:Q}
NSS_WINBIND=		${NSS_WINBIND_cmd:sh}
NSS_WINBIND_cmd=	\
	${TEST} -x ${WRKSRC}/config.status ||				\
		{ ${ECHO} "@comment no NSS winbind module" ; exit 0; };	\
	cd ${WRKDIR} && ${ECHO} @WINBIND_NSS@ |				\
	${WRKSRC}/config.status --file=-:- | 				\
	${AWK} '/^$$/ { print "@comment no NSS winbind module"; exit 0; } \
		{ sub(".*/", "lib/"); print; }' &&			\
	${RM} -f config.log

post-install: samba-nss-winbind-install
samba-nss-winbind-install:
	lib=${WRKSRC:Q}/nsswitch/${NSS_WINBIND:T:Q};			\
	${TEST} ! -f $$lib || ${INSTALL_LIB} $$lib ${PREFIX:Q}/lib

# Install the NSS WINS module if it exists.
PLIST_SUBST+=	NSS_WINS=${NSS_WINS:Q}
NSS_WINS=	${NSS_WINS_cmd:sh}
NSS_WINS_cmd=	\
	${TEST} -x ${WRKSRC}/config.status ||				\
		{ ${ECHO} "@comment no NSS WINS module" ; exit 0; };	\
	cd ${WRKDIR} && ${ECHO} @WINBIND_WINS_NSS@ |			\
	${WRKSRC}/config.status --file=-:- |				\
	${AWK} '/^$$/ { print "@comment no NSS WINS module"; exit 0; }	\
		{ sub(".*/", "lib/"); print; }' &&			\
	${RM} -f config.log

post-install: samba-nss-wins-install
samba-nss-wins-install:
	lib=${WRKSRC:Q}/nsswitch/${NSS_WINS:T:Q};			\
	${TEST} ! -f $$lib || ${INSTALL_LIB} $$lib ${PREFIX:Q}/lib
.else
CONFIGURE_ARGS+=	--without-winbind
PLIST_SUBST+=		WINBIND="@comment "
PLIST_SUBST+=		PAM_WINBIND="@comment no PAM winbind module"
PLIST_SUBST+=		NSS_WINBIND="@comment no NSS winbind module"
PLIST_SUBST+=		NSS_WINS="@comment no NSS WINS module"
.endif

###
### Support using an XML file as a "passdb backend" for password and
### account information storage.
###
.if !empty(PKG_OPTIONS:Mxml)
.  include "../../textproc/libxml2/buildlink3.mk"
SAMBA_PASSDB_BACKENDS:=	${SAMBA_PASSDB_BACKENDS},xml
SAMBA_STATIC_MODULES:=	${SAMBA_STATIC_MODULES},pdb_xml
.endif

###
### Add the optional passdb backends to the configuration.
###
.if !empty(SAMBA_PASSDB_BACKENDS)
CONFIGURE_ARGS+=	--with-expsam=${SAMBA_PASSDB_BACKENDS:S/^,//}
.endif

###
### Add the optional static modules to the configuration.
###
.if !empty(SAMBA_STATIC_MODULES)
CONFIGURE_ARGS+=	--with-static-modules=${SAMBA_STATIC_MODULES:S/^,//}
.endif
