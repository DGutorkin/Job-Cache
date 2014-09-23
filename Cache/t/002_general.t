#!/usr/bin/env perl

use Test::More 'no_plan';

BEGIN {
    use_ok ( 'Job::Cache' );
}

use Job::Cache;

require_ok( 'Job::Cache' );

my $memd = Job::Cache->new(
	host => '127.0.0.1',
	port => '11211',
);

isa_ok( $memd, 'Job::Cache' );

foreach my $method (qw( set get delete ) ) {
    can_ok( $memd, $method );
}

ok ($memd->set('my_key', 'my_value', 6000) eq 1, "\$memd->set() works!");
ok ($memd->get('my_key') eq 'my_value', "\$memd->get() works!");

ok ($memd->get('fake_key') eq undef, '$memd->get() returns undef if key not found ');
cmp_ok ($memd->err(), 'eq', 'Nothing found', '$memd->err returns correct error code if key to get not found');

ok ($memd->delete('my_key') eq 1, "\$memd->delete() works! [DELETED]");
ok ($memd->get('my_key') eq undef, '$memd->get() really deletes key from memcached');

ok ($memd->delete('my_false_key') eq undef, "\$memd->delete() works! [NOT FOUND]");
cmp_ok ($memd->err(), 'eq', 'NOT_FOUND', '$memd->err returns correct error code if key to delete not found');
