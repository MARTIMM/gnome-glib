use v6;
use Test;

sub GSourceFunc ( &c:( Int, Int --> Num ) ) { }


sub b ( Int $i, &GSourceFunc ) {
  ok 1, GSourceFunc( $i, $i + 10);
}

sub j1 ( Int $i, Int $j --> Num ) {
  $j.Num + 10.Num
}

sub j2 ( Int $j, Str $a --> Str ) {
  ($j + 10 + $a.Num).Str
}

lives-ok { b( 10, &j1 ); }, 'function has right signature';
dies-ok { b( 10, &j2 ); }, 'function has wrong signature';
