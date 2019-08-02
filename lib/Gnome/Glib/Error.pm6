use v6;
#-------------------------------------------------------------------------------
=begin pod

=TITLE Gnome::Glib::Error

=SUBTITLE a system for reporting errors

=head1 Description

GLib provides a standard method of reporting errors from a called function to the calling code. Functions that can fail take a return location for a C<N-GError> as their last argument. On error, a new C<N-GError> instance will be allocated and returned to the caller via this argument. After handling the error, the error object must be freed. Do this using C<clear-error()>.

=begin comment
For example:

  gboolean g_file_get_contents (const gchar  *filename,
                                gchar       **contents,
                                gsize        *length,
                                GError      **error);

If you pass a non-C<Any> value for the `error` argument, it should
point to a location where an error can be placed. For example:

  gchar *contents;
  GError *err = NULL;

  g_file_get_contents ("foo.txt", &contents, NULL, &err);
  g_assert ((contents == NULL && err != NULL) || (contents != NULL && err == NULL));
  if (err != NULL)
    {
      // Report error to user, and free error
      g_assert (contents == NULL);
      fprintf (stderr, "Unable to read file: C<s>\n", err->message);
      g_error_free (err);
    }
  else
    {
      // Use file contents
      g_assert (contents != NULL);
    }

Note that `err != NULL` in this example is a reliable indicator
of whether C<g_file_get_contents()> failed. Additionally,
C<g_file_get_contents()> returns a boolean which
indicates whether it was successful.
=end comment

Because C<g_file_get_contents()> returns C<0> on failure, if you
are only interested in whether it failed and don't need to display
an error message, you can pass C<Any> for the I<error> argument:
=begin comment
  if (g_file_get_contents ("foo.txt", &contents, NULL, NULL)) // ignore errors
    // no error occurred
    ;
  else
    // error
    ;
=end comment

The C<GError> object contains three fields: I<domain> indicates the module
the error-reporting function is located in, I<code> indicates the specific
error that occurred, and I<message> is a user-readable error message with
as many details as possible. Several functions are provided to deal
with an error received from a called function: C<g_error_matches()>
returns C<1> if the error matches a given domain and code,
C<g_propagate_error()> copies an error into an error location (so the
calling function will receive it), and C<g_clear_error()> clears an
error location by freeing the error and resetting the location to
C<Any>. To display an error to the user, simply display the I<message>,
perhaps along with additional context known only to the calling
function (the file being opened, or whatever - though in the
C<g_file_get_contents()> case, the I<message> already contains a filename).

When implementing a function that can report errors, the basic
tool is C<g_set_error()>. Typically, if a fatal error occurs you
want to C<g_set_error()>, then return immediately. C<g_set_error()>
does nothing if the error location passed to it is C<Any>.

=begin comment
Here's an example:

  gint
  foo_open_file (GError **error)
  {
    gint fd;
    int saved_errno;

    g_return_val_if_fail (error == NULL || *error == NULL, -1);

    fd = open ("file.txt", O_RDONLY);
    saved_errno = errno;

    if (fd < 0)
      {
        g_set_error (error,
                     FOO_ERROR,                 // error domain
                     FOO_ERROR_BLAH,            // error code
                     "Failed to open file: C<s>", // error message format string
                     g_strerror (saved_errno));
        return -1;
      }
    else
      return fd;
  }
=end comment

=begin comment
Things are somewhat more complicated if you yourself call another
function that can report a C<GError>. If the sub-function indicates
fatal errors in some way other than reporting a C<GError>, such as
by returning C<1> on success, you can simply do the following:
|[<!-- language="C" -->
gboolean
my_function_that_can_fail (GError **err)
{
  g_return_val_if_fail (err == NULL || *err == NULL, FALSE);

  if (!sub_function_that_can_fail (err))
    {
      // assert that error was set by the sub-function
      g_assert (err == NULL || *err != NULL);
      return FALSE;
    }

  // otherwise continue, no error occurred
  g_assert (err == NULL || *err == NULL);
}
]|
=end comment

If the sub-function does not indicate errors other than by
reporting a C<GError> (or if its return value does not reliably indicate
errors) you need to create a temporary C<GError>
since the passed-in one may be C<Any>. C<g_propagate_error()> is
intended for use in this case.
=begin comment
|[<!-- language="C" -->
gboolean
my_function_that_can_fail (GError **err)
{
  GError *tmp_error;

  g_return_val_if_fail (err == NULL || *err == NULL, FALSE);

  tmp_error = NULL;
  sub_function_that_can_fail (&tmp_error);

  if (tmp_error != NULL)
    {
      // store tmp_error in err, if err != NULL,
      // otherwise call C<g_error_free()> on tmp_error
      g_propagate_error (err, tmp_error);
      return FALSE;
    }

  // otherwise continue, no error occurred
}
]|
=end comment

=begin comment
Error pileups are always a bug. For example, this code is incorrect:
|[<!-- language="C" -->
gboolean
my_function_that_can_fail (GError **err)
{
  GError *tmp_error;

  g_return_val_if_fail (err == NULL || *err == NULL, FALSE);

  tmp_error = NULL;
  sub_function_that_can_fail (&tmp_error);
  other_function_that_can_fail (&tmp_error);

  if (tmp_error != NULL)
    {
      g_propagate_error (err, tmp_error);
      return FALSE;
    }
}
]|
=end comment

I<tmp_error> should be checked immediately after C<sub_function_that_can_fail()>, and either cleared or propagated upward. The rule is: after each error, you must either handle the error, or return it to the calling function.

Note that passing C<Any> for the error location is the equivalent of handling an error by always doing nothing about it. So the following code is fine, assuming errors in C<sub_function_that_can_fail()> are not fatal to C<my_function_that_can_fail()>:

=begin comment

|[<!-- language="C" -->
gboolean
my_function_that_can_fail (GError **err)
{
  GError *tmp_error;

  g_return_val_if_fail (err == NULL || *err == NULL, FALSE);

  sub_function_that_can_fail (NULL); // ignore errors

  tmp_error = NULL;
  other_function_that_can_fail (&tmp_error);

  if (tmp_error != NULL)
    {
      g_propagate_error (err, tmp_error);
      return FALSE;
    }
}
]|
=end comment

Note that passing C<Any> for the error location ignores errors;
it's equivalent to
`try { C<sub_function_that_can_fail()>; } catch (...) {}`
in C++. It does not mean to leave errors unhandled; it means
to handle them by doing nothing.

Error domains and codes are conventionally named as follows:

- The error domain is called <NAMESPACE>_<MODULE>_ERROR,
  for example C<G_SPAWN_ERROR> or C<G_THREAD_ERROR>:

=begin comment
  |[<!-- language="C" -->
  C<define> G_SPAWN_ERROR C<g_spawn_error_quark()>

  GQuark
  g_spawn_error_quark (void)
  {
      return g_quark_from_static_string ("g-spawn-error-quark");
  }
  ]|
=end comment

- The quark function for the error domain is called
  <namespace>_<module>_error_quark,
  for example C<g_spawn_error_quark()> or C<g_thread_error_quark()>.

- The error codes are in an enumeration called
  <Namespace><Module>Error;
  for example, C<GThreadError> or C<GSpawnError>.

- Members of the error code enumeration are called
  <NAMESPACE>_<MODULE>_ERROR_<CODE>,
  for example C<G_SPAWN_ERROR_FORK> or C<G_THREAD_ERROR_AGAIN>.

- If there's a "generic" or "unknown" error code for unrecoverable
  errors it doesn't make sense to distinguish with specific codes,
  it should be called <NAMESPACE>_<MODULE>_ERROR_FAILED,
  for example C<G_SPAWN_ERROR_FAILED>. In the case of error code
  enumerations that may be extended in future releases, you should
  generally not handle this error code explicitly, but should
  instead treat any unrecognized error code as equivalent to
  FAILED.

## Comparison of C<GError> and traditional error handling # {C<gerror>-comparison}

C<GError> has several advantages over traditional numeric error codes:
importantly, tools like
[gobject-introspection](https://developer.gnome.org/gi/stable/) understand
C<GErrors> and convert them to exceptions in bindings; the message includes
more information than just a code; and use of a domain helps prevent
misinterpretation of error codes.

C<GError> has disadvantages though: it requires a memory allocation, and
formatting the error message string has a performance overhead. This makes it
unsuitable for use in retry loops where errors are a common case, rather than
being unusual. For example, using C<G_IO_ERROR_WOULD_BLOCK> means hitting these
overheads in the normal control flow. String formatting overhead can be
eliminated by using C<g_set_error_literal()> in some cases.

These performance issues can be compounded if a function wraps the C<GErrors>
returned by the functions it calls: this multiplies the number of allocations
and string formatting operations. This can be partially mitigated by using
C<g_prefix_error()>.

## Rules for use of C<GError> # {C<gerror>-rules}

Summary of rules for use of C<GError>:

- Do not report programming errors via C<GError>.

- The last argument of a function that returns an error should
  be a location where a C<GError> can be placed (i.e. "C<GError>** error").
  If C<GError> is used with varargs, the C<GError>** should be the last
  argument before the "...".

- The caller may pass C<Any> for the C<GError>** if they are not interested
  in details of the exact error that occurred.

- If C<Any> is passed for the C<GError>** argument, then errors should
  not be returned to the caller, but your function should still
  abort and return if an error occurs. That is, control flow should
  not be affected by whether the caller wants to get a C<GError>.

- If a C<GError> is reported, then your function by definition had a
  fatal failure and did not complete whatever it was supposed to do.
  If the failure was not fatal, then you handled it and you should not
  report it. If it was fatal, then you must report it and discontinue
  whatever you were doing immediately.

- If a C<GError> is reported, out parameters are not guaranteed to
  be set to any defined value.

- A C<GError>* must be initialized to C<Any> before passing its address
  to a function that can report errors.

- "Piling up" errors is always a bug. That is, if you assign a
  new C<GError> to a C<GError>* that is non-C<Any>, thus overwriting
  the previous error, it indicates that you should have aborted
  the operation instead of continuing. If you were able to continue,
  you should have cleared the previous error with C<g_clear_error()>.
  C<g_set_error()> will complain if you pile up errors.

- By convention, if you return a boolean value indicating success
  then C<1> means success and C<0> means failure. Avoid creating
  functions which have a boolean return value and a GError parameter,
  but where the boolean does something other than signal whether the
  GError is set.  Among other problems, it requires C callers to allocate
  a temporary error.  Instead, provide a "gboolean *" out parameter.
  There are functions in GLib itself such as C<g_key_file_has_key()> that
  are deprecated because of this. If C<0> is returned, the error must
  be set to a non-C<Any> value.  One exception to this is that in situations
  that are already considered to be undefined behaviour (such as when a
  C<g_return_val_if_fail()> check fails), the error need not be set.
  Instead of checking separately whether the error is set, callers
  should ensure that they do not provoke undefined behaviour, then
  assume that the error will be set on failure.

- A C<Any> return value is also frequently used to mean that an error
  occurred. You should make clear in your documentation whether C<Any>
  is a valid return value in non-error cases; if C<Any> is a valid value,
  then users must check whether an error was returned to see if the
  function succeeded.

- When implementing a function that can report errors, you may want
  to add a check at the top of your function that the error return
  location is either C<Any> or contains a C<Any> error (e.g.
  `g_return_if_fail (error == NULL || *error == NULL);`).

=head1 Synopsis
=head2 Declaration

  unit class Gnome::Glib::Error;

=head2 Example

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

=item has uint32 $.domain; The set domain. 0 when cleared.
=item has int32 $.code; The set error code. 0 when cleared.
=item has Str $.message; The error message.

=end pod

class N-GError is repr('CStruct') is export {
  has uint32 $.domain is rw;            # is GQuark
  has int32 $.code is rw;
  has Str $.message;
}

#-------------------------------------------------------------------------------
has N-GError $!g-gerror;

#-------------------------------------------------------------------------------
=begin pod
=head1 Methods
=head2 new

=head3 multi method new ( UInt :$domain!, Int :$code!, Str :$error-message! )

Create a new error object. A domain, which is a string must be converted to an unsigned integer with one of the Quark conversion methods. See C<Gnome::Glib::Quark>.

=head3 multi method new ( N-GError :gerror )

Create a new error object using an other native error object.

=end pod

submethod BUILD ( *%options ) {

  # prevent creating wrong widgets
  # no parent, nor children ...
  # return unless self.^name eq 'Gnome::Glib::Error';

  # process all named arguments
  if %options<domain>.defined and
     %options<code>.defined and
     %options<error-message>.defined {

    $!g-gerror = g_error_new_literal(
      %options<domain>, %options<code>, %options<error-message>
    );
  }

  elsif %options<gerror>.defined {
    $!g-gerror = %options<gerror>
  }

  elsif %options.keys.elems {
    die X::Gnome.new(
      :message('Unsupported options for ' ~ self.^name ~
               ': ' ~ %options.keys.join(', ')
              )
    );
  }
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

  test-call( &$s, $!g-gerror, |c)
}

#-------------------------------------------------------------------------------
method clear-error ( ) {

  _g_error_free($!g-gerror);
  $!g-gerror.domain = 0;
  $!g-gerror.code = 0;
}

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
=begin pod
=head2 [g_error_] new_literal

Creates a new C<N-GError>.

Returns: a new C<N-GError>

  method g_error_new_literal (
    UInt $domain, Int $code, Str $message --> N-GError
  )

=item N-GObject $domain; error domain
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
# do not document. used indirectly using clear-error()
sub _g_error_free ( N-GError $error )
  is native(&glib-lib)
  is symbol('g_error_free')
  { * }

#-------------------------------------------------------------------------------
=begin pod
=head2 g_error_copy

Makes a copy of I<error>.

Returns: a new C<N-GError>

  method g_error_copy ( --> N-GError )

=end pod

sub g_error_copy ( N-GError $error )
  returns N-GError
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
=begin pod
=head2 g_error_matches

Returns C<1> if I<error> matches I<domain> and I<code>, C<0>
otherwise. In particular, when I<error> is C<Any>, C<0> will
be returned.

If I<domain> contains a `FAILED` (or otherwise generic) error code,
you should generally not check for it explicitly, but should
instead treat any not-explicitly-recognized error code as being
equivalent to the `FAILED` code. This way, if the domain is
extended in the future to provide a more specific error code for
a certain case, your code will still work.

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
