#!/usr/bin/perl
my $log_dir = "/linuxlogs";
mkdir $log_dir unless -d $log_dir;

my $config_file    = "/etc/login.defs";
my %configurations = (
    PASS_MAX_DAYS    => "90",
    PASS_MIN_DAYS    => "10",
    PASS_WARN_AGE    => "7",
    ENCRYPT_METHOD   => "sha512",
    LOG_UNKFAIL_ENAB => "no",
    SYSLOG_SU_ENAB   => "yes",
    UID_MIN          => "1000",
    UID_MAX          => "60000",
);

sub check_config_exists {
    ( -e $config_file ) ? return (1) : return (-1);
}

sub check_backup_exists {
    ( -e "$log_dir/login.bak" ) ? return (1) : return (-1);
}

# checks for root permissions
if ( $> != 0 ) {
    print "Run this as root!\n";
    exit(0);
}

# checks if login.defs exists
die "/etc/login.defs doesn't exist!" if check_config_exists() == -1;

# checks if backup is present, and prompt user to be sure if they want to delete the backup
if ( check_backup_exists() == 1 ) {
    print
"We found a backup, running this script again will remove it. \nEnter 'y' to continue: ";
    my $option = <>;
    chomp($option);
    die "Script aborted by user." if option != "y";
}

# initialize file read and write
open my $in, "<", "$config_file" or die "Can't open $config_file!";
open my $out, ">", "$config_file.new"
  or die "Can't write to $config_file.new!";

OUTER:
while (<$in>) {
    # read in line, remove first whitespace, then split along whitespace
    my $line = $_;
    $line =~ s/\s+/ /;
    my @tokenized = split( /\s/, $line );

    # skip over comments
    if (/^[\s+#]/) {
        ;
    }
    else {
        #iterate through every configuration, check if it matches current line
        for ( keys %configurations ) {
            if ( index( $line, $_ ) != -1 ) {

# if configuration matches, set it to the right configuration and remove from list, then continue outer loop
                print
"$_ is currently set to: @tokenized[1]! I'll set that to $configurations{$_}\n";
                print $out "$_	$configurations{$_}\n";
                delete( $configurations{$_} );
                next OUTER;
            }
        }

        #if no configuration set, then just print it out as-is
        print $out $line;
    }
}
for ( keys %configurations ) {

# if we haven't configured a specified configuration, then put it at the end of file
    print
"I couldn't find a configuration for $_ , so I'll set that to $configurations{$_}\n";
    print $out "$_	$configurations{$_}\n";
}
close $out;

`cp $config_file /linuxlogs/login.bak`;
`rm $config_file`;
rename "/etc/login.defs.new", "$config_file";
