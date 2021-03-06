#! /usr/bin/perl

# This is simple perl script to generate a Unix-style crypted/salted hash from the password input
# The username and hash are sent over via email 
# These can be for the accounts in FreeRADIUS (https://freeradius.org/radiusd/man/rlm_pap.txt)

# These modules are needed to be installed; Below are applicable for Debian Linux
# apt-get install perltermreadline libterm-readline-gnu-perl libterm-readkey-perl libterm-readline-perl-perl libterm-readline-zoid-perl

use strict;
use warnings;
use Term::ReadKey;

my $crypt;
my $debug = 0;
#my $logname = $ENV{ LOGNAME };
#print "\$logname = $logname\n";

# Collect username and password
print "Username: ";
my $logname = <>;
print "Enter password: ";
ReadMode 'noecho';
my $pass1 = <>;
ReadMode 'restore';
ReadMode 'noecho';
print "\nEnter password again: ";
my $pass2 = <>;
ReadMode 'restore';

# Compare password entered are similar
print "\n";
chomp($pass1);
chomp($pass2);

if ($pass1 cmp $pass2) {
    print "\nPassword do not match!\n"; 
} else {         
    print "\nPassword match\n"; 
    $crypt =  crypt($pass1, "salt"); # Note: the salt used is "salt" :)
    print "Username: $logname";
    if ($debug) { print "Password: $pass1\n"; }
    print "Crypt   : $crypt\n";
    # email crypt pass to network.support
    email ($crypt);
}

# email function
# Note: SMTP client services are operational on the machine.
sub email {
    my ($cryptpass)= @_;
    my $username = $logname; 
    my $hostname = `hostname -s`;
    my $to = 'admin@company.com';
    my $from = 'password@company.com';
    my $subject = 'Crypt-password Received';
    my $msg1 = 'Username :      '.$username;
    my $msg2 = 'Crypt-password: '.$cryptpass;
 
    open(MAIL, "|/usr/sbin/sendmail -t");
 
    # Email Header
    print MAIL "To: $to\n";
    print MAIL "From: $from\n";
    print MAIL "Subject: $subject\n\n";
    # Email Body
    print MAIL "$msg1\n";
    print MAIL "$msg2\n";

    close(MAIL);
    print "Email Sent Successfully\n";

}
