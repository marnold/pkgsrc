# $NetBSD: options.mk,v 1.1.1.1 2010/07/06 14:45:52 taca Exp $

PKG_OPTIONS_VAR=	PKG_OPTIONS.contao-translations

# Not yet ready for Contao 2.9: af ca fi id no pt sk sq sr th tl zh
#
CT_SUPPORTED_LANGUAGES=	bg bs cs da es fa fr gl hr hu is it ja \
			lt lv nl pl ro ru sl sv tr uk

CT_TRANSLATIONS.af=	TYPOlight-Afrikaans-v1.zip	# 2008/01/15
CT_TRANSLATIONS.bg=	TYPOlight-Bulgarian-v18.zip	# 2010/02/18
CT_TRANSLATIONS.bs=	TYPOlight-Bosnian-v10.zip	# 2010/03/18
CT_TRANSLATIONS.ca=	TYPOlight-Catalan-v4.zip	# 2008/09/24
CT_TRANSLATIONS.cs=	TYPOlight-Czech-v23.zip		# 2010/07/02
CT_TRANSLATIONS.da=	TYPOlight-Danish-v10.zip	# 2010/05/16
CT_TRANSLATIONS.es=	TYPOlight-Spanish-v14.zip	# 2010/06/10
CT_TRANSLATIONS.fa=	TYPOlight-Persian-v5.zip	# 2010/07/06
CT_TRANSLATIONS.fi=	TYPOlight-Finnish-v1.zip	# 2009/11/03
CT_TRANSLATIONS.fr=	TYPOlight-French-v56.zip	# 2010/07/03
CT_TRANSLATIONS.gl=	TYPOlight-Galician-v3.zip	# 2010/03/26
CT_TRANSLATIONS.hr=	TYPOlight-Croatian-v6.zip	# 2010/06/07
CT_TRANSLATIONS.hu=	TYPOlight-Hungarian-v4.zip	# 2010/05/04
CT_TRANSLATIONS.id=	TYPOlight-Indonesian-v1.zip	# 2009/01/13
CT_TRANSLATIONS.is=	TYPOlight-Icelandic-v5.zip	# 2010/02/10
CT_TRANSLATIONS.it=	TYPOlight-Italian-v24.zip	# 2010/07/02
CT_TRANSLATIONS.ja=	TYPOlight-Japanese-v32.zip	# 2010/07/02
CT_TRANSLATIONS.lt=	TYPOlight-Lithuanian-v4.zip	# 2010/04/14
CT_TRANSLATIONS.lv=	TYPOlight-Latvian-v24.zip	# 2010/04/20
CT_TRANSLATIONS.nl=	TYPOlight-Dutch-v43.zip		# 2010/06/07
CT_TRANSLATIONS.no=	TYPOlight-Norwegian-v11.zip	# 2009/11/16
CT_TRANSLATIONS.pl=	TYPOlight-Polish-v28.zip	# 2010/07/02
CT_TRANSLATIONS.pt=	TYPOlight-Portuguese-v7.zip	# 2009/11/01
CT_TRANSLATIONS.ro=	TYPOlight-Romanian-v10.zip	# 2009/07/02
CT_TRANSLATIONS.ru=	TYPOlight-Russian-v34.zip	# 2010/07/06
CT_TRANSLATIONS.sk=	TYPOlight-Slovak-v8.zip		# 2009/08/15
CT_TRANSLATIONS.sl=	TYPOlight-Slovenian-v6.zip	# 2010/03/12
CT_TRANSLATIONS.sq=	TYPOlight-Albanian-v4.zip	# 2008/12/14
CT_TRANSLATIONS.sr=	TYPOlight-Serbian-v7.zip	# 2010/05/10
CT_TRANSLATIONS.sv=	TYPOlight-Swedish-v51.zip	# 2010/07/02
CT_TRANSLATIONS.th=	TYPOlight-Thai-v2.zip		# 2008/11/23
CT_TRANSLATIONS.tl=	TYPOlight-Tagalog-v1.zip	# 2010/01/29
CT_TRANSLATIONS.tr=	TYPOlight-Turkish-v11.zip	# 2010/06/14
CT_TRANSLATIONS.uk=	TYPOlight-Ukrainian-v14.zip	# 2010/07/02
CT_TRANSLATIONS.zh=	TYPOlight-Chinese-v20.zip	# 2010/01/29

.for l in ${CT_SUPPORTED_LANGUAGES}
PKG_SUPPORTED_OPTIONS+=	lang-${l}
PKG_SUGGESTED_OPTIONS+=	lang-${l}
.endfor

.include "../../mk/bsd.options.mk"

.for l in ${PKG_OPTIONS:Mlang-*}
CT_LANGUAGES+=	${l:S/^lang-//1}
.endfor

.for l in ${CT_LANGUAGES}
CT_DISTFILES+=	${CT_TRANSLATIONS.${l}}
SITES.${CT_TRANSLATIONS.${l}}= \
	http://www.contao.org/download.html?iso=${l}&file=tl_files/languages/${l}/
PLIST_SRC+=	PLIST.${l}
.endfor
