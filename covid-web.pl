#!/usr/bin/env perl

use Modern::Perl;

use Carp::Always;
use Template;
use YAML qw(LoadFile);

my $tt = Template->new({
    INCLUDE_PATH => '.',
    INTERPOLATE  => 0,
}) || die "$Template::ERROR\n";

my $data = LoadFile('covid.yml'); 

my $vars = { data => $data };

my $html;
$tt->process('covid-web.tt', $vars, 'covid-web.html')
    || die $tt->error(), "\n";
