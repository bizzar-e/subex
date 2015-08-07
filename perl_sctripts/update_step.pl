

use Data::Dumper;
use ElectricCommander();

$|++;
use Time::HiRes qw(time);   
my $stime = time;
sub ecLogin($) {
    my ($cmdr) = @_;
    my $R = $cmdr->login("admin", "changeme");
    if ("1" ne $R->findvalue('//response/@requestId')) { 
        print "FAIL: ", $R->findnodes_as_string("/"); 
    }
}
print "2\n";
open CMD, '<', 'C:\sublime\Data\Packages\User\Meta\tmp\{INPUT}.log' or die $!;
local undef $/; my $cmd = <CMD>; close CMD;
open DBG1, '>', 'C:\sublime\Data\Packages\User\Meta\tmp\{DBG1}.log' or die $!;

my $cmdr = new ElectricCommander->new();

ecLogin($cmdr);

my $scratch_prj_name = 'scratch_prj';

my @p = split(' ', $ARGV[1]);

my $proj = $p[0];
my $proc = $p[1];
my $step = $p[2];


$ec_resp = $cmdr->modifyStep($proj, $proc, $step, {command => $cmd});
print $ec_resp->findnodes_as_string("/");

print "\nElapsed time: ", sprintf("%3.2f", time - $stime), " s", "\n"; 
print "Done\n";

close DBG1;