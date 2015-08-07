
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


my @p = split(' ', $ARGV[1]);

my $proj = $p[0];
my $proc = $p[1];
my $step = $p[2];

if ($cmd =~ /Cmdr projects tree/) {
	print "Update changes to Cmdr\n";
	@a = split(/\*{2,}/, $cmd);
	print scalar @a, "\n";

	$delete_action = 0;
	$rename_action = 0;
	for my $block (@a) {
		if ($block =~ /Project:\s+(.*)/) {
			$cur_prj = $1;
		}
		
		$cnt = 0;
		while ($block =~ m/(^.*)/gm) {
			my $line = $1;
			if ($line =~ /Procedure:/) { 
				++$cnt;
			}
			if ($line =~ /(^\w)\s+Procedure:\s+(\w+)/) {
				if ($1 eq 'd') { ++$delete_action; }
				if ($1 eq 'r') { ++$rename_action; }
				$proc_project = $cur_prj;
				$proc_numer = $cnt;
				$proc_name = $2;
				$proc_action = $1;

				push(@actions, $proc_project . "!!!" . $proc_numer . "!!!" . $proc_name .
								"!!!" . $proc_action );
			}
		}
	}


	print "\n\n", 'Delete - ', $delete_action, "\n";
	print 'Rename - ', $rename_action, "\n";
	print "All actions to execute: ", scalar @actions, "\n\n";

	for my $item (@actions) {
		my @a = split('!!!', $item);

		$proc_action = $a[3];
		if ($proc_action eq 'd') {
			$proc_project = $a[0]; 
			$proc_name = $a[2];
			push(@ev_act, "\$cmdr->deleteProcedure($proc_project, $proc_name);");
		}
	}
	print "DEBUG\n";
	for (@ev_act) {
		print $_, "\n";
		eval ($_);
	}

	


}
else {
	print "Buffer is empty or not valid!\n Request full project tree\n\n";
	print "Cmdr projects tree\n";
	my $xmlProj = $cmdr->getProjects();

	my @projects=$xmlProj->findnodes("//project");
	foreach my $node (@projects){
	  my $projName=$node->findvalue("projectName");
	  my $projDesc=$node->findvalue("description");
	  next if ($node->findvalue("pluginName"));
	  if ($projDesc ne "") {
	      printf("Project: %s\n\t\t%s\n", $projName, $projDesc);
	    } else {
	      printf("Project: %s\n", $projName);
	    }
	    my $xmlProc=$cmdr->getProcedures($projName);
	    my @procedures=$xmlProc->findnodes("//procedure");
	    foreach my $proc (@procedures) {
	      my $procName=$proc->findvalue("procedureName");
	      printf("\tProcedure: %s\n", $procName);
	    }
	    my $sep = "*"x20;
	    printf("\n$sep\n\n");
	  }
}


print "\nElapsed time: ", sprintf("%3.2f", time - $stime), " s", "\n"; 
print "Done\n";

close DBG1;