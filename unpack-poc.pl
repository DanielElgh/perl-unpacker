#!/usr/bin/env perl
###############################################################################
# Author.: Daniel Elgh
# Date...: March 25, 2023
# License: The MIT License
# Desc...:
#  The intention of this script is for the user to attach a gzip tar archive,
#  to help distribute multiple files from a single source file.
#  After extraction is complete, the script can exec() into another process
#  and continue to run seamlessly.
#  Attach a base64 encoded gzip tarball below the __DATA__ section found at
#  the end of this file. The contents of the tarball will be extracted to the
#  output directory defined in `$OUT_DIR`. If there is an executable file
#  named as per `$EXECUTABLE`, within the archive root, it will be executed
#  after the extraction phase has completed.
#
use utf8;
use warnings;
use strict;
use MIME::Base64;
use FindBin;
use File::Path qw(make_path);
use File::Basename;
use Archive::Tar; # RPM: perl-Archive-Tar
use IO::Zlib;     # RPM: perl-IO-Zlib
my $self = basename($0) =~ s/[^\w]/_/gr;

###############################################################
# These three variables can be changed as per the users liking
our $VERSION    = 'v1.0.0';
our $OUT_DIR   = ".$self-workdir";
our $EXECUTABLE = './main';
###############################################################

chdir $FindBin::Bin;
if (-e $OUT_DIR && ! -d $OUT_DIR) {
    die "pup: '$OUT_DIR' exists but is not a directory\n";
}
make_path $OUT_DIR;
chdir $OUT_DIR
    or die "pup: Unable to change working directory to '$OUT_DIR'\n";

my $data = retrieve_data();
my $fh = new IO::Zlib;
$fh->open(\$data, "rb")
    or die "pup: Unable to open fh to an in-memory scalar for reading\n";

my $tar = Archive::Tar->new();
$tar->extract_archive($fh)
    or die "pup: " . $tar->error() . "\n";
undef $fh;
undef $tar;

if (-e $EXECUTABLE && -x $EXECUTABLE) {
    exec $EXECUTABLE, @ARGV
        or die "pup: Unable to run: $!\n";
}

sub retrieve_data {
    local $/ = undef;
    return decode_base64(<DATA>);
}

############################################################################
# The dummy data below is expected to be replaced:
__DATA__
H4sICNyGH2QAA3RhcgDt1Etv2zAMAOCc/SvYbkAvRewkjn0IdmuB3bfjLoxMx0ItyZCoNvn3o5Pl
MqDbKXsA/GD4IYuUDJh0aP3ixirRbrfnq/j5Wq3q7WJV11XbNPW6aRbVqqplCKpbb2yWE2MEWMQQ
+Ffzfvf+P/XhrswplnvrS/KvMFEci5wI3jB66w9pd35KHK3hXVG4E3z06Ag+QRpsz1CW8PCFI/oD
xYddMUXrGe4/28u0u2/+XqL+9keqd3XZuVNJR3TTSEs+3uIfn2u8qet367/etJf6b6vNum2l/jer
9Vrr/0/4OtgEcqCHHz8B9FZOJhIydbA/wRN6SyM8j4cBOEBHLnhpCPIahvA2R2I0g32VILnfEyAz
mkGCMcGEpzFgNwciJBPtxI/zg0yjoyQx8yKj5IoSJkNkMtvgl0Vx3Zn0nz6P0IcoycyLNCVweWR7
3Wp6hJTNMC/mQpcvA+eF5MYE39tDls1KUiA2S5AGdd6LJLp+rAw4fCGwLCkiwRQi417qQTuXUkop
pZRSSimllFJKKaWUUkoppf59xXf04g3BASgAAA==
