
$arg1 = 'c:\sublime\Data\Packages\User\Meta\tmp\tmp1.dat';
open BUF, "<", $arg1 or die $!; undef $/; $buf = <BUF>; close BUF;
@res = split("---", $buf);
substr($res[2], 0, 1) = "";
open INPUT, '>', 'C:\sublime\Data\Packages\User\Meta\tmp\{INPUT}.log' or die $!;
print INPUT $res[2]; close INPUT;
@a = split(" ", $res[0]);
$res_cmd = '';

if ($a[0] eq 'getJobs') {
	$res_cmd = 'c:\sublime\Data\Packages\User\Meta\pl\eced_getJobs1.pl';
}

if ($a[0] eq 'getProjects') {
	$res_cmd = 'D:\_source\Polarion\Cmdr\LR_lab_1_(xml)_mod_1.pl';
}

my $skip = 0;
if ($a[0] eq 'getStep' && $a[1] eq '*') {
	$skip = 1;
	my @s = split('_', $a[2]);
	my $proc_name = 'scratch_' . $s[1] . '_procedure';
	my $step_name = 'scratch_' . $s[1] . '_step';

	my $prop_data = "scratch_prj" . " " . $proc_name . " " . $step_name;

	open PROP1, '>', 'C:\sublime\Data\Packages\User\Meta\tmp\last_step.prop' or die $!;
	print PROP1 $prop_data; close PROP1;
	$res_cmd = 'C:\sublime\Data\Packages\User\Meta\pl\eced_getStep1.pl ' . "scratch_prj" . " " . $proc_name . " " . $step_name;
}
if ($a[0] eq 'getStep' && $skip == 0) {
	$res_cmd = 'C:\sublime\Data\Packages\User\Meta\pl\eced_getStep1.pl ' . $a[1] . " " . $a[2] . " " . $a[3];
}

if ($a[0] eq 'getSteps') {
	$res_cmd = 'C:\sublime\Data\Packages\User\Meta\pl\eced_getSteps1.pl ' . $a[1] . " " . $a[2] . " " . $a[3];
}

if ($a[0] eq 'update') {

	open PROP1, '<', 'C:\sublime\Data\Packages\User\Meta\tmp\last_step.prop' or die $!;
	local undef $/; my $prop1 = <PROP1>; close PROP1;

	my @p = split(' ', $prop1);
	$res_cmd = 'C:\sublime\Data\Packages\User\Meta\pl\update_step.pl ' . $p[0] . " " . $p[1] . " " . $p[2];
}

if ($a[0] eq 'dsl') {
	$res_cmd = 'C:\sublime\Data\Packages\User\Meta\pl\run_dsl.pl ' . $a[1] . " " . $a[2] . " " . $a[3];
}

if ($a[0] eq 'live_tree-inbuf') {
	$res_cmd = 'C:\sublime\Data\Packages\User\Meta\pl\live_tree.pl ' . $a[1] . " " . $a[2] . " " . $a[3];
}

if ($a[0] eq 'ec-perl') {
	$res_cmd = 'C:\sublime\Data\Packages\User\Meta\pl\uc_scratch_template.pl ' . 
	$a[1] . " " .
	$res[2] . " " . 
	$a[3];
}
if ($a[0] eq 'gen') {
	$res_cmd = 'C:\sublime\Data\Packages\User\Meta\pl\dsl_gen_1.pl ' . $a[1] . " " . $a[2] . " " . $a[3];
}

if ($a[0] eq 'split-inbuf') {
	if ($a[0] eq 'split-inbuf') {
		$a[1] = "split";
	}
	$res_cmd = 'C:\sublime\Data\Packages\User\Meta\pl\dsl_gen_1.pl ' . $a[1] . " " . $a[2] . " " . $a[3];
}

if ($a[0] eq 'print_cmd-inbuf') {
	if ($a[0] eq 'print_cmd-inbuf') {
		$a[1] = "print_cmd";
	}
	$res_cmd = 'C:\sublime\Data\Packages\User\Meta\pl\dsl_gen_1.pl ' . $a[1] . " " . $a[2] . " " . $a[3];
}
@n = split(" ", $res_cmd);
if (!defined $n[1]) { $res_cmd .= " " . "nil"; }
if (!defined $n[2]) { $res_cmd .= " " . "nil"; }
if (!defined $n[3]) { $res_cmd .= " " . "nil"; }

print $res_cmd;