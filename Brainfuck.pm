#
# See POD documentation below for description, copyright and licensing info.
#
# $Id: Brainfuck.pm,v 1.4 2002/09/03 18:43:47 jaldhar Exp $
#
package Acme::Brainfuck;
use Filter::Simple;
use strict;
use warnings;

#remember to change this in the POD too.
our $VERSION = '1.0.0';
 
# The memory pointer and memory cells of our Turing machine. 
our $p = 0;
our @m = (); 

# The basic Brainfuck instructions.  Extras will be added in import().
our $ops = '+-<>,.[]'; 

# Whether or not we accept extra instructions.
our $verbose = 0;

# print out filtered text?
our $debug = 0;

sub import()
{
    shift;
    foreach (@_)
    {
	if (/^verbose$/)
	{
	    $ops .= '~#';
	    $verbose = 1;
	}
	if (/^debug$/)
	{
	    $debug = 1;
	}
    }
}

FILTER_ONLY code => sub
{
    my $ret = $_;
    while ($ret =~ /\s ([\Q$ops\E]+) \s/gsx)
    {
	my $code = $1;
	my $len = length($1);
	my $at = pos($ret) - ($len + 1);

	$code =~ s/^/do { /g;
	$code =~ s/$/P; }; /g;
	$code =~ s/(\++)/"P += ".length($1).";" /eg;
	$code =~ s/(\-+)/"P -= ".length($1).";" /eg;
	$code =~ s/(<+)/"\$Acme::Brainfuck::p -= ".length($1).";" /eg; 
	$code =~ s/(>+)/"\$Acme::Brainfuck::p += ".length($1).";" /eg;
	$code =~ s/\./print chr P; /g;
	$code =~ s/,/P = ord getc;/g;
	$code =~ s/\[/while(P){/g;
	$code =~ s/\]/}; /g;
	if ($verbose)
	{
	    $code =~
		s/~/\$Acme::Brainfuck::p = 0;\@Acme::Brainfuck::m = (); /g;
	    $code =~
		s/\#/print STDERR sprintf\('\$p = %d \$m[\$p]= %d', \$Acme::Brainfuck::p, P\), "\\n"; /g;
	}
	$code =~ s/P/\$Acme::Brainfuck::m\[\$Acme::Brainfuck::p\]/g;
	substr($ret, $at, $len, $code);
    }
    $_ = $ret;
    print $_ if $debug;
};

1;

__END__

=pod

=head1 NAME

Acme::Brainfuck - Embed Brainfuck in your perl code

=head1 SYNOPSIS

 #!/usr/bin/env perl
 use Acme::Brainfuck;

 print 'Hello world!', chr ++++++++++. ; 

=head1 DESCRIPTION

Brainfuck is about the tiniest Turing-complete programming language you
can get.  A language is Turing-complete if it can model the operations of
a Turing machine--an abstract model of a computer defined by the British
mathematician Alan Turing in 1936.  A Turing machine consists only of an
endless sequence of memory cells and a pointer to one particular memory
cell.  Yet it is theoretically capable of performing any computation. With
this module, you can embed Brainfuck instructions delimited by whitespace
into your perl code.  It will be translated into Perl as parsed.  
Brainfuck has just just 8 instructions (well more in this implementation,
see L</"Extensions to ANSI Brainfuck"> below.) which are as follows

=head2 Instructions

=over 4

=item + Increment

Increase the value of the current memory cell by one.

=item - Decrement

Decrease the value of the current memory cell by one.

=item > Forward

Move the pointer to the next memory cell.

=item < Back

Move the pointer to the previous memory cell.

=item , Input

Read a byte from Standard Input and store it in the current memory cell.

=item . Output

Write the value of the current memory cell to standard output.

=item [ Loop

If the value of the current memory cell is 0, continue to the cell after
the next ']'.

=item ] Next

Go back to the last previous '['.

=back

=head2  Extensions to ANSI Brainfuck

This implementation has extra instructions available.  In order to avoid such
terrible bloat, they are only available if you use the I<verbose> pragma like 
so:

use Acme::Brainfuck qw/verbose/;

The extra instructions are:

=over 4

=item ~ Reset

Resets the pointer to the first memory cell and clear all memory cells.

=item # Peek

Prints the values of the memory pointer and the current memory cell to 
STDERR.  See also L</"Debugging"> below.

=back

=head2 Debugging

By using the I<debug> pragma like this:
 
use Acme::Brainfuck qw/debug/;

you can dump out the generated perl code.  (Caution: it is not pretty.)
The key to understanding it is that the memory pointer is represented by 
I<$p>, and the memory array by I<@m>  Therefore the  value of the current 
memory cell is I<$m[$p]>.

=head1 RETURN VALUE

Each sequence of Brainfuck instructions becomes a Perl block and returns the 
value of the current memory cell.

=head1 EXAMPLES

=head2 JABH

 #!/usr/bin/env perl
 use Acme::Brainfuck;
 print "Just another ";
 ++++++[>++++++++++++++++<-]>
 ++.--
 >+++[<++++++>-]<.>[-]+++[<------>-]<
 +.-
 +++++++++.---------
 ++++++++++++++.--------------
 ++++++.------
 >+++[<+++++++>-]<.>[-]+++[<------->-]<
 +++.---
 +++++++++++.-----------
 print " hacker.\n";

=head2 Countdown

 #!/usr/bin/env perl
 use strict;
 use Acme::Brainfuck qw/verbose/;

 print "Countdown commencing...\n";
 ++++++++++[>+>+<<-]
 >>+++++++++++++++++++++++++++++++++++++++++++++++<<
 ++++++++++[>>.-<.<-]
 print "We have liftoff!\n";

=head2 Reverse

 #!/usr/bin/env perl
 use Acme::Brainfuck qw/verbose/;
 
 while(1)
 {
   print "Say something to Backwards Man and then press enter: ";
   +[->,----------]<
   print 'Backwards Man says, "';
   [+++++++++++.<]<
   print "\" to you too.\n";
   ~
 }

=head2 Math

 #!/usr/bin/env perl
 use Acme::Brainfuck;
 use strict;
 use warnings;

 my $answer = +++[>++++++<-]> ;

 print "3 * 6 = $answer \n";

=head1 VERSION

 1.0.0 Sep 03, 2002

=head1 AUTHOR

 Jaldhar H. Vyas E<lt>jaldhar@braincells.comE<gt>

=head1 THANKS

Urban Mueller - The inventor of Brainfuck.

Damian Conway - For twisting perl to hitherto unimaginable heights of 
weirdness.

Marco Nippula E<lt>http://www.hut.fi/~mnippula/E<gt> - Some code in this
module comes from his F<brainfuck.pl>

Mr. Rock - Who has a nice Brainfuck tutorial at 
L<http://www.cydathria.com/bf/>.  Some of the example code comes from there.

=head1 COPYRIGHT AND LICENSE

 Copyright (c) 2002, Consolidated Braincells Inc.
 Licensed with no warranties under the Crowley Public License:
 
 "Do what thou wilt shall be the whole of the license."

=cut
