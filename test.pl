#
# $Id: test.pl,v 1.1 2002/08/30 20:31:44 jaldhar Exp $
#
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl 1.t'

use Test::More tests => 3;
BEGIN { use_ok('Acme::Brainfuck', qw/verbose/) };

my $a = +++[>+++<-]> ;
ok ( $a == 9, ' Do + - < > [ ] work?');

$a = ~ ;
ok ( $a == 0, ' Does ~ work?');

