#TL:1:Gnome::Glib::VariantBuilder:

use v6;
#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Glib::VariantBuilder

Helper class to build arrays and tuples

=comment head1 Description


=head2 See Also

[Gnome::Glib::VariantType](VariantType.html), [Gnome::Glib::VariantTypeBuilder](VariantTypeBuilder.html), [gvariant format strings](https://developer.gnome.org/glib/stable/gvariant-format-strings.html), [gvariant text format](https://developer.gnome.org/glib/stable/gvariant-text.html).

=head1 Synopsis
=head2 Declaration

  unit class Gnome::Glib::VariantBuilder;
  also is Gnome::N::TopLevelClassSupport;

=comment head2 Example

=end pod
#-------------------------------------------------------------------------------
use NativeCall;

use Gnome::N::X;
use Gnome::N::NativeLib;
use Gnome::N::N-GVariant;
use Gnome::N::N-GVariantBuilder;
use Gnome::N::N-GVariantType;
use Gnome::N::TopLevelClassSupport;
use Gnome::Glib::Error;
use Gnome::Glib::VariantType;

#-------------------------------------------------------------------------------
unit class Gnome::Glib::VariantBuilder:auth<github:MARTIMM>;
also is Gnome::N::TopLevelClassSupport;

#-------------------------------------------------------------------------------
=begin pod
=head1 Methods
=head2 new

Create a new VariantNuilder object.

  multi method new ( Str :$type-string! )

Create a new VariantNuilder object.

  multi method new ( Gnome::Glib::VariantType :$type! )

Create a Variant object using a native object from elsewhere.

  multi method new ( N-GVariantBuilder :$native-object! )

=end pod

#TM:1:new(:type-string):
#TM:4:new(:native-object):Gnome::N::TopLevelClassSupport
submethod BUILD ( *%options ) {

  # prevent creating wrong native-objects
  if self.^name eq 'Gnome::Glib::VariantBuilder' or ?%options<VariantBuilder> {

    # check if native object is set by other parent class BUILDers
    if self.is-valid { }

    # process all named arguments
    elsif %options.elems == 0 {
      die X::Gnome.new(:message('No options specified ' ~ self.^name));
    }

    elsif ? %options<type-string> {
      self.set-native-object(
        g_variant_builder_new(
          Gnome::Glib::VariantType.new(
            :type-string(%options<type-string>)
          ).get-native-object-no-reffing
        )
      );
    }

    elsif ? %options<type> {
      my $nvt = %options<type>;
      $nvt .= get-native-object if $nvt ~~ Gnome::Glib::VariantType;
      self.set-native-object(g_variant_builder_new($nvt));
    }

    # only after creating the native-object, the gtype is known
    self.set-class-info('GVariantBuilder');
  }
}

#-------------------------------------------------------------------------------
# no pod. user does not have to know about it.
method _fallback ( $native-sub ) {

  my Callable $s;
  try { $s = &::("g_variant_builder_$native-sub"); };
  try { $s = &::("g_$native-sub"); } unless ?$s;
  try { $s = &::($native-sub); } if !$s and $native-sub ~~ m/^ 'g_' /;

  self.set-class-name-of-sub('GVariantBuilder');

  $s
}

#-------------------------------------------------------------------------------
method native-object-ref ( $n-native-object --> N-GVariantBuilder ) {
  _g_variant_builder_ref($n-native-object);
}

#-------------------------------------------------------------------------------
method native-object-unref ( $n-native-object ) {
  _g_variant_builder_unref($n-native-object)
}

#-------------------------------------------------------------------------------
#TM:1:g_variant_builder_new:new(:type),new(:type-string)
=begin pod
=head2 [g_] variant_builder_new

Allocates and initialises a new B<Gnome::Glib::VariantBuilder>.

Returns: a B<Gnome::Glib::VariantBuilder>

  method g_variant_builder_new ( N-GVariantType $type --> N-GVariantBuilder )

=item N-GVariantType $type; a container type

=end pod

sub g_variant_builder_new ( N-GVariantType $type --> N-GVariantBuilder )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#`{{ not for users, use clear-object()
#TM:1:_g_variant_builder_unref:
=begin pod
=head2 [g_] variant_builder_unref

Decreases the reference count on I<builder>. In the event that there are no more references, releases all memory associated with the B<Gnome::Glib::VariantBuilder>.

Don't call this on stack-allocated B<Gnome::Glib::VariantBuilder> instances or bad things will happen.

  method g_variant_builder_unref ( N-GVariantBuilder $builder )

=item N-GVariantBuilder $builder; (transfer full): a B<Gnome::Glib::VariantBuilder> allocated by C<g_variant_builder_new()>

=end pod
}}

sub _g_variant_builder_unref ( N-GVariantBuilder $builder  )
  is native(&glib-lib)
  is symbol('g_variant_builder_unref')
  { * }

#-------------------------------------------------------------------------------
#`{{ not for users
#TM:0:_g_variant_builder_ref:
=begin pod
=head2 [g_] variant_builder_ref

Increases the reference count on I<builder>.

Don't call this on stack-allocated B<Gnome::Glib::VariantBuilder> instances or bad things will happen.

Returns: (transfer full): a new reference to I<builder>

  method g_variant_builder_ref ( N-GVariantBuilder $builder --> N-GVariantBuilder )

=item N-GVariantBuilder $builder; a B<Gnome::Glib::VariantBuilder> allocated by C<g_variant_builder_new()>

=end pod
}}

sub _g_variant_builder_ref ( N-GVariantBuilder $builder --> N-GVariantBuilder )
  is native(&glib-lib)
  is symbol('g_variant_builder_ref')
  { * }

#-------------------------------------------------------------------------------
#TM:1:g_variant_builder_init:
=begin pod
=head2 [g_] variant_builder_init

Initialises a B<Gnome::Glib::VariantBuilder> structure.
B<Please note that the program will crash if the object is not valid!>

I<$type> must be a defined variant type. It specifies the type of container to construct.  It can be an indefinite type such as C<G_VARIANT_TYPE_ARRAY> or a definite type such as "as" or "(ii)". Maybe, array, tuple, dictionary entry and variant-typed values may be constructed.

After the builder is initialised, values are added using C<g_variant_builder_add_value()> or C<g_variant_builder_add()>.

After all the child values are added, C<g_variant_builder_end()> frees the memory associated with the builder and returns the B<Gnome::Glib::Variant> that was created.

This function completely ignores the previous contents of I<builder>. On one hand this means that it is valid to pass in completely uninitialised memory.  On the other hand, this means that if you are initialising over top of an existing B<Gnome::Glib::VariantBuilder> you need to first call C<g_variant_builder_clear()> in order to avoid leaking memory.

=begin comment
You must not call C<g_variant_builder_ref()> or C<g_variant_builder_unref()> on a B<Gnome::Glib::VariantBuilder> that was initialised with this function.  If you ever pass a reference to a B<Gnome::Glib::VariantBuilder> outside of the control of your own code then you should assume that the person receiving that reference may try to use reference counting; you should use C<g_variant_builder_new()> instead of this function.
=end comment

  method g_variant_builder_init ( N-GVariantType $type )

  method g_variant_builder_init ( Str $type-string )

=item N-GVariantBuilder $builder; a B<Gnome::Glib::VariantBuilder>
=item N-GVariantType $type; a container type
=item Str $type-string; In the second form a type string can be provided which is used to create a VariantType.

=end pod

proto sub g_variant_builder_init ( N-GVariantBuilder $builder, | ) { * }
multi
sub g_variant_builder_init ( $builder, N-GVariantType $type ) {
  _g_variant_builder_init( $builder, $type);
}

multi sub g_variant_builder_init ( $builder, Str $type-string ) {
  my Gnome::Glib::VariantType $vt .= new(:$type-string);
  _g_variant_builder_init( $builder, $vt.get-native-object)
}

sub _g_variant_builder_init ( N-GVariantBuilder $builder, N-GVariantType $type )
  is native(&glib-lib)
  is symbol('g_variant_builder_init')
  { * }

#-------------------------------------------------------------------------------
#TM:1:g_variant_builder_end:
=begin pod
=head2 [g_] variant_builder_end

Ends the builder process and returns the constructed value.

It is not permissible to use I<builder> in any way after this call except for reference counting operations (in the case of a heap-allocated B<Gnome::Glib::VariantBuilder>) or by reinitialising it with C<g_variant_builder_init()> (in the case of stack-allocated). This means that for the stack-allocated builders there is no need to call C<g_variant_builder_clear()> after the call to C<g_variant_builder_end()>.

It is an error to call this function in any way that would create an inconsistent value to be constructed (ie: insufficient number of items added to a container with a specific number of children required).  It is also an error to call this function if the builder was created with an indefinite array or maybe type and no children have been added; in this case it is impossible to infer the type of the empty array.

Returns: a new, floating native B<Gnome::Glib::Variant>

  method g_variant_builder_end ( --> N-GVariant )

=item N-GVariantBuilder $builder; a B<Gnome::Glib::VariantBuilder>

=end pod

sub g_variant_builder_end ( N-GVariantBuilder $builder --> N-GVariant )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:g_variant_builder_clear:
=begin pod
=head2 [g_] variant_builder_clear

Releases all memory associated with a B<Gnome::Glib::VariantBuilder> without freeing the B<Gnome::Glib::VariantBuilder> structure itself.

It typically only makes sense to do this on a stack-allocated B<Gnome::Glib::VariantBuilder> if you want to abort building the value part-way through.  This function need not be called if you call C<g_variant_builder_end()> and it also doesn't need to be called on builders allocated with C<g_variant_builder_new()> (see C<g_variant_builder_unref()> for that).

This function leaves the B<Gnome::Glib::VariantBuilder> structure set to all-zeros. It is valid to call this function on either an initialised B<Gnome::Glib::VariantBuilder> or one that is set to all-zeros but it is not valid to call this function on uninitialised memory.

  method g_variant_builder_clear ( )

=item N-GVariantBuilder $builder; a B<Gnome::Glib::VariantBuilder>

=end pod

sub g_variant_builder_clear ( N-GVariantBuilder $builder )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_builder_open:
=begin pod
=head2 [g_] variant_builder_open

Opens a subcontainer inside the given I<builder>.  When done adding items to the subcontainer, C<g_variant_builder_close()> must be called. I<type> is the type of the container: so to build a tuple of several values, I<type> must include the tuple itself.

It is an error to call this function in any way that would cause an inconsistent value to be constructed (ie: adding too many values or a value of an incorrect type).

=begin comment
Example of building a nested variant:
|[<!-- language="C" -->
N-GVariantBuilder builder;
guint32 some_number = C<get_number()>;
g_autoptr (GHashTable) some_dict = C<get_dict()>;
GHashTableIter iter;
const gchar *key;
const GVariant *value;
g_autoptr (GVariant) output = NULL;

g_variant_builder_init (&builder, G_VARIANT_TYPE ("(ua{sv})"));
g_variant_builder_add (&builder, "u", some_number);
g_variant_builder_open (&builder, G_VARIANT_TYPE ("a{sv}"));

g_hash_table_iter_init (&iter, some_dict);
while (g_hash_table_iter_next (&iter, (gpointer *) &key, (gpointer *) &value))
{
g_variant_builder_open (&builder, G_VARIANT_TYPE ("{sv}"));
g_variant_builder_add (&builder, "s", key);
g_variant_builder_add (&builder, "v", value);
g_variant_builder_close (&builder);
}

g_variant_builder_close (&builder);

output = g_variant_builder_end (&builder);
]|
=end comment

  method g_variant_builder_open ( N-GVariantType $type )

=item N-GVariantBuilder $builder; a B<Gnome::Glib::VariantBuilder>
=item N-GVariantType $type; the B<Gnome::Glib::VariantType> of the container

=end pod

sub g_variant_builder_open ( N-GVariantBuilder $builder, N-GVariantType $type  )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_builder_close:
=begin pod
=head2 [g_] variant_builder_close

Closes the subcontainer inside the given I<builder> that was opened by
the most recent call to C<g_variant_builder_open()>.

It is an error to call this function in any way that would create an
inconsistent value to be constructed (ie: too few values added to the
subcontainer).

  method g_variant_builder_close ( )

=item N-GVariantBuilder $builder; a B<Gnome::Glib::VariantBuilder>

=end pod

sub g_variant_builder_close ( N-GVariantBuilder $builder  )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_builder_add_value:
=begin pod
=head2 [[g_] variant_builder_] add_value

Adds I<value> to I<builder>.

It is an error to call this function in any way that would create an inconsistent value to be constructed.  Some examples of this are putting different types of items into an array, putting the wrong types or number of items in a tuple, putting more than one value into a variant, etc.

If I<value> is a floating reference (see C<g_variant_ref_sink()>), the I<builder> instance takes ownership of I<value>.

  method g_variant_builder_add_value ( N-GVariant $value )

Note that gnome errors can be shown on the commandline like

  (process:3360): GLib-CRITICAL **: 17:40:21.705: g_variant_builder_add_value: assertion 'GVSB(builder)->offset < GVSB(builder)->max_items' failed

when too many insertions are done or

  (process:3430): GLib-CRITICAL **: 17:42:24.826: g_variant_builder_add_value: assertion '!GVSB(builder)->expected_type || g_variant_is_of_type (value, GVSB(builder)->expected_type)' failed

when a wrong type of value is inserted

=item N-GVariantBuilder $builder; a B<Gnome::Glib::VariantBuilder>
=item N-GVariant $value; a B<Gnome::Glib::Variant>

=end pod

sub g_variant_builder_add_value (
  N-GVariantBuilder $builder, N-GVariant $value
) is native(&glib-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
#TM:0:g_variant_builder_add:
=begin pod
=head2 [g_] variant_builder_add

Adds to a B<Gnome::Glib::VariantBuilder>.

This call is a convenience wrapper that is exactly equivalent to
calling C<g_variant_new()> followed by C<g_variant_builder_add_value()>.

Note that the arguments must be of the correct width for their types
specified in I<format_string>. This can be achieved by casting them. See
the [GVariant varargs documentation][gvariant-varargs].

This function might be used as follows:

|[<!-- language="C" -->
GVariant *
make_pointless_dictionary (void)
{
N-GVariantBuilder builder;
int i;

g_variant_builder_init (&builder, G_VARIANT_TYPE_ARRAY);
for (i = 0; i < 16; i++)
{
gchar buf[3];

sprintf (buf, "C<d>", i);
g_variant_builder_add (&builder, "{is}", i, buf);
}

return g_variant_builder_end (&builder);
}
]|

  method g_variant_builder_add ( N-GVariantBuilder $builder, Str $format_string )

=item N-GVariantBuilder $builder; a B<Gnome::Glib::VariantBuilder>
=item Str $format_string; a B<Gnome::Glib::Variant> varargs format string @...: arguments, as per I<format_string>

=end pod

sub g_variant_builder_add ( N-GVariantBuilder $builder, Str $format_string, Any $any = Any  )
  is native(&glib-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:0:g_variant_builder_add_parsed:
=begin pod
=head2 [g_] variant_builder_add_parsed

Adds to a N-GVariantBuilder.

This call is a convenience wrapper that is exactly equivalent to calling g_variant_new_parsed() followed by g_variant_builder_add_value().

Note that the arguments must be of the correct width for their types specified in format_string. This can be achieved by casting them. See the GVariant varargs documentation.

This function might be used as follows:

  method make-pointless-dictionary ( --> Gnome::Glib::Variant ) {

    my Gnome::Glib::VariantBuilder $builder;

    $builder.variant-builder-init(G_VARIANT_TYPE_ARRAY);
    $builder.add-parsed('{"width": <600>}');
    $builder.add-parsed('{"title": <"foo">}');

    g_variant_builder_init (&builder, G_VARIANT_TYPE_ARRAY);
    g_variant_builder_add_parsed (&builder, "{'width', <%i>}", 600);
    g_variant_builder_add_parsed (&builder, "{'title', <%s>}", "foo");
    g_variant_builder_add_parsed (&builder, "{'transparency', <0.5>}");
    return g_variant_builder_end (&builder);
  }

  method g_variant_builder_add_parsed ( Str $data-string )

=item N-GVariantBuilder $builder;
=item Str $format;

=end pod

sub g_variant_builder_add_parsed (
  N-GVariantBuilder $builder, Str $data-string
) is native(&glib-lib)
  { * }
