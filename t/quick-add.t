#!perl

use strict;
use warnings;

use Test::More tests => 12;
use FindBin qw($Bin);

BEGIN { use_ok('App::gcal'); }
require_ok('App::gcal');

# test quick add
my $quick_add_text =
  'Mar 31 1976 at 12:34. Lunch with Bob';    # from ICal::QuickAdd tests
my $iqa = App::gcal::_process_text($quick_add_text);
isa_ok( $iqa, 'Data::ICal' );

is( @{ $iqa->entries }[0]->property('summary')->[0]->value, 'Lunch with Bob' );
my $time = DateTime::Format::ICal->parse_datetime(
    @{ $iqa->entries }[0]->property('dtstart')->[0]->value );
is( $time->datetime, '1976-03-31T12:34:00' );
is( $time->datetime, '1976-03-31T12:34:00' );

my $gcal_event = App::gcal::_create_new_gcal_event( @{ $iqa->entries }[0] );
isa_ok( $gcal_event, 'Net::Google::Calendar::Entry' );
is( $gcal_event->title, 'Lunch with Bob' );

$quick_add_text = '';
$iqa            = App::gcal::_process_text($quick_add_text);
isa_ok( $iqa, 'Class::ReturnValue' );
like( $iqa->error_message, qr/error parsing/ );

$quick_add_text = 'foo';
$iqa            = App::gcal::_process_text($quick_add_text);
isa_ok( $iqa, 'Class::ReturnValue' );
like( $iqa->error_message, qr/error parsing/ );
