package Job::Cache;

use Modern::Perl;
use IO::Socket::INET;
use Storable qw(nfreeze thaw);

=head1 NAME

Job::Cache - Memcached client class written for D.Simonov

=head1 SYNOPSIS

  use Job::Cache;
  my $memd = Job::Cache->new(
    host => '127.0.0.1',        # this is default values, you can omit them
    port => '11211',            # default port for memcached
  )



=head1 DESCRIPTION

Job::Cache is the simple class for memcached, which provides 3 basic methods: set, get and delete.
This module use Storable as the default serialization method and doesn't provide any compression for data.

=cut 

BEGIN {
    use Exporter ();
    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
    $VERSION     = '0.01';
    @ISA         = qw(Exporter);
    #Give a hoot don't pollute, do not export more than needed by default
    @EXPORT      = qw();
    @EXPORT_OK   = qw();
    %EXPORT_TAGS = ();
}

=head2 new - constructor method

my $memd = Job::Cache->new();

=cut

use constant F_STORABLE => 1;

sub new {
    my $class = shift;

    my %self = ();
    %self = %$class if ref $class;

    $class = ref $class || $class;
    %self = (%self, @_);

    my $self = \%self;

    $self->{host} //= '127.0.0.1';
    $self->{port} //= '11211';

    $self->{socket} = new IO::Socket::INET( PeerHost => $self->{host}, PeerPort => $self->{port}, Proto => 'tcp',) 
        or die "Looks like you don't have memcached on $self->{host}:$self->{port} - $!\n";

    bless $self, $class;
    return $self if $self->{socket};
}

=head2 set - store data in memcached

$memd->set('key', 'value', [timeout])

Default timeout is 3600.

Returns true if data stored successful. 

=cut

sub set {
    my $self = shift;
    my ($key, $value, $timeout) = @_;

    $timeout //= 3600;
    my $flag = '0';

    unless ($key or $value) {
        $self->err('Not enougth arguments (key/value expected)');
        return undef;
    }

    my $socket = $self->{socket};
 
    if (ref $value) {
        # we have to copy ref data and serialize it before sending to memcached
        $value = Storable::nfreeze($value);
        $flag |= F_STORABLE;

    }

    my $data_length = length($value);
    my $command = "set $key $flag $timeout $data_length\r\n$value\r\n";
    print $socket "$command";

    my $ret;
    while ( my $data = <$socket>) {
        $ret .= $data;
        if ($data =~ /(?:STORED|EXISTS)\r\n$/) {
            last;
        }
        elsif ($data =~ /(?:NOT_STORED|NOT_FOUND|ERROR)\r\n$/) {
            $self->err("$data");
            return undef;
        }
    }
    chop $ret; chop $ret;
    return $ret;
}

=head2 get - get the data from memcached by key

$memd->get('key')

Returns list of values (strings) stored under this key

=cut

sub get {
    my $self = shift;
    my $key = shift;

    $self->err('Expected key as argument to get') unless $key;

    my $socket = $self->{socket};
    print $socket "get $key\r\n";

    my $ret;
    while ( my $data = <$socket>) {
        $ret .= $data;
        if ($data =~ /(?:OK|END)\r\n$/) {
            last;
        } elsif ($data =~ /(?:ERROR)\r\n$/) {
            $self->err("$data");
            return undef;
        }
    }

    my @data = split (/\r\n/, $ret);    # @data consist of 3 parts: response line with information about the key, data and "END" word

    if ($data[0] =~ /VALUE\s\w+\s1\s/) {
        # deserialization if flag eq 1
        $data[1] = Storable::thaw($data[1]);
    } elsif ($data[0] !~ /VALUE\s\w+\s/) {; # if nothig found
        $self->err('Nothing found');
        return undef;
    }
    return $data[1];

}

=head2 delete - delete data in memcached by key

$memd->delete('key')

Returns 'DELETED' if data removed successful. 

=cut

sub delete {
    my $self = shift;
    my $key = shift;

    return 'Expected key as argument to delete' unless $key;

    my $socket = $self->{socket};
    print $socket "delete $key\r\n";

    my $ret;
    while ( my $data = <$socket>) {
        $ret .= $data;
        if ($data =~ /(?:DELETED)\r\n$/) {
            last;
        }
        elsif ($data =~ /(?:NOT_FOUND|ERROR)\r\n$/) {
            chop $data; chop $data;
            $self->err("$data");
            return undef;
        }
    }
    chop $ret; chop $ret;
    return $ret;
}

=head2 err - error handling getter/setter

$memd->err([error text])

Set error message and return undef or get error message.

=cut

sub err {
    my ($self, $errstr) = @_;

    if ($errstr) {
        $self->{error} = $errstr;
    } else {
        return $self->{error};
    }
    
}

=head1 SUPPORT

=head1 AUTHOR

    Dmitry Gutorkin
    DGutorkin@gmail.com

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.


=head1 SEE ALSO

perl(1).

https://github.com/memcached/memcached/blob/master/doc/protocol.txt

=cut

#################### main pod documentation end ###################


1;
# The preceding line will help the module return a true value

