#! /usr/bin/env perl

use 5.020;
use warnings;
use autodie;

use Getopt::Long;
use YAML::Tiny;

use Toolkit;

my %opts;
if ( !GetOptions( \%opts, 'verbose', 'commit' ) ) {
  die("Invalid incantation\n");
}

main();
exit(0);

sub main {

  my $rcFile = "$ENV{'HOME'}/.gitsyncrc";
  if ( !-f $rcFile ) {
    local $/ = undef;
    my @config = <DATA>;

    open( my $fh, '>', $rcFile );
    $fh->print( join( '', @config ), "\n" );
    close($fh);
  }

  my $config = YAML::Tiny->read($rcFile);
  $config = $config->[0];

  printObject($config) if ( $opts{'verbose'} );

  my $binaries = $config->{'binaries'};
  foreach my $key ( sort keys %{$binaries} ) {
    my $dir = $binaries->{$key};
    $dir =~ s/\$\{(.+?)\}/$ENV{$1}/go;
    my @changed = createFake( $dir );
    if ( scalar @changed ) {
      message( $key => @changed );
    }
  }

  my $libs = $config->{'libraries'};
  foreach my $key ( sort keys %{$libs} ) {
    my $dir = $libs->{$key};
    $dir =~ s/\$\{(.+?)\}/$ENV{$1}/go;
    my @changed = checkPerlToolkit( $dir );
    if ( scalar @changed ) {
      message( $key => map { green("  $_") } @changed );
    }
  }
}

sub checkPerlToolkit {
  my ($repo) = @_;

  my @retval;
  chdir($repo);
  foreach my $subdir ( 'bin', 'lib/perl5' ) {
    if ( -d $subdir ) {
      my @files = glob("$subdir/*");
      foreach my $file ( sort @files ) {
        if ( system("diff -q $file $ENV{'HOME'}/$file > /dev/null 2>&1") ) {
          push( @retval, $file );
        } else {
          quick( same => $file ) if ( $opts{'verbose'} );
        }
      }

    }
  }

  return wantarray ? @retval : \@retval;
}

sub createFake {
  my ($repo) = @_;

  if ( !-d "$repo/.git" ) {
    warn("unable to find repo:[$repo]");
    return wantarray ? () : [];
  }

  message("Checking $repo");
  chdir($repo);
  my @output = qx{ make brief };

  my @retval;
  my $dir = './';
  foreach my $ln (@output) {
    chomp($ln);
    quick($ln) if ( $opts{'verbose'} );

    my $format = \&white;
    my $mark   = undef;
    my @parts  = split( /\s+/, $ln );
    if ( $parts[0] eq 'Only' ) {
      if ( $parts[2] =~ /$ENV{'HOME'}/ ) {
        $mark   = '++';
        $format = \&green;
      } else {
        $mark   = '--';
        $format = \&red;
      }

      $parts[2] =~ s/:/\//;
      $parts[2] =~ s/$ENV{'HOME'}\///g;
    } elsif ( $parts[0] eq 'Files' ) {
      $mark   = '==';
      $format = \&magenta;

      $parts[2] = '';
    }

    push( @retval, $format->("$mark $parts[2]$parts[3]") ) if ($mark);
  }

  return wantarray ? @retval : \@retval;
}

__DATA__
---
binaries:
  'Bash Environment': '${WORKSPACE_DIR}/cxap/bashenvironment'
  'Vim Environment':  '${WORKSPACE_DIR}/cxap/vimenvironment'
libraries:
  Toolkit:          '${WORKSPACE_DIR}/cxap/Toolkit/Toolkit'
  tools:            '${WORKSPACE_DIR}/cxap/Toolkit/tools'
  Utilities:        '${WORKSPACE_DIR}/cxap/Toolkit/Utilities'
  PSInfo:           '${WORKSPACE_DIR}/cxap/Toolkit/PSInfo'
  StructurePrinter: '${WORKSPACE_DIR}/cxap/Toolkit/StructurePrinter'
