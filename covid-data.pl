#!/usr/bin/env perl

use Modern::Perl;

use Carp::Always;
use Data::Dumper;
use Getopt::Long::Descriptive;
use RT::Client::REST;
use Term::ANSIColor;
use Text::CSV::Slurp;
use Try::Tiny;
use YAML qw(DumpFile);

my ( $opt, $usage ) = describe_options(
    'tracker-updater.pl',
    [ "rt-url=s", "BWS RT URL", { required => 1, default => $ENV{RT_URL} } ],
    [
        "rt-username=s",
        "BWS RT username",
        { required => 1, default => $ENV{RT_USER} }
    ],
    [
        "rt-password=s",
        "BWS RT password",
        { required => 1, default => $ENV{RT_PW} }
    ],
    [],
    [ 'verbose|v+', "Print extra stuff" ],
    [ 'help|h', "Print usage message and exit", { shortcircuit => 1 } ],
);

print( $usage->text ), exit if $opt->help;

my $verbose = $opt->verbose || 0;

my $rt_url  = $opt->rt_url;
my $rt_user = $opt->rt_username;
my $rt_pass = $opt->rt_password;

my $rt = RT::Client::REST->new(
    server  => $rt_url,
    timeout => 30,
);

try {
    $rt->login( username => $rt_user, password => $rt_pass );
}
catch {
    die "Problem logging in: ", shift->message;
};

#my @ids = $rt->search( type => 'group', query => 'Disabled = 1' );
#my @groups;
#foreach my $group_id (@ids) {
#    my $group = $rt->show( type => 'group', id => $group_id );
#    $group->{id_only} = $group_id;
#    next unless $group->{Name};
#    say "Found group $group_id";
#    push( @groups, $group );
#}

my $groups = Text::CSV::Slurp->load( file => 'requestorgroups.csv' );

my @groups_with_tickets;
my $tickets = {};
foreach my $g (@$groups) {
    my $group = $g->{Id};
    say "Working on group " . colored( $group, 'green' );
    my $rt_query = qq{ RequestorGroup.Id = '$group' AND CF.{Tags} LIKE 'covid' };
    my @ids = $rt->search(
        type    => 'ticket',
        query   => $rt_query,
        orderby => '-id',
    );

    my @tickets;
    foreach my $ticket_id (@ids) {
        my $ticket = $rt->show( type => 'ticket', id => $ticket_id );

        say "  Working on ticket " . colored( $ticket_id, 'cyan' );
        push( @tickets, $ticket );
    }

    if ( @tickets ) {
        push( @groups_with_tickets, $g );
        $tickets->{ $g->{Id} } = \@tickets;
    }
}

DumpFile( 'covid.yml', { groups => \@groups_with_tickets, tickets => $tickets } );

say colored( 'Finished!', 'green' ) if $verbose;
