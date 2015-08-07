use ElectricCommander;

$| = 1;

# get an EC object
my $ec = ElectricCommander->new();
$ec->abortOnError(0);

print "$[/myJobId]\n";


print $result, "Done.\n";

1;