# last_job

use ElectricCommander;

$| = 1;

my $cmdr = new ElectricCommander();
my $ec_resp = $cmdr-> getJobs({sortKey=>'start', sortOrder=>'descending', maxResults=>1});

my @jobs = $ec_resp->findnodes("//job");

my $jobId = "";

foreach my $node (@jobs){
    $jobId = $node->findvalue("jobId");
    my $jobName = $node->findvalue("jobName");
    my $procedureName = $node->findvalue("procedureName");
    my $modifyTime = $node->findvalue("modifyTime");

    print "\$jobId = $jobId\n";
    print "\$jobName = $jobName\n";
    print "\$procedureName = $procedureName\n";
    print "\$modifyTime = $modifyTime\n\n";
}


print "last_job $jobId\n";

print "Done\n";