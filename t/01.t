#!perl

use strict;
use warnings;

use Test::More tests => 5;
use FindBin qw($Bin);

BEGIN { use_ok('App::gcal'); }
require_ok('App::gcal');

my $err_from_ics = App::gcal::_process_file("$Bin/../dist.ini");
isa_ok( $err_from_ics, 'Class::ReturnValue' );
like( $err_from_ics->error_message, qr/error parsing/ );

my $testfile_simple = "$Bin/resources/simple.ics";    # version 2, one event
my $cal_from_ics = App::gcal::_process_file($testfile_simple);
isa_ok( $cal_from_ics, 'Data::ICal' );
