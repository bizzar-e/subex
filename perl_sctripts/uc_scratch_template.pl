

use Data::Dumper;
use ElectricCommander();

$|++;
use Time::HiRes qw(time);   
my $stime = time;
sub gen_salt {
    my $gmark;

    @symbs = ('a'..'z', 'A'..'Z', '0'..'9'); 
    for (my $j = 0; $j < 4; $j++) { $gmark .= $symbs[ int rand scalar @symbs ]; }
    return $gmark;
}
sub ecLogin($) {
    my ($cmdr) = @_;
    my $R = $cmdr->login("admin", "changeme");
    if ("1" ne $R->findvalue('//response/@requestId')) { 
        print "FAIL: ", $R->findnodes_as_string("/"); 
    }
}
sub chkResult($;$) {
  my ($response) = @_;

  print "[DEBUG] response is ", $response, "\n";
  
  if ("1" ne $response->findvalue('//response/@requestId')) {
     die "FAIL: ", $response->findnodes_as_string("/");
  }
}
print "1\n";

my $proj = "tools";
my $proc = "ASD4FF11";
my $step = "test";
open CMD, '<', 'C:\sublime\Data\Packages\User\Meta\tmp\{INPUT}.log' or die $!;
local undef $/; my $cmd = <CMD>; close CMD;
open DBG1, '>', 'C:\sublime\Data\Packages\User\Meta\tmp\{DBG1}.log' or die $!;

my $cmdr = new ElectricCommander->new();

ecLogin($cmdr);

my $scratch_prj_name = 'scratch_prj';

my $salt = gen_salt();
my $scratch_proc_name = "scratch_" . $salt . "_procedure";
my $scratch_step_name = "scratch_" . $salt . "_step";
$ec_resp = $cmdr->createProcedure($scratch_prj_name, $scratch_proc_name,
    {description => "Scratch procedure for ec-perl script"});
$ec_resp = $cmdr->createStep($scratch_prj_name, $scratch_proc_name, $scratch_step_name, 
    {
        description => "Scratch step for ec-perl script",
        command => $cmd,
        shell => 'ec-perl'
    });
$ec_resp = $cmdr->runProcedure($scratch_prj_name,
    {procedureName => $scratch_proc_name});
my $jobId = $ec_resp->findvalue("//response/jobId");

$ec_resp = $cmdr->getJobDetails($jobId);
my $jobName = $ec_resp->findvalue("//job/jobStep/jobName");
my $logFileName = $ec_resp->findvalue("//job/jobStep/logFileName");

my $logpath = 'N:\\' . $jobName . "\\" . $logFileName;
print "\$logpath is $logpath\n\n";
sleep(1);
open LOG , "<" , $logpath or die "Can't open log file on network drive. The error is '$!'"; undef $/; $log = <LOG>; close LOG;
print "--- LOG START ---\n\n";
print $log;
print "\n\n--- LOG END ---\n\n";

print "\nElapsed time: ", sprintf("%3.2f", time - $stime), " s", "\n"; 
print "Done\n";

close DBG1;