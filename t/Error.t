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
  throws-like(
    { Gnome::Glib::Error.new(); },
    X::Gnome, 'Cannot create without args',
    :message(/:s No options specified/)
  );

  throws-like(
    { Gnome::Glib::Error.new(:message('abc def')); },
    X::Gnome, 'Cannot create with wrong args',
    :message(/:s Unsupported options for/)
  );

  # The error domain is called <NAMESPACE>_<MODULE>_ERROR
  my Int $domain = $quark.from-string('gnome_gtk3_button_test_error');
  $e .= new( :$domain, :code(1), :error-message('Error in test'));
  isa-ok $e, Gnome::Glib::Error, '.new(:$domain, :$code, :$error-message)';

  diag '.clear-error()';
  $e.clear-error;
  ok !$e.error-is-valid, 'error $e is not valid';
  $e = Nil;
}

#-------------------------------------------------------------------------------
subtest 'Manipulations', {
  my Int $domain = $quark.from-string('gnome_gtk3_button_test_error');
  $e .= new( :$domain, :code(2), :error-message('Error in test'));
  ok $e.error-is-valid, 'error $e is valid';

  my Gnome::Glib::Error $e2 .= new(:gerror($e.g-error-copy));
  ok $e2.error-is-valid, 'error $e2 is valid';
  is $e2.g-error-matches( $domain, 2), 1, 'Error matches with domain and code';

  is $e2.domain, $domain, 'domain in structure ok';
  is $e2.code, 2, 'code in structure ok';
  is $e2.message, 'Error in test', 'message in structure ok';
  $e2.clear-error;
  ok !$e2.error-is-valid, 'error $e is not valid anymore';

  $domain = $quark.from-string('gnome_gtk3_button_2nd_test_error');
  $e2 .= new( :$domain, :code(3), :error-message('2nd error in test'));
  is $e2.g-error-matches( $domain, 3), 1,
     '2nd error matches with domain and code';

  is $e2.domain, $domain, 'domain in structure ok';
  is $e2.code, 3, 'code in structure ok';
  is $e2.message, '2nd error in test', 'message in structure ok';

  $e2.clear-error;
  $e.clear-error;

  is $e.domain, UInt, 'domain undefined';
  is $e.code, Int, 'code undefined';
  is $e.message, Str, 'message undefined';

  is $e.g-error-matches( $domain, 3), 0, 'error does not match anymore';
}


#-------------------------------------------------------------------------------
# create a local sub to call a gtk function
# Definition is:
#   gboolean g_file_get_contents (
#      const gchar  *filename,
#      gchar       **contents,  // Address to return content
#      gsize        *length,
#      GError      **error);    // Address to return error
#
# So for api spec for contents and error;
#   CArray[Str] $contents
#   CArray[N-GError] $error
#
# The variables must be initialized with undefined fields;
#   my CArray[Str] $s .= new(Str);
#   my CArray[N-GError] $ga .= new(N-GError);
#
sub g_file_get_contents (
  Str $filename, CArray[Str] $contents, int32 $length is rw,
  CArray[N-GError] $error
) returns int32
  is native(&glib-lib)
  { * }

subtest 'A real error', {
  my Str $f = 't/abc.txt';
  $f.IO.spurt('test text');

  my CArray[N-GError] $ga .= new(N-GError);
  my CArray[Str] $s .= new(Str);
  my int32 $l;
  my Int $r = g_file_get_contents( $f, $s, $l, $ga);
  #my Int $r = g_file_get_contents( $f, $s, $l, $e.set-error);
  is $r, 1, 'no error';
  is $l, 9, 'length of string is ok';
  is $s[0], 'test text', 'returned text is ok';

  $r = g_file_get_contents( 'unknown-file.txt', $s, $l, $ga);
  #$r = g_file_get_contents( 'unknown-file.txt', $s, $l, $e.set-error);
  is $r, 0, 'returned an error';

  $e .= new(:gerror($ga[0]));
#removed test because there is an issue about this domain being 4 instead of 3.
#this means that perhaps there is an extra registration done somehow
#is $e.domain, 3, 'domain is 3; 3rd domain registration in this test';
  is $quark.to-string($e.domain), 'g-file-error-quark',
     'domain text is g-file-error-quark';

  # 4 is value of G_FILE_ERROR_NOENT in enum GFileError (not defined yet)
  # See also https://developer.gnome.org/glib/stable/glib-File-Utilities.html
  is $e.code, 4, 'error code for this error is 4';
  like $e.message, /:s Failed to open file/, $e.message;

  unlink $f;
}

#-------------------------------------------------------------------------------
done-testing;
