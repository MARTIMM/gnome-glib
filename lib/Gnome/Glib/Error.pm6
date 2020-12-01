#TL:1:Gnome::Glib::Error

use v6;

#-------------------------------------------------------------------------------
=begin pod

=TITLE Gnome::Glib::Error

=SUBTITLE a system for reporting errors

=head1 Description

GLib provides a standard method of reporting errors from a called function to the calling code. Functions that can fail take a return location for a C<N-GError> as their last argument. On error, a new C<N-GError> instance will be allocated and returned to the caller via this argument. After handling the error, the error object must be freed. Do this using C<clear-error()>.

The C<N-GError> object contains three fields: I<domain> indicates the module the error-reporting function is located in, I<code> indicates the specific error that occurred, and I<message> is a user-readable error message with as many details as possible. Several functions are provided to deal with an error received from a called function: C<g_error_matches()> returns C<1> if the error matches a given domain and code. To display an error to the user, simply call the C<message()> method, perhaps along with additional context known only to the calling function.

This class is greatly simplified because in Raku one can use Exception classes to throw any errors. It exists mainly to handle errors coming from other GTK+ functions.


Error domains and codes are conventionally named as follows:

=item The error domain is called I<NAMESPACE>_I<MODULE>_ERROR. For instance glib file utilities uses G_FILE_ERROR.

=item The quark function for the error domain is called <namespace>_<module>_error_quark, for example C<g-file-error-quark()>.

=item The error codes are in an enumeration called <Namespace><Module>Error, for example C<GFileError>.

=item Members of the error code enumeration are called <NAMESPACE>_<MODULE>_ERROR_<CODE>, for example C<G_FILE_ERROR_NOENT>.

=item If there's a "generic" or "unknown" error code for unrecoverable errors it doesn't make sense to distinguish with specific codes, it should be called <NAMESPACE>_<MODULE>_ERROR_FAILED, for example C<G_SPAWN_ERROR_FAILED>. In the case of error code enumerations that may be extended in future releases, you should generally not handle this error code explicitly, but should instead treat any unrecognized error code as equivalent to FAILED.


=head1 Synopsis
=head2 Declaration

  unit class Gnome::Glib::Error;
  also is Gnome::N::TopLevelClassSupport;


=head2 Uml Diagram

![](plantuml/Error.svg)


=head2 Example

  my Gnome::Gtk3::Builder $builder .= new;

  # Try to read non existing file
  my Gnome::Glib::Error $e = $builder.add-from-file('x.glade');
  die $e.message if $e.is-valid;

=end pod
#-------------------------------------------------------------------------------
use NativeCall;

use Gnome::N::X;
use Gnome::N::NativeLib;
use Gnome::N::TopLevelClassSupport;
use Gnome::N::GlibToRakuTypes;

#-------------------------------------------------------------------------------
# See /usr/include/glib-2.0/glib/gerror.h
# https://developer.gnome.org/glib/stable/glib-Error-Reporting.html
unit class Gnome::Glib::Error:auth<github:MARTIMM>;
also is Gnome::N::TopLevelClassSupport;

#-------------------------------------------------------------------------------
=begin pod
=head1 Types
=head2 class N-GError;

=item has UInt $.domain; The set domain.
=item has Int $.code; The set error code.
=item has Str $.message; The error message.

=end pod
#TT:1:N-GError:
class N-GError is repr('CStruct') is export {
  has GQuark $.domain;            # is GQuark
  has gint $.code;
  has gchar-ptr $.message;
}

#TM:4:new(:native-object):Gnome::N::TopLevelClassSupport
#TM:1:new(:$domain, :code, :error-message):
=begin pod
=head1 Methods
=head2 new

=head3 :domain, :code, :error-message

Create a new Error object. A domain, which is a string must be converted to an unsigned integer with one of the Quark conversion methods. See B<Gnome::Glib::Quark>.

  multi method new ( UInt :$domain!, Int :$code!, Str :$error-message! )

=head3 :native-object

Create a new Error object using an other native error object.

  multi method new ( N-GError :$native-object! )

=end pod

submethod BUILD ( *%options ) {

  # prevent creating wrong widgets
  if self.^name eq 'Gnome::Glib::Error' or ?%options<GError> {

    # check if native object is set by other parent class BUILDers
    if self.is-valid { }

    # process all named arguments
    elsif %options.elems == 0 {
      die X::Gnome.new(:message('No options specified ' ~ self.^name));
    }

    elsif %options<domain>:exists and %options<code>:exists and
          %options<error-message>:exists {

      self.set-native-object(
        _g_error_new_literal(
          %options<domain>, %options<code>, %options<error-message>
        )
      );
    }

    elsif %options<gerror>:exists {
      Gnome::N::deprecate(
        '.new(:gerror())', '.new(:native-object())', '0.15.5', '0.18.0'
      );
      _g_error_new_literal(%options<gerror>);
    }

    # only after creating the native-object, the gtype is known
    self.set-class-info('GError');
  }
}

#-------------------------------------------------------------------------------
method _fallback ( $native-sub --> Callable ) {

  my Callable $s;
  try { $s = &::("g_error_$native-sub"); };
  try { $s = &::("g_$native-sub"); } unless ?$s;
  try { $s = &::($native-sub); } if !$s and $native-sub ~~ m/^ 'g_' /;

  self.set-class-name-of-sub('GError');

  $s
}

#-------------------------------------------------------------------------------
method error-is-valid ( --> Bool ) {

  Gnome::N::deprecate(
    '.error-is-valid()', '.is-valid()', '0.15.5', '0.18.0'
  );

  self.is-valid;
}

#-------------------------------------------------------------------------------
method clear-error ( ) {

  Gnome::N::deprecate(
    '.clear-error()', '.clear-object()', '0.15.5', '0.18.0'
  );

  self.clear-object;
}

#-------------------------------------------------------------------------------
# no ref/unref for a variant type
method native-object-ref ( $n-native-object --> N-GError ) {
  $n-native-object
}

#-------------------------------------------------------------------------------
method native-object-unref ( $n-native-object ) {
  _g_error_free($n-native-object)
}

#-------------------------------------------------------------------------------
#TM:1:domain
=begin pod
=head2 domain

Get the domain code from the error object. Use C<to-string()> from I<Gnome::Glib::Quark> to get the domain text representation of it. Returns C<UInt> if object is invalid.

  method domain ( --> UInt )

=end pod

method domain ( --> UInt ) {
  self.is-valid ?? self.get-native-object-no-reffing.domain !! UInt;
}

#-------------------------------------------------------------------------------
#TM:1:code
=begin pod
=head2 code

Return the error code of the error. Returns C<Int> if object is invalid.

  method code ( --> Int )

=end pod

method code ( --> Int ) {
  self.is-valid ?? self.get-native-object-no-reffing.code !! Int;
}

#-------------------------------------------------------------------------------
#TM:1:message
=begin pod
=head2 message

Return the error message in the error object. Returns C<Str> if object is invalid.

  method message ( --> Str )

=end pod

method message ( --> Str ) {
  self.is-valid ?? self.get-native-object-no-reffing.message !! Str;
}

#`{{ Todo
#-------------------------------------------------------------------------------
method set-error ( --> CArray[N-GError] ) {
  if $!is-valid {
    _g_error_free($!g-gerror);
    $!is-valid = False;
    $!g-gerror = N-GError;
  }

  state CArray[N-GError] $ga;
  $ga .= new(N-GError);
  $!g-gerror := $ga[0];

  $ga
}
}}
#`{{
#-------------------------------------------------------------------------------
=begin pod
=head2 [g_] error_new

Creates a new C<N-GError> with the given I<domain>, I<code> and a I<error-message>. Originally the message is a printf like string followed with variables to be substituted in the format string. This can be easily solved in Raku and is therefore simplified here. A warning; every percent character is substituted with the text 'percent-filtered-out' to prevent crashes in the C function. If needed please use C<g_error_new_literal()>.

Returns: a new C<N-GError>

  method g_error_new ( UInt $domain, Int $code, Str $format --> N-GError)

=item N-GObject $domain; error domain
=item Int $code; error code
=item Str $error-message; the message

=end pod

sub g_error_new (
  UInt $domain, Int $code, Str $error-message --> N-GError
) is inlinable {
  $error-message ~~ s/'%'/'percent-filtered-out'/;
  _g_error_new( $domain, $code, $error-message, Any)
}

sub _g_error_new (
  int32 $domain, int32 $code, Str $format, Str $any --> N-GError )
  is native(&glib-lib)
  is symbol('g_error_new')
  { * }
}}

#-------------------------------------------------------------------------------
#TM:2:_g_error_new_literal:new( :domain, :code, :error-message)
#`{{
=begin pod
=head2 [[g_] error_] new_literal

Creates a new C<N-GError>.

  method g_error_new_literal (
    UInt $domain, Int $code, Str $message --> N-GError
  )

=item UInt $domain; error domain
=item Int $code; error code
=item Str $message; error message

=end pod
}}

sub _g_error_new_literal (
  GQuark $domain, gint $code, Str $message --> N-GError
) is native(&glib-lib)
  is symbol('g_error_new_literal')
  { * }

#`{{
#-------------------------------------------------------------------------------
=begin pod
=head2 [[g_] error_] new_valist

Creates a new C<N-GError> with the given I<domain> and I<code>,
and a message formatted with I<format>.

Returns: a new C<N-GError>

Since: 2.22

  method g_error_new_valist ( N-GObject $domain, Int $code, Str $format,  $va_list args G_GNUC_PRINTF3,  $0 --> N-GObject  )

=item N-GObject $domain; error domain
=item Int $code; error code
=item Str $format; C<printf()>-style format for error message
=item  $va_list args G_GNUC_PRINTF3; C<va_list> of parameters for the message format
=item  $0;

=end pod

sub g_error_new_valist ( N-GObject $domain, int32 $code, Str $format,  $va_list args G_GNUC_PRINTF3,  $0 --> N-GObject )
  is native(&glib-lib)
  { * }
}}

#-------------------------------------------------------------------------------
# do not document. used indirectly via clear-error()
sub _g_error_free ( N-GError $error )
  is native(&glib-lib)
  is symbol('g_error_free')
  { * }

#-------------------------------------------------------------------------------
#TM:1:g_error_copy
=begin pod
=head2 [g_] error_copy

Makes a copy of the native error object.

  # create or get the error object from somewhere
  my Gnome::Glib::Error $e = ...;

  # later one can copy the error if needed and create a second object
  my Gnome::Glib::Error $e2 .= new(:native-object($e.g-error-copy));

Returns: a new C<N-GError>

  method g_error_copy ( --> N-GError )

=end pod

sub g_error_copy ( N-GError $error --> N-GError )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:g_error_matches
=begin pod
=head2 [g_] error_matches

Returns C<1> if Gnome::Glib::Error> matches I<$domain> and I<$code>, C<0> otherwise. In particular, when I<error> is C<Any>, C<0> will be returned.

=begin comment
If I<$domain> contains a `FAILED` (or otherwise generic) error code, you should generally not check for it explicitly, but should instead treat any not-explicitly-recognized error code as being equivalent to the `FAILED` code. This way, if the domain is extended in the future to provide a more specific error code for a certain case, your code will still work.
=end comment

  method g_error_matches ( UInt $domain, Int $code --> Int  )

=item Uint $domain; an error domain
=item Int $code; an error code

=end pod

sub g_error_matches ( N-GError $error, GQuark $domain, gint $code --> gboolean )
  is native(&glib-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
=begin pod
=head2 [g_] set_error

Does nothing if I<err> is C<Any>; if I<err> is non-C<Any>, then I<err>
must be C<Any>. A new C<N-GError> is created and assigned to I<err>. I<message> is like in C<g_error_new()> filtered from percent characters. For these strings please use C<g_set_error_literal()>.

  method g_set_error ( UInt $domain, Int $code, Str $error-message --> Int)

=item UInt $domain; error domain
=item Int $code; error code
=item Str $error-message

=end pod

sub g_set_error (
  N-GError $err, UInt $domain, Int $code, Str $error-message --> Int
) is inlinable {
  $error-message ~~ s/'%'/'percent-filtered-out'/;
  _g_set_error( $domain, $code, $error-message, Any)
}

sub _g_set_error (
  N-GError $err, uint32 $domain, int32 $code, Str $format, Str $any
--> int32 )
  is native(&glib-lib)
  is symbol('g_set_error')
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
=begin pod
=head2 [g_] set_error_literal

Does nothing if I<err> is C<Any>; if I<err> is non-C<Any>, then I<err>
must be C<Any>. A new C<GError> is created and assigned to I<err>.

Since: 2.18

  method g_set_error_literal ( UInt $domain, Int $code, Str $message )

=item N-GObject $domain; error domain
=item Int $code; error code
=item Str $message; error message

=end pod

sub g_set_error_literal (
  N-GError $err is rw, uint32 $domain, int32 $code, Str $message
) is native(&glib-lib)
  { * }
}}
#`{{
#-------------------------------------------------------------------------------
=begin pod
=head2 [g_] propagate_error

If I<dest> is C<Any>, free I<src>; otherwise, moves I<src> into I<dest>.
The error variable I<dest> points to must be C<Any>.

I<src> must be defined.

Note that I<src> is no longer valid after this call. If you want
to keep using the same GError*, you need to set it to C<Any>
after calling this function on it.

  method g_propagate_error ( N-GObject $src )

=item N-GObject $src; (transfer full): error to move into the return location

=end pod

sub g_propagate_error ( N-GObject $dest, N-GObject $src )
  is native(&glib-lib)
  { * }
}}
#`{{
#-------------------------------------------------------------------------------
=begin pod
=head2 [g_] clear_error

Calls C<g_error_free()> on the native object and sets it to C<Any>.

  method g_clear_error ( )

=end pod

sub g_clear_error ( N-GError $err )
  is native(&glib-lib)
  { * }
}}
#`{{
#-------------------------------------------------------------------------------
=begin pod
=head2 [g_] prefix_error

Formats a string according to I<format> and prefix it to an existing
error message. If I<err> is C<Any> (ie: no error variable) then do
nothing.

If I<err> is C<Any> (ie: an error variable is present but there is no
error condition) then also do nothing.

Since: 2.16

  method g_prefix_error ( Str $format,  $3 )

=item Str $format; C<printf()>-style format string @...: arguments to I<format>
=item  $3;

=end pod

sub g_prefix_error ( N-GObject $err, Str $format, Any $any = Any,  $3 )
  is native(&glib-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
=begin pod
=head2 [g_] propagate_prefixed_error

If I<dest> is C<Any>, free I<src>; otherwise, moves I<src> into *I<dest>.
*I<dest> must be C<Any>. After the move, add a prefix as with
C<g_prefix_error()>.

Since: 2.16

  method g_propagate_prefixed_error ( N-GObject $src, Str $format,  $4 )

=item N-GObject $src; error to move into the return location
=item Str $format; C<printf()>-style format string @...: arguments to I<format>
=item  $4;

=end pod

sub g_propagate_prefixed_error ( N-GObject $dest, N-GObject $src, Str $format, Any $any = Any,  $4 )
  is native(&glib-lib)
  { * }
}}
