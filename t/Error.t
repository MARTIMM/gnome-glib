use v6;
use NativeCall;
use Test;

use Gnome::N::NativeLib;

use Gnome::Glib::Quark;
use Gnome::Glib::Error;

use Gnome::N::X;
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


#-------------------------------------------------------------------------------
# create a local sub to call a gk function
sub g_file_get_contents (
  Str $filename, CArray[Str] $contents is rw, int32 $length is rw,
  CArray[N-GError] $error is rw
) returns int32
  is native(&glib-lib)
  { * }

subtest 'A real error', {
  my Str $f = 't/abc.txt';
  $f.IO.spurt('test text');

  my CArray[N-GError] $ga .= new(N-GError);
  my N-GError $gerr;
  my CArray[Str] $s .= new('');
  my int32 $l;
  my Int $r = g_file_get_contents( $f, $s, $l, $ga);
  is $r, 1, 'no error';
  is $l, 9, 'length of string is ok';
  is $s[0], 'test text', 'returned text is ok';

  $r = g_file_get_contents( 'unknown-file.txt', $s, $l, $ga);
  is $r, 0, 'returned an error';

  $gerr = $ga[0];
  is $gerr.domain, 3, 'domain is 3; 3rd domain registration in this test';
  is $quark.to-string($gerr.domain), 'g-file-error-quark',
     'domain text is g-file-error-quark';
  is $gerr.code, 4, 'error code for this error is 4';
  is $gerr.message,
     'Failed to open file “unknown-file.txt”: No such file or directory',
     $gerr.message;

  unlink $f;
}

#-------------------------------------------------------------------------------
done-testing;
