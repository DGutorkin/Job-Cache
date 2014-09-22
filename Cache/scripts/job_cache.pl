#!/usr/bin/env perl
# console client for memcached powered by Job::Cache module

use Modern::Perl;
use lib::abs("../lib");
use Job::Cache;
 
if (!$ARGV[0]) {
die <<EOF;
Usage: $0 <command> [parameters]
Command might be:
\t set <key> <value> - to store data in memcached
\t get <key> - to get data from memcached
\t delete <key> - to delete data in memcached
This client assume that memcached is running on 127.0.0.1:11211
EOF
}

my ($command, $key, $value) = @ARGV;
my $memd = Job::Cache->new( host => 'domsireni.com' );
if ($command eq 'set' and defined $key and defined $value) {
    $memd->set($key, $value);
}
elsif ($command eq 'get' and defined $key) {
    say $memd->get($key);
}
elsif ($command eq 'delete' and defined $key) {
    $memd->delete($key);
}