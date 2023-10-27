#!/usr/bin/perl
use FindBin;
my $log_dir = "/linuxlogs";
mkdir $log_dir unless -d $log_dir;
my $default_pass = "EpicGamer!123";

# checks for root permissions
if ( $> != 0 ) {
    print "Run this as root!\n";
    exit(0);
}

# Open log file to write to
open my $log, ">", "/linuxlogs/users.txt"
  or die "Can't write to /linuxlogs/users.txt!";

# get user inputted file
my $userfile = $ARGV[0];
if ( not defined $userfile ) {
    die
"Please provide a file to read the users from. It must be in this directory.";
}

# get all users on the system
while ( ( $name, $passwd, $uid, $gid, $quota, $comment, $gcos, $dir, $shell ) =
    getpwent() )
{
    chomp $name;

    # log user
    print $log "$name       $uid\n";

    # check they are a regular user
    if ( $uid >= 1000 and $uid < 65534 ) {

        # get user list
        open my $list, "<", "$FindBin::Bin/$userfile"
          or die "Can't find $FindBin::Bin/$userfile!";
        my $good = 0;

        # check if user is allowed
        while (<$list>) {
            chomp $_;
            if ( $name eq $_ ) {
                print "User $name has been located, and is allowed.\n";
                $good = 1;
                break;
            }
        }

        # if user is disallowed, delete user
        if ( $good == 0 ) {
            print
              "User $name has been located, and is NOT allowed, removing... \n";
            `userdel $name`;
        }
        close $list;
    }
}
close $log;

# get list of users
open my $list, "<", "$FindBin::Bin/$userfile"
  or die "Can't find $FindBin::Bin/$userfile!";

# iterate through list of users, and check if they exist
while (<$list>) {
    chomp $_;
    my $uid = getpwnam($_);
    if ( not defined $uid ) {

        # add user if does not exist
        print "User $_ was not found, but is required. Adding...\n";
        `useradd -p $default_pass $_`;
    }
}
close $list;

