#TL:1:Gnome::Glib::Error

use v6;

#-------------------------------------------------------------------------------
=begin pod

=TITLE Gnome::Glib::Error

=SUBTITLE a system for reporting errors

=head1 Description

GLib provides a standard method of reporting errors from a called function to the calling code. Functions that can fail take a return location for a C<N-GError> as their last argument. On error, a new C<N-GError> instance will be allocated and returned to the caller via this argument. After handling the error, the error object must be freed. Do this using C<clear-error()>.

The C<N-GError> object contains three fields: I<domain> indicates the module the error-reporting function is located in, I<code> indicates the specific error that occurred, and I<message> is a user-readable error message with as many details as possible. Several functions are provided to deal with an error received from a called function: C<g_error_matches()> returns C<1> if the error matches a given domain and code. To display an error to the user, simply call the C<message()> method, perhaps along with additional context known only to the calling function.

This class is greatly simplified because in Perl6 one can use Exception classes to throw any errors. It exists mainly to handle errors coming from other GTK+ functions.


Error domains and codes are conventionally named as follows:

- The error domain is called I<NAMESPACE>_I<MODULE>_ERROR. For instance glib file utilities uses G_FILE_ERROR.

- The quark function for the error domain is called <namespace>_<module>_error_quark, for example C<g-file-error-quark()>.

- The error codes are in an enumeration called <Namespace><Module>Error, for example C<GFileError>.

- Members of the error code enumeration are called
  <NAMESPACE>_<MODULE>_ERROR_<CODE>, for example C<G_FILE_ERROR_NOENT>.

- If there's a "generic" or "unknown" error code for unrecoverable
  errors it doesn't make sense to distinguish with specific codes,
  it should be called <NAMESPACE>_<MODULE>_ERROR_FAILED,
  for example C<G_SPAWN_ERROR_FAILED>. In the case of error code
  enumerations that may be extended in future releases, you should
  generally not handle this error code explicitly, but should
  instead treat any unrecognized error code as equivalent to
  FAILED.

=head1 Synopsis
=head2 Declaration

  unit class Gnome::Glib::Error;

=head2 Example

  my Gnome::Gtk3::Builder $builder .= new(:empty);

  # try to read non existing file
  my Gnome::Glib::Error $e = $builder.add-from-file('x.glade');
  die $e.message if $e.error-is-valid;

=end pod
#-------------------------------------------------------------------------------
use NativeCall;

use Gnome::N::X;
use Gnome::N::NativeLib;
#use Gnome::N::N-GObject;

#-------------------------------------------------------------------------------
# See /usr/include/glib-2.0/glib/gerror.h
# https://developer.gnome.org/glib/stable/glib-Error-Reporting.html
unit class Gnome::Glib::Error:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------
=begin pod
=head1 Types
=head2 class N-GError;

=item has uint32 $.domain; The set domain.
=item has int32 $.code; The set error code.
=item has Str $.message; The error message.

=end pod

class N-GError is repr('CStruct') is export {
  has uint32 $.domain;            # is GQuark
  has int32 $.code;
  has Str $.message;
}

#-------------------------------------------------------------------------------
has N-GError $!g-gerror;

has Bool $.error-is-valid = False;
#-------------------------------------------------------------------------------
#TN:1:new(:gerror):
#TN:1:new(:$domain, :code, :error-message):

=begin pod
=head1 Methods
=head2 new

=head3 multi method new ( UInt :$domain!, Int :$code!, Str :$error-message! )

Create a new error object. A domain, which is a string must be converted to an unsigned integer with one of the Quark conversion methods. See I<Gnome::Glib::Quark>.

=head3 multi method new ( N-GError :$gerror! )

Create a new error object using an other native error object.

=end pod

submethod BUILD ( *%options ) {

  # prevent creating wrong widgets
  # no parent, nor children ...
  # return unless self.^name eq 'Gnome::Glib::Error';

  # process all named arguments
  if %options.elems == 0 {
    die X::Gnome.new(
      :message( 'No options specified ' ~ self.^name ~
                ': ' ~ %options.keys.join(', ')
      )
    );
  }

  elsif %options<domain>.defined and
     %options<code>.defined and
     %options<error-message>.defined {

    $!g-gerror = g_error_new_literal(
      %options<domain>, %options<code>, %options<error-message>
    );

    $!error-is-valid = ?$!g-gerror;
  }

  elsif %options<gerror>:exists {
    $!g-gerror = %options<gerror>;
    $!error-is-valid = ?$!g-gerror;
  }

  elsif %options.elems {
    die X::Gnome.new(
      :message( 'Unsupported options for ' ~ self.^name ~
                ': ' ~ %options.keys.join(', ')
      )
    );
  }
}

#-------------------------------------------------------------------------------
method CALL-ME ( N-GError $gerror? --> N-GError ) {

  if $gerror.defined {
    _g_error_free($!g-gerror) if $!g-gerror.defined;
    $!g-gerror = $gerror;
    $!error-is-valid = True;
  }

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
  try { $s = &::("g_error_$native-sub"); };
  try { $s = &::("g_$native-sub"); } unless ?$s;
  try { $s = &::($native-sub); } if !$s and $native-sub ~~ m/^ 'g_' /;

  test-call( &$s, $!g-gerror, |c)
}

#-------------------------------------------------------------------------------
#TM:1:error-is-valid
# doc of $!error-is-valid defined above
=begin pod
=head2 error-is-valid

Returns True if native error object is valid, otherwise C<False>.

  method error-is-valid ( --> Bool )

=end pod

#-------------------------------------------------------------------------------
#TM:1:clear-error
=begin pod
=head2 clear-error

Clear the error and return data to memory to pool. The error object is not valid after this call and error-is-valid() will return C<False>.

  method clear-error ()

=end pod

method clear-error ( ) {

  _g_error_free($!g-gerror) if $!g-gerror.defined;
  $!error-is-valid = False;
  $!g-gerror = N-GError;
}

#-------------------------------------------------------------------------------
#TM:1:domain
=begin pod
=head2 domain

Get the domain code from the error object. Use C<to-string()> from I<Gnome::Glib::Quark> to get the domain text representation of it. Returns C<UInt> if object is invalid.

  method domain ( --> UInt )

=end pod

method domain ( --> UInt ) {
  $!error-is-valid ?? $!g-gerror.domain !! UInt;
}

#-------------------------------------------------------------------------------
#TM:1:code
=begin pod
=head2 code

Return the error code of the error. Returns C<Int> if object is invalid.

  method code ( --> Int )

=end pod

method code ( --> Int ) {
  $!error-is-valid ?? $!g-gerror.code !! Int;
}

#-------------------------------------------------------------------------------
#TM:1:message
=begin pod
=head2 message

Return the error message in the error object. Returns C<Str> if object is invalid.

  method message ( --> Str )

=end pod

method message ( --> Str ) {
  $!error-is-valid ?? $!g-gerror.message !! Str;
}

#`{{ Todo
#-------------------------------------------------------------------------------
method set-error ( --> CArray[N-GError] ) {
  if $!error-is-valid {
    _g_error_free($!g-gerror);
    $!error-is-valid = False;
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
=head2 g_error_new

Creates a new C<N-GError> with the given I<domain>, I<code> and a I<error-message>. Originally the message is a printf like string followed with variables to be substituted in the format string. This can be easily solved in Perl6 and is therefore simplified here. A warning; every percent character is substituted with the text 'percent-filtered-out' to prevent crashes in the C function. If needed please use C<g_error_new_literal()>.

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
  int32 $domain, int32 $code, Str $format, Str $any
) returns N-GError
  is native(&glib-lib)
  is symbol('g_error_new')
  { * }
}}

#-------------------------------------------------------------------------------
#TM:2:g_error_new_literal:new( :domain, :code, :error-message)
=begin pod
=head2 [g_error_] new_literal

Creates a new C<N-GError>.

  method g_error_new_literal (
    UInt $domain, Int $code, Str $message --> N-GError
  )

=item UInt $domain; error domain
=item Int $code; error code
=item Str $message; error message

=end pod

sub g_error_new_literal ( uint32 $domain, int32 $code, Str $message )
  returns N-GError
  is native(&glib-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
=begin pod
=head2 [g_error_] new_valist

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

sub g_error_new_valist ( N-GObject $domain, int32 $code, Str $format,  $va_list args G_GNUC_PRINTF3,  $0 )
  returns N-GObject
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
=head2 g_error_copy

Makes a copy of the native error object.

  # create or get the error object from somewhere
  my Gnome::Glib::Error $e = ...;

  # later one can copy the error if needed and create a second object
  my Gnome::Glib::Error $e2 .= new(:gerror($e.g-error-copy));

Returns: a new C<N-GError>

  method g_error_copy ( --> N-GError )

=end pod

sub g_error_copy ( N-GError $error )
  returns N-GError
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:g_error_matches
=begin pod
=head2 g_error_matches

Returns C<1> if Gnome::Glib::Error> matches I<$domain> and I<$code>, C<0> otherwise. In particular, when I<error> is C<Any>, C<0> will be returned.

=begin comment
If I<$domain> contains a `FAILED` (or otherwise generic) error code,
you should generally not check for it explicitly, but should
instead treat any not-explicitly-recognized error code as being
equivalent to the `FAILED` code. This way, if the domain is
extended in the future to provide a more specific error code for
a certain case, your code will still work.
=end comment

  method g_error_matches ( UInt $domain, Int $code --> Int  )

=item Uint $domain; an error domain
=item Int $code; an error code

=end pod

sub g_error_matches ( N-GError $error, uint32 $domain, int32 $code )
  returns int32
  is native(&glib-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
=begin pod
=head2 g_set_error

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
) returns int32
  is native(&glib-lib)
  is symbol('g_set_error')
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
=begin pod
=head2 g_set_error_literal

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
=head2 g_propagate_error

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
=head2 g_clear_error

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
=head2 g_prefix_error

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
=head2 g_propagate_prefixed_error

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

#-------------------------------------------------------------------------------
=begin pod
=begin comment

=head1 Not yet implemented methods

=head3 method g_error_new_valist ( ... )

=end comment
=end pod

#-------------------------------------------------------------------------------
=begin pod
=begin comment

=head1 Not implemented methods

=head3 method g_error_new ( ... )
=head3 method g_set_error ( ... )
=head3 method g_clear_error ( ... )
=head3 method g_prefix_error ( ... )
=head3 method g_propagate_prefixed_error ( ... )
=head3 method g_propagate_error ( ... )
=head3 method g_set_error_literal ( ... )

=end comment
=end pod




























=finish
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
