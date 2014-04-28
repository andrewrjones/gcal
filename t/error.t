#!perl

use strict;
use warnings;

use Test::More tests => 4;
use FindBin qw($Bin);

BEGIN { use_ok('App::gcal'); }
require_ok('App::gcal');

my $err_from_ics = App::gcal::_process_file("$Bin/../dist.ini");
isa_ok( $err_from_ics, 'Class::ReturnValue' );
like( $err_from_ics->error_message, qr/error parsing/ );
