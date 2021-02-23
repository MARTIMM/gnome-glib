#TL:1:Gnome::Glib::VariantType:

use v6;
#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Glib::VariantType

introduction to the Gnome::Glib::Variant type system

=head1 Description

This section introduces the Gnome::Glib::Variant type system. It is based, in large part, on the D-Bus type system, with two major changes and some minor lifting of restrictions. The [D-Bus specification](http://dbus.freedesktop.org/doc/dbus-specification.html), therefore, provides a significant amount of information that is useful when working with Gnome::Glib::Variant.

The first major change with respect to the D-Bus type system is the introduction of maybe (or "nullable") types.  Any type in Gnome::Glib::Variant can be converted to a maybe type, in which case, "nothing" (or "null") becomes a valid value.  Maybe types have been added by introducing the character "m" to type strings.

The second major change is that the Gnome::Glib::Variant type system supports the concept of "indefinite types" -- types that are less specific than the normal types found in D-Bus.  For example, it is possible to speak of "an array of any type" in Gnome::Glib::Variant, where the D-Bus type system would require you to speak of "an array of integers" or "an array of strings".  Indefinite types have been added by introducing the characters "*", "?" and "r" to type strings.

Finally, all arbitrary restrictions relating to the complexity of types are lifted along with the restriction that dictionary entries may only appear nested inside of arrays.

Just as in D-Bus, Gnome::Glib::Variant types are described with strings ("type strings").  Subject to the differences mentioned above, these strings are of the same form as those found in DBus.  Note, however: D-Bus always works in terms of messages and therefore individual type strings appear nowhere in its interface.  Instead, "signatures" are a concatenation of the strings of the type of each argument in a message.  Gnome::Glib::Variant deals with single values directly so Gnome::Glib::Variant type strings always describe the type of exactly one value.  This means that a D-Bus signature string is generally not a valid Gnome::Glib::Variant type string -- except in the case that it is the signature of a message containing exactly one argument.

An indefinite type is similar in spirit to what may be called an abstract type in other type systems.  No value can exist that has an indefinite type as its type, but values can exist that have types that are subtypes of indefinite types.  That is to say, C<g_variant_get_type()> will never return an indefinite type, but calling C<g_variant_is_of_type()> with an indefinite type may return C<True>.  For example, you cannot have a value that represents "an array of no particular type", but you can have an "array of integers" which certainly matches the type of "an array of no particular type", since "array of integers" is a subtype of "array of no particular type".

This is similar to how instances of abstract classes may not directly exist in other type systems, but instances of their non-abstract subtypes may.

=begin comment
 For example, in GTK, no object that has the type of B<Gnome::Gtk3::Bin> can exist (since B<Gnome::Gtk3::Bin> is an abstract class), but a B<Gnome::Gtk3::Window> can certainly be instantiated, and you would say that the B<Gnome::Gtk3::Window> is a B<Gnome::Gtk3::Bin> (since B<Gnome::Gtk3::Window> is a subclass of B<Gnome::Gtk3::Bin>).
=end comment

=head2 Gnome::Glib::Variant Type Strings

A Gnome::Glib::Variant type string can be any of the following:

=item any basic type string (listed below)

=item "v", "r" or "*"

=item one of the characters 'a' or 'm', followed by another type string

=item the character '(', followed by a concatenation of zero or more other type strings, followed by the character ')'

=item the character '{', followed by a basic type string (see below), followed by another type string, followed by the character '}'

A basic type string describes a basic type (as per C<g_variant_type_is_basic()>) and is always a single character in length. The valid basic type strings are "b", "y", "n", "q", "i", "u", "x", "t", "h", "d", "s", "o", "g" and "?".

The above definition is recursive to arbitrary depth. "aaaaai" and "(ui(nq((y)))s)" are both valid type strings, as is "a(aa(ui)(qna{ya(yd)}))". In order to not hit memory limits, B<Gnome::Glib::Variant> imposes a limit on recursion depth of 65 nested containers. This is the limit in the D-Bus specification (64) plus one to allow a B<GDBusMessage> to be nested in a top-level tuple.

The meaning of each of the characters is as follows:
=item `b`: the type string of C<G_VARIANT_TYPE_BOOLEAN>; a boolean value.
=item `y`: the type string of C<G_VARIANT_TYPE_BYTE>; a byte.
=item `n`: the type string of C<G_VARIANT_TYPE_INT16>; a signed 16 bit integer.
=item `q`: the type string of C<G_VARIANT_TYPE_UINT16>; an unsigned 16 bit integer.
=item `i`: the type string of C<G_VARIANT_TYPE_INT32>; a signed 32 bit integer.
=item `u`: the type string of C<G_VARIANT_TYPE_UINT32>; an unsigned 32 bit integer.
=item `x`: the type string of C<G_VARIANT_TYPE_INT64>; a signed 64 bit integer.
=item `t`: the type string of C<G_VARIANT_TYPE_UINT64>; an unsigned 64 bit integer.
=item `h`: the type string of C<G_VARIANT_TYPE_HANDLE>; a signed 32 bit value that, by convention, is used as an index into an array of file descriptors that are sent alongside a D-Bus message.
=item `d`: the type string of C<G_VARIANT_TYPE_DOUBLE>; a double precision floating point value.
=item `s`: the type string of C<G_VARIANT_TYPE_STRING>; a string.
=item `o`: the type string of C<G_VARIANT_TYPE_OBJECT_PATH>; a string in the form of a D-Bus object path.
=item `g`: the type string of C<G_VARIANT_TYPE_SIGNATURE>; a string in the form of a D-Bus type signature.
=item `?`: the type string of C<G_VARIANT_TYPE_BASIC>; an indefinite type that is a supertype of any of the basic types.
=item `v`: the type string of C<G_VARIANT_TYPE_VARIANT>; a container type that contain any other type of value.
=item `a`: used as a prefix on another type string to mean an array of that type; the type string "ai", for example, is the type of an array of signed 32-bit integers.
=item `m`: used as a prefix on another type string to mean a "maybe", or "nullable", version of that type; the type string "ms", for example, is the type of a value that maybe contains a string, or maybe contains nothing.
=item `()`: used to enclose zero or more other concatenated type strings to create a tuple type; the type string "(is)", for example, is the type of a pair of an integer and a string.
=item `r`: the type string of C<G_VARIANT_TYPE_TUPLE>; an indefinite type that is a supertype of any tuple type, regardless of the number of items.
=item `{}`: used to enclose a basic type string concatenated with another type string to create a dictionary entry type, which usually appears inside of an array to form a dictionary; the type string "a{sd}", for example, is the type of a dictionary that maps strings to double precision floating point values. The first type (the basic type) is the key type and the second type is the value type. The reason that the first type is restricted to being a basic type is so that it can easily be hashed.
=item `*`: the type string of C<G_VARIANT_TYPE_ANY>; the indefinite type that is a supertype of all types.  Note that, as with all type strings, this character represents exactly one type. It cannot be used inside of tuples to mean "any number of items".

Any type string of a container that contains an indefinite type is, itself, an indefinite type. For example, the type string "a*" (corresponding to C<G_VARIANT_TYPE_ARRAY>) is an indefinite type that is a supertype of every array type. "(*s)" is a supertype of all tuples that contain exactly two items where the second item is a string.

"a{?*}" is an indefinite type that is a supertype of all arrays containing dictionary entries where the key is any basic type and the value is any type at all.  This is, by definition, a dictionary, so this type string corresponds to C<G_VARIANT_TYPE_DICTIONARY>. Note that, due to the restriction that the key of a dictionary entry must be a basic type, "{**}" is not a valid type string.

=head2 Errors

When you provide faulty type strings you can expect gnome errors on the commandline like for example

  (process:1660): GLib-CRITICAL **: 16:40:45.734: g_variant_type_checked_: assertion 'g_variant_type_string_is_valid (type_string)' failed

This, unfortunately, doesn't tell you where it happens.
=comment TODO above errors can be prevented when tests are inserted before applying them and returning the user a stackdump

=head2 See Also

B<Gnome::Glib::Variant>

=head1 Synopsis
=head2 Declaration

  unit class Gnome::Glib::VariantType;
  also is Gnome::N::TopLevelClassSupport;

=comment head2 Example

=end pod
#-------------------------------------------------------------------------------
use NativeCall;

use Gnome::N::X;
use Gnome::N::NativeLib;
use Gnome::N::TopLevelClassSupport;
use Gnome::N::GlibToRakuTypes;

use Gnome::Glib::N-GVariantType;
use Gnome::Glib::N-GVariantType;

#-------------------------------------------------------------------------------
unit class Gnome::Glib::VariantType:auth<github:MARTIMM>:ver<0.1.0>;
also is Gnome::N::TopLevelClassSupport;

#-------------------------------------------------------------------------------
=begin pod
=head1 Types
=end pod

#-------------------------------------------------------------------------------
=begin pod
=head2 Type constants

=item G_VARIANT_TYPE_BOOLEAN; The type of a value that can be either TRUE or FALSE.

=item G_VARIANT_TYPE_BYTE; The type of an integer value that can range from 0 to 255.

=item G_VARIANT_TYPE_INT16; The type of an integer value that can range from -32768 to 32767.

=item G_VARIANT_TYPE_UINT16; The type of an integer value that can range from 0 to 65535. There were about this many people living in Toronto in the 1870s.
=item G_VARIANT_TYPE_INT32; The type of an integer value that can range from -2147483648 to 2147483647.

=item G_VARIANT_TYPE_UINT32; The type of an integer value that can range from 0 to 4294967295. That's one number for everyone who was around in the late 1970s.

=item G_VARIANT_TYPE_INT64; The type of an integer value that can range from -9223372036854775808 to 9223372036854775807.

=item G_VARIANT_TYPE_UINT64; The type of an integer value that can range from 0 to 18446744073709551615 (inclusive). That's a really big number, but a Rubik's cube can have a bit more than twice as many possible positions.

=item G_VARIANT_TYPE_HANDLE; The type of a 32bit signed integer value, that by convention, is used as an index into an array of file descriptors that are sent alongside a D-Bus message. If you are not interacting with D-Bus, then there is no reason to make use of this type.

=item G_VARIANT_TYPE_DOUBLE; The type of a double precision IEEE754 floating point number. These guys go up to about 1.80e308 (plus and minus) but miss out on some numbers in between. In any case, that's far greater than the estimated number of fundamental particles in the observable universe.

=item G_VARIANT_TYPE_STRING; The type of a string. "" is a string. NULL is not a string.

=item G_VARIANT_TYPE_OBJECT_PATH; The type of a D-Bus object reference. These are strings of a specific format used to identify objects at a given destination on the bus. If you are not interacting with D-Bus, then there is no reason to make use of this type. If you are, then the D-Bus specification contains a precise description of valid object paths.

=item G_VARIANT_TYPE_SIGNATURE; The type of a D-Bus type signature. These are strings of a specific format used as type signatures for D-Bus methods and messages. If you are not interacting with D-Bus, then there is no reason to make use of this type. If you are, then the D-Bus specification contains a precise description of valid signature strings.

=item G_VARIANT_TYPE_VARIANT; The type of a box that contains any other value (including another variant).

=item G_VARIANT_TYPE_ANY; An indefinite type that is a supertype of every type (including itself).

=item G_VARIANT_TYPE_BASIC; An indefinite type that is a supertype of every basic (ie: non-container) type.

=item G_VARIANT_TYPE_MAYBE; An indefinite type that is a supertype of every maybe type.

=item G_VARIANT_TYPE_ARRAY; An indefinite type that is a supertype of every array type.

=item G_VARIANT_TYPE_TUPLE; An indefinite type that is a supertype of every tuple type, regardless of the number of items in the tuple.

=item G_VARIANT_TYPE_UNIT; The empty tuple type. Has only one instance. Known also as "triv" or "void".

=item G_VARIANT_TYPE_DICT_ENTRY; An indefinite type that is a supertype of every dictionary entry type.

=item G_VARIANT_TYPE_DICTIONARY; An indefinite type that is a supertype of every dictionary type -- that is, any array type that has an element type equal to any dictionary entry type.

=item G_VARIANT_TYPE_STRINGARRAY; The type of an array of strings.

=item G_VARIANT_TYPE_OBJECT_PATH_ARRAY; The type of an array of object paths.

=item G_VARIANT_TYPE_BYTESTRING; The type of an array of bytes. This type is commonly used to pass around strings that may not be valid utf8. In that case, the convention is that the nul terminator character should be included as the last character in the array.

=item G_VARIANT_TYPE_BYTESTRING_ARRAY; The type of an array of byte strings (an array of arrays of bytes).

=item G_VARIANT_TYPE_VARDICT; The type of a dictionary mapping strings to variants (the ubiquitous "a{sv}" type).

=end pod

#TT:1:GVariantTypeConstants
constant G_VARIANT_TYPE_BOOLEAN is export = 'b';
constant G_VARIANT_TYPE_BYTE is export = 'y';
constant G_VARIANT_TYPE_INT16 is export = 'n';
constant G_VARIANT_TYPE_UINT16 is export = 'q';
constant G_VARIANT_TYPE_INT32 is export = 'i';
constant G_VARIANT_TYPE_UINT32 is export = 'u';
constant G_VARIANT_TYPE_INT64 is export = 'x';
constant G_VARIANT_TYPE_UINT64 is export = 't';
constant G_VARIANT_TYPE_HANDLE is export = 'h';
constant G_VARIANT_TYPE_DOUBLE is export = 'd';
constant G_VARIANT_TYPE_STRING is export = 's';
constant G_VARIANT_TYPE_OBJECT_PATH is export = 'o';
constant G_VARIANT_TYPE_SIGNATURE is export = 'g';
constant G_VARIANT_TYPE_VARIANT is export = 'v';
constant G_VARIANT_TYPE_ANY is export = '*';
constant G_VARIANT_TYPE_BASIC is export = '?';
constant G_VARIANT_TYPE_MAYBE is export = 'm*';
constant G_VARIANT_TYPE_ARRAY is export = 'a*';
constant G_VARIANT_TYPE_TUPLE is export = 'r';
constant G_VARIANT_TYPE_UNIT is export = '()';
constant G_VARIANT_TYPE_DICT_ENTRY is export = '{?*}';
constant G_VARIANT_TYPE_DICTIONARY is export = 'a{?*}';
constant G_VARIANT_TYPE_STRINGARRAY is export = 'as';
constant G_VARIANT_TYPE_OBJECT_PATH_ARRAY is export = 'ao';
constant G_VARIANT_TYPE_BYTESTRING is export = 'ay';
constant G_VARIANT_TYPE_BYTESTRING_ARRAY is export = 'aay';
constant G_VARIANT_TYPE_VARDICT is export = 'a{sv}';
#constant G_VARIANT_TYPE_ is export = '';

#-------------------------------------------------------------------------------
=begin pod
=head1 Methods
=head2 new

=head3 :array

Constructs the type corresponding to an array of elements of the given type in C<$array>.

  multi method new ( N-GVariantType :$array!! )

=head3 :maybe

Constructs the type corresponding to a maybe instance containing in given type

  multi method new ( N-GVariantType :$maybe! )

=begin comment
=head3 :tuple

Constructs a new tuple type from I<items> given by the array $tuple.

  multi method new ( Array[N-GVariantType] :$tuple! )
=end comment

=head3 :type-string

Creates a new B<Gnome::Glib::VariantType> corresponding to the type string given
by I<$type_string>.
=comment TODO Can DESTROY be used in this case? Call C<.clear-object()> to free the data.

It is a programmer error to call this function with an invalid type string. The string is checked to be sure resulting in a (in)valid object. Test with C<.is-valid()> to be sure.

  multi method new ( Str :$type-string! )

=head3 :native-object

Create a VariantType object using a native object from elsewhere. See also B<Gnome::N::TopLevelClassSupport>.

  multi method new ( N-GVariantType :$native-object! )
=end pod

#TM:1:new(:type-string):
#TM:4:new(:native-object):Gnome::N::TopLevelClassSupport
submethod BUILD ( *%options ) {

  # prevent creating wrong native-objects
  if self.^name eq 'Gnome::Glib::VariantType' {

    # check if native object is set by other parent class BUILDers
    if self.is-valid { }

    # check if common options are handled by some parent
    elsif %options<native-object>:exists { }

    # process all other options
    else {
      my $no;
      if ? %options<type-string> {
        $no = _g_variant_type_new(%options<type-string>)
          if self.string-is-valid(%options<type-string>);
      }

      elsif %options<array> {
        $no = %options<array>;
        $no .= get-native-object-no-reffing unless $no ~~ N-GVariantType;
        $no = _g_variant_type_new_array($no);
      }

      elsif %options<maybe> {
        $no = %options<maybe>;
        $no .= get-native-object-no-reffing unless $no ~~ N-GVariantType;
        $no = _g_variant_type_new_maybe($no);
      }

      elsif %options<tuple> {
        $no = _g_variant_type_new_tuple(%options<tuple>);
      }

      ##`{{ when there are no defaults use this
      # check if there are any options
      elsif %options.elems == 0 {
        die X::Gnome.new(:message('No options specified ' ~ self.^name));
      }
      #}}

      self.set-native-object($no);
    }

    # only after creating the native-object, the gtype is known
    self.set-class-info('GVariantType');
  }
}


#-------------------------------------------------------------------------------
# no pod. user does not have to know about it.
method _fallback ( $native-sub --> Callable ) {

  my Callable $s;
  try { $s = &::("g_variant_type_$native-sub"); };
  try { $s = &::("g_$native-sub"); } unless ?$s;
  try { $s = &::($native-sub); } if !$s and $native-sub ~~ m/^ 'g_' /;

  self.set-class-name-of-sub('GVariantType');

  $s
}

#-------------------------------------------------------------------------------
# no ref/unref for a variant type
method native-object-ref ( $n-native-object ) {
  $n-native-object
}

#-------------------------------------------------------------------------------
method native-object-unref ( $n-native-object ) {
  _g_variant_type_free($n-native-object)
}

#-------------------------------------------------------------------------------
#TM:1:copy:
=begin pod
=head2 copy

Makes a copy of a B<GVariantType>.  It is appropriate to call C<clear-object()> on the return value.

Returns: a new B<GVariantType>

  method copy ( --> Gnome::Glib::VariantType )

=end pod

method copy ( --> Gnome::Glib::VariantType ) {
  Gnome::Glib::VariantType.new(
    :native-object(g_variant_type_copy(self.get-native-object-no-reffing))
  );
}

sub g_variant_type_copy ( N-GVariantType $type --> N-GVariantType )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:dup-string:
=begin pod
=head2 dup-string

Returns a copy of the type string corresponding to I<type>.

Returns: (transfer full): the corresponding type string

  method dup-string ( -->  Str  )

=end pod

method dup-string ( -->  Str  ) {

  g_variant_type_dup_string(
    self.get-native-object-no-reffing,
  );
}

sub g_variant_type_dup_string ( N-GVariantType $type --> gchar-ptr )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:element:
=begin pod
=head2 element

Determines the element type of an array or maybe type.  This function may only be used with array or maybe types.

Returns: the element type of I<type>

  method element ( --> Gnome::Glib::VariantType )

=end pod

method element ( --> Gnome::Glib::VariantType ) {
  Gnome::Glib::VariantType.new(
    :native-object(g_variant_type_element(self.get-native-object-no-reffing))
  );
}

sub g_variant_type_element ( N-GVariantType $type --> N-GVariantType )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:equal:
=begin pod
=head2 equal

Compares this type and I<$type2> for equality.  Only returns C<True> if the types are exactly equal.  Even if one type is an indefinite type and the other is a subtype of it, C<False> will be returned if they are not exactly equal. If you want to check for subtypes, use C<is-subtype-of()>.

=comment The argument types of I<type1> and I<type2> are only B<gconstpointer> to allow use with B<GHashTable> without function pointer casting.  For both arguments, a valid B<GVariantType> must be provided.

  method equal ( N-GVariantType $type2 --> Bool )

=item N-GVariantType $type2; a B<GVariantType>

=end pod

method equal ( $type2 --> Bool ) {
  my $no = $type2;
  $no .= get-native-object-no-reffing unless $no ~~ N-GVariantType;

  g_variant_type_equal(
    self.get-native-object-no-reffing, $no
  ).Bool;
}

sub g_variant_type_equal (
  N-GVariantType $type1, N-GVariantType $type2 --> gboolean
) is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:first:
=begin pod
=head2 first

Determines the first item type of a tuple or dictionary entry type.  This function may only be used with tuple or dictionary entry types, but must not be used with the generic tuple type C<G_VARIANT_TYPE_TUPLE>.  In the case of a dictionary entry type, this returns the type of the key.  C<Any> is returned in case of I<type> being C<G_VARIANT_TYPE_UNIT>.  This call, together with C<g_variant_type_next()> provides an iterator interface over tuple and dictionary entry types.

Returns: the first item type of I<type>, or invalid

  method first ( --> N-GVariantType )

=end pod

method first ( --> Gnome::Glib::VariantType ) {
  Gnome::Glib::VariantType.new(
    :native-object(g_variant_type_first(self.get-native-object-no-reffing))
  );
}

sub g_variant_type_first ( N-GVariantType $type --> N-GVariantType )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:get-string-length:
=begin pod
=head2 get-string-length

Returns the length of the type string corresponding to the given I<type>.  This function must be used to determine the valid extent of the memory region returned by C<g_variant_type_peek_string()>.

Returns: the length of the corresponding type string

  method get-string-length ( --> UInt )

=end pod

method get-string-length ( --> UInt ) {

  g_variant_type_get_string_length(
    self.get-native-object-no-reffing,
  );
}

sub g_variant_type_get_string_length ( N-GVariantType $type --> gsize )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:hash:
=begin pod
=head2 hash

Hashes I<type>.
=comment The argument type of I<type> is only B<gconstpointer> to allow use with B<GHashTable> without function pointer casting.  A valid B<GVariantType> must be provided.

Returns: the hash value

  method hash ( N-GVariantType $type --> UInt )

=item N-GVariantType $type; a B<N-GVariantType>

=end pod

method hash ( --> UInt ) {

  g_variant_type_hash(
    self.get-native-object-no-reffing
  );
}

sub g_variant_type_hash ( N-GVariantType $type --> guint )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:is-array:
=begin pod
=head2 is-array

Determines if the given I<type> is an array type.  This is true if the type string for I<type> starts with an 'a'.  This function returns C<True> for any indefinite type for which every definite subtype is an array type -- C<G_VARIANT_TYPE_ARRAY>, for example.

Returns: C<True> if I<type> is an array type

  method is-array ( --> Bool )


=end pod

method is-array ( --> Bool ) {

  g_variant_type_is_array(
    self.get-native-object-no-reffing,
  ).Bool;
}

sub g_variant_type_is_array ( N-GVariantType $type --> gboolean )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:is-basic:
=begin pod
=head2 is-basic

Determines if the given I<type> is a basic type.  Basic types are booleans, bytes, integers, doubles, strings, object paths and signatures.  Only a basic type may be used as the key of a dictionary entry.  This function returns C<False> for all indefinite types except C<G_VARIANT_TYPE_BASIC>.

Returns: C<True> if I<type> is a basic type

  method is-basic ( --> Bool )

=end pod

method is-basic ( --> Bool ) {

  g_variant_type_is_basic(
    self.get-native-object-no-reffing,
  ).Bool;
}

sub g_variant_type_is_basic ( N-GVariantType $type --> gboolean )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:is-container:
=begin pod
=head2 is-container

Determines if the given I<type> is a container type.  Container types are any array, maybe, tuple, or dictionary entry types plus the variant type.  This function returns C<True> for any indefinite type for which every definite subtype is a container -- C<G_VARIANT_TYPE_ARRAY>, for example.

Returns: C<True> if I<type> is a container type

  method is-container ( --> Bool )


=end pod

method is-container ( --> Bool ) {

  g_variant_type_is_container(
    self.get-native-object-no-reffing,
  ).Bool;
}

sub g_variant_type_is_container ( N-GVariantType $type --> gboolean )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:is-definite:
=begin pod
=head2 is-definite

Determines if the given I<type> is definite (ie: not indefinite).  A type is definite if its type string does not contain any indefinite type characters ('*', '?', or 'r').  A B<GVariant> instance may not have an indefinite type, so calling this function on the result of C<g_variant_get_type()> will always result in C<True> being returned.  Calling this function on an indefinite type like C<G_VARIANT_TYPE_ARRAY>, however, will result in C<False> being returned.

Returns: C<True> if I<type> is definite

  method is-definite ( --> Bool )


=end pod

method is-definite ( --> Bool ) {

  g_variant_type_is_definite(
    self.get-native-object-no-reffing,
  ).Bool;
}

sub g_variant_type_is_definite ( N-GVariantType $type --> gboolean )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:is-dict-entry:
=begin pod
=head2 is-dict-entry

Determines if the given I<type> is a dictionary entry type.  This is true if the type string for I<type> starts with a '{'.  This function returns C<True> for any indefinite type for which every definite subtype is a dictionary entry type -- C<G_VARIANT_TYPE_DICT_ENTRY>, for example.

Returns: C<True> if I<type> is a dictionary entry type

  method is-dict-entry ( --> Bool )


=end pod

method is-dict-entry ( --> Bool ) {

  g_variant_type_is_dict_entry(
    self.get-native-object-no-reffing,
  ).Bool;
}

sub g_variant_type_is_dict_entry ( N-GVariantType $type --> gboolean )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:is-maybe:
=begin pod
=head2 is-maybe

Determines if the given I<type> is a maybe type.  This is true if the type string for I<type> starts with an 'm'.  This function returns C<True> for any indefinite type for which every definite subtype is a maybe type -- C<G_VARIANT_TYPE_MAYBE>, for example.

Returns: C<True> if I<type> is a maybe type

  method is-maybe ( --> Bool )


=end pod

method is-maybe ( --> Bool ) {

  g_variant_type_is_maybe(
    self.get-native-object-no-reffing,
  ).Bool;
}

sub g_variant_type_is_maybe ( N-GVariantType $type --> gboolean )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:is-subtype-of:
=begin pod
=head2 is-subtype-of

Checks if this type is a subtype of I<$supertype>.  This function returns C<True> if I<type> is a subtype of I<$supertype>.  All types are considered to be subtypes of themselves.  Aside from that, only indefinite types can have subtypes.

Returns: C<True> if I<type> is a subtype of I<$supertype>

  method is-subtype-of ( N-GVariantType $supertype --> Bool )

=item N-GVariantType $supertype; a B<GVariantType>

=end pod

method is-subtype-of ( $supertype --> Bool ) {
  my $no = $supertype;
  $no .= get-native-object-no-reffing unless $no ~~ N-GVariantType;

  g_variant_type_is_subtype_of(
    self.get-native-object-no-reffing, $no
  ).Bool;
}

sub g_variant_type_is_subtype_of ( N-GVariantType $type, N-GVariantType $supertype --> gboolean )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:is-tuple:
=begin pod
=head2 is-tuple

Determines if the given I<type> is a tuple type.  This is true if the type string for I<type> starts with a '(' or if I<type> is C<G_VARIANT_TYPE_TUPLE>.  This function returns C<True> for any indefinite type for which every definite subtype is a tuple type -- C<G_VARIANT_TYPE_TUPLE>, for example.

Returns: C<True> if I<type> is a tuple type

  method is-tuple ( --> Bool )


=end pod

method is-tuple ( --> Bool ) {

  g_variant_type_is_tuple(
    self.get-native-object-no-reffing,
  ).Bool;
}

sub g_variant_type_is_tuple ( N-GVariantType $type --> gboolean )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1::string-is-valid
=begin pod
=head2 string-is-valid

Checks if I<type_string> is a valid Gnome::Glib::Variant type string.  This call is equivalent to calling C<string-scan()> and confirming that the following character is a nul terminator.

Returns: C<True> if I<$type_string> is exactly one valid type string

  method string-is-valid ( Str $type_string --> Bool )

=item Str $type_string; a pointer to any string

=end pod

method string-is-valid ( Str $type_string --> Bool ) {
  g_variant_type_string_is_valid($type_string).Bool;
}

sub g_variant_type_string_is_valid ( gchar-ptr $type_string --> gboolean )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:is-variant:
=begin pod
=head2 is-variant

Determines if the given I<type> is the variant type.

Returns: C<True> if I<type> is the variant type

  method is-variant ( --> Bool )

=end pod

method is-variant ( --> Bool ) {

  g_variant_type_is_variant(
    self.get-native-object-no-reffing,
  ).Bool;
}

sub g_variant_type_is_variant ( N-GVariantType $type --> gboolean )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:key:
=begin pod
=head2 key

Determines the key type of a dictionary entry type.  This function may only be used with a dictionary entry type.  Other than the additional restriction, this call is equivalent to C<g_variant_type_first()>.

Returns: the key type of the dictionary entry

  method key ( --> Gnome::Glib::VariantType )


=end pod

method key ( --> Gnome::Glib::VariantType ) {
  Gnome::Glib::VariantType.new(
    :native-object(g_variant_type_key(self.get-native-object-no-reffing))
  );
}

sub g_variant_type_key ( N-GVariantType $type --> N-GVariantType )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:n-items:
=begin pod
=head2 n-items

Determines the number of items contained in a tuple or dictionary entry type.  This function may only be used with tuple or dictionary entry types, but must not be used with the generic tuple type C<G_VARIANT_TYPE_TUPLE>.  In the case of a dictionary entry type, this function will always return 2.

Returns: the number of items in I<type>

  method n-items ( --> UInt )


=end pod

method n-items ( --> UInt ) {

  g_variant_type_n_items(
    self.get-native-object-no-reffing,
  );
}

sub g_variant_type_n_items ( N-GVariantType $type --> gsize )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:next:
=begin pod
=head2 next

Determines the next item type of a tuple or dictionary entry type.  I<type> must be the result of a previous call to C<first()> or C<next()>.  If called on the key type of a dictionary entry then this call returns the value type.  If called on the value type of a dictionary entry then this call returns C<Any>.  For tuples, C<Any> is returned when I<type> is the last item in a tuple.

Returns: the next B<Gnome::Glib::VariantType> after I<type>, or invalid

  method next ( --> Gnome::Glib::VariantType )

=end pod

method next ( --> Gnome::Glib::VariantType ) {
  Gnome::Glib::VariantType.new(
    :native-object(g_variant_type_next(self.get-native-object-no-reffing))
  );
}

sub g_variant_type_next ( N-GVariantType $type --> N-GVariantType )
  is native(&glib-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
# TM:1:peek-string:
=begin pod
=head2 peek-string

Returns the type string corresponding to the given I<type>.  The result is not nul-terminated; in order to determine its length you must call C<get-string-length()>.  To get a nul-terminated string, see C<g_variant_type_dup_string()>.

Returns: the corresponding type string (not nul-terminated)

  method peek-string ( -->  Str  )


=end pod

method peek-string ( -->  Str  ) {

  g_variant_type_peek_string(
    self.get-native-object-no-reffing,
  );
}

sub g_variant_type_peek_string ( N-GVariantType $type --> gchar-ptr )
  is native(&glib-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
# TM:0:g_variant_type_string_scan:
=begin pod
=head2 [g_variant_type_] string_scan

Scan for a single complete and valid Gnome::Glib::VariantType string in I<$string>. The memory pointed to by I<$limit> (or bytes beyond it) is never accessed.

If a valid type string is found, I<$endptr> is updated to point to the first character past the end of the string that was found and C<True> is returned.

If there is no valid type string starting at I<$string>, or if the type string does not end before I<$limit> then C<False> is returned.

For the simple case of checking if a string is a valid type string, see C<g_variant_type_string_is_valid()>.

Returns: C<True> if a valid type string was found

  method g_variant_type_string_scan (
    Str $string, Str $limit, CArray[Str] $endptr --> Int
  )

=item Str $string; a pointer to any string
=item Str $limit; (nullable): the end of I<string>, or C<Any>
=item CArray[Str] $endptr; (out) (optional): location to store the end pointer, or C<Any>

=end pod

sub g_variant_type_string_scan ( Str $string, Str $limit, CArray[Str] $endptr --> int32 )
  is native(&glib-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:1:value:
=begin pod
=head2 value

Determines the value type of a dictionary entry type.  This function may only be used with a dictionary entry type.

Returns: the value type of the dictionary entry

  method value ( --> Gnome::Glib::VariantType )


=end pod

method value ( --> Gnome::Glib::VariantType ) {
  Gnome::Glib::VariantType.new(
    :native-object(g_variant_type_value(self.get-native-object-no-reffing))
  );
}

sub g_variant_type_value ( N-GVariantType $type --> N-GVariantType )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#`{{ User must not know about it, they have to use clear-object()
#
#TM:0:g_variant_type_free:
=begin pod
=head2 g_variant_type_free

Frees a B<Gnome::Glib::VariantType> that was allocated with C<g_variant_type_copy()>, C<g_variant_type_new()> or one of the container type constructor functions. In the case that I<type> is C<Any>, this function does nothing.

  method g_variant_type_free ( )

=end pod
}}

#TM:1:_g_variant_type_free:
sub _g_variant_type_free ( N-GVariantType $type )
  is native(&glib-lib)
  is symbol('g_variant_type_free')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_variant_type_new:
#`{{
=begin pod
=head2 g_variant_type_new

Creates a new B<Gnome::Glib::VariantType> corresponding to the type string given
by I<type_string>.  It is appropriate to call C<g_variant_type_free()> on
the return value.

It is a programmer error to call this function with an invalid type
string.  Use C<g_variant_type_string_is_valid()> if you are unsure.

Returns: (transfer full): a new B<Gnome::Glib::VariantType>

  method g_variant_type_new ( Str $type_string --> N-GVariantType )

=item Str $type_string; a valid Gnome::Glib::Variant type string

=end pod
}}

sub _g_variant_type_new ( Str $type_string --> N-GVariantType )
  is native(&glib-lib)
  is symbol('g_variant_type_new')
  { * }


#-------------------------------------------------------------------------------
#TM:1:_g_variant_type_new_array:
#`{{
=begin pod
=head2 _g_variant_type_new_array

Constructs the type corresponding to an array of elements of the type I<type>.  It is appropriate to call C<g_variant_type_free()> on the return value.

Returns: (transfer full): a new array B<GVariantType>

  method _g_variant_type_new_array ( --> N-GVariantType )


=end pod
}}

sub _g_variant_type_new_array ( N-GVariantType $element --> N-GVariantType )
  is native(&glib-lib)
  is symbol('g_variant_type_new_array')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_variant_type_new_maybe:
#`{{
=begin pod
=head2 _g_variant_type_new_maybe

Constructs the type corresponding to a maybe instance containing type I<type> or Nothing.  It is appropriate to call C<g_variant_type_free()> on the return value.

Returns: (transfer full): a new maybe B<GVariantType>

  method _g_variant_type_new_maybe ( --> N-GVariantType )


=end pod
}}

sub _g_variant_type_new_maybe ( N-GVariantType $element --> N-GVariantType )
  is native(&glib-lib)
  is symbol('g_variant_type_new_maybe')
  { * }

#-------------------------------------------------------------------------------
#TM:0:_g_variant_type_new_tuple:
#`{{
=begin pod
=head2 _g_variant_type_new_tuple

Constructs a new tuple type, from I<items>.  I<length> is the number of items in I<items>, or -1 to indicate that I<items> is C<Any>-terminated.  It is appropriate to call C<g_variant_type_free()> on the return value.

Returns: (transfer full): a new tuple B<GVariantType>

  method _g_variant_type_new_tuple (
    *@items --> N-GVariantType
  )

=item  $const GVariantType * const *items; (array length=length): an array of B<GVariantTypes>, one for each item
=item Int $length; the length of I<items>, or -1

=end pod
}}

sub _g_variant_type_new_tuple ( @items --> N-GVariantType ) {
  my $no = CArray[N-GVariantType].new;
  my $count = 0;
  for @items -> $item is copy {
    $item .= get-native-object-no-reffing unless $item ~~ N-GVariantType;
    $no[$count++] = $item;
  }

  my @parameter-list = (
    Parameter.new(:type(CArray[N-GVariantType])), # GVariantType * const *items
    Parameter.new(:type(gint))
  );

  # create signature
  my Signature $signature .= new(
    :params(|@parameter-list),
    :returns(N-GVariantType)
  );

  # get a pointer to the sub, then cast it to a sub with the proper
  # signature. after that, the sub can be called, returning a value.
  state $ptr = cglobal( &glib-lib, 'g_variant_type_new_tuple', Pointer);
  my Callable $f = nativecast( $signature, $ptr);

  $f( $no, $count)
}

#  is native(&glib-lib)
#  is symbol('g_variant_type_new_tuple')
#  { * }


#`{{
#-------------------------------------------------------------------------------
#TM:0:_g_variant_type_new_dict_entry:
#`{{
=begin pod
=head2 _g_variant_type_new_dict_entry

Constructs the type corresponding to a dictionary entry with a key of type I<key> and a value of type I<value>.  It is appropriate to call C<g_variant_type_free()> on the return value.

Returns: (transfer full): a new dictionary entry B<GVariantType>

  method _g_variant_type_new_dict_entry ( N-GVariantType $value --> N-GVariantType )

=item N-GVariantType $value; a B<GVariantType>

=end pod
}}

sub _g_variant_type_new_dict_entry ( N-GVariantType $key, N-GVariantType $value --> N-GVariantType )
  is native(&glib-lib)
  is symbol('g_variant_type_new_dict_entry')
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
# TM:0:checked-:
=begin pod
=head2 checked-



  method checked- (  $const gchar * --> N-GVariantType )

=item  $const gchar *;

=end pod

method checked- (  $const gchar * --> N-GVariantType ) {

  g_variant_type_checked_(
    self.get-native-object-no-reffing, $const gchar *
  );
}

sub g_variant_type_checked_ (  $const gchar * --> N-GVariantType )
  is native(&glib-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
# TM:0:string-get-depth:
=begin pod
=head2 string-get-depth-

Get the maximum depth of the nested types in I<type_string>. A basic type will return depth 1, and a container type will return a greater value. The depth of a tuple is 1 plus the depth of its deepest child type.  If I<type_string> is not a valid B<GVariant> type string, 0 will be returned.

Returns: depth of I<type_string>, or 0 on error

  method string-get-depth- (  Str  $type_string --> UInt )

=item  Str  $type_string; a pointer to any string

=end pod

method string-get-depth- (  Str  $type_string --> UInt ) {

  g_variant_type_string_get_depth_(
    self.get-native-object-no-reffing, $type_string
  );
}

sub g_variant_type_string_get_depth_ ( gchar-ptr $type_string --> gsize )
  is native(&glib-lib)
  { * }
}}
