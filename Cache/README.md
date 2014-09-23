#  Job::Cache

Job::Cache is the simple class for memcached, which provides 3 basic methods: set, get and delete.
This module use Storable as the default serialization method and doesn't provide any compression for data.

# Usage
```Perl
  use Job::Cache;
  my $memd = Job::Cache->new(
    host => '127.0.0.1',        # this is default values, you can omit them
    port => '11211',            # default port for memcached
  );
```
Than you can set, get and delete data:
```Perl
    $memd->set('key', 'xyz');
```

Or you can also use client :
```Code
[mdn:~/Documents/Job/Cache/scripts]$ ./job_cache.pl
Usage: ./job_cache.pl <command> [parameters]
Command might be:
     set <key> <value> - to store data in memcached
     get <key> - to get data from memcached
     delete <key> - to delete data in memcached
This client assume that memcached is running on 127.0.0.1:11211
```

At the very least you should be able to use this set of instructions
to install the module...

perl Makefile.PL
make
make test
make install