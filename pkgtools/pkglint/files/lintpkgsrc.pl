#!@PREFIX@/bin/perl

# $NetBSD: lintpkgsrc.pl,v 1.66.2.1 2002/06/23 18:57:47 jlam Exp $

# Written by David Brownlee <abs@netbsd.org>.
#
# Caveats:
#	The 'Makefile parsing' algorithym used to obtain package versions
#	and DEPENDS information is geared towards speed rather than perfection,
#	though it has got somewhat better over time, it only parses the
#	simplest Makefile conditionals. (a == b, no && etc).
#
# TODO: Handle fun DEPENDS like avifile-devel with
#			{qt2-designer>=2.2.4,qt2-designer-kde>=2.3.1nb1} 

$^W = 1;
use locale;
use strict;
use Getopt::Std;
use File::Find;
use Cwd;
my(	$pkglist,		# list of Pkg packages
	$default_vars,		# Set for Makefiles, inc PACKAGES & PKGSRCDIR
	%opt,			# Command line options
	%vuln,			# vulnerability data
	@matched_prebuiltpackages,# List of obsolete prebuilt package paths
	@prebuilt_pkgdirs,	# Use to follow symlinks in prebuilt pkgdirs
	%prebuilt_pkgdir_cache,	# To avoid symlink loops in prebuilt_pkgdirs
	);

$ENV{PATH} .= ':/usr/sbin';

if (! getopts('BDK:LM:OP:RSVdg:hilmopru', \%opt) || $opt{h} ||
	! ( defined($opt{d}) || defined($opt{g}) || defined($opt{i}) ||
	    defined($opt{l}) || defined($opt{m}) || defined($opt{o}) ||
	    defined($opt{p}) || defined($opt{r}) || defined($opt{u}) ||
	    defined($opt{B}) || defined($opt{D}) || defined($opt{R}) ||
	    defined($opt{O}) || defined($opt{S}) || defined($opt{V}) ))
    { usage_and_exit(); }
$| = 1;

get_default_makefile_vars(); # $default_vars

if ($opt{D} && @ARGV)
    {
    foreach my $file (@ARGV)
	{
	if ( -d $file)
	    { $file .= "/Makefile"; }
	if (! -f $file)
	    { fail("No such file: $file"); }
	my($pkgname, $vars);
	($pkgname, $vars) = parse_makefile_pkgsrc($file);
	$pkgname ||= 'UNDEFINED';
	print "$file -> $pkgname\n";
	foreach my $varname (sort keys %{$vars})
	    { print "\t$varname = $vars->{$varname}\n"; }
	if ($opt{d})
	    { pkgsrc_check_depends(); }
	}
    exit;
    }

# main
    {
    my($pkglint_flags, $pkgsrcdir, $pkgdistdir);

    $pkgsrcdir = $default_vars->{PKGSRCDIR};
    $pkgdistdir = $default_vars->{DISTDIR};
    $pkglint_flags = '-v';

    if ($opt{r} && !$opt{o} && !$opt{m} && !$opt{p})
	{ $opt{o} = $opt{m} = $opt{p} = 1; }
    if ($opt{o} || $opt{m})
	{
	my(@baddist);

	@baddist = scan_pkgsrc_distfiles_vs_distinfo($pkgsrcdir, $pkgdistdir,
							$opt{o}, $opt{m});
	if ($opt{r})
	    {
	    safe_chdir("$pkgdistdir");
	    verbose("Unlinking 'bad' distfiles\n");
	    foreach my $distfile (@baddist)
		{ unlink($distfile); }
	    }
	}

    # List BROKEN packages
    if ($opt{B})
	{
	scan_pkgsrc_makefiles($pkgsrcdir);
	foreach my $pkgver ($pkglist->pkgver)
	    {
	    $pkgver->var('BROKEN') || next;
	    print $pkgver->pkgname.': '.$pkgver->var('BROKEN')."\n";
	    }
	}

    # List obsolete or NO_BIN_ON_FTP/RESTRICTED prebuilt packages
    #
    if ($opt{p} || $opt{O} || $opt{R} || $opt{V})
	{
	if ($opt{V})
	    {
	    my($vuln) = "$pkgdistdir/vulnerabilities";
	    if (! open(VULN, $vuln))
		{ fail("Unable to open '$vuln': $!"); }
	    while (<VULN>)
		{
		s/#.*//;
		if ( /([^*?[]+)(<|>|<=|>=)(\d\S+)/ ) 
		    {
		    my($pkg, $cmp, $ver) = ($1, $2, $3);
		    push(@{$vuln{$pkg}},"$cmp $ver");
		    }
		}
	    close(VULN);
	    }
	if ($opt{p} || $opt{O} || $opt{R})
	    { scan_pkgsrc_makefiles($pkgsrcdir); }
	@prebuilt_pkgdirs = ($default_vars->{PACKAGES});
	%prebuilt_pkgdir_cache = ();
	while (@prebuilt_pkgdirs)
	    { find(\&check_prebuilt_packages, shift @prebuilt_pkgdirs); }
	if ($opt{r})
	    {
	    verbose("Unlinking listed prebuiltpackages\n");
	    foreach my $pkgfile (@matched_prebuiltpackages)
		{ unlink($pkgfile); }
	    }
	}

    if ($opt{S})
	{
	my(%in_subdir);

	foreach my $cat (list_pkgsrc_categories($pkgsrcdir))
	    {
	    my($vars) = parse_makefile_vars("$pkgsrcdir/$cat/Makefile");
	    if (! $vars->{SUBDIR})
		{ print "Warning - no SUBDIR for $cat\n"; next; }
	    foreach my $pkgdir (split(/\s+/, $vars->{SUBDIR}))
		{ $in_subdir{"$cat/$pkgdir"} = 1; }
	    }

	scan_pkgsrc_makefiles($pkgsrcdir);
	foreach my $pkgver ($pkglist->pkgver)
	    {
	    if (!defined $in_subdir{$pkgver->var('dir')})
		{ print $pkgver->var('dir').": Not in SUBDIR\n"; }
	    }
	}

    if ($opt{g})
	{
	my($tmpfile);

	$tmpfile = "$opt{g}.tmp.$$";

	scan_pkgsrc_makefiles($pkgsrcdir);
	if (!open(TABLE, ">$tmpfile"))
	    { fail("Unable to write '$tmpfile': $!"); }
	foreach my $pkgver ($pkglist->pkgver)
	    {
	    print TABLE $pkgver->pkg."\t".$pkgver->var('dir')."\t".
							$pkgver->ver."\n";
	    }
	if (!close(TABLE))
	    { fail("Error while writing '$tmpfile': $!"); }
	if (!rename($tmpfile, $opt{g}))
	    { fail("Error in rename('$tmpfile','$opt{g}'): $!"); }
	}

    if ($opt{d})
	{
	scan_pkgsrc_makefiles($pkgsrcdir);
	pkgsrc_check_depends();
	}
    if ($opt{i} || $opt{u})
	{
	my(@pkgs, @update);

	@pkgs = list_installed_packages();
	scan_pkgsrc_makefiles($pkgsrcdir);

	foreach my $pkgname (sort @pkgs)
	    {
	    if ($_ = invalid_version($pkgname))
		{
		print $_;
		if ($pkgname =~ /^([^*?[]+)-([\d*?[].*)/) 
		    {
		    foreach my $pkgver ($pkglist->pkgver($1))
			{
			$pkgver->var('dir') =~ /-current/ && next;
			push(@update, $pkgver);
			last;
			}
		    }
		}
	    }

	if ($opt{u})
	    {
	    print "\nREQUIRED details for packages that could be updated:\n";
	    foreach my $pkgver (@update)
		{
		print $pkgver->pkg.':';
		if (open(PKGINFO, 'pkg_info -R '.$pkgver->pkg.'|'))
		    {
		    my($list);
		    while (<PKGINFO>)
			{
			if (/Required by:/)
			    { $list = 1; }
			elsif ($list)
			    {
			    chomp;
			    s/-\d.*//;
			    print " $_";
			    }
			}
		    close(PKGINFO);
		    }
		print "\n";
		}
	    print "\nRunning 'make fetch-list | sh' for each package:\n";
	    foreach my $pkgver (@update)
		{
		my($pkgdir);

		$pkgdir = $pkgver->var('dir');
		if (!defined($pkgdir))
		    { fail('Unable to determine '.$pkgver->pkg.' directory'); }
		print "$pkgsrcdir/$pkgdir\n";
		safe_chdir("$pkgsrcdir/$pkgdir");
		system('make fetch-list | sh');
		}
	    }
	}
    if ($opt{l})
	{ pkglint_all_pkgsrc($pkgsrcdir, $pkglint_flags); }
    }
exit;

# Could speed up by building a cache of package names to paths, then processing
# each package name once against the tests.
sub check_prebuilt_packages
    {
    if ($_ eq 'distfiles' || $_ eq 'pkgsrc') # Skip these subdirs if present
	{ $File::Find::prune = 1; }
    elsif (/(.+)-(\d.*)\.tgz$/)
	{
	my($pkg, $ver);
	($pkg, $ver) = ($1, $2);

	if ($opt{V} && $vuln{$pkg})
	    {
	    foreach my $chk (@{$vuln{$pkg}})
		{
		my($test, $matchver) = split(' ',$chk);
		if (deweycmp($ver, $test, $matchver))
		    {
		    print "$File::Find::dir/$_\n";
		    push(@matched_prebuiltpackages, "$File::Find::dir/$_");
		    last;
		    }
		}
	    }

	my($pkgs);
	if ($pkgs = $pkglist->pkgs($pkg))
	    {
	    my($pkgver) = $pkgs->pkgver($ver);
	    if (!defined $pkgver)
		{
		if ($opt{p})
		    {
		    print "$File::Find::dir/$_\n";
		    push(@matched_prebuiltpackages, "$File::Find::dir/$_");
		    }
		# Pick probably the last version
		$pkgver = $pkgs->latestver;
		}
	    if ($opt{R} && $pkgver->var('RESTRICTED'))
		{
		print "$File::Find::dir/$_\n";
		push(@matched_prebuiltpackages, "$File::Find::dir/$_");
		}
	    if ($opt{O} && $pkgver->var('OSVERSION_SPECIFIC'))
		{
		print "$File::Find::dir/$_\n";
		push(@matched_prebuiltpackages, "$File::Find::dir/$_");
		}
	    }

	}
    elsif (-d $_)
	{
	if ($prebuilt_pkgdir_cache{"$File::Find::dir/$_"})
	    { $File::Find::prune = 1; return; }
	$prebuilt_pkgdir_cache{"$File::Find::dir/$_"} = 1;
	if (-l $_)
	    {
	    my($dest) = readlink($_);
	    if (substr($dest, 0, 1) ne '/')
		{ $dest = "$File::Find::dir/$dest"; }
	    if (!$prebuilt_pkgdir_cache{$dest})
		{ push(@prebuilt_pkgdirs, $dest); }
	    }
	}
    }

# Dewey decimal verson number matching - or thereabouts
# Also handles 'nb<N>' suffix (checked iff values otherwise identical)
#
sub deweycmp
    {
    my($match, $test, $val) = @_;
    my($cmp, $match_nb, $val_nb);

    $match_nb = $val_nb = 0;
    if ($match =~ /(.*)nb(.*)/)	# Handle nb<N> suffix
	{
	$match = $1;
	$match_nb = $2;
	}

    if ($val =~ /(.*)nb(.*)/)		# Handle nb<N> suffix 
	{
	$val = $1;
	$val_nb = $2;
	}

    $cmp = deweycmp_extract($match, $val);

    if (!$cmp)			# Iff otherwise identical, check nb suffix
	{ $cmp = deweycmp_extract($match_nb, $val_nb); }

    eval "$cmp $test 0";
    }

sub convert_to_standard_dewey
    {
    # According to the current implementation in pkg_install/lib/str.c
    # as of 2002/06/02, '_' before a number, '.', and 'pl' get treated as 0,
    # while 'rc' gets treated as -1; other characters are converted to lower
    # case and then to a number: a->1, b->2, c->3, etc. Numbers stay the same.
    # 'nb' is a special case that's already been handled when we are here.
    my($elem, $underscore, @temp);
    foreach $elem (@_) {
	if ($elem =~ /\d+/) {
	    push(@temp, $elem);
	}
	elsif ($elem =~ /^pl$/ or $elem =~ /^\.$/) {
	    push(@temp, 0);
	}
	elsif ($elem =~ /^_$/) {
	    push(@temp, 0);
	}
	elsif ($elem =~ /^rc$/) {
	    push(@temp, -1);
	}
	else {
	    push(@temp, 0);
	    push(@temp, ord($elem)-ord("a")+1);
	}
    }
    @temp;
}

sub deweycmp_extract
    {
    my($match, $val) = @_;
    my($cmp, @matchlist, @vallist);

    @matchlist = convert_to_standard_dewey(split(/(\D+)/, lc($match)));
    @vallist = convert_to_standard_dewey(split(/(\D+)/, lc($val)));
    $cmp = 0;
    while( ! $cmp && (@matchlist || @vallist))
	{
	if (!@matchlist)
	    { $cmp = -1; }
	elsif (!@vallist)
	    { $cmp = 1; }
	else
	    { $cmp = (shift @matchlist <=> shift @vallist) }
	}
    $cmp;
    }

sub fail
    { print STDERR @_, "\n"; exit(3); }

sub get_default_makefile_vars
    {
    chomp($_ = `uname -srm`);
    ( $default_vars->{OPSYS},
	$default_vars->{OS_VERSION},
	$default_vars->{MACHINE} ) = (split);

    # Handle systems without uname -p  (NetBSD pre 1.4)
    chomp($default_vars->{MACHINE_ARCH} = `uname -p 2>/dev/null`);
    if (! $default_vars->{MACHINE_ARCH} &&
				$default_vars->{OS_VERSION} eq 'NetBSD')
	{ chomp($default_vars->{MACHINE_ARCH} = `sysctl -n hw.machine_arch`);}
    if (! $default_vars->{MACHINE_ARCH})
	{ $default_vars->{MACHINE_ARCH} = $default_vars->{MACHINE}; }

    $default_vars->{OBJECT_FMT} = 'x';
    $default_vars->{LOWER_OPSYS} = lc($default_vars->{OPSYS});

    if ($opt{P})
	{ $default_vars->{PKGSRCDIR} = $opt{P}; }
    else
	{ $default_vars->{PKGSRCDIR} = '/usr/pkgsrc'; }

    my($vars);
    if (-f '/etc/mk.conf' && ($vars = parse_makefile_vars('/etc/mk.conf')))
	{
	foreach my $var (keys %{$vars})
	    { $default_vars->{$var} = $vars->{$var}; }
	}

    if ($opt{P})
	{ $default_vars->{PKGSRCDIR} = $opt{P}; }

    if ($opt{M})
	{ $default_vars->{DISTDIR} = $opt{M}; }
    $default_vars->{DISTDIR} ||= $default_vars->{PKGSRCDIR}.'/distfiles';

    if ($opt{K})
	{ $default_vars->{PACKAGES} = $opt{K}; }

    # Extract some variables from bsd.pkg.mk
    my($mkvars);
    $mkvars = parse_makefile_vars("$default_vars->{PKGSRCDIR}/mk/bsd.pkg.mk");
    foreach my $varname (keys %{$mkvars})
	{
	if ($varname =~ /_REQD$/ || $varname eq 'EXTRACT_SUFX')
	    { $default_vars->{$varname} = $mkvars->{$varname}; }
	}

    $default_vars->{PACKAGES} ||= $default_vars->{PKGSRCDIR}.'/packages';
    }

# Determine if a package version is current. If not, report correct version
# if found
#
sub invalid_version
    {
    my($pkgmatch) = @_;
    my($fail, $ok);
    my(@pkgmatches, @todo);

    @todo = ($pkgmatch);

    # We handle {} here, everything else in package_globmatch
    while ($pkgmatch = shift @todo)
	{
	if ($pkgmatch =~ /(.*){([^{}]+)}(.*)/)
	    {
	    foreach (split(',', $2))
		{ push(@todo, "$1$_$3"); }
	    }
	else
	    { push (@pkgmatches, $pkgmatch); }
	}

    foreach $pkgmatch (@pkgmatches)
	{
	my($pkg, $badver) = package_globmatch($pkgmatch);

	if (defined($badver))
	    {
	    my($pkgs);
	    if ($pkgs = $pkglist->pkgs($pkg))
		{
		$fail .= "Version mismatch: '$pkg' $badver vs ".
				    join(',', $pkgs->versions)."\n";
		}
	    else
		{ $fail .= "Unknown package: '$pkg' version $badver\n"; }
	    }
	else
	    { $ok = 1; } # If we find one match, don't bitch about others
	}
    $ok && ($fail = undef);
    $fail;
    }

# List (recursive) non directory contents of specified directory
#
sub listdir
    {
    my($base, $dir) = @_;
    my($thisdir);
    my(@list, @thislist);

    $thisdir = $base;
    if (defined($dir))
	{
	$thisdir .= "/$dir";
	$dir .= '/';
	}
    else
	{ $dir = ''; }
    opendir(DIR, $thisdir) || fail("Unable to opendir($thisdir): $!");
    @thislist = grep(substr($_, 0, 1) ne '.' && $_ ne 'CVS', readdir(DIR));
    closedir(DIR);
    foreach my $entry (@thislist)
	{
	if (-d "$thisdir/$entry")
	    { push(@list, listdir($base, "$dir$entry")); }
	else
	    { push(@list, "$dir$entry"); }
	}
    @list;
    }

# Use pkg_info to list installed packages
#
sub list_installed_packages
    {
    my(@pkgs);
    my $pkgver;

    open(PKG_INFO, 'pkg_info -a|') || fail("Unable to run pkg_info: $!");
    while ( <PKG_INFO> )
	{ push(@pkgs, (split)[0]); }
    close(PKG_INFO);

    # pkg_install is not in the pkg_info -a output, add it manually
    $pkgver = `pkg_info -V 2>/dev/null || echo 20010302`;
    chomp($pkgver);
    push(@pkgs, "pkg_install-$pkgver");
    @pkgs;
    }

# List top level pkgsrc categories
#
sub list_pkgsrc_categories
    {
    my($pkgsrcdir) = @_;
    my(@categories);

    opendir(BASE, $pkgsrcdir) || die("Unable to opendir($pkgsrcdir): $!");
    @categories = grep(substr($_, 0, 1) ne '.' && $_ ne 'CVS' &&
				-f "$pkgsrcdir/$_/Makefile", readdir(BASE));
    closedir(BASE);
    @categories;
    }

# For a given category, list potentially valid pkgdirs
#
sub list_pkgsrc_pkgdirs
    {
    my($pkgsrcdir, $cat) = @_;
    my(@pkgdirs);

    if (! opendir(CAT, "$pkgsrcdir/$cat"))
	{ die("Unable to opendir($pkgsrcdir/cat): $!"); }
    @pkgdirs = sort grep($_ ne 'Makefile' && $_ ne 'pkg' && $_ ne 'CVS' &&
					substr($_, 0, 1) ne '.', readdir(CAT));
    close(CAT);
    @pkgdirs;
    }

sub glob2regex
    {
    my($glob) = @_;
    my(@chars, $in_alt);
    my($regex);

    @chars = split(//, $glob);
    while (defined($_ = shift @chars))
	{
	if ($_ eq '*')
	    { $regex .= '.*'; }
	elsif ($_ eq '?')
	    { $regex .= '.'; }
	elsif ($_ eq '+')
	    { $regex .= '.'; }
	elsif ($_ eq '\\+')
	    { $regex .= $_ . shift @chars; }
	elsif ($_ eq '.' || $_ eq '|' )
	    { $regex .= quotemeta; }
	elsif ($_ eq '{' )
	    { $regex .= '('; ++$in_alt; }
	elsif ($_ eq '}' )
	    {
	    if (!$in_alt)		# Error
		{ return undef; }
	    $regex .= ')';
	    --$in_alt;
	    }
	elsif ($_ eq ','  && $in_alt)
	    { $regex .= '|'; }
	else
	    { $regex .= $_; }
	}
    if ($in_alt)			# Error
	{ return undef; }
    if ($regex eq $glob)
	{ return(''); }
    if ($opt{D})
	{ print "glob2regex: $glob -> $regex\n"; }
    '^'.$regex.'$';
    }

# Perform some (reasonable) subset of 'pkg_info -e' / glob(3)
# Returns (sometimes best guess at) package name,
# and either 'problem version' or undef if all OK
#
sub package_globmatch
    {
    my($pkgmatch) = @_;
    my($matchpkgname, $matchver, $regex);

    if ($pkgmatch =~ /^([^*?[]+)(<|>|<=|>=|-)(\d[^*?[{]*)$/) 
	{						# (package)(cmp)(dewey)
	my($test, @pkgvers);

	($matchpkgname, $test, $matchver) = ($1, $2, $3);

	if ($test ne '-' && $matchver !~ /^[\d.]+(pl\d+|p\d+|rc\d+|nb\d+|)*$/ )
	    { $matchver = "invalid-dewey($test$matchver)"; }
	elsif (@pkgvers = $pkglist->pkgver($matchpkgname))
	    {
	    foreach my $pkgver (@pkgvers)
		{
		if ($test eq '-')
		    {
		    if ($pkgver->ver eq $matchver)
			{ $matchver = undef; last }
		    }
		else
		    {
		    if (deweycmp($pkgver->ver, $test, $matchver))
			{ $matchver = undef; last }
		    }
		}
	    if ($matchver && $test ne '-')
		{ $matchver = "$test$matchver"; }
	    }
	}
    elsif ( $pkgmatch =~ /^([^[]+)-([\d*?{[].*)$/ )	# }
	{					 	# (package)-(globver)
	my(@pkgnames);

	($matchpkgname, $matchver) = ($1, $2);

	if (defined $pkglist->pkgs($matchpkgname))
	    { push(@pkgnames, $matchpkgname); }
	elsif ($regex = glob2regex($matchpkgname))
	    {
	    foreach my $pkg ($pkglist->pkgs)
		{ ($pkg->pkg() =~ /$regex/) && push(@pkgnames, $pkg->pkg()); }
	    }

	# Try to convert $matchver into regex version
	#
	$regex = glob2regex($matchver);

	foreach my $pkg (@pkgnames)
	    {
	    if (defined $pkglist->pkgver($pkg, $matchver))
		{ return($matchver); }

	    if ($regex)
		{
		foreach my $ver ($pkglist->pkgs($pkg)->versions)
		    {
		    if( $ver =~ /$regex/ )
			{ $matchver = undef; last }
		    }
		}
	    $matchver || last;
	    }

	# last ditch attempt to handle the whole DEPENDS as a glob
	#
	if ($matchver && ($regex = glob2regex($pkgmatch)))	# (large-glob)
	    {
	    foreach my $pkgver ($pkglist->pkgver)
		{
		if( $pkgver->pkgname =~ /$regex/ )
		    { $matchver = undef; last }
		}
	    }
	}
    else
	{ ($matchpkgname, $matchver) = ($pkgmatch, 'missing'); }
    ($matchpkgname, $matchver);
    }

# Parse a pkgsrc package makefile and return the pkgname and set variables
#
sub parse_makefile_pkgsrc
    {
    my($file) = @_;
    my($pkgname, $vars);

    $vars = parse_makefile_vars($file);

    if (!$vars) # Missing Makefile
	{ return(undef); }

    if (defined $vars->{PKGNAME})
	{ $pkgname = $vars->{PKGNAME}; }
    elsif (defined $vars->{DISTNAME})
	{ $pkgname = $vars->{DISTNAME}; }
    if (defined $pkgname)
	{
	if (defined $vars->{PKGREVISION}
	    and not $vars->{PKGREVISION} =~ /^\s*$/ )
	    {
	    $pkgname .= "nb";
	    $pkgname .= $vars->{PKGREVISION};
	    }
	if ( $pkgname =~ /\$/ )
	    { print "\rBogus: $pkgname (from $file)\n"; }
	elsif ($pkgname =~ /(.*)-(\d.*)/)
	    {
	    if ($pkglist)
		{
		my($pkgver) = $pkglist->add($1, $2);

		foreach my $var (qw(DEPENDS RESTRICTED OSVERSION_SPECIFIC BROKEN))
		    { $pkgver->var($var, $vars->{$var}); }
		if (defined $vars->{NO_BIN_ON_FTP})
		    { $pkgver->var('RESTRICTED', 'NO_BIN_ON_FTP'); }
		if ($file =~ m:([^/]+/[^/]+)/Makefile$:)
		    { $pkgver->var('dir', $1); }
		else
		    { $pkgver->var('dir', 'unknown'); }
		}
	    }
	else
	    { print "Cannot extract $pkgname version ($file)\n"; }
	return($pkgname, $vars);
	}
    else
	{ return(undef); }
    }

# Extract variable assignments from Makefile
# Much unpalatable magic to avoid having to use make (all for speed)
#
sub parse_makefile_vars
    {
    my($file) = @_;
    my($pkgname, %vars, $plus, $value, @data,
       %incfiles,
       @if_false); # 0:true 1:false 2:nested-false&nomore-elsif


    if (! open(FILE, $file))
	{ return(undef); }
    @data = map {chomp; $_} <FILE>;
    close(FILE);

    # Some Makefiles depend on these being set
    if ($file eq '/etc/mk.conf')
	{ $vars{LINTPKGSRC} = 'YES'; }
    else
	{ %vars = %{$default_vars}; }
    $vars{BSD_PKG_MK} = 'YES';

    if ($file =~ m#(.*)/#)
	{ $vars{'.CURDIR'} = $1; }
    else
	{ $vars{'.CURDIR'} = getcwd; }
    if ($opt{L})
	{ print "$file\n"; }

    while( defined($_ = shift(@data)) )
	{
	s/\s*#.*//;

	# Continuation lines
	#
	while ( substr($_, -1) eq "\\" )
	    { substr($_, -2) = shift @data; }

	# Conditionals
	#
	if (m#^\.if(|def|ndef)\s+(.*)#)
	    {
	    my($type, $false);

	    $type = $1;
	    if ($if_false[$#if_false])
		{ push(@if_false, 2); }
	    elsif( $type eq '')	# Straight if
		{ push(@if_false, parse_eval_make_false($2, \%vars)); }
	    else
		{
		$false = ! defined($vars{parse_expand_vars($2, \%vars)});
		if ( $type eq 'ndef' )
		    { $false = ! $false ; }
		push(@if_false, $false ?1 :0);
		}
	    debug("$file: .if$type (@if_false)\n");
	    next;
	    }
	if (m#^\.elif\s+(.*)# && @if_false)
	    {
	    if ($if_false[$#if_false] == 0)
		{ $if_false[$#if_false] = 2; }
	    elsif ($if_false[$#if_false] == 1 &&
		    ! parse_eval_make_false($1, \%vars) )
		{ $if_false[$#if_false] = 0; }
	    debug("$file: .elif (@if_false)\n");
	    next;
	    }
	if (m#^\.else\b# && @if_false)
	    {
	    $if_false[$#if_false] = $if_false[$#if_false] == 1?0:1;
	    debug("$file: .else (@if_false)\n");
	    next;
	    }
	if (m#^\.endif\b#)
	    {
	    pop(@if_false);
	    debug("$file: .endif (@if_false)\n");
	    next;
	    }

        $if_false[$#if_false] && next;

	# Included files (just unshift onto @data)
	#
	if (m#^\.include\s+"([^"]+)"#)
	    {
	    $_ = $1;
	    if (! m#/mk/#)
		{
		my($incfile) = ($_);

		# Expand any simple vars in $incfile
		#
		$incfile = parse_expand_vars($incfile, \%vars);

		# Handle relative path incfile
		#
		if (substr($incfile, 0, 1) ne '/')
		    { $incfile = "$vars{'.CURDIR'}/$incfile"; }
		if (!$incfiles{$incfile})
		    {
		    $incfiles{$incfile} = 1;
		    if (!open(FILE, $incfile))
			{ verbose("Cannot open '$incfile' (from $file): $!\n");}
		    else
			{
			unshift(@data, map {chomp; $_} <FILE>);
			close(FILE);
			}
		    }
		}
	    next;
	    }

	if (/^ *([-\w\.]+)\s*([:+?]?)=\s*(.*)/)
	    {
	    my($key);
	    $key = $1;
	    $plus = $2;
	    $value = $3;
	    if ($plus eq ':')
		{ $vars{$key} = parse_expand_vars($value, \%vars); }
	    elsif ($plus eq '+' && defined $vars{$key} )
		{ $vars{$key} .= " $value"; }
	    elsif ($plus ne '?' || !defined $vars{$key} )
		{ $vars{$key} = $value; }
	    } 
	}

    debug("$file: expand\n");

    # Handle variable substitutions  FRED = a-${JIM:S/-/-b-/}
    #
    my($loop);
    for ($loop = 1 ; $loop ;)
	{
	$loop = 0;
	foreach my $key (keys %vars)
	    {
	    if ( index($vars{$key}, '$') == -1 )
		{ next; }
	    $_ = parse_expand_vars($vars{$key}, \%vars);
	    if ($_ ne $vars{$key})
		{
		$vars{$key} = $_;
		$loop = 1;
		}
	    elsif ($vars{$key} =~ m#\${(\w+):([CS]([^{}])[^{}\3]+\3[^{}\3]*\3[g1]*(|:[^{}]+))}#)
		{
		my($left, $subvar, $right) = ($`, $1, $');
		my(@patterns) = split(':', $2);
		my($result);

		$result = $vars{$subvar};
		$result ||= '';

		# If $vars{$subvar} contains a $ skip it on this pass.
		# Hopefully it will get substituted and we can catch it
		# next time around.
		if (index($result, '${') != -1)
		    { next; }

		debug("$file: substitutelist $key ($result) $subvar (@patterns)\n");
		foreach (@patterns)
		    {
		    if (! m#([CS])/([^/]+)/([^/]*)/([1g]*)#)
			{ next; }

		    my($how, $from, $to, $global) = ($1, $2, $3, $4);

		    debug("$file: substituteglob $subvar, $how, $from, $to, $global\n");
		    if ($how eq 'S') # Limited substitution - keep ^ and $
			{ $from =~ s/([?.{}\]\[*+])/\\$1/g; }
		    $to =~ s/\\(\d)/\$$1/g; # Change \1 etc to $1

		    my($notfirst);
		    if ($global =~ s/1//)
			{ ($from, $notfirst) = split('\s', $from, 2); }

		    debug("$file: substituteperl $subvar, $how, $from, $to\n");
		    eval "\$result =~ s/$from/$to/$global";
		    if (defined $notfirst)
			{ $result .= " $notfirst"; }
		    }
		$vars{$key} = $left . $result . $right;
		$loop = 1;
		}
	    }
	}
    \%vars;
    }

sub parse_expand_vars
    {
    my($line, $vars) = @_;

    while ( $line =~ /\$\{([-\w.]+)\}/ )
	{
	if (defined(${$vars}{$1}))
	    { $line = $`.${$vars}{$1}.$'; }
	else
	    { $line = $`.'UNDEFINED'.$'; }
	}
    $line;
    }

sub parse_expand_vars_dumb
    {
    my($line, $vars) = @_;

    while ( $line =~ /\$\{([-\w.]+)\}/ )
	{
	if (defined(${$vars}{$1}))
	    { $line = $`.${$vars}{$1}.$'; }
	else
	    { $line = $`.'UNDEFINED'.$'; }
	}
    $line;
    }

sub parse_eval_make_false
    {
    my($line, $vars) = @_;
    my($false, $test);

    $false = 0;
    $test = parse_expand_vars_dumb($line, $vars);
    # XXX This is _so_ wrong - need to parse this correctly
    $test =~ s/""/\r/g;
    $test =~ s/"//g;
    $test =~ s/\r/""/g;

    debug("conditional: $test\n");
    # XXX Could do something with target and empty
    while ( $test =~ /(target|empty|make|defined|exists)\s*\(([^()]+)\)/ )
	{
	if ($1 eq 'exists')
	    { $_ = (-e $2) ?1 :0; }
	elsif( $1 eq 'defined')
	    { $_ = (defined($${vars}{$2}) ?1 :0); }
	else
	    { $_ = 0; }
	$test =~ s/$1\s*\([^()]+\)/$_/;
	}
    while ( $test =~ /([^\s()]+)\s+(!=|==)\s+([^\s()]+)/ )
	{
	if ($2 eq '==')
	    { $_ = ($1 eq $3) ?1 :0; }
	else
	    { $_ = ($1 ne $3) ?1 :0; }
	$test =~ s/[^\s()]+\s+(!=|==)\s+[^\s()]+/$_/;
	}
    if ($test !~ /[^<>\d()\s&|.]/ )
	{
	$false = eval "($test)?0:1";
	if (!defined $false)
	    { fail("Eval failed $line - $test"); }
	debug("conditional: evaluated to ".($false?0:1)."\n");
	}
    else
	{
	$false = 0;
	debug("conditional: defaulting to 0\n");
	}
    $false;
    }

# Run pkglint on every pkgsrc entry
#
sub pkglint_all_pkgsrc
    {
    my($pkgsrcdir, $pkglint_flags) = @_;
    my(@categories, @output);

    @categories = list_pkgsrc_categories($pkgsrcdir);
    foreach my $cat ( sort @categories )
	{
	safe_chdir("$pkgsrcdir/$cat");
	foreach my $pkgdir (list_pkgsrc_pkgdirs($pkgsrcdir, $cat))
	    {
	    if (-f "$pkgdir/Makefile")
		{
		if (!open(PKGLINT, "cd $pkgdir ; pkglint $pkglint_flags|"))
		    { fail("Unable to run pkglint: $!"); }
		@output = grep(!/^OK:/ &&
			     !/^WARN: be sure to cleanup .*work.* before/ &&
			     !/^WARN: is it a new package/ &&
			     !/^\d+ fatal errors and \d+ warnings found/
			     , <PKGLINT> );
		close(PKGLINT);
		if (@output)
		    { print "===> $cat/$pkgdir\n", @output, "\n"; }
		}
	    }
	}
    }

# chdir() || fail()
#
sub safe_chdir
    {
    my($dir) = @_;

    if (! chdir($dir))
	{ fail("Unable to chdir($dir): $!"); }
    }

# Generate pkgname->category/pkg mapping, optionally check DEPENDS
#
sub scan_pkgsrc_makefiles
    {
    my($pkgsrcdir, $check_depends) = @_;
    my(@categories);

    if ($pkglist) # Already done
	{ return; }
    $pkglist = new PkgList;
    @categories = list_pkgsrc_categories($pkgsrcdir);
    verbose("Scanning pkgsrc Makefiles: ");
    if (!$opt{L})
	{ verbose('_'x@categories."\b"x@categories); }
    else
	{ verbose("\n"); }

    foreach my $cat ( sort @categories )
	{
	foreach my $pkgdir (list_pkgsrc_pkgdirs($pkgsrcdir, $cat))
	    {
	    my($pkg, $vars) =
		    parse_makefile_pkgsrc("$pkgsrcdir/$cat/$pkgdir/Makefile");
	    }
	if (!$opt{L})
	    { verbose('.'); }
	}

    if (!$opt{L})
	{
	my ($len);
	$_ = $pkglist->numpkgver().' packages';
	$len = @categories - length($_);
	verbose("\b"x@categories, $_, ' 'x$len, "\b"x$len, "\n");
	}
    }

# Cross reference all depends
#
sub pkgsrc_check_depends
    {
    foreach my $pkgver ($pkglist->pkgver)
	{
	my($err, $msg);
	defined $pkgver->var('DEPENDS') || next;
	foreach my $depend (split(" ", $pkgver->var('DEPENDS')))
	    {
	    $depend =~ s/:.*// || next;
	    if (($msg = invalid_version($depend)))
		{
		if (!defined($err))
		    { print $pkgver->pkgname." DEPENDS errors:\n"; }
		$err = 1;
		$msg =~ s/(\n)(.)/$1\t$2/g;
		print "\t$msg";
		}
	    }
	}
    }

# Extract all distinfo entries, then verify contents of distfiles
#
sub scan_pkgsrc_distfiles_vs_distinfo
    {
    my($pkgsrcdir, $pkgdistdir, $check_unref, $check_distinfo) = @_;
    my(@categories);
    my(%distfiles, %sumfiles, @distwarn, $numpkg);
    my(%bad_distfiles);

    @categories = list_pkgsrc_categories($pkgsrcdir);

    verbose("Scanning pkgsrc distinfo: ".'_'x@categories."\b"x@categories);
    $numpkg = 0;
    foreach my $cat (sort @categories)
	{
	foreach my $pkgdir (list_pkgsrc_pkgdirs($pkgsrcdir, $cat))
	    {
	    if (open(DISTINFO, "$pkgsrcdir/$cat/$pkgdir/distinfo"))
		{
		++$numpkg;
		while( <DISTINFO> )
		    {
		    if (m/^(\w+) ?\(([^\)]+)\) = (\S+)/)
			{
			if ($2 =~ /^patch-[a-z0-9]+$/)
			    { next; }
			if (!defined $distfiles{$2})
			    {
			    $distfiles{$2}{sumtype} = $1;
			    $distfiles{$2}{sum} = $3;
			    $distfiles{$2}{path} = "$cat/$pkgdir";
			    }
			elsif ($distfiles{$2}{sumtype} eq $1 &&
				$distfiles{$2}{sum} ne $3)
			    {
			    push(@distwarn, "checksum mismatch between '$1' ".
			    "in $cat/$pkgdir and $distfiles{$2}{path}\n");
			    }
			}
		    }
		close(DISTINFO);
		}
	    }
	verbose('.');
	}
    verbose(" ($numpkg packages)\n");

    # Do not mark the vulnerabilities file as unknown
    $distfiles{vulnerabilities} = { path => 'vulnerabilities',
				      sum => 'IGNORE'};

    foreach my $file (listdir("$pkgdistdir"))
	{
	my($dist);
	if (!defined($dist = $distfiles{$file}))
	    { $bad_distfiles{$file} = 1; }
	else
	    {
	    if ($dist->{sum} ne 'IGNORE')
		{ push(@{$sumfiles{$dist->{sumtype}}}, $file); }
	    }
	}

    if ($check_unref && %bad_distfiles)
	{
	verbose(scalar(keys %bad_distfiles),
			" unreferenced file(s) in '$pkgdistdir':\n");
	print join("\n", sort keys %bad_distfiles), "\n";
	}

    if ($check_distinfo)
	{
	if (@distwarn)
	    { verbose(@distwarn); }
	verbose("checksum mismatches\n");
	safe_chdir("$pkgdistdir");
	foreach my $sum (keys %sumfiles)
	    {
	    if ($sum eq 'Size')
		{
		foreach (@{$sumfiles{$sum}})
		    {
		    if (! -f $_ || -S $_ != $distfiles{$_}{sum})
			{
			print $_, " (Size)\n";
			$bad_distfiles{$_} = 1;
			}
		    }
		next;
		}
	    open(DIGEST, "digest $sum @{$sumfiles{$sum}}|") ||
						fail("Run digest: $!");
	    while (<DIGEST>)
		{
		if (m/^$sum ?\(([^\)]+)\) = (\S+)/)
		    {
		    if ($distfiles{$1}{sum} ne $2)
			{
			print $1, " ($sum)\n";
			$bad_distfiles{$1} = 1;
			}
		    }
		}
	    close(DIGEST);
	    }
	}
    (sort keys %bad_distfiles);
    }

# Remember to update manual page when modifying option list
#
sub usage_and_exit
    {
    print "Usage: lintpkgsrc [opts] [makefiles]
opts:
  -h : This help.	 [see lintpkgsrc(1) for more information]

Installed package options:		Distfile options:
  -i : Check version against pkgsrc	  -m : List distinfo mismatches
  -u : As -i + fetch dist (may change)	  -o : List obsolete (no distinfo)

Prebuilt package options:		Makefile options:
  -p : List old/obsolete		  -B : List packages marked as 'BROKEN'
  -O : List OSVERSION_SPECIFIC		  -d : Check 'DEPENDS' up to date
  -R : List NO_BIN_ON_FTP/RESTRICTED	  -S : List packages not in 'SUBDIRS'
  -V : List known vulnerabilities

Misc:
  -g file : Generate 'pkgname pkgdir pkgver' map in file
  -l	  : Pkglint all packages
  -r	  : Remove bad files (Without -m -o -p or -V implies all, can use -R)

Modifiers:
  -K path : Set PACKAGES basedir (default PKGSRCDIR/packages)
  -M path : Set DISTDIR		 (default PKGSRCDIR/distfiles)
  -P path : Set PKGSRCDIR	 (default /usr/pkgsrc)
  -D      : Debug makefile and glob parsing
  -L      : List each Makefile when scanned
";
    exit;
    }

sub verbose
    {
    if (-t STDERR)
	{ print STDERR @_; }
    }

sub debug
    {
    ($opt{D}) && print STDERR 'DEBUG: ', @_;
    }

# PkgList is the master list of all packages in pkgsrc.
#
package PkgList;

sub add
    {
    my $self = shift;

    if (!$self->pkgs($_[0]))
	{ $self->{_pkgs}{$_[0]} = new Pkgs $_[0]; }
    $self->pkgs($_[0])->add(@_);
    }

sub new
    {
    my $class = shift;
    my $self = {};
    bless $self, $class;
    return $self;
    }

sub numpkgver
    {
    my $self = shift;
    scalar($self->pkgver);
    }

sub pkgver
    {
    my $self = shift;

    if (@_ == 0)
	{
	my(@list);
	foreach my $pkg ($self->pkgs)
	    { push(@list, $pkg->pkgver); }
	return (@list);
	}
    if (defined $self->{_pkgs}{$_[0]})
	{
	return (@_>1)?$self->{_pkgs}{$_[0]}->pkgver($_[1])
		     :$self->{_pkgs}{$_[0]}->pkgver();
	}
    return;
    }

sub pkgs
    {
    my $self = shift;
    if(@_)
	{ return $self->{_pkgs}{$_[0]} }
    else
	{ return (sort {$a->pkg cmp $b->pkg} values %{$self->{_pkgs}}); }
    return;
    }

# Pkgs is all versions of a given package (eg: apache-1.x and apache-2.x)
#
package Pkgs;

sub add
    {
    my $self = shift;
    $self->{_pkgver}{$_[1]} = new PkgVer @_;
    }

sub new
    {
    my $class = shift;
    my $self = {};
    bless $self, $class;
    $self->{_pkg} = $_[0];
    return $self;
    }

sub versions
    {
    my $self = shift;
    return sort {$b cmp $a} keys %{$self->{_pkgver}};
    }

sub pkg
    {
    my $self = shift;
    $self->{_pkg};
    }

sub pkgver
    {
    my $self = shift;
    if (@_)
	{
	if ($self->{_pkgver}{$_[0]})
	    { return ($self->{_pkgver}{$_[0]}) }
	return;
	}
    return sort {$b->ver() cmp $a->ver()} values %{$self->{_pkgver}};
    }

sub latestver
    {
    my $self = shift;
    ($self->pkgver())[0];
    }

# PkgVer is a unique package+version
#
package PkgVer;

sub new
    {
    my $class = shift;
    my $self = {};
    bless $self, $class;
    $self->{_pkg} = $1;
    $self->{_ver} = $2;
    return $self;
    }

sub pkgname
    {
    my $self = shift;
    $self->pkg.'-'.$self->ver;
    }

sub pkg
    {
    my $self = shift;
    $self->{_pkg};
    }

sub var
    {
    my $self = shift;
    my($key, $val) = @_;
    (defined $val)  ? ($self->{$key} = $val)
		    : $self->{$key};
    }

sub ver
    {
    my $self = shift;
    $self->{_ver};
    }
