#!/usr/bin/perl
use FindBin;
my $log_dir = "/linuxlogs";
mkdir $log_dir unless -d $log_dir;

# checks for root permissions
if ( $> != 0 ) {
    print "Run this as root!\n";
    exit(0);
}

# Making a backup of the sysctl config
`cp /etc/sysctl.conf /linuxlogs/sysctl.bak`;
`rm /etc/sysctl.conf`;

# Copying the pre-configured file
`cp -f $FindBin::Bin/sysctl.conf /etc/sysctl.conf`;

# Applying changes
`sysctl -p`
