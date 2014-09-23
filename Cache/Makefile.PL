

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'Job::Cache',
    VERSION_FROM => 'lib/Job/Cache.pm', # finds \$VERSION
    AUTHOR       => 'Dmitry Gutorkin (DGutorkin@gmail.com)',
    ABSTRACT     => 'Memcached client class written for D.Simonov',
    PREREQ_PM    => {
                     'Test::Simple' => 0.44,
                     'Modern::Perl' => 0,
                     'IO::Socket::INET' => 0,
                     'Storable' => 0,
                     'Test::More' => 0,
                    },
);
