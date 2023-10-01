#!/usr/bin/perl
my $log_dir = "/linuxlogs";
mkdir $log_dir unless -d $log_dir;
sub check_config_exists {
    ( -e "/etc/login.defs" ) ? return (1) : return (-1);
}

# checks for root permissions
if ( $> != 0 ) {
    print "Run this as root!\n";
    exit(0);
}

# checks if login.defs exists
die "/etc/login.defs doesn't exist!" if check_config_exists() == -1;

# initialize file read and write
open my $in,  "<", "/etc/login.defs"     or die "Can't open /etc/login.defs!";
open my $out, ">", "/etc/login.defs.new" or die "Can't write to /etc/login.defs.new!";
while (<$in>) {
    $_ =~ s/\s+/ /;
    my @tokenized = split( /\s/, $_ );

    # skip over comments
    if (/^[\s+#]/) {
        print $out $_;
    }

    # password maximum days
    elsif ( index( $_, "PASS_MAX_DAYS" ) != -1 ) {
        print "PASS_MAX_DAYS is currently set to: @tokenized[1]\n";
        print $out "PASS_MAX_DAYS	90\n";
    }

    # password minimum days
    elsif ( index( $_, "PASS_MIN_DAYS" ) != -1 ) {
        print "PASS_MIN_DAYS is currently set to: @tokenized[1]\n";
        print $out "PASS_MIN_DAYS	10\n";
    }

    # password warn age
    elsif ( index( $_, "PASS_WARN_AGE" ) != -1 ) {
        print "PASS_WARN_AGE is currently set to: @tokenized[1]\n";
        print $out "PASS_WARN_AGE	7\n";
    }

    # encryption method
    elsif ( index( $_, "ENCRYPT_METHOD" ) != -1 ) {
        print "ENCRYPT_METHOD is currently set to: @tokenized[1]\n";
        print $out "ENCRYPT_METHOD	SHA512\n";
    }
    elsif ( index( $_, "LOG_UNKFAIL_ENAB" ) != -1 ) {
        print "LOG_UNKFAIL_ENAB is currently set to: @tokenized[1]\n";
        print $out "LOG_UNKFAIL_ENAB	no\n";
    }
    elsif ( index( $_, "SYSLOG_SU_ENAB" ) != -1 ) {
        print "SYSLOG_SU_ENAB is currently set to: @tokenized[1]\n";
        print $out "SYSLOG_SU_ENAB		yes\n";
    }
    # uids
    elsif ( index( $_, "UID_MIN" ) != -1 ) {
        print "UID_MIN is currently set to: @tokenized[1]\n";
        print $out "UID_MIN		1000\n";
    }
    elsif ( index( $_, "UID_MAX" ) != -1 ) {
        print "UID_MAX is currently set to: @tokenized[1]\n";
        print $out "UID_MAX		1000\n";
    }
    else { print $out $_; }
}
close $out;

`cp /etc/login.defs /linuxlogs/login.bak`;
`rm /etc/login.defs`;
rename "/etc/login.defs.new", "/etc/login.defs";
