use strict;
use warnings;

package App::gcal;

use Class::ReturnValue;
use Data::ICal;
use Net::Google::Calendar;
use Net::Google::Calendar::Entry;
use DateTime::Format::ICal;

use Smart::Comments;

# ABSTRACT: Command Line Interface interface to Google Calendar.

our $gcal;

sub run {
    my (@args) = @_;

    # loop over args
    for my $arg (@args) {

        my $cal;
        if ( ( -e $arg ) && ( -r $arg ) ) {

            # looks like a file
            $cal = _process_file($arg);

        }
        else {

            # give to ICal::QuickAdd
            $cal = _process_text($arg);
        }

        if ($cal) {
            _save_to_gcal($cal);
        }
        else {
            print STDERR $cal->error_message . "\n";
        }
    }
}

sub _process_file {
    my ($file) = @_;

    my $calendar = Data::ICal->new( filename => $file );
    unless ($calendar) {
        return _error("error parsing $file");
    }

    return $calendar;
}

sub _process_text {
    my ($text) = @_;

    # TODO
}

sub _save_to_gcal {
    my ($cal) = @_;

    unless ($gcal) {
        $gcal = Net::Google::Calendar->new;

        # TODO: load from .netrc, or similar
        $gcal->login( '', '' );
    }

    for my $entry ( @{ $cal->entries } ) {

        # create gcal event
        # TODO: extract & test
        my $event = Net::Google::Calendar::Entry->new();

        $event->title( $entry->property('summary')->[0]->value );
        $event->content( $entry->property('description')->[0]->value );
        $event->location( $entry->property('location')->[0]->value );
        $event->when(
            DateTime::Format::ICal->parse_datetime(
                $entry->property('dtstart')->[0]->value
            ),
            DateTime::Format::ICal->parse_datetime(
                $entry->property('dtend')->[0]->value
            )
        );
        $event->status('confirmed');

        # save
        my $tmp = $gcal->add_entry($event);
        die "Couldn't add event: $@\n" unless defined $tmp;
    }
}

sub _error {
    my $msg = shift;

    my $ret = Class::ReturnValue->new;
    $ret->as_error( errno => 1, message => $msg );
    return $ret;
}

=head1 DESCRIPTION

The C<gcal> command provides a quick and easy interface to Google Calendar from the command line.

=head1 TODO

=cut

1;
