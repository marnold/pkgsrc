#	$NetBSD: bsd.pkg.subdir.mk,v 1.47.2.1 2002/06/23 18:54:41 jlam Exp $
#	Derived from: FreeBSD Id: bsd.port.subdir.mk,v 1.19 1997/03/09 23:10:56 wosch Exp 
#	from: @(#)bsd.subdir.mk	5.9 (Berkeley) 2/1/91
#
# The include file <bsd.pkg.subdir.mk> contains the default targets
# for building ports subdirectories. 
#
#
# +++ variables +++
#
# OPSYS		Get the operating system type [`uname -s`]
#
# SUBDIR	A list of subdirectories that should be built as well.
#		Each of the targets will execute the same target in the
#		subdirectories.
#
#
# +++ targets +++
#
#	README.html:
#		Creating README.html for package.
#
#	afterinstall, all, beforeinstall, build, checksum, clean,
#	configure, deinstall, depend, describe, extract, fetch, fetch-list, 
#	install, package, readmes, realinstall, reinstall, tags,
#	mirror-distfiles, bulk-install, bulk-package, ${PKG_MISC_TARGETS}
#

# Pull in stuff from mk.conf - need to check two places as this may be
# called from pkgsrc or from pkgsrc/category.
.if exists(${.CURDIR}/mk/bsd.prefs.mk)
.include "${.CURDIR}/mk/bsd.prefs.mk"
.else
.if exists(${.CURDIR}/../mk/bsd.prefs.mk)
.include "${.CURDIR}/../mk/bsd.prefs.mk"
.endif	# exists(${.CURDIR}/../mk/bsd.prefs.mk)
.endif	# exists(${.CURDIR}/mk/bsd.prefs.mk)


.MAIN: all

AWK?=		/usr/bin/awk
CAT?=		/bin/cat
BASENAME?=	/usr/bin/basename
ECHO?=		echo
ECHO_MSG?=	${ECHO}
MV?=		/bin/mv
RM?=		/bin/rm
SED?=		/usr/bin/sed
SORT?=		/usr/bin/sort

_SUBDIRUSE: .USE
	@for entry in "" ${SUBDIR}; do \
		if [ "X$$entry" = "X" ]; then continue; fi; \
		OK=""; \
		for dud in "" ${DUDS}; do \
			if [ "X$$dud" = "X" ]; then continue; fi; \
			if [ $${dud} = $${entry} ]; then \
				OK="false"; \
				${ECHO_MSG} "===> ${_THISDIR_}$${entry} skipped"; \
			fi; \
		done; \
		if [ -d ${.CURDIR}/$${entry}.${MACHINE} ]; then \
			edir=$${entry}.${MACHINE}; \
		elif [ -d ${.CURDIR}/$${entry} ]; then \
			edir=$${entry}; \
		else \
			OK="false"; \
			${ECHO_MSG} "===> ${_THISDIR_}$${entry} non-existent"; \
		fi; \
		if [ "$$OK" = "" ]; then \
			cd ${.CURDIR}/$${edir}; \
			${ECHO_MSG} "===> ${_THISDIR_}$${edir}"; \
			${MAKE} ${MAKEFLAGS} "_THISDIR_=${_THISDIR_}$${edir}/" \
			    ${.TARGET:realinstall=install} || true; \
		fi; \
	done

${SUBDIR}::
	@if [ -d ${.TARGET}.${MACHINE} ]; then \
		cd ${.CURDIR}/${.TARGET}.${MACHINE}; \
	else \
		cd ${.CURDIR}/${.TARGET}; \
	fi; \
	${MAKE} ${MAKEFLAGS} all

.for __target in all fetch package extract configure build clean \
		cleandir distclean depend describe reinstall tags checksum \
		makepatchsum mirror-distfiles deinstall show-downlevel \
		show-pkgsrc-dir show-var show-vars bulk-install bulk-package \
		fetch-list-one-pkg fetch-list-recursive \
		${PKG_MISC_TARGETS}
.if !target(__target)
${__target}: _SUBDIRUSE
.endif
.endfor

.if !target(install)
.if !target(beforeinstall)
beforeinstall:
.endif
.if !target(afterinstall)
afterinstall:
.endif
install: afterinstall
afterinstall: realinstall
realinstall: beforeinstall _SUBDIRUSE
.endif

.if !target(readmes)
readmes: readme _SUBDIRUSE
.endif

.if !target(readme)
readme:
	@if [ -f README.html ]; then ${MV} -f README.html README.html.BAK ; fi
	@${MAKE} ${MAKEFLAGS} README.html _README_TYPE=$@
.endif

.if !target(cdrom-readme)
cdrom-readme:
	@if [ -f README.html ]; then ${MV} -f README.html README.html.BAK ; fi
	@${MAKE} ${MAKEFLAGS} README.html _README_TYPE=$@
.endif

.if defined(PKGSRCTOP)
README=	templates/README.top
.else
README=	../templates/README.category
.endif

HTMLIFY=	${SED} -e 's/&/\&amp;/g' -e 's/>/\&gt;/g' -e 's/</\&lt;/g'

README.html: .PRECIOUS
	@> $@.tmp
.for entry in ${SUBDIR}
.if defined(PKGSRCTOP)
	@${ECHO} -n '<TR><TD VALIGN=TOP><a href="'${entry}/README.html'">'"`${ECHO} ${entry} | ${HTMLIFY}`"'</a>: <TD>' >> $@.tmp
	@${ECHO} `cd ${entry} && ${MAKE} ${MAKEFLAGS} show-comment | ${HTMLIFY}` >> $@.tmp
.else
	@${ECHO} '<TR><TD VALIGN=TOP><a href="'${entry}/README.html'">'"`cd ${entry}; ${MAKE} ${MAKEFLAGS} make-readme-html-help`" >> $@.tmp
.endif
.endfor
	@${SORT} -t '>' +3 -4 $@.tmp > $@.tmp2
	@${AWK} '{ ++n } END { print n }' < $@.tmp2 > $@.tmp4
.if exists(${.CURDIR}/DESCR)
	@${HTMLIFY} ${.CURDIR}/DESCR > $@.tmp3
.else
	@> $@.tmp3
.endif
	@${CAT} ${README} | \
		${SED} -e 's/%%CATEGORY%%/'"`${BASENAME} ${.CURDIR}`"'/g' \
			-e '/%%NUMITEMS%%/r$@.tmp4' \
			-e '/%%NUMITEMS%%/d' \
			-e '/%%DESCR%%/r$@.tmp3' \
			-e '/%%DESCR%%/d' \
			-e '/%%SUBDIR%%/r$@.tmp2' \
			-e '/%%SUBDIR%%/d' \
		> $@.tmp5
	@if cmp -s $@.tmp5 $@.BAK ; then \
		${MV} $@.BAK $@ ; \
		${RM} $@.tmp5 ; \
	else \
		${ECHO_MSG} "===>  Creating README.html for ${_THISDIR_}${.CURDIR:T}" ; \
		${MV} $@.tmp5 $@ ; \
		${RM} -f $@.BAK ; \
	fi
	@${RM} -f $@.tmp $@.tmp2 $@.tmp3 $@.tmp4
.for subdir in ${SUBDIR}
	@cd ${subdir} && ${MAKE} ${MAKEFLAGS} "_THISDIR_=${_THISDIR_}${.CURDIR:T}/" ${_README_TYPE}
.endfor

show-comment:
	@if [ "${COMMENT}" ]; then					\
		${ECHO} "${COMMENT:S/"/''/}";				\
	elif [ -f COMMENT ] ; then					\
		${CAT} COMMENT;						\
	else								\
		${ECHO} '(no description)';				\
	fi

.if !target(show-distfiles)
show-distfiles:
	@for entry in ${SUBDIR}; do					\
		if [ -d ${.CURDIR}/$${entry}.${MACHINE} ]; then		\
			edir=$${entry}.${MACHINE};			\
		elif [ -d ${.CURDIR}/$${entry} ]; then			\
			edir=$${entry};					\
		else							\
			OK="false";					\
			${ECHO_MSG} "===> ${_THISDIR_}$${entry} non-existent"; \
		fi;							\
		if [ "$$OK" = "" ]; then				\
			cd ${.CURDIR}/$${edir} && ${MAKE} ${MAKEFLAGS} show-distfiles; \
		fi;							\
	done
.endif


# Print out a script to fetch all needed files (no checksumming).
#
# When invoked at the top or category level, this target needs to be
# handled specially, to elide the "===>" messages that would otherwise
# ruin the script.
#
.if !target(fetch-list)
.PHONY: fetch-list

fetch-list:
	@${ECHO} '#!/bin/sh'
	@${ECHO} '#'
	@${ECHO} '# This is an auto-generated script, the result of running'
	@${ECHO} '# `make fetch-list'"'"' in directory "'"`pwd`"'"'
	@${ECHO} '# on host "'"`${UNAME} -n`"'" on "'"`date`"'".'
	@${ECHO} '#'
.if defined(PKGSRCTOP) && !defined(SPECIFIC_PKGS)
#	Recursing over dependencies would be pointless, in this case.
	@${MAKE} ${MAKEFLAGS} fetch-list-one-pkg		\
	| ${AWK} '						\
	function do_block () {					\
		if (FoundSomething) {				\
			for (line = 0; line < c; line++)	\
				print block[line];		\
			FoundSomething = 0			\
			}					\
		c = 0						\
		}						\
	/^[^#=]/ { FoundSomething = 1 }				\
	/^unsorted/ { gsub(/[[:space:]]+/, " \\\n\t") }		\
	/^echo/ { gsub(/;[[:space:]]+/, "\n") }			\
	!/^=/ { block[c++] = $$0 }				\
	/^=/ { do_block() }					\
	END { do_block() }					\
	'
.else
	@${MAKE} ${MAKEFLAGS} fetch-list-recursive		\
	| ${SED} '/^=/d'
.endif
.endif # !target(fetch-list)
