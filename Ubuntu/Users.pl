#!/usr/bin/perl
my $log_dir = "/linuxlogs";
`mkdir $log_dir` unless -d $log_dir;

# Returns a list of all users, along with UIDs
sub get_all_users {
    my @users = split /:[^:]*:[^:]*:[^:]*:[^:]*\n/, `getent passwd`;
    return @users;
}

sub get_all_regusers {
    my @users = split /:[^:]*:[^:]*:[^:]*:[^:]*\n/,
      `getent passwd {1000..60000}`;
    return @users;
}

# checks for root permissions
if ( $> != 0 ) {
    print "Run this as root!\n";
    exit(0);
}

# Open log file to write to
open my $log, ">", "/linuxlogs/users.txt"
  or die "Can't write to /linuxlogs/users.txt!";

# Get all users, then print to log file
my @users = get_all_users();
foreach (@users) {
    print $log "$_\n";
}

close $log;
