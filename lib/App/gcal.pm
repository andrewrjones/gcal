use strict;
use warnings;

package App::gcal;

use Class::ReturnValue;
use Data::ICal;

# ABSTRACT: Command Line Interface interface to Google Calendar.

our $gcal;

# entry point
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

# process an ics file
sub _process_file {
    my ($file) = @_;

    my $calendar = Data::ICal->new( filename => $file );
    unless ($calendar) {
        return _error("error parsing $file");
    }

    return $calendar;
}

# process a text event
sub _process_text {
    my ($text) = @_;

    my $error_msg = 'error parsing text';

    unless ($text) {
        return _error($error_msg);
    }

    require ICal::QuickAdd;
    my $iqa = ICal::QuickAdd->new($text)->as_ical;

    unless ( @{ $iqa->entries }[0]->property('summary')->[0]->value ) {
        return _error($error_msg);
    }

    return $iqa;
}

# save event to Google Calendar
sub _save_to_gcal {
    my ($cal) = @_;

    unless ($gcal) {

        # get login and password from .netrc
        require Net::Netrc;
        my $netrc = Net::Netrc->lookup('google.com');

        # login
        require Net::Google::Calendar;
        $gcal = Net::Google::Calendar->new;
        $gcal->login( $netrc->login, $netrc->password );
    }

    for my $entry ( @{ $cal->entries } ) {

        # create gcal event
        my $event = _create_new_gcal_event($entry);

        # save
        my $tmp = $gcal->add_entry($event);
        die "Couldn't add event: $@\n" unless defined $tmp;
    }
}

# converts Data::ICal to Net::Google::Calendar::Entry
sub _create_new_gcal_event {
    my ($entry) = @_;

    require Net::Google::Calendar::Entry;
    require DateTime::Format::ICal;

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

    return $event;
}

# return an error
sub _error {
    my $msg = shift;

    my $ret = Class::ReturnValue->new;
    $ret->as_error( errno => 1, message => $msg );
    return $ret;
}

=head1 SYNOPSIS

The C<gcal> command provides a quick and easy interface to Google Calendar from the command line.

=head1 USAGE

  gcal --help
  
  gcal [events.ical, 'tomorrow at noon. Lunch with Bob', ...]

=head1 DESCRIPTION

Before using the C<gcal> command, you need to provide your Google credentials in your C<.netrc> file, for the C<google.com> machine. For example:

  machine google.com
  login bob
  password 1234

You can then pass one or more C<.ics> files to the C<gcal> command and it will be added to your Google Calendar.

You can also pass one or more strings to the C<gcal> command, which will attempt to parse it and create a new event. It uses L<ICal::QuickAdd> to parse, so has the same functionality and limitations.

=cut

1;
