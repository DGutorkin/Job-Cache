#!/usr/bin/env perl

use Test::More 'no_plan';

BEGIN {
    use_ok ( 'Job::Cache' );
}

use Job::Cache;

require_ok( 'Job::Cache' );

my $memd = Job::Cache->new({
	host => '127.0.0.1',
	port => '11211',
});

isa_ok( $memd, 'Job::Cache' );

foreach my $method (qw( set get delete ) ) {
    can_ok( $memd, $method );
}

ok ($memd->set('my_key', 'my_value', 6000) eq 1, "\$memd->set() works!");
ok ($memd->get('my_key') eq 'my_value', "\$memd->get() works!");
ok ($memd->delete('my_key') eq 1, "\$memd->delete() works! [DELETED]");
ok ($memd->delete('my_false_key') eq 0, "\$memd->delete() works! [NOT FOUND]");


cmp_ok($memd->delete(), 'eq', 'Expected key as argument to delete', '$memd->delete() returns error if no args provided');
cmp_ok($memd->get(), 'eq', 'Expected key as argument to get', '$memd->get() returns error if no args provided');
