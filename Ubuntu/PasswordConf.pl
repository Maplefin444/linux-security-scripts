#!/usr/bin/perl
sub check_Config_Exists {
    ( -e "/etc/login.defs" ) ? return (1) : return (-1);
}

# checks for root permissions
if ( $> != 0 ) {
    print "Run this as root!\n";
    exit(0);
}

# checks if login.defs exists
die "/etc/login.defs doesn't exist!" if check_Config_Exists() == -1;

# initialize file read and write
open my $in,  "<", "/etc/login.defs"     or die "Can't open /etc/login.defs!";
open my $out, ">", "/etc/login.defs.new" or die "Can't open /etc/login.defs!";
while (<$in>) {
    my @tokenized = split(/\s/,$_);
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
    else { print $out $_; }
}
close $out;

`rm /etc/login.defs`;
rename "/etc/login.defs.new", "/etc/login.defs";
