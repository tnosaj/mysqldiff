package MySQL::Diff::Event;

=head1 NAME

MySQL::Diff::Event - Event Definition Class

=head1 SYNOPSIS

  use MySQL::Diff::Event

  my $db = MySQL::Diff::Event->new(%options);
  my $def           = $db->def();
  my $name          = $db->name();
  my $definer       = $db->definer();

=head1 DESCRIPTION

Parses an event definition into component parts.

=cut

use warnings;
use strict;

our $VERSION = '0.60';

# ------------------------------------------------------------------------------
# Libraries

use Carp qw(:DEFAULT);
use MySQL::Diff::Utils qw(debug);

# ------------------------------------------------------------------------------

=head1 METHODS

=head2 Constructor

=over 4

=item new( %options )

Instantiate the objects, providing the command line options for database
access and process requirements.

=cut

sub new {
    my $class = shift;
    my %hash  = @_;
    my $self = {};
    bless $self, ref $class || $class;

    $self->{$_} = $hash{$_} for(keys %hash);

    debug(3,"\nconstructing new MySQL::Diff::Event");
    croak "MySQL::Diff::Event::new called without def params" unless $self->{def};
    $self->_parse;
    return $self;
}

=back

=head2 Public Methods

Fuller documentation will appear here in time :)

=over 4

=item * def

Returns the event definition as a string.

=item * name

Returns the name of the current event.

=back

=cut

sub def             { my $self = shift; return $self->{def};            }
sub name            { my $self = shift; return $self->{name};           }
sub schedule        { my $self = shift; return $self->{schedule};       }
sub preserve        { my $self = shift; return $self->{preserve};       }
sub enable          { my $self = shift; return $self->{enable};         }
sub body            { my $self = shift; return $self->{body};         }
#
# ------------------------------------------------------------------------------
# Private Methods

sub _parse {
    my $self = shift;

    $self->{def} =~ s/\n+/\n/;
    $self->{lines} = [ grep ! /^\s*$/, split /(?=^)/m, $self->{def} ];
    my @lines = @{$self->{lines}};
    debug(4,"parsing event def: '$self->{def}'");

    my $name;
    my $all_lines = join "\n", @lines;
    if ($all_lines =~ /^\/\*!\d{5}\sCREATE\*\/\s\/\*!\d{5}\sDEFINER=(\S+)\*\/\s\/\*!\d{5}\sEVENT\s`(\w+)`\sON SCHEDULE (.*)\sON COMPLETION (PRESERVE|NOT PRESERVE)\s(ENABLE|DISABLE)\sDO\s(.*?)\s\*\//ms) {
        $self->{definer} = $1;
        $self->{name} = $2;
        $self->{schedule} = $3;
        $self->{preserve} = $4;
        $self->{enable} = $5;
        $self->{body} = $6;
        debug(3,"got event name '$self->{name}'");
        shift @lines;
    } else {
        croak "couldn't figure out event name";
    }
}
