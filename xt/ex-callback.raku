use v6.d;

note :( Int $d --> Bool ).WHAT;
note :( Int $d --> Bool ).gist;

subset GSourceFunc of Routine where .signature ~~ :( Int $d --> Bool );
note GSourceFunc.gist;

sub abc ( Int $i, GSourceFunc $f) {
  note "value of f\({$i//'-'}): ", $f($i);
}

sub f ( Int $j --> Bool ) {
  (?$j and $j >= 10)
}

# try with undefined Int
abc( Int, &f);

# and a range of Int
for 7..12 -> $i {
  abc( $i, &f);
}

# try with a different func
sub g ( Str $s --> Int ) {
  $s.chars
}

abc( 10, &g);
