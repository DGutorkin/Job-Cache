# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 2;

BEGIN { use_ok( 'Job::Cache' ); }

my $object = Job::Cache->new ();
isa_ok ($object, 'Job::Cache');


