#!perl
use strict;
use warnings FATAL => 'all';
use Test::More qw(no_plan);
use File::Basename;
use File::Copy;
use File::Path;
use File::Temp qw/tempdir/;
use Cwd;

BEGIN { use_ok "App::FatPacker", "" }

my $keep = $ENV{'FATPACKER_KEEP_TESTDIR'};
my $tempdir = tempdir($keep ? (CLEANUP => 0) : (CLEANUP => 1));
mkpath([<$tempdir/{lib,fatlib}/t/mod>]);

for(<t/mod/*.pm>) {
  copy $_, "$tempdir/lib/$_" or die "copy failed: $!";
}

my $cwd = getcwd;
chdir $tempdir;

my $fp = App::FatPacker->new;
my $temp_fh = File::Temp->new;
select $temp_fh;
$fp->script_command_file;
print "1;\n";
select STDOUT;
close $temp_fh;

# Packed, now try using it:
require $temp_fh;

{
  require t::mod::a;
  no warnings 'once';
  ok $t::mod::a::foo eq 'bar';
}

# moving away from the dir so it could be deleted
chdir $cwd;
