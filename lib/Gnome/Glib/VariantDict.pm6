#TL:1:Gnome::Glib::Variant:

use v6;
#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Glib::VariantDict

=head1 Description

B<Gnome::Glib::VariantDict> is a mutable interface to GVariant dictionaries.

It can be used for doing a sequence of dictionary lookups in an efficient way on an existing GVariant dictionary or it can be used to construct new dictionaries with a hashtable-like interface. It can also be used for taking existing dictionaries and modifying them in order to create new ones.

B<Gnome::Glib::VariantDict> can only be used with G_VARIANT_TYPE_VARDICT dictionaries.

C<end()> is used to convert the B<Gnome::Glib::VariantDict> back into a dictionary-type B<Gnome::Glib::Variant>. You must call C<clear-object()> afterwards.


=head3 Example

  my Gnome::Glib::VariantDict $vd .= new(
    :variant(
      Gnome::Glib::Variant.new(:parse(Q:q/{ 'width': <350>, 'height': <200>}/))
    )
  );

  $vd.insert-value( 'depth', Gnome::Glib::Variant.new(:parse('-40')));
  say $vd.lookup-value( 'width', 'i').get-int32;  # 350
  $vd.remove('width');

  my Gnome::Glib::Variant $v .= new(:native-object($vd.end));
  $vd.clear-object;
  say 'dict: ' ~ $v.print(False); # dict: {'height': <200>, 'vd01': <-40>}


=head2 See Also

=item L<Variants|Variant.html>
=item L<Variant types|VariantType.html>
=item L<Gnome::Glib::VariantType|VariantType.html>
=item L<Variant format strings|https://developer.gnome.org/glib/stable/gvariant-format-strings.html>
=item L<Variant text format|https://developer.gnome.org/glib/stable/gvariant-text.html>

=head1 Synopsis
=head2 Declaration

  unit class Gnome::Glib::VariantDict;
  also is Gnome::N::TopLevelClassSupport;

=end pod
#-------------------------------------------------------------------------------
use NativeCall;

use Gnome::N::X;
use Gnome::N::NativeLib;
use Gnome::N::TopLevelClassSupport;
use Gnome::N::GlibToRakuTypes;

use Gnome::Glib::N-GVariant;
use Gnome::Glib::N-GVariantDict;
use Gnome::Glib::N-GVariantType;
use Gnome::Glib::Error;
use Gnome::Glib::VariantType;
use Gnome::Glib::Variant;

#-------------------------------------------------------------------------------
unit class Gnome::Glib::VariantDict:auth<github:MARTIMM>:ver<0.1.0>;
also is Gnome::N::TopLevelClassSupport;

#-------------------------------------------------------------------------------
=begin pod
=head1 Methods
=head2 new

=head3 default no options

=head3 :variant

=end pod
#TM:0:new
#TM:1:new(:variant)
#TM:4:new(:native-object):Gnome::N::TopLevelClassSupport
submethod BUILD ( *%options ) {

  # prevent creating wrong native-objects
  if self.^name eq 'Gnome::Glib::VariantDict' #`{{or ?%options<GVariantDict>}} {

    # check if native object is set by other parent class BUILDers
    if self.is-valid { }

    elsif %options<native-object>:exists { }

    # process all other options
    else {
      my $no;

      if %options<variant> {
        $no = %options<variant>;
        $no .= get-native-object-no-reffing unless $no ~~ N-GVariant;
        $no = _g_variant_dict_new($no);
      }

      else {
        $no = _g_variant_dict_new(N-GVariant);
      }

      self.set-native-object($no);
    }

    # only after creating the native-object, the gtype is known
    self.set-class-info('GVariantDict');
  }
}

#-------------------------------------------------------------------------------
method native-object-ref ( $n-native-object --> N-GVariantDict ) {
  _g_variant_dict_ref($n-native-object)
}

#-------------------------------------------------------------------------------
method native-object-unref ( $n-native-object ) {
  self.clear;
  _g_variant_dict_unref($n-native-object)
}

#-------------------------------------------------------------------------------
#TM:2:clear:native-object-unref,clear-object
=begin pod
=head2 clear

Releases all memory associated with a B<Gnome::Glib::VariantDict> without freeing the B<Gnome::Glib::VariantDict> structure itself.  It typically only makes sense to do this on a stack-allocated B<Gnome::Glib::VariantDict> if you want to abort building the value part-way through.  This function need not be called if you call C<g_variant_dict_end()> and it also doesn't need to be called on dicts allocated with g_variant_dict_new (see C<clear-object()> for that).  It is valid to call this function on either an initialised B<Gnome::Glib::VariantDict> or one that was previously cleared by an earlier call to C<g_variant_dict_clear()> but it is not valid to call this function on uninitialised memory.

  method clear ( )

=end pod

method clear ( ) {

  g_variant_dict_clear(
    self.get-native-object-no-reffing
  );
}

sub g_variant_dict_clear ( N-GVariantDict $dict  )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:contains:
=begin pod
=head2 contains

Checks if I<$key> exists in I<dict>.

Returns: C<True> if I<$key> is in I<dict>

  method contains ( Str $key --> Bool )

=item Str $key; the key to lookup in the dictionary

=end pod

method contains ( Str $key --> Bool ) {

  g_variant_dict_contains( self.get-native-object-no-reffing, $key).Bool;
}

sub g_variant_dict_contains (
  N-GVariantDict $dict, gchar-ptr $key --> gboolean
) is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:end:
=begin pod
=head2 end

Returns the current value of I<dict> as a B<Gnome::Glib::VariantDict> of type C<G_VARIANT_TYPE_VARDICT>, clearing it in the process.  It is not permissible to use I<dict> in any way after this call except for C<clear-object()>, C<clear()>

=comment Returns: a new, floating, B<Gnome::Glib::VariantDict>
Returns: a new B<Gnome::Glib::Variant> of type C<G_VARIANT_TYPE_VARDICT>.

  method end ( --> N-GVariant )

=end pod

method end ( --> N-GVariant ) {

  g_variant_dict_end(
    self.get-native-object-no-reffing
  );
}

sub g_variant_dict_end ( N-GVariantDict $dict --> N-GVariant )
  is native(&glib-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
# TM:0:init:
=begin pod
=head2 init

Initialises a B<Gnome::Glib::VariantDict> structure.  If I<from_asv> is given, it is used to initialise the dictionary.  This function completely ignores the previous contents of I<dict>.  On one hand this means that it is valid to pass in completely uninitialised memory.  On the other hand, this means that if you are initialising over top of an existing B<Gnome::Glib::VariantDict> you need to first call C<g_variant_dict_clear()> in order to avoid leaking memory.  You must not call C<g_variant_dict_ref()> or C<g_variant_dict_unref()> on a B<Gnome::Glib::VariantDict> that was initialised with this function.  If you ever pass a reference to a B<Gnome::Glib::VariantDict> outside of the control of your own code then you should assume that the person receiving that reference may try to use reference counting; you should use C<g_variant_dict_new()> instead of this function.

  method init ( N-GVariant $from_asv )

=item N-GVariant $from_asv; (nullable): the initial value for I<dict>

=end pod

method init ( N-GVariant $from_asv ) {
  my $no = $from_asv;
  $no .= get-native-object-no-reffing unless $no ~~ N-GVariant;

  g_variant_dict_init(
    self.get-native-object-no-reffing, $no
  );
}

sub g_variant_dict_init ( N-GVariantDict $dict, N-GVariant $from_asv  )
  is native(&glib-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
#TM:0:insert:
=begin pod
=head2 insert

Inserts a value into a B<Gnome::Glib::VariantDict>.
=comment This call is a convenience wrapper that is exactly equivalent to calling C<Gnome::Glib::Variant.new()> followed by C<insert-value()>.

  method insert ( Str $key, Str $string )

=item Str $key; the key to insert a value for
=item Str $string; a B<Gnome::Glib::VariantDict> varargs string

=end pod

method insert ( Str $key, Str $string is copy ) {

  $string ~~ s:g/ '%' /%%/;
  g_variant_dict_insert(
    self.get-native-object-no-reffing, $key, $string, Nil
  );
}

sub g_variant_dict_insert (
  N-GVariantDict $dict, gchar-ptr $key, gchar-ptr $format_string, Pointer
) is native(&glib-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:1:insert-value:
=begin pod
=head2 insert-value

Inserts (or replaces) a key in a B<Gnome::Glib::VariantDict>.  I<value> is consumed if it is floating.

  method insert-value ( Str $key, N-GVariant $value )

=item Str $key; the key to insert a value for
=item N-GVariant $value; the value to insert

=end pod

method insert-value ( Str $key, $value ) {
  my $no = $value;
  $no .= get-native-object-no-reffing unless $no ~~ N-GVariant;

  g_variant_dict_insert_value(
    self.get-native-object-no-reffing, $key, $no
  );
}

sub g_variant_dict_insert_value ( N-GVariantDict $dict, gchar-ptr $key, N-GVariant $value  )
  is native(&glib-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
#TM:0:lookup:
=begin pod
=head2 lookup

Looks up a value in a B<Gnome::Glib::VariantDict>.  This function is a wrapper around C<g_variant_dict_lookup_value()> and C<g_variant_get()>.  In the case that C<Any> would have been returned, this function returns C<0>.  Otherwise, it unpacks the returned value and returns C<1>.  I<format_string> determines the C types that are used for unpacking the values and also determines if the values are copied or borrowed, see the section on [GVariant format strings][gvariant-format-strings-pointers].

Returns: C<True> if a value was unpacked

  method lookup ( Str $key, Str $format_string --> Bool )

=item Str $key; the key to lookup in the dictionary
=item Str $string; a GVariant string @...: the arguments to unpack the value into

=end pod

method lookup ( Str $key, Str $format_string --> Bool ) {

  g_variant_dict_lookup(
    self.get-native-object-no-reffing, $key, $format_string
  ).Bool;
}

sub g_variant_dict_lookup ( N-GVariantDict $dict, gchar-ptr $key, gchar-ptr $format_string, Any $any = Any --> gboolean )
  is native(&glib-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:1:lookup-value:
=begin pod
=head2 lookup-value

Looks up a value in a B<Gnome::Glib::VariantDict>.  If I<$key> is not found in I<dictionary>, an invalid B<Gnome::Glib::Variant> is returned.  The I<$expected_type> string specifies what type of value is expected. If the value associated with I<$key> has a different type then an invalid B<Gnome::Glib::Variant> is returned. If the key is found and the value has the correct type, it is returned. If I<$expected_type> was specified then any valid return value will have this type.

Returns: the value of the dictionary key, or undefined

  method lookup-value (
    Str $key, N-GVariantType $expected_type --> Gnome::Glib::Variant
  )

=item Str $key; the key to lookup in the dictionary
=item N-GVariantType $expected_type; a B<GVariantType>, or C<undefined>

=end pod

multi method lookup-value (
  Str $key, Str $expected-type-string --> Gnome::Glib::Variant
) {
  my $no = Gnome::Glib::VariantType.new(
    :type-string($expected-type-string)
  ).get-native-object-no-reffing;

  my $lv = g_variant_dict_lookup_value(
    self.get-native-object-no-reffing, $key, $no
  );

  Gnome::Glib::Variant.new(:native-object($lv))
}

multi method lookup-value (
  Str $key, $expected_type --> Gnome::Glib::Variant
) {
  my $no = $expected_type;
  $no .= get-native-object-no-reffing unless $no ~~ N-GVariantType;

  Gnome::Glib::Variant.new(
    :native-object(
      g_variant_dict_lookup_value(self.get-native-object-no-reffing, $key, $no)
    )
  )
}

sub g_variant_dict_lookup_value ( N-GVariantDict $dict, gchar-ptr $key, N-GVariantType $expected_type --> N-GVariant )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:remove:
=begin pod
=head2 remove

Removes a key and its associated value from a B<Gnome::Glib::VariantDict>.

Returns: C<True> if the key was found and removed

  method remove ( Str $key --> Bool )

=item Str $key; the key to remove

=end pod

method remove ( Str $key --> Bool ) {

  g_variant_dict_remove(
    self.get-native-object-no-reffing, $key
  ).Bool;
}

sub g_variant_dict_remove ( N-GVariantDict $dict, gchar-ptr $key --> gboolean )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_variant_new_dict_entry:

=begin pod
=head2 _g_variant_new_dict_entry

Creates a new dictionary entry B<Gnome::Glib::VariantDict>. I<key> and I<value> must be non-C<Any>. I<key> must be a value of a basic type (ie: not a container).  If the I<key> or I<value> are floating references (see C<g_variant_ref_sink()>), the new instance takes ownership of them as if via C<g_variant_ref_sink()>.

Returns: a floating reference to a new dictionary entry B<Gnome::Glib::VariantDict>

  method _g_variant_new_dict_entry ( N-GVariant $value --> N-GVariant )

=item N-GVariant $value; a B<Gnome::Glib::VariantDict>, the value

=end pod

sub _g_variant_new_dict_entry (
  N-GVariant $key, N-GVariant $value --> N-GVariantDict
)
  is native(&glib-lib)
  is symbol('g_variant_new_dict_entry')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_variant_dict_ref:
#`{{
=begin pod
=head2 ref

Increases the reference count.  Don't call this on stack-allocated B<Gnome::Glib::VariantDict> instances or bad things will happen.

Returns: a new reference

  method ref ( --> N-GVariantDict )

=end pod

method ref ( --> N-GVariantDict ) {

  g_variant_dict_ref(
    self.get-native-object-no-reffing, $dict
  );
}
}}

sub _g_variant_dict_ref ( N-GVariantDict $dict --> N-GVariantDict )
  is native(&glib-lib)
  is symbol('g_variant_dict_ref')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_variant_dict_unref:
#`{{
=begin pod
=head2 unref

Decreases the reference count.  In the event that there are no more references, releases all memory associated with the B<Gnome::Glib::VariantDict>.  Don't call this on stack-allocated B<Gnome::Glib::VariantDict> instances or bad things will happen.

  method unref ( )

=end pod

method unref ( ) {

  g_variant_dict_unref(
    self.get-native-object-no-reffing, $dict
  );
}
}}

sub _g_variant_dict_unref ( N-GVariantDict $dict  )
  is native(&glib-lib)
  is symbol('g_variant_dict_unref')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_variant_dict_new:
#`{{
=begin pod
=head2 new

Allocates and initialises a new B<Gnome::Glib::VariantDict>.  You should call C<clear-object()> on the return value when it is no longer needed.  The memory will not be automatically freed by any other call.  In some cases it may be easier to place a B<Gnome::Glib::VariantDict> directly on the stack of the calling function and initialise it with C<g_variant_dict_init()>.  This is particularly useful when you are using B<Gnome::Glib::VariantDict> to construct a B<Gnome::Glib::VariantDict>.

Returns: a B<Gnome::Glib::VariantDict>

  method new ( N-GVariant $from_asv --> N-GVariantDict )

=item N-GVariant from_asv; the GVariant with which to initialise the dictionary.

=end pod

method new ( N-GVariant $from_asv --> N-GVariantDict ) {

  g_variant_dict_new(
    self.get-native-object-no-reffing,
  );
}
}}

sub _g_variant_dict_new ( N-GVariant $from_asv --> N-GVariantDict )
  is native(&glib-lib)
  is symbol('g_variant_dict_new')
  { * }
