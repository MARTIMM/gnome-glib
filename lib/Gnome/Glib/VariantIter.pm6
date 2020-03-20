#TL:1:Gnome::Glib::VariantIter:

use v6;
#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Glib::VariantIter

Variant iterator

=comment head1 Description


=head1 Synopsis
=head2 Declaration

  unit class Gnome::Glib::VariantIter;
  also is Gnome::N::TopLevelClassSupport;

=comment head2 Example

=end pod
#-------------------------------------------------------------------------------
use NativeCall;

use Gnome::N::X;
use Gnome::N::NativeLib;
use Gnome::N::TopLevelClassSupport;
use Gnome::N::N-GVariant;
use Gnome::N::N-GVariantIter;

#-------------------------------------------------------------------------------
unit class Gnome::Glib::VariantIter:auth<github:MARTIMM>;
also is Gnome::N::TopLevelClassSupport;

#-------------------------------------------------------------------------------
=begin pod
=head1 Methods
=head2 new

Create a new VariantIter object using a Variant object. Must be freed using C<.g_variant_iter_free()>.

  multi method new ( N-GVariant :$variant! )

Create a VariantIter object using a native object from elsewhere.

  multi method new ( N-GVariantType :$native-object! )

=end pod

#TM:1:new():
#TM:4:new(:native-object):Gnome::N::TopLevelClassSupport
submethod BUILD ( *%options ) {

  # prevent creating wrong native-objects
  if self.^name eq 'Gnome::Glib::VariantIter' or ?%options<VariantIter> {

    # check if native object is set by other parent class BUILDers
    if self.is-valid { }

    # process all named arguments
    elsif %options.elems == 0 {
      die X::Gnome.new(:message('No options specified ' ~ self.^name));
    }

    # create Iter object from a variant obj
    elsif %options<variant> {

      # _g_variant_iter_new sub will take a reference on the variant object
      my $v = %options<variant>;
      $v .= get-native-object-no-reffing
        if $v.^can('get-native-object-no-reffing');
      self.set-native-object(_g_variant_iter_new($v));
    }

    # only after creating the native-object, the gtype is known
    self.set-class-info('GVariantIter');
  }
}

#-------------------------------------------------------------------------------
# no pod. user does not have to know about it.
method _fallback ( $native-sub --> Callable ) {

  my Callable $s;
  try { $s = &::("g_variant_iter_$native-sub"); };
  try { $s = &::("g_$native-sub"); } unless ?$s;
  try { $s = &::($native-sub); } if !$s and $native-sub ~~ m/^ 'g_' /;

  self.set-class-name-of-sub('GVariantIter');

  $s
}

#-------------------------------------------------------------------------------
# no ref/unref for a variant iter
method native-object-ref ( $n-native-object --> N-GVariant ) {
  $n-native-object
}

#-------------------------------------------------------------------------------
method native-object-unref ( $n-native-object ) {
  _g_variant_iter_free($n-native-object)
}

#-------------------------------------------------------------------------------
#TM:2:_g_variant_iter_new:new()
#`{{

Creates a heap-allocated B<Gnome::Glib::VariantIter> for iterating over the items in I<value>. Use C<g_variant_iter_free()> to free the return value when you no longer need it. A reference is taken to I<value> and will be released only when C<g_variant_iter_free()> is called.

Returns: a new heap-allocated B<Gnome::Glib::VariantIter>

  method _g_variant_iter_new ( --> N-GVariantIter )

}}

sub _g_variant_iter_new ( N-GVariant $value --> N-GVariantIter )
  is native(&glib-lib)
  is symbol('g_variant_iter_new')
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_iter_init:
=begin pod
=head2 [g_variant_] iter_init

Initialises (without allocating) a B<Gnome::Glib::VariantIter>.  I<iter> may be
completely uninitialised prior to this call; its old value is
ignored.

The iterator remains valid for as long as I<value> exists, and need not
be freed in any way.

Returns: the number of items in I<value>

  method g_variant_iter_init ( N-GVariantIter $iter, N-GVariant $value --> UInt )

=item N-GVariantIter $iter; a pointer to a B<Gnome::Glib::VariantIter>
=item N-GVariant $value; a container B<Gnome::Glib::Variant>

=end pod

sub g_variant_iter_init ( N-GVariantIter $iter, N-GVariant $value --> uint64 )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_iter_copy:
=begin pod
=head2 [g_variant_] iter_copy

Creates a new heap-allocated B<Gnome::Glib::VariantIter> to iterate over the
container that was being iterated over by I<iter>.  Iteration begins on
the new iterator from the current position of the old iterator but
the two copies are independent past that point.

Use C<g_variant_iter_free()> to free the return value when you no longer
need it.

A reference is taken to the container that I<iter> is iterating over
and will be releated only when C<g_variant_iter_free()> is called.

Returns: (transfer full): a new heap-allocated B<Gnome::Glib::VariantIter>

  method g_variant_iter_copy ( N-GVariantIter $iter --> N-GVariantIter )

=item N-GVariantIter $iter; a B<Gnome::Glib::VariantIter>

=end pod

sub g_variant_iter_copy ( N-GVariantIter $iter --> N-GVariantIter )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_iter_n_children:
=begin pod
=head2 [g_variant_] iter_n_children

Queries the number of child items in the container that we are
iterating over.  This is the total number of items -- not the number
of items remaining.

This function might be useful for preallocation of arrays.

Returns: the number of children in the container

  method g_variant_iter_n_children ( N-GVariantIter $iter --> UInt )

=item N-GVariantIter $iter; a B<Gnome::Glib::VariantIter>

=end pod

sub g_variant_iter_n_children ( N-GVariantIter $iter --> uint64 )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:g_variant_iter_free:
=begin pod
=head2 [g_variant_] iter_free

Frees a heap-allocated B<Gnome::Glib::VariantIter>.  Only call this function on
iterators that were returned by C<.new(:$variant))> or
C<g_variant_iter_copy()>.

  method g_variant_iter_free ( N-GVariantIter $iter )

=item N-GVariantIter $iter; (transfer full): a heap-allocated B<Gnome::Glib::VariantIter>

=end pod

sub _g_variant_iter_free ( N-GVariantIter $iter )
  is native(&glib-lib)
  is symbol('g_variant_iter_free')
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_iter_next_value:
=begin pod
=head2 [g_variant_] iter_next_value

Gets the next item in the container.  If no more items remain then
C<Any> is returned.

Use C<g_variant_unref()> to drop your reference on the return value when
you no longer need it.

Here is an example for iterating with C<g_variant_iter_next_value()>:
|[<!-- language="C" -->
// recursively iterate a container
void
iterate_container_recursive (GVariant *container)
{
N-GVariantIter iter;
GVariant *child;

g_variant_iter_init (&iter, container);
while ((child = g_variant_iter_next_value (&iter)))
{
g_print ("type 'C<s>'\n", g_variant_get_type_string (child));

if (g_variant_is_container (child))
iterate_container_recursive (child);

g_variant_unref (child);
}
}
]|

Returns: (nullable) (transfer full): a B<Gnome::Glib::Variant>, or C<Any>

  method g_variant_iter_next_value ( N-GVariantIter $iter --> N-GVariant )

=item N-GVariantIter $iter; a B<Gnome::Glib::VariantIter>

=end pod

sub g_variant_iter_next_value ( N-GVariantIter $iter --> N-GVariant )
  is native(&glib-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
#TM:0:g_variant_iter_next:
=begin pod
=head2 [g_variant_] iter_next

Gets the next item in the container and unpacks it into the variable
argument list according to I<format_string>, returning C<1>.

If no more items remain then C<0> is returned.

All of the pointers given on the variable arguments list of this
function are assumed to point at uninitialised memory.  It is the
responsibility of the caller to free all of the values returned by
the unpacking process.

Here is an example for memory management with C<g_variant_iter_next()>:
|[<!-- language="C" -->
// Iterates a dictionary of type 'a{sv}'
void
iterate_dictionary (GVariant *dictionary)
{
N-GVariantIter iter;
GVariant *value;
gchar *key;

g_variant_iter_init (&iter, dictionary);
while (g_variant_iter_next (&iter, "{sv}", &key, &value))
{
g_print ("Item 'C<s>' has type 'C<s>'\n", key,
g_variant_get_type_string (value));

// must free data for ourselves
g_variant_unref (value);
g_free (key);
}
}
]|

For a solution that is likely to be more convenient to C programmers
when dealing with loops, see C<g_variant_iter_loop()>.

I<format_string> determines the C types that are used for unpacking
the values and also determines if the values are copied or borrowed.

See the section on
[GVariant format strings][gvariant-format-strings-pointers].

Returns: C<1> if a value was unpacked, or C<0> if there as no value

  method g_variant_iter_next ( N-GVariantIter $iter, Str $format_string --> Int )

=item N-GVariantIter $iter; a B<Gnome::Glib::VariantIter>
=item Str $format_string; a GVariant format string @...: the arguments to unpack the value into

=end pod

sub g_variant_iter_next ( N-GVariantIter $iter, Str $format_string, Any $any = Any --> int32 )
  is native(&glib-lib)
  { * }

sub g_variant_iter_next (
  N-GVariantIter $iter, Str $format_string --> Any
) {



  # get a pointer to the sub, then cast it to a sub with the proper
  # signature. after that, the sub can be called, returning a value.
  state $ptr = cglobal( &glib-lib, 'g_variant_iter_next', Pointer);
  my Callable $f = nativecast( $signature, $ptr);

  $f( $title, $parent, $action, |@buttons, Pointer)

}
}}

#`{{
#-------------------------------------------------------------------------------
#TM:0:g_variant_iter_loop:
=begin pod
=head2 [g_variant_] iter_loop

Gets the next item in the container and unpacks it into the variable
argument list according to I<format_string>, returning C<1>.

If no more items remain then C<0> is returned.

On the first call to this function, the pointers appearing on the
variable argument list are assumed to point at uninitialised memory.
On the second and later calls, it is assumed that the same pointers
will be given and that they will point to the memory as set by the
previous call to this function.  This allows the previous values to
be freed, as appropriate.

This function is intended to be used with a while loop as
demonstrated in the following example.  This function can only be
used when iterating over an array.  It is only valid to call this
function with a string constant for the format string and the same
string constant must be used each time.  Mixing calls to this
function and C<g_variant_iter_next()> or C<g_variant_iter_next_value()> on
the same iterator causes undefined behavior.

If you break out of a such a while loop using C<g_variant_iter_loop()> then
you must free or unreference all the unpacked values as you would with
C<g_variant_get()>. Failure to do so will cause a memory leak.

Here is an example for memory management with C<g_variant_iter_loop()>:
|[<!-- language="C" -->
// Iterates a dictionary of type 'a{sv}'
void
iterate_dictionary (GVariant *dictionary)
{
N-GVariantIter iter;
GVariant *value;
gchar *key;

g_variant_iter_init (&iter, dictionary);
while (g_variant_iter_loop (&iter, "{sv}", &key, &value))
{
g_print ("Item 'C<s>' has type 'C<s>'\n", key,
g_variant_get_type_string (value));

// no need to free 'key' and 'value' here
// unless breaking out of this loop
}
}
]|

For most cases you should use C<g_variant_iter_next()>.

This function is really only useful when unpacking into B<Gnome::Glib::Variant> or
B<Gnome::Glib::VariantIter> in order to allow you to skip the call to
C<g_variant_unref()> or C<g_variant_iter_free()>.

For example, if you are only looping over simple integer and string
types, C<g_variant_iter_next()> is definitely preferred.  For string
types, use the '&' prefix to avoid allocating any memory at all (and
thereby avoiding the need to free anything as well).

I<format_string> determines the C types that are used for unpacking
the values and also determines if the values are copied or borrowed.

See the section on
[GVariant format strings][gvariant-format-strings-pointers].

Returns: C<1> if a value was unpacked, or C<0> if there was no
value

  method g_variant_iter_loop ( N-GVariantIter $iter, Str $format_string --> Int )

=item N-GVariantIter $iter; a B<Gnome::Glib::VariantIter>
=item Str $format_string; a GVariant format string @...: the arguments to unpack the value into

=end pod

sub g_variant_iter_loop ( N-GVariantIter $iter, Str $format_string, Any $any = Any --> int32 )
  is native(&glib-lib)
  { * }
}}
