#!/usr/bin/perl
sub check_UFW_installed {

    # gets information on ufw
    my @dpkg = `dpkg -s ufw`;
    chomp @dpkg;

    # return 1 if ufw is installed, return -1 if not installed
    index( @dpkg[1], "installed" ) != -1 ? return (1) : return (-1);
}

sub get_UFW_status {
    # get ufw status
    my @status = `ufw status`;

    # return 1 if ufw is active, return -1 if inactive
    index( @status[0], "inactive" ) != -1 ? return (-1) : return (1);
}

sub get_UFW_rules {
    # get ufw status
    my @rules = `ufw status`;
    # remove the first two lines, which only state if ufw is enabled
    splice @rules, 0, 2;
    # return only the rules
    return @rules;
}

# checks for root permissions
if ( $> != 0 ) {
    print "Run this as root!\n";
    exit(0);
}

my $installed_state = check_UFW_installed();

# if ufw is not installed, try installing
if ( $installed_state == -1 ) {
    print "UFW is not installed!\nInstalling UFW...\n";

    `apt-get update -y`;
    `apt-get install ufw -y`;

    # if ufw was unable to be installed, exit
    die "Unable to install UFW..." if check_UFW_installed() == -1;

    print "UFW successfully installed!\n\n";
}

my $active_status = get_UFW_status();
# if ufw is inactive, try enabling
if($active_status == -1){
    print "UFW is not enabled!\nEnabling UFW...\n";

    `ufw enable`;

    # if ufw was unable to be activated, exit
    die "Unable to enable UFW..." if get_UFW_status() == -1;

    print "UFW is now enabled!\n\n";
}

my @rules = get_UFW_rules();
# if there are rules, print them
if(scalar @rules > 0){
    print "Currently enabled rules:\n";
    print @rules;
}
# otherwise, print that there are no rules, and show how to add rules
else { print "There are no rules currently!\nAdd some rules using 'ufw allow'\n";}
