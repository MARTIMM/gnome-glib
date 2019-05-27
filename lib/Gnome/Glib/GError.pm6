use v6;
use NativeCall;

use Gnome::N::X;
use Gnome::N::NativeLib;

#-------------------------------------------------------------------------------
# See /usr/include/glib-2.0/glib/gerror.h
# https://developer.gnome.org/glib/stable/glib-Error-Reporting.html
unit class Gnome::Glib::GError:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------
class N-GError is repr('CStruct') is export {
  has uint32 $.domain;            # is GQuark
  has int32 $.code;
  has Str $.message;
}

#-------------------------------------------------------------------------------
sub g_error_new (
  int32 $domain, int32 $code, Str $format, Str $a1, Str $a2
) returns N-GError
  is native(&gtk-lib)
  { * }

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
has N-GError $!g-gerror;

#-------------------------------------------------------------------------------
submethod BUILD ( ) {
  $!g-gerror = g_error_new( 1, 0, "", "", "");
}

#-------------------------------------------------------------------------------
method CALL-ME ( N-GError $gerror? --> N-GError ) {

  $!g-gerror = $gerror if ?$gerror;
  $!g-gerror
}

#-------------------------------------------------------------------------------
method FALLBACK ( $native-sub is copy, |c ) {

  CATCH { test-catch-exception( $_, $native-sub); }

  $native-sub ~~ s:g/ '-' /_/ if $native-sub.index('-');
  die X::Gnome.new(:message(
      "Native sub name '$native-sub' made too short. Keep at least one '-' or '_'."
    )
  ) unless $native-sub.index('_') >= 0;

  my Callable $s;
  try { $s = &::($native-sub); }
  try { $s = &::("g_error_$native-sub"); }

  test-call( &$s, Any, |c)
}
