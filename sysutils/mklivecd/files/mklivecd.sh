#!/bin/sh
#
# $NetBSD: mklivecd.sh,v 1.1.1.1 2004/02/26 03:58:56 xtraeme Exp $
#
# Copyright (c) 2004 Juan RP <xtraeme@NetBSD.org>
# All rights Reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in
#    the documentation and/or other materials provided with the
#    distribution.
# 3. Neither the name of author nor the names of its contributors may
#    be used to endorse or promote products derived from this software
#    without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE NETBSD FOUNDATION, INC. AND CONTRIBUTORS
# ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
# TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE FOUNDATION OR CONTRIBUTORS
# BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#
# ====================================================================== #
#  mklivecd - Build a NetBSD LiveCD! for i386 machines.			 #
# ====================================================================== #

progname=$(basename $0)
config_dir="$HOME/.mklivecd/"
config_file="$config_dir/mklivecd.conf"
pers_conffile="personal_config"
tmp_file="/tmp/${progname}.$$"

MKISOFS="@PREFIX@/bin/mkisofs"
CDRECORD="@PREFIX@/bin/cdrecord"

# ====================================================================== #
#  My functions :-)							 #
# ====================================================================== #

usage()
{
	cat <<_usage_

	${progname}: [target]

	Target operations:

	kernel	    Build and install the Boot kernel image
	iso	    Build the ISO 9660 image
	burn	    Burn the ISO image via cdrecord
	base	    Install the base/x11 sets into ISODIR
	chroot	    chroot into the livecd
	clean	    Clean the work directory
	config	    Create the default configuration file

_usage_

	exit 1
}

showmsg()
{
	echo "===> $@"
}

bye()
{
	_exitarg="$1"
	rm -f $tmp_file; exit $_exitarg
}

do_conf()
{
	BASE_VARS="SOURCEDIR PKGSRCDIR SHAREDIR BASEDIR WORKDIR ISODIR \
		   BASE_SETS_DIR X11_SETS_DIR BASE_SETS X11_SETS"

	MISC_VARS="ENABLE_X11 BLANK_BEFORE_BURN CDROM_DEVICE PERSONAL_CONFIG \
		   BOOTKERN KERNEL_NAME IMAGE_NAME PKG_SYSCONFDIR REMOVE_DIRS"

	MNT_VARS="MNT_DEV_ARGS MNT_ETC_ARGS MNT_VAR_ARGS \
		  MNT_ROOT_ARGS MNT_TMP_ARGS MNT_HOME_ARGS \
		  MNT_PKG_SYSCONFDIR_ARGS"

	# Base directories/sets
        : ${SOURCEDIR:=/usr/src}
	: ${PKGSRCDIR:=/usr/pkgsrc}
	: ${SHAREDIR:=@PREFIX@/share/mklivecd}
	: ${BASEDIR:=$HOME/livecd}
	: ${WORKDIR:=${BASEDIR}/work}
	: ${ISODIR:=${BASEDIR}/iso}
	: ${BASE_SETS_DIR:=$HOME/release/binary/sets}
	: ${X11_SETS_DIR:=${BASE_SETS_DIR}}
	: ${BASE_SETS:=etc.tgz base.tgz comp.tgz text.tgz}
	: ${X11_SETS:=xbase.tgz xcomp.tgz xfont.tgz xserver.tgz}

	# Miscellaneous options
	: ${ENABLE_X11:=no}
	: ${BLANK_BEFORE_BURN:=no}
	: ${CDROM_DEVICE:=15,1,0}
	: ${PERSONAL_CONFIG:=no}
	: ${BOOTKERN:=KERN-LIVECD}
	: ${KERNEL_NAME:=MKLIVECD}
	: ${IMAGE_NAME:=NetBSD-LiveCD}
	: ${PKG_SYSCONFDIR:=usr/pkg/etc}
	: ${REMOVE_DIRS:=altroot usr/share/info}
	
	# Mount arguments
	: ${MNT_DEV_ARGS:=-o noatime -s 5m}
	: ${MNT_ETC_ARGS:=-o noatime -s 2m}
	: ${MNT_VAR_ARGS:=-o noatime -s 10m}
	: ${MNT_ROOT_ARGS:=-o noatime -s 5m}
	: ${MNT_TMP_ARGS:=-o noatime -s 10m}
	: ${MNT_HOME_ARGS:=-o noatime -s 50m}
	: ${MNT_PKG_SYSCONFDIR_ARGS:=-o noatime -s 1m}

	if [ ! -d $config_dir ]; then
		mkdir $config_dir
	fi

	if [ ! -f $config_dir/$pers_conffile ]; then
		cp $SHAREDIR/$pers_conffile $config_dir
	fi

	if [ ! -f $config_file ]; then
		cat >> $config_file <<EOF
# --*-sh-*--    
#               
# mklivecd - configuration file
# See mklivecd(8) for a detailed description of each variable.
#
# Generated automatically on $(date).

EOF
		echo "# Base directories/options" >> $config_file
		for var in `echo $BASE_VARS | tr ' ' '\n'`
		do
		    eval val=\""\$$var"\"
		    echo "$var=\"$val\"" >> $config_file
		done
		echo >> $config_file

		echo "# Miscellaneous options" >> $config_file
		for var in `echo $MISC_VARS | tr ' ' '\n'`
		do
		    eval val=\""\$$var"\"
		    echo "$var=\"$val\"" >> $config_file
		done
		echo >> $config_file

		echo "# Mount arguments" >> $config_file
		for var in `echo $MNT_VARS | tr ' ' '\n'`
		do
		    eval val=\""\$$var"\"
		    echo "$var=\"$val\"" >> $config_file
		done
		echo >> $config_file

		echo "=> Configuration file created, now please edit it."
	else
		. $config_file

		if [ ! -d $SOURCEDIR/sys ]; then
		    showmsg "Cannot find $SOURCEDIR, please download"
		    showmsg "the src module."
		    bye 1
		fi
	fi
}

do_conf_reset()
{
	for F in ${BASE_VARS} ${MISC_VARS} ${MNT_VARS}
	do
		eval $F=\"\"
	done
}

do_cdlive()
{
	. $config_file

	vars="$BASEDIR $ISODIR $WORKDIR"

	for value in $vars
	do
		if [ ! -d $value ]; then
			mkdir -p $value
		fi
	done

	case "$1" in
	kernel)
		showmsg "Building boot image on $(date)"
		echo
		showmsg "Using the following values:"
		showmsg "   SHAREDIR=$SHAREDIR"
		showmsg "   WORKDIR=$WORKDIR"
		showmsg "   ISODIR=$ISODIR"
		showmsg "   BASEDIR=$BASEDIR"
		showmsg "Using kernel: $BOOTKERN"
		showmsg "Kernel name: $KERNEL_NAME"
		echo
		sleep 2
		sed -e "s,@KERNEL_NAME@,${KERNEL_NAME}," \
		    $SHAREDIR/bootkern.mk > $WORKDIR/Makefile
		sed -e "s,@ISODIR@,${ISODIR},g" $SHAREDIR/Makefile.bootfloppy \
			> $WORKDIR/Makefile.bootfloppy

		# if there's a kernel in ~/.mklivecd, use it, otherwise
		# use the default one located in SHAREDIR.
		if [ -s $config_dir/$BOOTKERN ]; then
		    cp $config_dir/$BOOTKERN $WORKDIR
		else
		    cp $SHAREDIR/$BOOTKERN $WORKDIR
		fi

		cd $WORKDIR
		[ ! -d $WORKDIR/$KERNEL_NAME ] && mkdir $WORKDIR/$KERNEL_NAME
		config -s $SOURCEDIR/sys -b $WORKDIR/$KERNEL_NAME \
		    $BOOTKERN
		cd $KERNEL_NAME
		make depend
		make COPTS="-Os"	    # Don't use additional flags
		cd $WORKDIR
		make USETOOLS=no COPTS=    # Don't use tools/copts
		if [ $? -eq 0 ]; then
		    [ ! -d $ISODIR/stand ] && mkdir -p $ISODIR/stand
		    cp cdlive-boot1.fs $ISODIR/stand/cdlive-boot.fs
		    cp netbsd $ISODIR
		    make clean
		    rm -rf $KERNEL_NAME
		    echo
		    showmsg "Build successful"
		    showmsg "Boot/kernel image installed!"
		    showmsg "Next step: ${progname} base"
		    echo
		else
		    echo
		    showmsg "Build failed"
		    showmsg "Boot/kernel image not installed!"
		    echo
		fi
	;;
	base)
		chown root:wheel $ISODIR/netbsd $ISODIR/stand/*

		for F in ${BASE_SETS}
		do
		    if [ ! -f $BASE_SETS_DIR/$F ]; then
			showmsg "Target base failed!"
			showmsg "Can't find $F, exiting."
			bye 1
		    fi
		done

		showmsg "Installing base sets"
		for S in ${BASE_SETS}
		do
		    if [ -f $BASE_SETS_DIR/$S ]; then
			echo "=> Unpacking $S"
			tar xfzp $BASE_SETS_DIR/$S -C $ISODIR
		    fi
		done

		if [ "${ENABLE_X11}" = "yes" ]; then
		    for FX in ${X11_SETS}
		    do
			if [ ! -f $X11_SETS_DIR/$FX ]; then
			    showmsg "Can't find $FX, disabling X11."
			    DISABLE_X11=yes
			    break
			fi
		    done

		    if [ "$DISABLE_X11" = "" ]; then
			showmsg "Installing X11 sets"
			for X in ${X11_SETS}
			do
			    if [ -f $X11_SETS_DIR/$X ]; then
				echo "=> Unpacking $X"
				tar xfzp $X11_SETS_DIR/$X -C $ISODIR
			    fi
			done
		    fi
		fi # ENABLE_X11
			
		cp $SHAREDIR/mfs_rcd $ISODIR/etc/rc.d

		# /etc/rc.conf
		showmsg "Installing configuration files"
		sed -e "s,rc_configured=NO,rc_configured=YES,g" \
			$ISODIR/etc/rc.conf > $ISODIR/etc/rc.conf.fixed
		mv $ISODIR/etc/rc.conf.fixed $ISODIR/etc/rc.conf
		touch $ISODIR/etc/fstab

		(						    \
		echo "mfsrc=yes";				    \
		echo "dhclient=yes dhclient_flags=-q";		    \
		echo "wscons=yes";				    \
		echo "hostname=$KERNEL_NAME";			    \
		echo "nfs_client=yes";				    \
		echo "inetd=no";				    \
		echo "ntpdate=yes";				    \
		echo "savecore=no";				    \
		) >> $ISODIR/etc/rc.conf

		# /etc/rc.d/root could umount the mfs directories, 
		# so it's best not to touch them.

		rm $ISODIR/etc/rc.d/root
		cat > $ISODIR/etc/rc.d/root <<_EOF_
#!/bin/sh
#
# \$NetBSD: mklivecd.sh,v 1.1.1.1 2004/02/26 03:58:56 xtraeme Exp $
# 

# PROVIDE: root
# REQUIRE: fsck

. /etc/rc.subr

name="root"
start_cmd="root_start"
stop_cmd=":"

root_start()
{
        rm -f /fastboot
}

load_rc_config \$name
run_rc_command "\$1"
_EOF_
		# Make sure the devices are created before creating
		# the .tbz files.

		showmsg "Creating devices"
		cd $ISODIR/dev && ./MAKEDEV all
		echo
		showmsg "Target base successful"
		showmsg "Base system installed"
		showmsg "Next step: ${progname} chroot"
	;;
	chroot)
		if [ ! -f $ISODIR/.prompt_done ]; then
		    (						    \
		    echo "export PS1=\"$KERNEL_NAME> \"";	    \
		    echo "set -o emacs";			    \
		    ) > $ISODIR/etc/profile
		    touch $ISODIR/.prompt_done
		else
		    showmsg "Prompt already set!"
		fi

		if [ ! -d $ISODIR/usr/pkgsrc ]; then
		    mkdir $ISODIR/usr/pkgsrc
		fi

		if [ ! -f $ISODIR/usr/share/misc/termcap ]; then
		    cp /usr/share/misc/termcap* \
			$ISODIR/usr/share/misc
		fi

		showmsg "Entering into the chroot!"

		if [ -d $PKGSRCDIR ]; then
		    showmsg "Mounting pkgsrc directory."
		    mount_null $PKGSRCDIR $ISODIR/usr/pkgsrc
		else
		    showmsg "Can't find $PKGSRCDIR, disabling it"
		fi

		echo
		chroot $ISODIR /bin/ksh
		echo
		showmsg "Unmounting pkgsrc."

		if [ ! -d $ISODIR/root ]; then
		    showmsg "Target chroot failed!"
		    showmsg "Can't find root directory, exiting."
		    bye 1
		fi

		cd $ISODIR
		cp -f $SHAREDIR/mfs_rcd $ISODIR/etc/rc.d

		SUBST_H="mount_mfs $MNT_HOME_ARGS swap /home"
		SUBST_HT="tar xfjp /stand/mfs_home.tbz -C /"
		SUBST_S="mount_mfs $MNT_PKG_SYSCONFDIR_ARGS swap /$PKG_SYSCONFDIR"
		SUBST_ST="tar xfjp /stand/mfs_pkg_sysconfdir.tbz -C /"

		sed -e "s,@MNT_DEV_ARGS@,$MNT_DEV_ARGS,g" \
		    -e "s,@MNT_ETC_ARGS@,$MNT_ETC_ARGS,g" \
		    -e "s,@MNT_VAR_ARGS@,$MNT_VAR_ARGS,g" \
		    -e "s,@MNT_ROOT_ARGS@,$MNT_ROOT_ARGS,g" \
		    -e "s,@MNT_TMP_ARGS@,$MNT_TMP_ARGS,g" \
		    $ISODIR/etc/rc.d/mfs_rcd > $ISODIR/etc/rc.d/mfs_rcd.in
		mv $ISODIR/etc/rc.d/mfs_rcd.in $ISODIR/etc/rc.d/mfs_rcd
		
		for U in root var dev etc home
		do
		    if [ -d $ISODIR/$U ]; then
			tar cfjp $ISODIR/stand/mfs_$U.tbz $U >/dev/null 2>&1
			showmsg "Creating /stand/mfs_$U.tbz"
		    fi
		done
 
		if [ -d $ISODIR/home ]; then
		    sed -e "s,@HOME@,$SUBST_H," \
			-e "s,@HOMETAR@,$SUBST_HT," \
			$ISODIR/etc/rc.d/mfs_rcd > $ISODIR/etc/rc.d/mfs_rcd.f
			mv $ISODIR/etc/rc.d/mfs_rcd.f $ISODIR/etc/rc.d/mfs_rcd
		else
		    sed -e "s,@HOME@,," -e "s,@HOMETAR@,," \
			$ISODIR/etc/rc.d/mfs_rcd > $ISODIR/etc/rc.d/mfs_rcd.f
		    mv $ISODIR/etc/rc.d/mfs_rcd.f $ISODIR/etc/rc.d/mfs_rcd
		fi
                        
		if [ -d $ISODIR/$PKG_SYSCONFDIR ]; then
		    tar cfjp $ISODIR/stand/mfs_pkg_sysconfdir.tbz \
			$PKG_SYSCONFDIR >/dev/null 2>&1
		    showmsg "Creating /stand/mfs_pkg_sysconfdir.tbz"
		    sed -e "s,@USRPKGETC@,$SUBST_S," \
			-e "s,@USRPKGETCTAR@,$SUBST_ST," \
			$ISODIR/etc/rc.d/mfs_rcd > $ISODIR/etc/rc.d/mfs_rcd.f
		    mv $ISODIR/etc/rc.d/mfs_rcd.f $ISODIR/etc/rc.d/mfs_rcd
		else
		    sed -e "s,@USRPKGETC@,," -e "s,@USRPKGETCTAR@,," \
			$ISODIR/etc/rc.d/mfs_rcd > $ISODIR/etc/rc.d/mfs_rcd.f
		    mv $ISODIR/etc/rc.d/mfs_rcd.f $ISODIR/etc/rc.d/mfs_rcd
		fi

		if [ "${ENABLE_X11}" = "yes" ]; then
		    if [ -f /etc/X11/XF86Config ]; then
			cp /etc/X11/XF86Config $ISODIR/etc/X11
		    fi
		fi

		if [ "${PERSONAL_CONFIG}" = "yes" -a -f $config_dir/$pers_conffile ]; then
		    echo
		    showmsg "Running personal config file"
		    . $config_dir/$pers_conffile
		    showmsg "Done!"
		    echo
		elif [ "${PERSONAL_CONFIG}" = "yes" -a ! -f $config_dir/$pers_conffile ]; then
		    echo
		    showmsg "Can't find personal configuration file, please"
		    showmsg "disable it if you don't want to use it, or otherwise"
		    showmsg "use the example file to see how to create your"
		    showmsg "own custom file."
		    echo
		else
		    continue
		fi
		
		# Make sure mfs_rcd has the right permissions, because
		# it could be critical!.

		chmod -R a+rx $ISODIR/etc/rc.d

		umount $ISODIR/usr/pkgsrc
		rm $ISODIR/.prompt_done
		showmsg "Size: $(du -sh $ISODIR)"
	;;
	clean)
		showmsg "Cleaning WORKDIR: $WORKDIR"
		rm -rf $WORKDIR
		for F in bin dev etc lib libexec mnt rescue \
		    root tmp usr var sbin home
		do
		    if [ -d $ISODIR/$F ]; then
			rm -rf $ISODIR/$F
		    fi
		done
		showmsg "Done"
	;;
	iso)
		if [ ! -f $ISODIR/netbsd ]; then
			showmsg "Target iso failed!"
			showmsg "Can't find NetBSD kernel"
			bye 1
		elif [ ! -f $ISODIR/stand/mfs_etc.tbz ]; then
			showmsg "Target iso failed!"
			showmsg "Can't find mfs_etc.tbz file"
			bye 1
		fi

		echo
		showmsg "Removing not needed directories:"
		for RM in ${REMOVE_DIRS}
                do
                    if [ -d $ISODIR/$RM ]; then
                        echo "=> Removing $RM..."; rm -rf $ISODIR/$RM
		    else
			echo "=> Nonexistent directory: $RM"
		    fi
		done

		sleep 2 # Because I want to see the messages :-)
		
		if [ ! -f $BASEDIR/$IMAGE_NAME.iso ]; then
		    echo
		    showmsg "Creating ISO CD9660 image"
		    $MKISOFS -nobak -b stand/cdlive-boot.fs \
			-o $BASEDIR/$IMAGE_NAME.iso -J -R $ISODIR
		fi

	;;
	burn)
		if [ ! -f $BASEDIR/$IMAGE_NAME.iso ]; then
		    showmsg "Can't find iso image!"
		    bye 1
		fi

		if [ $BLANK_BEFORE_BURN = "yes" ]; then
		    $CDRECORD dev=$CDROM_DEVICE -v blank=fast
		fi
		
		$CDRECORD dev=$CDROM_DEVICE -v $BASEDIR/$IMAGE_NAME.iso
	;;
	esac
	
}

checkconf()
{
    if [ -f $config_file ]; then
	[ `id -u` -ne 0 ] && showmsg "must be run as root" && bye 1
	    do_conf_reset; . $config_file; do_conf
    else
	showmsg "$config_file does not exist"
	bye 1
    fi
}

# =========================================================================== #
#  Main program								      #
# =========================================================================== #

if [ $# -lt 1 ]; then
	usage
fi

case "$1" in
	iso)
		checkconf
		do_cdlive iso
	;;
	kernel)
		do_cdlive kernel
	;;
	base)
		checkconf
		do_cdlive base
	;;
	chroot)
		checkconf
		do_cdlive chroot
	;;
	clean)
		checkconf
		do_cdlive clean
	;;
	config)
		do_conf
	;;
	burn)
		checkconf
		do_cdlive burn
	;;
esac

exit 0 # agur!
