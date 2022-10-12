#! /usr/bin/env perl

#use 5.020;
#use warnings;
#use autodie;

#use Cwd qw( fastcwd );
use File::Basename;
use JSON;
use Term::ANSIColor;
use Term::ReadKey; 

#use Toolkit;

my $GITBUFFER = undef;

main();
exit(0);

sub main {

  my $mask = $ENV{'PROMPT_MASK'} || 0x1F;

  my $venv = exists($ENV{'VIRTUAL_ENV'}) ? basename($ENV{'VIRTUAL_ENV'}) : undef;
  if( !defined($venv) && $ENV{'PIPENV_ACTIVE'} ){
    $venv = 'pipenv';
  }

  my $shlvl = $ENV{'SHLVL'} > 0 ? "($ENV{'SHLVL'})" : '';

  my @conf = (
    (defined($venv) ? 
      [ 19,  46, 'l',sub { (($mask & 0x10) ? $venv || $ENV{WORKPRE} || getpwuid($<) : '') . " $shlvl" } ]
      :
      [ 91,  234, 'l',sub { (($mask & 0x10) ? $ENV{WORKPRE} || getpwuid($<) : '') . " $shlvl" } ]
    ),
    [ 255, 235, 'l',sub { ($mask & 0x08) ? basename( $ENV{PWD} ) : '' } ],
    [ 255, 237, 'l',sub { ($mask & 0x04) ? gitBranch() : ''} ],
    [ 255, 239, 'l',sub { ($mask & 0x02) ? gitStatus() : ''} ],
#    [ 0,0, undef, undef],
    [ 255, 53,  'l',sub { ($mask & 0x01) ? dockerStatus() : ''} ],
  );

  binmode( STDOUT, ':utf8' );

#  my ( $x, $y, $xp, $yp ) = GetTerminalSize();

  my %plates;
  my $sz = scalar(@conf);
  my ($llen,$rlen) = (0,0);
  my ($ldelim,$rdelim);
  for ( my $i = 0; $i < $sz; $i++ ) {
    my ( $fg, $bg, $jstfy, $ref ) = @{ $conf[$i] };
    my $data = defined($ref) ? $ref->() : '';

    my ($nfg,$nbg) =(0, 0);
    if( $jstfy eq 'l' ){
    my $nxt = $conf[ $i + 1 ];
    $nfg = defined($nxt) ? $nxt->[0] : 0;
    $nbg = defined($nxt) ? $nxt->[1] : 0;

    $ldelim = '';
    $rdelim = "\N{U+E0B0}";
    $llen += length($data);
  }else{
    my $prev = $conf[ $i - 1 ];
    $nfg = defined($prev) ? $prev->[0] : 0;
    $nbg = defined($prev) ? $prev->[1] : 0;
    $ldelim = "\N{U+E0B2}";
    $rdelim = '';
    $rlen += length($data);
  }



    push( @{$plates{$jstfy}},
      color( "ansi$bg", "on_ansi$nbg" ) . $ldelim,
      (defined($ref) ? color( "ansi$fg", "on_ansi$bg" ) . $ref->(): ''),
      (defined($ref) ? color( "ansi$bg", "on_ansi$nbg" ) . $rdelim: ''),
    );

  }

  my $left = join('', @{$plates{'l'}});
  my $right = join('', @{$plates{'r'}});

  my $wide = 0;#= $x - $sz- $llen - $rlen;
  my $buffer = ' ' x $wide;

  print( "$left$buffer$right", color('reset') );
}

sub dockerStatus {
   my $json = JSON->new->allow_nonref();
   my $status = qx{ docker info --format '{{json .}}' };
   my $obj = $json->decode($status);
   my ($count, $running, $paused, $stopped) = @{$obj}{'Containers','ContainersRunning','ContainersPaused','ContainersStopped'};

   my $retval = "\N{U+1F40B}";

   if( defined($count) ){
   my $restart = $count - $running- $paused- $stopped;

#   quick($count, $running, $paused, $stopped, $restart);

   $retval = "\N{U+1F433} ";


   $retval .= "\N{U+25CF}$running "    if ($running);
   $retval .= "~$paused "   if ($paused);
#   $retval .= "\N{U+2716}$stopped " if ($stopped);
   $retval .= "\N{U+2715}$stopped " if ($stopped);
   $retval .= "\N{U+21BB}$restart "  if ($restart);

   my $rc = qx{ grep docker-mti.di2e.net ~/.docker/config.json };
   $retval .= '!' if( $rc );
 }
   return $retval;
}

sub gitBranch {
  if ( !defined($GITBUFFER) ) {
    $GITBUFFER = qx{ git status --branch --porcelain 2> /dev/null };
  }

  my ($branch) = $GITBUFFER =~ /^#+\s+([-\w]+)(\s+|\.\.\.)/;
  if( defined($branch) ){
    my $len = length($branch);
    if( $len > 19 ){
      substr($branch, 16, $len, '...');
    }
  }
  return (defined($branch) ? "\N{U+E0A0}$branch": '' );
}

sub gitStatus {
  if ( !defined($GITBUFFER) ) {
    $GITBUFFER = qx{ git status --branch --porcelain 2> /dev/null };
  }
#  quick( status => $GITBUFFER );
  my @status = split( /\n/, $GITBUFFER );
  my ( $ahead, $behind, $untrack, $staged, $modified ) = ( 0, 0, 0, 0, 0 );
  foreach my $ln (@status) {
#    chomp($ln);
#    quick($ln);
    if ( $ln =~ /^##/ ) {
      ($ahead)  = $ln =~ /ahead\s+(\d+)/;
      ($behind) = $ln =~ /behind\s+(\d+)/;
      next;
    }

    $untrack++  if ( $ln =~ /^\?\?/ );
    $staged++   if ( $ln =~ /^A / );
    $modified++ if ( $ln =~ /^ M/ );
  }

  my $retval = '';
  $retval .= "\N{U+2BC5}$ahead "    if ($ahead);
  $retval .= "\N{U+2BC6}$behind "   if ($behind);
  $retval .= "\N{U+271A}$modified " if ($modified);
  $retval .= "\N{U+22EF}$untrack "  if ($untrack);
  $retval .= "\N{U+2B24}$staged "   if ($staged);

  return $retval;
}

__END__

=head1 NAME

prompt.pl - [description here]

=head1 VERSION

This documentation refers to prompt.pl version 0.0.1

=head1 USAGE

    prompt.pl [options]

=head1 REQUIRED ARGUMENTS

=over

None

=back

=head1 OPTIONS

=over

None

=back

=head1 DIAGNOSTICS

None.

=head1 CONFIGURATION AND ENVIRONMENT

Requires no configuration files or environment variables.


=head1 DEPENDENCIES

None.


=head1 BUGS

None reported.
Bug reports and other feedback are most welcome.


=head1 AUTHOR

Andrew Pressel C<< apressel@nextgenfed.com >>


=head1 COPYRIGHT

Copyright (c) 2020, Andrew Pressel C<< <apressel@nextgenfed.com> >>. All rights reserved.

This module is free software. It may be used, redistributed
and/or modified under the terms of the Perl Artistic License
(see http://www.perl.com/perl/misc/Artistic.html)


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

