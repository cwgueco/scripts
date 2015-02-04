#!/usr/bin/perl -w
#Updated
use Getopt::Long;

# no nonsense
no warnings 'uninitialized';

my $DEBUG = 0;
my ( $optinttype, $optstartint, $optendint, $optsource, $optoutput );
my @configcommands;
my ( $line, $iface, $start, $end );

# Input Options
if ( $ARGV[0] eq "" ) { &usage(); }

GetOptions(
    't=s'  => \$optinttype,
    's=s'  => \$optstartint,
    'e=s'  => \$optendint,
    'i=s'  => \$optsource,    
    'o=s'  => \$optoutput,
    'v'    => \$DEBUG
    )
or &usage(); 

print "Inttype: $optinttype\n" if $DEBUG;
print "Start  : $optstartint\n" if $DEBUG;
print "End    : $optendint\n" if $DEBUG;
print "Input  : $optsource\n" if $DEBUG;
print "Output : $optoutput\n" if $DEBUG;


if ( $optsource ) {
    print "DEBUG: Loading input configuration\n" if $DEBUG;
    &loadfile();

    print "DEBUG: Contents of Input file\n" if $DEBUG;
    foreach $line (@configcommands)
    {
        print $line if $DEBUG;
    }
}

if ( $optinttype ) {
    $iface = "";
    if ( $optinttype =~ /G/ ) {
       #print "GigabitEthernet\n";
       $iface = "GigabitEthernet";
    }
   
    if ( $optinttype =~ /F/ ) {
        #print "FastEthernet\n";
        $iface = "FastEthernet";
    }
   
    if ( $optinttype =~ /X/ ) {
        #print "Ten-GigabitEthernet\n";   
        $iface = "Ten-GigabitEthernet";
    }
    
    if ( $optinttype =~ /B/ ) {
        #print "Bridge-Aggregation\n";   
        $iface = "Bridge-Aggregation";
    }
}

 
if ( $optstartint ) {
    # $start = number after last /
    # $end  = number after last /
    my @iface_start = split(/\//, $optstartint);
    my @iface_end = split(/\//, $optendint);      
   
    #print $iface_start[2];
    #print $iface_end[2];
   
    $start = $iface_start[2];
    $end = $iface_end[2];
    print "#### Configuration Start: ####\n";
    do {
        print "interface $iface$iface_start[0]\/$iface_start[1]\/$start\n";
        foreach $line (@configcommands)
        {  if ( $line !~ /#/ ) { print $line; }
        }
        print "#\n";
        $start++;
    } while ( $start <= $end );
    print "#### Configuration End: ####\n";
}

sub loadfile {
    open( my $SOURCE, '<', "$optsource") or die "Can't open $optsource";
    @configcommands = undef;
    
    print "DEBUG: Opening file $optsource\n" if $DEBUG;
    @configcommands = <$SOURCE>;

    close $SOURCE;
}

sub usage {
    print <<USAGE;
Program: HP Comware Interface Config Generator
Generate configuration commands for range of interfaces for HP Comware network devices

    Usage: genconfig [options]
      -t (F/G/X) Interface type(F=FastEthernet, G=GigabitEthernet, X=Ten-GigaEthernet)
      -s <start> Starting interface number
      -e <end>   Ending interface number
      -i  file   Input configuration command
      -o  file   Output file for generated config (defaults to screen)
      -v         Verbose output 
USAGE
    exit;
}
