#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Test::LongString;
use File::Basename;

use OPM::Maker;
use OPM::Maker::Command::changes;

my $git =  dirname(__FILE__) . '/../bin/git';

$OPM::Maker::Utils::Git::GIT = 'perl ' . $git;

my $file = OPM::Maker->execute_command( 'OPM::Maker::Command::changes', { dir => '.' }, [] );
ok $file;
ok -f $file;

my $check = '17.1.1    2017-11-14T10:35:07+01:00

    noch ein Test
        
        Fuer den Text des Commits

    prepare release

    prepare release


17.1.0    2017-09-29T14:41:14+02:00

    noch ein Test
        
        Fuer den Text des Commits

    prepare release

    prepare release


17.0.99    2017-09-29T13:37:57+02:00

    noch ein Test
        
        Fuer den Text des Commits

    prepare release

    prepare release


17.0.98    2017-09-08T13:46:20+02:00

    noch ein Test
        
        Fuer den Text des Commits

    prepare release

    prepare release


16.0.1    2017-07-14T13:21:44+02:00

    noch ein Test
        
        Fuer den Text des Commits

    prepare release

    prepare release


15.3.2    2017-04-27T15:40:30+02:00

    noch ein Test
        
        Fuer den Text des Commits

    prepare release

    prepare release


';

#is_string $new, $check;

done_testing();
