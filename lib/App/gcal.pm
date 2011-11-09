use strict;
use warnings;

package App::gcal;

# ABSTRACT: Command Line Interface interface to Google Calendar.

sub run {
    my @args = @_;
    
    # loop over args
    
    # if file, open and parse with Data::ICal
    
    # if not, try and parse with ICal::QuickAdd
    
    # if success, use Net::Google::Calendar to save
}

=head1 DESCRIPTION

The C<gcal> command provides a quick and easy interface to Google Calendar from the command line.

=head1 TODO

=cut

1;
