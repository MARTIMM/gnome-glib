use v6;
use NativeCall;
use Test;

use Gnome::N::NativeLib;

use Gnome::Glib::Quark;
use Gnome::Glib::Error;

#use Gnome::N::X;
#Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
my Gnome::Glib::Quark $quark .= new;
my Gnome::Glib::Error $e;
#-------------------------------------------------------------------------------
subtest 'ISA test', {
  # The error domain is called <NAMESPACE>_<MODULE>_ERROR
  my Int $domain = $quark.from-string('gnome_gtk3_button_test_error');
  $e .= new( :$domain, :code(1), :error-message('Error in test'));
  isa-ok $e, Gnome::Glib::Error;

  $e.clear-error;
  $e = Nil;
}

#-------------------------------------------------------------------------------
subtest 'Manipulations', {
  my Int $domain = $quark.from-string('gnome_gtk3_button_test_error');
  $e .= new( :$domain, :code(2), :error-message('Error in test'));

  my Gnome::Glib::Error $e2 .= new(:gerror($e.g-error-copy));
  is $e2.g-error-matches( $domain, 2), 1, 'Error matches with domain and code';

  my N-GError $gerr = $e2();
  is $gerr.domain, $domain, 'domain in structure ok';
  is $gerr.code, 2, 'code in structure ok';
  is $gerr.message, 'Error in test', 'message in structure ok';
  $e2.clear-error;
  is $gerr.domain, 0, 'domain in structure set to 0';

  $domain = $quark.from-string('gnome_gtk3_button_2nd_test_error');
  $e2 .= new( :$domain, :code(3), :error-message('2nd error in test'));
  is $e2.g-error-matches( $domain, 3), 1,
     '2nd error matches with domain and code';

  $gerr = $e2();
  is $gerr.domain, $domain, 'domain in structure ok';
  is $gerr.code, 3, 'code in structure ok';
  is $gerr.message, '2nd error in test', 'message in structure ok';

  $e2.clear-error;
  $e.clear-error;
}

#`{{
#-------------------------------------------------------------------------------
# create a local sub to call a gk function
sub g_file_get_contents (
  Str $filename,
  Pointer $contents is rw, int32 $length is rw,
  N-GError $error
) returns int32
  is native(&glib-lib)
  { * }

class string is repr('CStruct') {
  has CArray[uint8] $.s;
}


subtest 'A real error', {
  my Str $f = 't/abc.txt';
  $f.IO.spurt('test text');

  my N-GError $gerr .= new;
  $e .= new(:gerror($gerr));
  my string $s .= new;
  my int32 $l = 0;
  my Int $r = g_file_get_contents( $f, $s, $l, $gerr);
  note "rls: $r, $l, ", $s.s;
  note 'd: ', $gerr.domain, ', ', $quark.to-string($gerr.domain);
  note 'c: ', $gerr.code;
  note 'm: ', $gerr.message;

  unlink $f;
}
}}

#-------------------------------------------------------------------------------
done-testing;
