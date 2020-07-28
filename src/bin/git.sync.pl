#! /usr/bin/env perl

use 5.020;
use warnings;
use autodie;

use Getopt::Long;
use YAML::Tiny;


use Toolkit;

my %opts;
if ( !GetOptions( \%opts, 'verbose','commit' ) ) {
  die("Invalid incantation\n");
}

main();
exit(0);

sub main {

  my $rcFile = "$ENV{'HOME'}/.gitsyncrc";
  if( !-f $rcFile ){
    local $/ = undef;
    my @config = <DATA>;

    open(my $fh, '>', $rcFile);
    $fh->print(join('', @config),"\n");
    close($fh);
  }
  
  my $config = YAML::Tiny->read($rcFile);
  $config = $config->[0];

  printObject($config) if( $opts{'verbose'});

  foreach my $key ( sort keys %{$config} ) {
    my @changed = createFake( $config->{$key} );
    if ( scalar @changed ) {
      message( $key => map{ green("  $_") } @changed );
    }
  }
}

sub createFake {
  my ($repo) = @_;

  if ( !-d "$repo/.git" ) {
    warn("unable to find repo:[$repo]");
    return wantarray ? () : [];
  }

  chdir($repo);
  my @output = qx{ make fake };

  my @retval;
  my $dir = './';
  foreach my $ln (@output) {
    chomp($ln);

    if( $ln =~ /^rsync/ ){
      my @chunk = split(/\s+/, $ln);
      $dir = $chunk[-2];
    }



    quick($ln) if( $opts{'verbose'} );
    push( @retval, "$ln" ) if ( -f "$dir$ln" );
  }

  return wantarray ? @retval : \@retval;
}

__DATA__
---
'Bash Environment': '${WORKSPACE_DIR}/cxap/bashenvironment'
'Vim Environment':  '${WORKSPACE_DIR}/cxap/vimenvironment'
