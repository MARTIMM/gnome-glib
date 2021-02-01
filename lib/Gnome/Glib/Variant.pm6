#TL:1:Gnome::Glib::Variant:

use v6;
#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Glib::Variant

Strongly typed value datatype


=head1 Description

B<Gnome::Glib::Variant> is a variant datatype; it can contain one or more values along with information about the type of the values.

A B<Gnome::Glib::Variant> may contain simple types, like an integer, or a boolean value; or complex types, like an array of two strings, or a dictionary of key value pairs. A B<Gnome::Glib::Variant> is also immutable: once it's been created neither its type nor its content can be modified further.

Gnome::Glib::Variant is useful whenever data needs to be serialized, for example when sending method parameters in DBus, or when saving settings using GSettings.

When creating a new B<Gnome::Glib::Variant>, you pass the data you want to store in it along with a string representing the type of data you wish to pass to it.

For instance, if you want to create a B<Gnome::Glib::Variant> holding an integer value you can use:

  my Gnome::Glib::Variant $v .= new( :type-string<ui>, :values([ 40, -40]));

The string "u" in the first argument tells B<Gnome::Glib::Variant> that the data passed to the constructor (40) is going to be an unsigned integer.

More advanced examples of B<Gnome::Glib::Variant> in use can be found in documentation for [GVariant format strings][gvariant-format-strings-pointers].

The range of possible values is determined by the type.

The type system used by B<Gnome::Glib::Variant> is B<Gnome::Glib::VariantType>.

B<Gnome::Glib::Variant> instances always have a type and a value (which are given at construction time). The type and value of a B<Gnome::Glib::Variant> instance can never change other than by the B<Gnome::Glib::Variant> itself being destroyed. A B<Gnome::Glib::Variant> cannot contain a pointer.

=begin comment
B<Gnome::Glib::Variant> is reference counted using C<g_variant_ref()> and C<g_variant_unref()>.  B<Gnome::Glib::Variant> also has floating reference counts -- see C<g_variant_ref_sink()>.
=end comment

B<Gnome::Glib::Variant> is completely threadsafe.  A B<Gnome::Glib::Variant> instance can be concurrently accessed in any way from any number of threads without problems.

B<Gnome::Glib::Variant> is heavily optimised for dealing with data in serialised form.  It works particularly well with data located in memory-mapped files.  It can perform nearly all deserialisation operations in a small constant time, usually touching only a single memory page. Serialised B<Gnome::Glib::Variant> data can also be sent over the network.

B<Gnome::Glib::Variant> is largely compatible with D-Bus.  Almost all types of B<Gnome::Glib::Variant> instances can be sent over D-Bus.  See B<Gnome::Glib::VariantType> for exceptions.  (However, B<Gnome::Glib::Variant>'s serialisation format is not the same as the serialisation format of a D-Bus message body: use B<GDBusMessage>, in the gio library, for those.)

For space-efficiency, the B<Gnome::Glib::Variant> serialisation format does not automatically include the variant's length, type or endianness, which must either be implied from context (such as knowledge that a particular file format always contains a little-endian C<G_VARIANT_TYPE_VARIANT> which occupies the whole length of the file) or supplied out-of-band (for instance, a length, type and/or endianness indicator could be placed at the beginning of a file, network message or network stream).

A B<Gnome::Glib::Variant>'s size is limited mainly by any lower level operating system constraints, such as the number of bits in B<gsize>.  For example, it is reasonable to have a 2GB file mapped into memory with B<GMappedFile>, and call C<g_variant_new_from_data()> on it.

For convenience to C programmers, B<Gnome::Glib::Variant> features powerful varargs-based value construction and destruction.  This feature is designed to be embedded in other libraries.

=begin comment
There is a Python-inspired text language for describing B<Gnome::Glib::Variant> values.  B<Gnome::Glib::Variant> includes a printer for this language and a parser with type inferencing.
=end comment


=head2 Memory Use

B<Gnome::Glib::Variant> tries to be quite efficient with respect to memory use.
This section gives a rough idea of how much memory is used by the
current implementation.  The information here is subject to change
in the future.

The memory allocated by B<Gnome::Glib::Variant> can be grouped into 4 broad
purposes: memory for serialised data, memory for the type
information cache, buffer management memory and memory for the
B<Gnome::Glib::Variant> structure itself.

=head3 Serialised Data Memory

This is the memory that is used for storing GVariant data in
serialised form.  This is what would be sent over the network or
what would end up on disk, not counting any indicator of the
endianness, or of the length or type of the top-level variant.

The amount of memory required to store a boolean is 1 byte. 16,
32 and 64 bit integers and double precision floating point numbers
use their "natural" size.  Strings (including object path and
signature strings) are stored with a nul terminator, and as such
use the length of the string plus 1 byte.

Maybe types use no space at all to represent the null value and
use the same amount of space (sometimes plus one byte) as the
equivalent non-maybe-typed value to represent the non-null case.

Arrays use the amount of space required to store each of their
members, concatenated.  Additionally, if the items stored in an
array are not of a fixed-size (ie: strings, other arrays, etc)
then an additional framing offset is stored for each item.  The
size of this offset is either 1, 2 or 4 bytes depending on the
overall size of the container.  Additionally, extra padding bytes
are added as required for alignment of child values.

Tuples (including dictionary entries) use the amount of space
required to store each of their members, concatenated, plus one
framing offset (as per arrays) for each non-fixed-sized item in
the tuple, except for the last one.  Additionally, extra padding
bytes are added as required for alignment of child values.

Variants use the same amount of space as the item inside of the
variant, plus 1 byte, plus the length of the type string for the
item inside the variant.

As an example, consider a dictionary mapping strings to variants.
In the case that the dictionary is empty, 0 bytes are required for
the serialisation.

If we add an item "width" that maps to the int32 value of 500 then
we will use 4 byte to store the int32 (so 6 for the variant
containing it) and 6 bytes for the string.  The variant must be
aligned to 8 after the 6 bytes of the string, so that's 2 extra
bytes.  6 (string) + 2 (padding) + 6 (variant) is 14 bytes used
for the dictionary entry.  An additional 1 byte is added to the
array as a framing offset making a total of 15 bytes.

If we add another entry, "title" that maps to a nullable string
that happens to have a value of null, then we use 0 bytes for the
null value (and 3 bytes for the variant to contain it along with
its type string) plus 6 bytes for the string.  Again, we need 2
padding bytes.  That makes a total of 6 + 2 + 3 = 11 bytes.

We now require extra padding between the two items in the array.
After the 14 bytes of the first item, that's 2 bytes required.
We now require 2 framing offsets for an extra two
bytes. 14 + 2 + 11 + 2 = 29 bytes to encode the entire two-item
dictionary.

=head3 Type Information Cache

For each GVariant type that currently exists in the program a type
information structure is kept in the type information cache.  The
type information structure is required for rapid deserialisation.

Continuing with the above example, if a B<Gnome::Glib::Variant> exists with the
type "a{sv}" then a type information struct will exist for
"a{sv}", "{sv}", "s", and "v".  Multiple uses of the same type
will share the same type information.  Additionally, all
single-digit types are stored in read-only static memory and do
not contribute to the writable memory footprint of a program using
B<Gnome::Glib::Variant>.

Aside from the type information structures stored in read-only
memory, there are two forms of type information.  One is used for
container types where there is a single element type: arrays and
maybe types.  The other is used for container types where there
are multiple element types: tuples and dictionary entries.

Array type info structures are 6 * sizeof (void *), plus the
memory required to store the type string itself.  This means that
on 32-bit systems, the cache entry for "a{sv}" would require 30
bytes of memory (plus malloc overhead).

Tuple type info structures are 6 * sizeof (void *), plus 4 *
sizeof (void *) for each item in the tuple, plus the memory
required to store the type string itself.  A 2-item tuple, for
example, would have a type information structure that consumed
writable memory in the size of 14 * sizeof (void *) (plus type
string)  This means that on 32-bit systems, the cache entry for
"{sv}" would require 61 bytes of memory (plus malloc overhead).

This means that in total, for our "a{sv}" example, 91 bytes of
type information would be allocated.

The type information cache, additionally, uses a B<GHashTable> to
store and lookup the cached items and stores a pointer to this
hash table in static storage.  The hash table is freed when there
are zero items in the type cache.

Although these sizes may seem large it is important to remember
that a program will probably only have a very small number of
different types of values in it and that only one type information
structure is required for many different values of the same type.

=head3 Buffer Management Memory

B<Gnome::Glib::Variant> uses an internal buffer management structure to deal
with the various different possible sources of serialised data
that it uses.  The buffer is responsible for ensuring that the
correct call is made when the data is no longer in use by
B<Gnome::Glib::Variant>.  This may involve a C<g_free()> or a C<g_slice_free()> or
even C<g_mapped_file_unref()>.

One buffer management structure is used for each chunk of
serialised data.  The size of the buffer management structure
is 4 * (void *).  On 32-bit systems, that's 16 bytes.

## GVariant structure

The size of a B<Gnome::Glib::Variant> structure is 6 * (void *).  On 32-bit
systems, that's 24 bytes.

B<Gnome::Glib::Variant> structures only exist if they are explicitly created
with API calls.  For example, if a B<Gnome::Glib::Variant> is constructed out of
serialised data for the example given above (with the dictionary)
then although there are 9 individual values that comprise the
entire dictionary (two keys, two values, two variants containing
the values, two dictionary entries, plus the dictionary itself),
only 1 B<Gnome::Glib::Variant> instance exists -- the one referring to the
dictionary.

If calls are made to start accessing the other values then
B<Gnome::Glib::Variant> instances will exist for those values only for as long
as they are in use (ie: until you call C<g_variant_unref()>).  The
type information is shared.  The serialised data and the buffer
management structure for that serialised data is shared by the
child.

=head3 Summary

To put the entire example together, for our dictionary mapping
strings to variants (with two entries, as given above), we are
using 91 bytes of memory for type information, 29 bytes of memory
for the serialised data, 16 bytes for buffer management and 24
bytes for the B<Gnome::Glib::Variant> instance, or a total of 160 bytes, plus
malloc overhead.  If we were to use C<g_variant_get_child_value()> to
access the two dictionary entries, we would use an additional 48
bytes.  If we were to have other dictionaries of the same type, we
would use more memory for the serialised data and buffer
management for those dictionaries, but the type information would
be shared.

=head2 See Also

[Gnome::Glib::VariantType](VariantType.html), [gvariant format strings](https://developer.gnome.org/glib/stable/gvariant-format-strings.html), [gvariant text format](https://developer.gnome.org/glib/stable/gvariant-text.html).

=head1 Synopsis
=head2 Declaration

  unit class Gnome::Glib::Variant;
  also is Gnome::N::TopLevelClassSupport;

=comment head2 Example

=end pod
#-------------------------------------------------------------------------------
use NativeCall;

use Gnome::N::X;
use Gnome::N::NativeLib;
use Gnome::N::TopLevelClassSupport;

use Gnome::Glib::N-GVariant;
#use Gnome::Glib::N-GVariantIter;
use Gnome::Glib::N-GVariantType;
use Gnome::Glib::Error;
use Gnome::Glib::VariantType;

#-------------------------------------------------------------------------------
unit class Gnome::Glib::Variant:auth<github:MARTIMM>;
also is Gnome::N::TopLevelClassSupport;


#`{{
#-------------------------------------------------------------------------------
=begin pod
=head2 class N-GVariantDict

GVariantDict is a mutable interface to GVariant dictionaries.

It can be used for doing a sequence of dictionary lookups in an efficient way on an existing GVariant dictionary or it can be used to construct new dictionaries with a hashtable-like interface. It can also be used for taking existing dictionaries and modifying them in order to create new ones.

GVariantDict can only be used with G_VARIANT_TYPE_VARDICT dictionaries.

It is possible to use GVariantDict allocated on the stack or on the heap. When using a stack-allocated GVariantDict, you begin with a call to g_variant_dict_init() and free the resources with a call to g_variant_dict_clear().

Heap-allocated GVariantDict follows normal refcounting rules: you allocate it with g_variant_dict_new() and use g_variant_dict_ref() and g_variant_dict_unref().

g_variant_dict_end() is used to convert the GVariantDict back into a dictionary-type GVariant. When used with stack-allocated instances, this also implicitly frees all associated memory, but for heap-allocated instances, you must still call g_variant_dict_unref() afterwards.

You will typically want to use a heap-allocated GVariantDict when you expose it as part of an API. For most other uses, the stack-allocated form will be more convenient.

Consider the following two examples that do the same thing in each style: take an existing dictionary and look up the "count" uint32 key, adding 1 to it if it is found, or returning an error if the key is not found. Each returns the new dictionary as a floating GVariant.
Using a stack-allocated GVariantDict

GVariant *
add_to_count (GVariant  *orig,
              GError   **error)
{
  GVariantDict dict;
  guint32 count;

  g_variant_dict_init (&dict, orig);
  if (!g_variant_dict_lookup (&dict, "count", "u", &count))
    {
      g_set_error (...);
      g_variant_dict_clear (&dict);
      return NULL;
    }

  g_variant_dict_insert (&dict, "count", "u", count + 1);

  return g_variant_dict_end (&dict);
}

Using heap-allocated GVariantDict

GVariant *
add_to_count (GVariant  *orig,
              GError   **error)
{
  GVariantDict *dict;
  GVariant *result;
  guint32 count;

  dict = g_variant_dict_new (orig);

  if (g_variant_dict_lookup (dict, "count", "u", &count))
    {
      g_variant_dict_insert (dict, "count", "u", count + 1);
      result = g_variant_dict_end (dict);
    }
  else
    {
      g_set_error (...);
      result = NULL;
    }

  g_variant_dict_unref (dict);

  return result;
}

=end pod

#TT:1:N-GVariantDict:
class N-GVariantDict
  is repr('CPointer')
  is export
  { }
}}

#-------------------------------------------------------------------------------
=begin pod
=head2 GVariantClass
=end pod

#TT:1:GVariantClass
enum GVariantClass is export (
  G_VARIANT_CLASS_BOOLEAN       => 'b',
  G_VARIANT_CLASS_BYTE          => 'y',
  G_VARIANT_CLASS_INT16         => 'n',
  G_VARIANT_CLASS_UINT16        => 'q',
  G_VARIANT_CLASS_INT32         => 'i',
  G_VARIANT_CLASS_UINT32        => 'u',
  G_VARIANT_CLASS_INT64         => 'x',
  G_VARIANT_CLASS_UINT64        => 't',
  G_VARIANT_CLASS_HANDLE        => 'h',
  G_VARIANT_CLASS_DOUBLE        => 'd',
  G_VARIANT_CLASS_STRING        => 's',
  G_VARIANT_CLASS_OBJECT_PATH   => 'o',
  G_VARIANT_CLASS_SIGNATURE     => 'g',
  G_VARIANT_CLASS_VARIANT       => 'v',
  G_VARIANT_CLASS_MAYBE         => 'm',
  G_VARIANT_CLASS_ARRAY         => 'a',
  G_VARIANT_CLASS_TUPLE         => '(',
  G_VARIANT_CLASS_DICT_ENTRY    => '{'
);

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

=begin comment
Create a new Variant object.

  multi method new ( Str :$type-string!, Array :$values! )
=end comment

=head3 :boolean

Creates a new boolean B<GVariant> instance -- either C<1> or C<0>.

=head3 :type-string, :data-string

Create a new Variant object by parsing the type and data provided in strings.

  multi method new ( Str :$type-string!, Str :$data-string! )

=head3 :native-object

Create a Variant object using a native object from elsewhere. See also B<Gnome::N::TopLevelClassSupport>.

  multi method new ( N-GObject :$native-object! )

=end pod

#TM:1:new(:type-string,:values):
#TM:1:new(:type-string,:data-string):
#TM:4:new(:native-object):Gnome::N::TopLevelClassSupport
submethod BUILD ( *%options ) {

  # prevent creating wrong native-objects
  if self.^name eq 'Gnome::Glib::Variant' or ?%options<GVariant> {

    # check if native object is set by other parent class BUILDers
    if self.is-valid { }

    elsif %options<native-object>:exists { }

    # process all other options
    else {
      my $no;

#      if %options<boolean>:exists {
#        $no = _g_variant_new_boolean(%options<boolean>.Int);
#      }

#      elsif ? %options<type-string> and %options<values> {
      if ? %options<type-string> and %options<values> {
#note "new val: ", %options<values>.perl;
        $no = _g_variant_new( %options<type-string>, %options<values>);
      }

      elsif ? %options<type-string> and ? %options<data-string> {
        my Gnome::Glib::Error $e;
        ( $no, $e) = g_variant_parse(
          %options<type-string>, %options<data-string>
        );

        die X::Gnome.new(:message($e.message)) if $e.is-valid;
      }

      self.set-native-object($no);
    }

    # only after creating the native-object, the gtype is known
    self.set-class-info('GVariant');
  }
}

#-------------------------------------------------------------------------------
# no pod. user does not have to know about it.
method _fallback ( $native-sub --> Callable ) {

  my Callable $s;
  try { $s = &::("g_variant_$native-sub"); };
  try { $s = &::("g_$native-sub"); } unless ?$s;
  try { $s = &::($native-sub); } if !$s and $native-sub ~~ m/^ 'g_' /;

  self.set-class-name-of-sub('GVariant');

  $s
}

#-------------------------------------------------------------------------------
method native-object-ref ( $n-native-object --> N-GVariant ) {
  _g_variant_ref($n-native-object)
}

#-------------------------------------------------------------------------------
method native-object-unref ( $n-native-object ) {
  _g_variant_unref($n-native-object)
}

#-------------------------------------------------------------------------------
#`{{ not for users
#TM:1:_g_variant_unref:
=begin pod
=head2 g_variant_unref

Decreases the reference count of value . When its reference count drops to 0, the memory used by the variant is freed.

  method g_variant_unref ( )

=end pod
}}

sub _g_variant_unref ( N-GVariant $value  )
  is native(&glib-lib)
  is symbol('g_variant_unref')
  { * }

#-------------------------------------------------------------------------------
#`{{ not for users
#TM:0:_g_variant_ref:
=begin pod
=head2 g_variant_ref

Increases the reference count of value .

  method g_variant_ref ( --> N-GVariant )

=end pod
}}
sub _g_variant_ref ( N-GVariant $value --> N-GVariant )
  is native(&glib-lib)
  is symbol('g_variant_ref')
  { * }

#`{{
#-------------------------------------------------------------------------------
#TM:0:g_variant_ref_sink:
=begin pod
=head2 [g_variant_] ref_sink



  method g_variant_ref_sink ( --> N-GVariant )


=end pod

sub g_variant_ref_sink ( N-GVariant $value --> N-GVariant )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_is_floating:
=begin pod
=head2 [g_variant_] is_floating



  method g_variant_is_floating ( --> Int )


=end pod

sub g_variant_is_floating ( N-GVariant $value --> int32 )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_take_ref:
=begin pod
=head2 [g_variant_] take_ref



  method g_variant_take_ref ( --> N-GVariant )


=end pod

sub g_variant_take_ref ( N-GVariant $value --> N-GVariant )
  is native(&glib-lib)
  { * }
}}

#`[[[
#-------------------------------------------------------------------------------
#TM:0:get-type:
=begin pod
=head2 get-type

Determines the type of I<value>.  The return value is valid for the lifetime of I<value> and must not be freed.

Returns: a B<GVariantType>

  method get-type ( --> N-GVariantType )


=end pod

method get-type ( --> N-GVariantType ) {

  g_variant_get_type(
    self.get-native-object-no-reffing,
  );
}

sub g_variant_get_type ( N-GVariant $value --> N-GVariantType )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-type-string:
=begin pod
=head2 get-type-string

Returns the type string of I<value>.  Unlike the result of calling C<g_variant_type_peek_string()>, this string is nul-terminated.  This string belongs to B<GVariant> and must not be freed.

Returns: the type string for the type of I<value>

  method get-type-string ( -->  Str  )


=end pod

method get-type-string ( -->  Str  ) {

  g_variant_get_type_string(
    self.get-native-object-no-reffing,
  );
}

sub g_variant_get_type_string ( N-GVariant $value --> gchar-ptr )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:is-of-type:
=begin pod
=head2 is-of-type

Checks if a value has a type matching the provided type.

Returns: C<1> if the type of I<value> matches I<type>

  method is-of-type ( N-GVariantType $type --> Int )

=item N-GVariantType $type; a B<GVariantType>

=end pod

method is-of-type ( N-GVariantType $type --> Int ) {
  my $no = …;
  $no .= get-native-object-no-reffing unless $no ~~ N-GVariantType;

  g_variant_is_of_type(
    self.get-native-object-no-reffing, $type
  );
}

sub g_variant_is_of_type ( N-GVariant $value, N-GVariantType $type --> gboolean )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:is-container:
=begin pod
=head2 is-container

Checks if I<value> is a container.

Returns: C<1> if I<value> is a container

  method is-container ( --> Int )


=end pod

method is-container ( --> Int ) {

  g_variant_is_container(
    self.get-native-object-no-reffing,
  );
}

sub g_variant_is_container ( N-GVariant $value --> gboolean )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:classify:
=begin pod
=head2 classify

Classifies I<value> according to its top-level type.

Returns: the B<GVariantClass> of I<value>

  method classify ( --> GVariantClass )


=end pod

method classify ( --> GVariantClass ) {

  g_variant_classify(
    self.get-native-object-no-reffing,
  );
}

sub g_variant_classify ( N-GVariant $value --> GEnum )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_variant_new_boolean:
#`{{
=begin pod
=head2 _g_variant_new_boolean

Creates a new boolean B<GVariant> instance -- either C<1> or C<0>.

Returns: (transfer none): a floating reference to a new boolean B<GVariant> instance

  method _g_variant_new_boolean ( Int $value --> N-GVariant )

=item Int $value; a B<gboolean> value

=end pod
}}

sub _g_variant_new_boolean ( gboolean $value --> N-GVariant )
  is native(&glib-lib)
  is symbol('g_variant_new_boolean')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_variant_new_byte:
#`{{
=begin pod
=head2 _g_variant_new_byte

Creates a new byte B<GVariant> instance.

Returns: (transfer none): a floating reference to a new byte B<GVariant> instance

  method _g_variant_new_byte ( UInt $value --> N-GVariant )

=item UInt $value; a B<guint8> value

=end pod
}}

sub _g_variant_new_byte ( guint8 $value --> N-GVariant )
  is native(&glib-lib)
  is symbol('g_variant_new_byte')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_variant_new_int16:
#`{{
=begin pod
=head2 _g_variant_new_int16

Creates a new int16 B<GVariant> instance.

Returns: (transfer none): a floating reference to a new int16 B<GVariant> instance

  method _g_variant_new_int16 ( Int $value --> N-GVariant )

=item Int $value; a B<gint16> value

=end pod
}}

sub _g_variant_new_int16 ( gint16 $value --> N-GVariant )
  is native(&glib-lib)
  is symbol('g_variant_new_int16')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_variant_new_uint16:
#`{{
=begin pod
=head2 _g_variant_new_uint16

Creates a new uint16 B<GVariant> instance.

Returns: (transfer none): a floating reference to a new uint16 B<GVariant> instance

  method _g_variant_new_uint16 ( UInt $value --> N-GVariant )

=item UInt $value; a B<guint16> value

=end pod
}}

sub _g_variant_new_uint16 ( guint16 $value --> N-GVariant )
  is native(&glib-lib)
  is symbol('g_variant_new_uint16')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_variant_new_int32:
#`{{
=begin pod
=head2 _g_variant_new_int32

Creates a new int32 B<GVariant> instance.

Returns: (transfer none): a floating reference to a new int32 B<GVariant> instance

  method _g_variant_new_int32 ( Int $value --> N-GVariant )

=item Int $value; a B<gint32> value

=end pod
}}

sub _g_variant_new_int32 ( gint32 $value --> N-GVariant )
  is native(&glib-lib)
  is symbol('g_variant_new_int32')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_variant_new_uint32:
#`{{
=begin pod
=head2 _g_variant_new_uint32

Creates a new uint32 B<GVariant> instance.

Returns: (transfer none): a floating reference to a new uint32 B<GVariant> instance

  method _g_variant_new_uint32 ( UInt $value --> N-GVariant )

=item UInt $value; a B<guint32> value

=end pod
}}

sub _g_variant_new_uint32 ( guint32 $value --> N-GVariant )
  is native(&glib-lib)
  is symbol('g_variant_new_uint32')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_variant_new_int64:
#`{{
=begin pod
=head2 _g_variant_new_int64

Creates a new int64 B<GVariant> instance.

Returns: (transfer none): a floating reference to a new int64 B<GVariant> instance

  method _g_variant_new_int64 ( Int $value --> N-GVariant )

=item Int $value; a B<gint64> value

=end pod
}}

sub _g_variant_new_int64 ( gint64 $value --> N-GVariant )
  is native(&glib-lib)
  is symbol('g_variant_new_int64')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_variant_new_uint64:
#`{{
=begin pod
=head2 _g_variant_new_uint64

Creates a new uint64 B<GVariant> instance.

Returns: (transfer none): a floating reference to a new uint64 B<GVariant> instance

  method _g_variant_new_uint64 ( UInt $value --> N-GVariant )

=item UInt $value; a B<guint64> value

=end pod
}}

sub _g_variant_new_uint64 ( guint64 $value --> N-GVariant )
  is native(&glib-lib)
  is symbol('g_variant_new_uint64')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_variant_new_handle:
#`{{
=begin pod
=head2 _g_variant_new_handle

Creates a new handle B<GVariant> instance.  By convention, handles are indexes into an array of file descriptors that are sent alongside a D-Bus message.  If you're not interacting with D-Bus, you probably don't need them.

Returns: (transfer none): a floating reference to a new handle B<GVariant> instance

  method _g_variant_new_handle ( Int $value --> N-GVariant )

=item Int $value; a B<gint32> value

=end pod
}}

sub _g_variant_new_handle ( gint32 $value --> N-GVariant )
  is native(&glib-lib)
  is symbol('g_variant_new_handle')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_variant_new_double:
#`{{
=begin pod
=head2 _g_variant_new_double

Creates a new double B<GVariant> instance.

Returns: (transfer none): a floating reference to a new double B<GVariant> instance

  method _g_variant_new_double ( Num $value --> N-GVariant )

=item Num $value; a B<gdouble> floating point value

=end pod
}}

sub _g_variant_new_double ( gdouble $value --> N-GVariant )
  is native(&glib-lib)
  is symbol('g_variant_new_double')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_variant_new_string:
#`{{
=begin pod
=head2 _g_variant_new_string

Creates a string B<GVariant> with the contents of I<string>.  I<string> must be valid UTF-8, and must not be C<Any>. To encode potentially-C<Any> strings, use C<g_variant_new()> with `ms` as the [format string][gvariant-format-strings-maybe-types].

Returns: (transfer none): a floating reference to a new string B<GVariant> instance

  method _g_variant_new_string (  Str  $string --> N-GVariant )

=item  Str  $string; a normal UTF-8 nul-terminated string

=end pod
}}

sub _g_variant_new_string ( gchar-ptr $string --> N-GVariant )
  is native(&glib-lib)
  is symbol('g_variant_new_string')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_variant_new_take_string:
#`{{
=begin pod
=head2 _g_variant_new_take_string

Creates a string B<GVariant> with the contents of I<string>.  I<string> must be valid UTF-8, and must not be C<Any>. To encode potentially-C<Any> strings, use this with C<g_variant_new_maybe()>.  This function consumes I<string>.  C<g_free()> will be called on I<string> when it is no longer required.  You must not modify or access I<string> in any other way after passing it to this function.  It is even possible that I<string> is immediately freed.

Returns: (transfer none): a floating reference to a new string B<GVariant> instance

  method _g_variant_new_take_string (  Str  $string --> N-GVariant )

=item  Str  $string; a normal UTF-8 nul-terminated string

=end pod
}}

sub _g_variant_new_take_string ( gchar-ptr $string --> N-GVariant )
  is native(&glib-lib)
  is symbol('g_variant_new_take_string')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_variant_new_printf:
#`{{
=begin pod
=head2 _g_variant_new_printf

Creates a string-type GVariant using printf formatting.  This is similar to calling C<g_strdup_printf()> and then C<g_variant_new_string()> but it saves a temporary variable and an unnecessary copy.

Returns: (transfer none): a floating reference to a new string B<GVariant> instance

  method _g_variant_new_printf (  Str  $format_string,  $2 --> N-GVariant )

=item  Str  $format_string; a printf-style format string @...: arguments for I<format_string>
=item  $2;

=end pod
}}

sub _g_variant_new_printf ( gchar-ptr $format_string, Any $any = Any,  $2 --> N-GVariant )
  is native(&glib-lib)
  is symbol('g_variant_new_printf')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_variant_new_object_path:
#`{{
=begin pod
=head2 _g_variant_new_object_path

Creates a D-Bus object path B<GVariant> with the contents of I<string>. I<string> must be a valid D-Bus object path.  Use C<g_variant_is_object_path()> if you're not sure.

Returns: (transfer none): a floating reference to a new object path B<GVariant> instance

  method _g_variant_new_object_path (  Str  $object_path --> N-GVariant )

=item  Str  $object_path; a normal C nul-terminated string

=end pod
}}

sub _g_variant_new_object_path ( gchar-ptr $object_path --> N-GVariant )
  is native(&glib-lib)
  is symbol('g_variant_new_object_path')
  { * }

#-------------------------------------------------------------------------------
#TM:0:is-object-path:
=begin pod
=head2 is-object-path

Determines if a given string is a valid D-Bus object path.  You should ensure that a string is a valid D-Bus object path before passing it to C<g_variant_new_object_path()>.  A valid object path starts with `/` followed by zero or more sequences of characters separated by `/` characters.  Each sequence must contain only the characters `[A-Z][a-z][0-9]_`.  No sequence (including the one following the final `/` character) may be empty.

Returns: C<1> if I<string> is a D-Bus object path

  method is-object-path (  Str  $string --> Int )

=item  Str  $string; a normal C nul-terminated string

=end pod

method is-object-path (  Str  $string --> Int ) {

  g_variant_is_object_path(
    self.get-native-object-no-reffing, $string
  );
}

sub g_variant_is_object_path ( gchar-ptr $string --> gboolean )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_variant_new_signature:
#`{{
=begin pod
=head2 _g_variant_new_signature

Creates a D-Bus type signature B<GVariant> with the contents of I<string>.  I<string> must be a valid D-Bus type signature.  Use C<g_variant_is_signature()> if you're not sure.

Returns: (transfer none): a floating reference to a new signature B<GVariant> instance

  method _g_variant_new_signature (  Str  $signature --> N-GVariant )

=item  Str  $signature; a normal C nul-terminated string

=end pod
}}

sub _g_variant_new_signature ( gchar-ptr $signature --> N-GVariant )
  is native(&glib-lib)
  is symbol('g_variant_new_signature')
  { * }

#-------------------------------------------------------------------------------
#TM:0:is-signature:
=begin pod
=head2 is-signature

Determines if a given string is a valid D-Bus type signature.  You should ensure that a string is a valid D-Bus type signature before passing it to C<g_variant_new_signature()>.  D-Bus type signatures consist of zero or more definite B<GVariantType> strings in sequence.

Returns: C<1> if I<string> is a D-Bus type signature

  method is-signature (  Str  $string --> Int )

=item  Str  $string; a normal C nul-terminated string

=end pod

method is-signature (  Str  $string --> Int ) {

  g_variant_is_signature(
    self.get-native-object-no-reffing, $string
  );
}

sub g_variant_is_signature ( gchar-ptr $string --> gboolean )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_variant_new_variant:
#`{{
=begin pod
=head2 _g_variant_new_variant

Boxes I<value>.  The result is a B<GVariant> instance representing a variant containing the original value.  If I<child> is a floating reference (see C<g_variant_ref_sink()>), the new instance takes ownership of I<child>.

Returns: (transfer none): a floating reference to a new variant B<GVariant> instance

  method _g_variant_new_variant ( --> N-GVariant )


=end pod
}}

sub _g_variant_new_variant ( N-GVariant $value --> N-GVariant )
  is native(&glib-lib)
  is symbol('g_variant_new_variant')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_variant_new_strv:
#`{{
=begin pod
=head2 _g_variant_new_strv

Constructs an array of strings B<GVariant> from the given array of strings.  If I<length> is -1 then I<strv> is C<Any>-terminated.

Returns: (transfer none): a new floating B<GVariant> instance

  method _g_variant_new_strv (  CArray[Str]  $strv, Int $length --> N-GVariant )

=item  CArray[Str]  $strv; (array length=length) (element-type utf8): an array of strings
=item Int $length; the length of I<strv>, or -1

=end pod
}}

sub _g_variant_new_strv ( gchar-pptr $strv, gssize $length --> N-GVariant )
  is native(&glib-lib)
  is symbol('g_variant_new_strv')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_variant_new_objv:
#`{{
=begin pod
=head2 _g_variant_new_objv

Constructs an array of object paths B<GVariant> from the given array of strings.  Each string must be a valid B<GVariant> object path; see C<g_variant_is_object_path()>.  If I<length> is -1 then I<strv> is C<Any>-terminated.

Returns: (transfer none): a new floating B<GVariant> instance

  method _g_variant_new_objv (  CArray[Str]  $strv, Int $length --> N-GVariant )

=item  CArray[Str]  $strv; (array length=length) (element-type utf8): an array of strings
=item Int $length; the length of I<strv>, or -1

=end pod
}}

sub _g_variant_new_objv ( gchar-pptr $strv, gssize $length --> N-GVariant )
  is native(&glib-lib)
  is symbol('g_variant_new_objv')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_variant_new_bytestring:
#`{{
=begin pod
=head2 _g_variant_new_bytestring

Creates an array-of-bytes B<GVariant> with the contents of I<string>. This function is just like C<g_variant_new_string()> except that the string need not be valid UTF-8.  The nul terminator character at the end of the string is stored in the array.

Returns: (transfer none): a floating reference to a new bytestring B<GVariant> instance

  method _g_variant_new_bytestring (  Str  $string --> N-GVariant )

=item  Str  $string; (array zero-terminated=1) (element-type guint8): a normal nul-terminated string in no particular encoding

=end pod
}}

sub _g_variant_new_bytestring ( gchar-ptr $string --> N-GVariant )
  is native(&glib-lib)
  is symbol('g_variant_new_bytestring')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_variant_new_bytestring_array:
#`{{
=begin pod
=head2 _g_variant_new_bytestring_array

Constructs an array of bytestring B<GVariant> from the given array of strings.  If I<length> is -1 then I<strv> is C<Any>-terminated.

Returns: (transfer none): a new floating B<GVariant> instance

  method _g_variant_new_bytestring_array (  CArray[Str]  $strv, Int $length --> N-GVariant )

=item  CArray[Str]  $strv; (array length=length): an array of strings
=item Int $length; the length of I<strv>, or -1

=end pod
}}

sub _g_variant_new_bytestring_array ( gchar-pptr $strv, gssize $length --> N-GVariant )
  is native(&glib-lib)
  is symbol('g_variant_new_bytestring_array')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_variant_new_fixed_array:
#`{{
=begin pod
=head2 _g_variant_new_fixed_array

Constructs a new array B<GVariant> instance, where the elements are of I<element_type> type.  I<elements> must be an array with fixed-sized elements.  Numeric types are fixed-size as are tuples containing only other fixed-sized types.  I<element_size> must be the size of a single element in the array. For example, if calling this function for an array of 32-bit integers, you might say sizeof(gint32). This value isn't used except for the purpose of a double-check that the form of the serialised data matches the caller's expectation.  I<n_elements> must be the length of the I<elements> array.

Returns: (transfer none): a floating reference to a new array B<GVariant> instance

  method _g_variant_new_fixed_array ( N-GVariantType $element_type, Pointer $elements, UInt $n_elements, UInt $element_size --> N-GVariant )

=item N-GVariantType $element_type; the B<GVariantType> of each element
=item Pointer $elements; a pointer to the fixed array of contiguous elements
=item UInt $n_elements; the number of elements
=item UInt $element_size; the size of each element

=end pod
}}

sub _g_variant_new_fixed_array ( N-GVariantType $element_type, gpointer $elements, gsize $n_elements, gsize $element_size --> N-GVariant )
  is native(&glib-lib)
  is symbol('g_variant_new_fixed_array')
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-boolean:
=begin pod
=head2 get-boolean

Returns the boolean value of I<value>.  It is an error to call this function with a I<value> of any type other than C<G_VARIANT_TYPE_BOOLEAN>.

Returns: C<1> or C<0>

  method get-boolean ( --> Int )


=end pod

method get-boolean ( --> Int ) {

  g_variant_get_boolean(
    self.get-native-object-no-reffing,
  );
}

sub g_variant_get_boolean ( N-GVariant $value --> gboolean )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-byte:
=begin pod
=head2 get-byte

Returns the byte value of I<value>.  It is an error to call this function with a I<value> of any type other than C<G_VARIANT_TYPE_BYTE>.

Returns: a B<guint8>

  method get-byte ( --> UInt )


=end pod

method get-byte ( --> UInt ) {

  g_variant_get_byte(
    self.get-native-object-no-reffing,
  );
}

sub g_variant_get_byte ( N-GVariant $value --> guint8 )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-int16:
=begin pod
=head2 get-int16

Returns the 16-bit signed integer value of I<value>.  It is an error to call this function with a I<value> of any type other than C<G_VARIANT_TYPE_INT16>.

Returns: a B<gint16>

  method get-int16 ( --> Int )


=end pod

method get-int16 ( --> Int ) {

  g_variant_get_int16(
    self.get-native-object-no-reffing,
  );
}

sub g_variant_get_int16 ( N-GVariant $value --> gint16 )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-uint16:
=begin pod
=head2 get-uint16

Returns the 16-bit unsigned integer value of I<value>.  It is an error to call this function with a I<value> of any type other than C<G_VARIANT_TYPE_UINT16>.

Returns: a B<guint16>

  method get-uint16 ( --> UInt )


=end pod

method get-uint16 ( --> UInt ) {

  g_variant_get_uint16(
    self.get-native-object-no-reffing,
  );
}

sub g_variant_get_uint16 ( N-GVariant $value --> guint16 )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-int32:
=begin pod
=head2 get-int32

Returns the 32-bit signed integer value of I<value>.  It is an error to call this function with a I<value> of any type other than C<G_VARIANT_TYPE_INT32>.

Returns: a B<gint32>

  method get-int32 ( --> Int )


=end pod

method get-int32 ( --> Int ) {

  g_variant_get_int32(
    self.get-native-object-no-reffing,
  );
}

sub g_variant_get_int32 ( N-GVariant $value --> gint32 )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-uint32:
=begin pod
=head2 get-uint32

Returns the 32-bit unsigned integer value of I<value>.  It is an error to call this function with a I<value> of any type other than C<G_VARIANT_TYPE_UINT32>.

Returns: a B<guint32>

  method get-uint32 ( --> UInt )


=end pod

method get-uint32 ( --> UInt ) {

  g_variant_get_uint32(
    self.get-native-object-no-reffing,
  );
}

sub g_variant_get_uint32 ( N-GVariant $value --> guint32 )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-int64:
=begin pod
=head2 get-int64

Returns the 64-bit signed integer value of I<value>.  It is an error to call this function with a I<value> of any type other than C<G_VARIANT_TYPE_INT64>.

Returns: a B<gint64>

  method get-int64 ( --> Int )


=end pod

method get-int64 ( --> Int ) {

  g_variant_get_int64(
    self.get-native-object-no-reffing,
  );
}

sub g_variant_get_int64 ( N-GVariant $value --> gint64 )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-uint64:
=begin pod
=head2 get-uint64

Returns the 64-bit unsigned integer value of I<value>.  It is an error to call this function with a I<value> of any type other than C<G_VARIANT_TYPE_UINT64>.

Returns: a B<guint64>

  method get-uint64 ( --> UInt )


=end pod

method get-uint64 ( --> UInt ) {

  g_variant_get_uint64(
    self.get-native-object-no-reffing,
  );
}

sub g_variant_get_uint64 ( N-GVariant $value --> guint64 )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-handle:
=begin pod
=head2 get-handle

Returns the 32-bit signed integer value of I<value>.  It is an error to call this function with a I<value> of any type other than C<G_VARIANT_TYPE_HANDLE>.  By convention, handles are indexes into an array of file descriptors that are sent alongside a D-Bus message.  If you're not interacting with D-Bus, you probably don't need them.

Returns: a B<gint32>

  method get-handle ( --> Int )


=end pod

method get-handle ( --> Int ) {

  g_variant_get_handle(
    self.get-native-object-no-reffing,
  );
}

sub g_variant_get_handle ( N-GVariant $value --> gint32 )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-double:
=begin pod
=head2 get-double

Returns the double precision floating point value of I<value>.  It is an error to call this function with a I<value> of any type other than C<G_VARIANT_TYPE_DOUBLE>.

Returns: a B<gdouble>

  method get-double ( --> Num )


=end pod

method get-double ( --> Num ) {

  g_variant_get_double(
    self.get-native-object-no-reffing,
  );
}

sub g_variant_get_double ( N-GVariant $value --> gdouble )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-variant:
=begin pod
=head2 get-variant

Unboxes I<value>.  The result is the B<GVariant> instance that was contained in I<value>.

Returns: (transfer full): the item contained in the variant

  method get-variant ( --> N-GVariant )


=end pod

method get-variant ( --> N-GVariant ) {

  g_variant_get_variant(
    self.get-native-object-no-reffing,
  );
}

sub g_variant_get_variant ( N-GVariant $value --> N-GVariant )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-string:
=begin pod
=head2 get-string

Returns the string value of a B<GVariant> instance with a string type.  This includes the types C<G_VARIANT_TYPE_STRING>, C<G_VARIANT_TYPE_OBJECT_PATH> and C<G_VARIANT_TYPE_SIGNATURE>.  The string will always be UTF-8 encoded, and will never be C<Any>.  If I<length> is non-C<Any> then the length of the string (in bytes) is returned there.  For trusted values, this information is already known.  For untrusted values, a C<strlen()> will be performed.  It is an error to call this function with a I<value> of any type other than those three.  The return value remains valid as long as I<value> exists.

Returns: (transfer none): the constant string, UTF-8 encoded

  method get-string ( UInt $length -->  Str  )

=item UInt $length; (optional) (default 0) (out): a pointer to a B<gsize>, to store the length

=end pod

method get-string ( UInt $length -->  Str  ) {

  g_variant_get_string(
    self.get-native-object-no-reffing, $length
  );
}

sub g_variant_get_string ( N-GVariant $value, gsize $length --> gchar-ptr )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:dup-string:
=begin pod
=head2 dup-string

Similar to C<g_variant_get_string()> except that instead of returning a constant string, the string is duplicated.  The string will always be UTF-8 encoded.  The return value must be freed using C<g_free()>.

Returns: (transfer full): a newly allocated string, UTF-8 encoded

  method dup-string ( UInt $length -->  Str  )

=item UInt $length; (out): a pointer to a B<gsize>, to store the length

=end pod

method dup-string ( UInt $length -->  Str  ) {

  g_variant_dup_string(
    self.get-native-object-no-reffing, $length
  );
}

sub g_variant_dup_string ( N-GVariant $value, gsize $length --> gchar-ptr )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-strv:
=begin pod
=head2 get-strv

Gets the contents of an array of strings B<GVariant>.  This call makes a shallow copy; the return result should be released with C<g_free()>, but the individual strings must not be modified.  If I<length> is non-C<Any> then the number of elements in the result is stored there.  In any case, the resulting array will be C<Any>-terminated.  For an empty array, I<length> will be set to 0 and a pointer to a C<Any> pointer will be returned.

Returns: (array length=length zero-terminated=1) (transfer container): an array of constant strings

  method get-strv ( UInt $length -->  CArray[Str]  )

=item UInt $length; (out) (optional): the length of the result, or C<Any>

=end pod

method get-strv ( UInt $length -->  CArray[Str]  ) {

  g_variant_get_strv(
    self.get-native-object-no-reffing, $length
  );
}

sub g_variant_get_strv ( N-GVariant $value, gsize $length --> gchar-pptr )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:dup-strv:
=begin pod
=head2 dup-strv

Gets the contents of an array of strings B<GVariant>.  This call makes a deep copy; the return result should be released with C<g_strfreev()>.  If I<length> is non-C<Any> then the number of elements in the result is stored there.  In any case, the resulting array will be C<Any>-terminated.  For an empty array, I<length> will be set to 0 and a pointer to a C<Any> pointer will be returned.

Returns: (array length=length zero-terminated=1) (transfer full): an array of strings

  method dup-strv ( UInt $length -->  CArray[Str]  )

=item UInt $length; (out) (optional): the length of the result, or C<Any>

=end pod

method dup-strv ( UInt $length -->  CArray[Str]  ) {

  g_variant_dup_strv(
    self.get-native-object-no-reffing, $length
  );
}

sub g_variant_dup_strv ( N-GVariant $value, gsize $length --> gchar-pptr )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-objv:
=begin pod
=head2 get-objv

Gets the contents of an array of object paths B<GVariant>.  This call makes a shallow copy; the return result should be released with C<g_free()>, but the individual strings must not be modified.  If I<length> is non-C<Any> then the number of elements in the result is stored there.  In any case, the resulting array will be C<Any>-terminated.  For an empty array, I<length> will be set to 0 and a pointer to a C<Any> pointer will be returned.

Returns: (array length=length zero-terminated=1) (transfer container): an array of constant strings

  method get-objv ( UInt $length -->  CArray[Str]  )

=item UInt $length; (out) (optional): the length of the result, or C<Any>

=end pod

method get-objv ( UInt $length -->  CArray[Str]  ) {

  g_variant_get_objv(
    self.get-native-object-no-reffing, $length
  );
}

sub g_variant_get_objv ( N-GVariant $value, gsize $length --> gchar-pptr )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:dup-objv:
=begin pod
=head2 dup-objv

Gets the contents of an array of object paths B<GVariant>.  This call makes a deep copy; the return result should be released with C<g_strfreev()>.  If I<length> is non-C<Any> then the number of elements in the result is stored there.  In any case, the resulting array will be C<Any>-terminated.  For an empty array, I<length> will be set to 0 and a pointer to a C<Any> pointer will be returned.

Returns: (array length=length zero-terminated=1) (transfer full): an array of strings

  method dup-objv ( UInt $length -->  CArray[Str]  )

=item UInt $length; (out) (optional): the length of the result, or C<Any>

=end pod

method dup-objv ( UInt $length -->  CArray[Str]  ) {

  g_variant_dup_objv(
    self.get-native-object-no-reffing, $length
  );
}

sub g_variant_dup_objv ( N-GVariant $value, gsize $length --> gchar-pptr )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-bytestring:
=begin pod
=head2 get-bytestring

Returns the string value of a B<GVariant> instance with an array-of-bytes type.  The string has no particular encoding.  If the array does not end with a nul terminator character, the empty string is returned.  For this reason, you can always trust that a non-C<Any> nul-terminated string will be returned by this function.  If the array contains a nul terminator character somewhere other than the last byte then the returned string is the string, up to the first such nul character.  C<g_variant_get_fixed_array()> should be used instead if the array contains arbitrary data that could not be nul-terminated or could contain nul bytes.  It is an error to call this function with a I<value> that is not an array of bytes.  The return value remains valid as long as I<value> exists.

Returns: (transfer none) (array zero-terminated=1) (element-type guint8): the constant string

  method get-bytestring ( -->  Str  )


=end pod

method get-bytestring ( -->  Str  ) {

  g_variant_get_bytestring(
    self.get-native-object-no-reffing,
  );
}

sub g_variant_get_bytestring ( N-GVariant $value --> gchar-ptr )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:dup-bytestring:
=begin pod
=head2 dup-bytestring

Similar to C<g_variant_get_bytestring()> except that instead of returning a constant string, the string is duplicated.  The return value must be freed using C<g_free()>.

Returns: (transfer full) (array zero-terminated=1 length=length) (element-type guint8): a newly allocated string

  method dup-bytestring ( UInt $length -->  Str  )

=item UInt $length; (out) (optional) (default NULL): a pointer to a B<gsize>, to store the length (not including the nul terminator)

=end pod

method dup-bytestring ( UInt $length -->  Str  ) {

  g_variant_dup_bytestring(
    self.get-native-object-no-reffing, $length
  );
}

sub g_variant_dup_bytestring ( N-GVariant $value, gsize $length --> gchar-ptr )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-bytestring-array:
=begin pod
=head2 get-bytestring-array

Gets the contents of an array of array of bytes B<GVariant>.  This call makes a shallow copy; the return result should be released with C<g_free()>, but the individual strings must not be modified.  If I<length> is non-C<Any> then the number of elements in the result is stored there.  In any case, the resulting array will be C<Any>-terminated.  For an empty array, I<length> will be set to 0 and a pointer to a C<Any> pointer will be returned.

Returns: (array length=length) (transfer container): an array of constant strings

  method get-bytestring-array ( UInt $length -->  CArray[Str]  )

=item UInt $length; (out) (optional): the length of the result, or C<Any>

=end pod

method get-bytestring-array ( UInt $length -->  CArray[Str]  ) {

  g_variant_get_bytestring_array(
    self.get-native-object-no-reffing, $length
  );
}

sub g_variant_get_bytestring_array ( N-GVariant $value, gsize $length --> gchar-pptr )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:dup-bytestring-array:
=begin pod
=head2 dup-bytestring-array

Gets the contents of an array of array of bytes B<GVariant>.  This call makes a deep copy; the return result should be released with C<g_strfreev()>.  If I<length> is non-C<Any> then the number of elements in the result is stored there.  In any case, the resulting array will be C<Any>-terminated.  For an empty array, I<length> will be set to 0 and a pointer to a C<Any> pointer will be returned.

Returns: (array length=length) (transfer full): an array of strings

  method dup-bytestring-array ( UInt $length -->  CArray[Str]  )

=item UInt $length; (out) (optional): the length of the result, or C<Any>

=end pod

method dup-bytestring-array ( UInt $length -->  CArray[Str]  ) {

  g_variant_dup_bytestring_array(
    self.get-native-object-no-reffing, $length
  );
}

sub g_variant_dup_bytestring_array ( N-GVariant $value, gsize $length --> gchar-pptr )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_variant_new_maybe:
#`{{
=begin pod
=head2 _g_variant_new_maybe

Depending on if I<child> is C<Any>, either wraps I<child> inside of a maybe container or creates a Nothing instance for the given I<type>.  At least one of I<child_type> and I<child> must be non-C<Any>. If I<child_type> is non-C<Any> then it must be a definite type. If they are both non-C<Any> then I<child_type> must be the type of I<child>.  If I<child> is a floating reference (see C<g_variant_ref_sink()>), the new instance takes ownership of I<child>.

Returns: (transfer none): a floating reference to a new B<GVariant> maybe instance

  method _g_variant_new_maybe ( N-GVariantType $child_type, N-GVariant $child --> N-GVariant )

=item N-GVariantType $child_type; (nullable): the B<GVariantType> of the child, or C<Any>
=item N-GVariant $child; (nullable): the child value, or C<Any>

=end pod
}}

sub _g_variant_new_maybe ( N-GVariantType $child_type, N-GVariant $child --> N-GVariant )
  is native(&glib-lib)
  is symbol('g_variant_new_maybe')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_variant_new_array:
#`{{
=begin pod
=head2 _g_variant_new_array

Creates a new B<GVariant> array from I<children>.  I<child_type> must be non-C<Any> if I<n_children> is zero.  Otherwise, the child type is determined by inspecting the first element of the I<children> array.  If I<child_type> is non-C<Any> then it must be a definite type.  The items of the array are taken from the I<children> array.  No entry in the I<children> array may be C<Any>.  All items in the array must have the same type, which must be the same as I<child_type>, if given.  If the I<children> are floating references (see C<g_variant_ref_sink()>), the new instance takes ownership of them as if via C<g_variant_ref_sink()>.

Returns: (transfer none): a floating reference to a new B<GVariant> array

  method _g_variant_new_array ( N-GVariantType $child_type,  $GVariant * const *children, UInt $n_children --> N-GVariant )

=item N-GVariantType $child_type; (nullable): the element type of the new array
=item  $GVariant * const *children; (nullable) (array length=n_children): an array of B<GVariant> pointers, the children
=item UInt $n_children; the length of I<children>

=end pod
}}

sub _g_variant_new_array ( N-GVariantType $child_type,  $GVariant * const *children, gsize $n_children --> N-GVariant )
  is native(&glib-lib)
  is symbol('g_variant_new_array')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_variant_new_tuple:
#`{{
=begin pod
=head2 _g_variant_new_tuple

Creates a new tuple B<GVariant> out of the items in I<children>.  The type is determined from the types of I<children>.  No entry in the I<children> array may be C<Any>.  If I<n_children> is 0 then the unit tuple is constructed.  If the I<children> are floating references (see C<g_variant_ref_sink()>), the new instance takes ownership of them as if via C<g_variant_ref_sink()>.

Returns: (transfer none): a floating reference to a new B<GVariant> tuple

  method _g_variant_new_tuple (  $GVariant * const *children, UInt $n_children --> N-GVariant )

=item  $GVariant * const *children; (array length=n_children): the items to make the tuple out of
=item UInt $n_children; the length of I<children>

=end pod
}}

sub _g_variant_new_tuple (  $GVariant * const *children, gsize $n_children --> N-GVariant )
  is native(&glib-lib)
  is symbol('g_variant_new_tuple')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_variant_new_dict_entry:
#`{{
=begin pod
=head2 _g_variant_new_dict_entry

Creates a new dictionary entry B<GVariant>. I<key> and I<value> must be non-C<Any>. I<key> must be a value of a basic type (ie: not a container).  If the I<key> or I<value> are floating references (see C<g_variant_ref_sink()>), the new instance takes ownership of them as if via C<g_variant_ref_sink()>.

Returns: (transfer none): a floating reference to a new dictionary entry B<GVariant>

  method _g_variant_new_dict_entry ( N-GVariant $value --> N-GVariant )

=item N-GVariant $value; a B<GVariant>, the value

=end pod
}}

sub _g_variant_new_dict_entry ( N-GVariant $key, N-GVariant $value --> N-GVariant )
  is native(&glib-lib)
  is symbol('g_variant_new_dict_entry')
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-maybe:
=begin pod
=head2 get-maybe

Given a maybe-typed B<GVariant> instance, extract its value.  If the value is Nothing, then this function returns C<Any>.

Returns: (nullable) (transfer full): the contents of I<value>, or C<Any>

  method get-maybe ( --> N-GVariant )


=end pod

method get-maybe ( --> N-GVariant ) {

  g_variant_get_maybe(
    self.get-native-object-no-reffing,
  );
}

sub g_variant_get_maybe ( N-GVariant $value --> N-GVariant )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:n-children:
=begin pod
=head2 n-children



  method n-children ( --> UInt )


=end pod

method n-children ( --> UInt ) {

  g_variant_n_children(
    self.get-native-object-no-reffing,
  );
}

sub g_variant_n_children ( N-GVariant $value --> gsize )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-child:
=begin pod
=head2 get-child

Reads a child item out of a container B<GVariant> instance and deconstructs it according to I<format_string>.  This call is essentially a combination of C<g_variant_get_child_value()> and C<g_variant_get()>.  I<format_string> determines the C types that are used for unpacking the values and also determines if the values are copied or borrowed, see the section on [GVariant format strings][gvariant-format-strings-pointers].

  method get-child ( UInt $index_,  Str  $format_string )

=item UInt $index_; the index of the child to deconstruct
=item  Str  $format_string; a B<GVariant> format string @...: arguments, as per I<format_string>

=end pod

method get-child ( UInt $index_,  Str  $format_string ) {

  g_variant_get_child(
    self.get-native-object-no-reffing, $index_, $format_string
  );
}

sub g_variant_get_child ( N-GVariant $value, gsize $index_, gchar-ptr $format_string, Any $any = Any  )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-child-value:
=begin pod
=head2 get-child-value



  method get-child-value ( UInt $index_ --> N-GVariant )

=item UInt $index_;

=end pod

method get-child-value ( UInt $index_ --> N-GVariant ) {

  g_variant_get_child_value(
    self.get-native-object-no-reffing, $index_
  );
}

sub g_variant_get_child_value ( N-GVariant $value, gsize $index_ --> N-GVariant )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:lookup:
=begin pod
=head2 lookup

Looks up a value in a dictionary B<GVariant>.  This function is a wrapper around C<g_variant_lookup_value()> and C<g_variant_get()>.  In the case that C<Any> would have been returned, this function returns C<0>.  Otherwise, it unpacks the returned value and returns C<1>.  I<format_string> determines the C types that are used for unpacking the values and also determines if the values are copied or borrowed, see the section on [GVariant format strings][gvariant-format-strings-pointers].  This function is currently implemented with a linear scan.  If you plan to do many lookups then B<GVariantDict> may be more efficient.

Returns: C<1> if a value was unpacked

  method lookup (  Str  $key,  Str  $format_string --> Int )

=item  Str  $key; the key to lookup in the dictionary
=item  Str  $format_string; a GVariant format string @...: the arguments to unpack the value into

=end pod

method lookup (  Str  $key,  Str  $format_string --> Int ) {

  g_variant_lookup(
    self.get-native-object-no-reffing, $key, $format_string
  );
}

sub g_variant_lookup ( N-GVariant $dictionary, gchar-ptr $key, gchar-ptr $format_string, Any $any = Any --> gboolean )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:lookup-value:
=begin pod
=head2 lookup-value

Looks up a value in a dictionary B<GVariant>.  This function works with dictionaries of the type a{s*} (and equally well with type a{o*}, but we only further discuss the string case for sake of clarity).  In the event that I<dictionary> has the type a{sv}, the I<expected_type> string specifies what type of value is expected to be inside of the variant. If the value inside the variant has a different type then C<Any> is returned. In the event that I<dictionary> has a value type other than v then I<expected_type> must directly match the value type and it is used to unpack the value directly or an error occurs.  In either case, if I<key> is not found in I<dictionary>, C<Any> is returned.  If the key is found and the value has the correct type, it is returned.  If I<expected_type> was specified then any non-C<Any> return value will have this type.  This function is currently implemented with a linear scan.  If you plan to do many lookups then B<GVariantDict> may be more efficient.

Returns: (transfer full): the value of the dictionary key, or C<Any>

  method lookup-value (  Str  $key, N-GVariantType $expected_type --> N-GVariant )

=item  Str  $key; the key to lookup in the dictionary
=item N-GVariantType $expected_type; (nullable): a B<GVariantType>, or C<Any>

=end pod

method lookup-value (  Str  $key, N-GVariantType $expected_type --> N-GVariant ) {
  my $no = …;
  $no .= get-native-object-no-reffing unless $no ~~ N-GVariantType;

  g_variant_lookup_value(
    self.get-native-object-no-reffing, $key, $expected_type
  );
}

sub g_variant_lookup_value ( N-GVariant $dictionary, gchar-ptr $key, N-GVariantType $expected_type --> N-GVariant )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-fixed-array:
=begin pod
=head2 get-fixed-array

Provides access to the serialised data for an array of fixed-sized items.  I<value> must be an array with fixed-sized elements.  Numeric types are fixed-size, as are tuples containing only other fixed-sized types.  I<element_size> must be the size of a single element in the array, as given by the section on [serialized data memory][gvariant-serialised-data-memory].  In particular, arrays of these fixed-sized types can be interpreted as an array of the given C type, with I<element_size> set to the size the appropriate type: - C<G_VARIANT_TYPE_INT16> (etc.): B<gint16> (etc.) - C<G_VARIANT_TYPE_BOOLEAN>: B<guchar> (not B<gboolean>!) - C<G_VARIANT_TYPE_BYTE>: B<guint8> - C<G_VARIANT_TYPE_HANDLE>: B<guint32> - C<G_VARIANT_TYPE_DOUBLE>: B<gdouble>  For example, if calling this function for an array of 32-bit integers, you might say `sizeof(gint32)`. This value isn't used except for the purpose of a double-check that the form of the serialised data matches the caller's expectation.  I<n_elements>, which must be non-C<Any>, is set equal to the number of items in the array.

Returns: (array length=n_elements) (transfer none): a pointer to the fixed array

  method get-fixed-array ( UInt $n_elements, UInt $element_size --> Pointer )

=item UInt $n_elements; (out): a pointer to the location to store the number of items
=item UInt $element_size; the size of each element

=end pod

method get-fixed-array ( UInt $n_elements, UInt $element_size --> Pointer ) {

  g_variant_get_fixed_array(
    self.get-native-object-no-reffing, $n_elements, $element_size
  );
}

sub g_variant_get_fixed_array ( N-GVariant $value, gsize $n_elements, gsize $element_size --> gpointer )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-size:
=begin pod
=head2 get-size



  method get-size ( --> UInt )


=end pod

method get-size ( --> UInt ) {

  g_variant_get_size(
    self.get-native-object-no-reffing,
  );
}

sub g_variant_get_size ( N-GVariant $value --> gsize )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-data:
=begin pod
=head2 get-data



  method get-data ( --> Pointer )


=end pod

method get-data ( --> Pointer ) {

  g_variant_get_data(
    self.get-native-object-no-reffing,
  );
}

sub g_variant_get_data ( N-GVariant $value --> gpointer )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-data-as-bytes:
=begin pod
=head2 get-data-as-bytes



  method get-data-as-bytes ( --> N-GObject )


=end pod

method get-data-as-bytes ( --> N-GObject ) {

  g_variant_get_data_as_bytes(
    self.get-native-object-no-reffing,
  );
}

sub g_variant_get_data_as_bytes ( N-GVariant $value --> N-GObject )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:store:
=begin pod
=head2 store



  method store ( Pointer $data )

=item Pointer $data;

=end pod

method store ( Pointer $data ) {

  g_variant_store(
    self.get-native-object-no-reffing, $data
  );
}

sub g_variant_store ( N-GVariant $value, gpointer $data  )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:print:
=begin pod
=head2 print

Pretty-prints I<value> in the format understood by C<g_variant_parse()>.  The format is described [here][gvariant-text].  If I<type_annotate> is C<1>, then type information is included in the output.

Returns: (transfer full): a newly-allocated string holding the result.

  method print ( Int $type_annotate -->  Str  )

=item Int $type_annotate; C<1> if type information should be included in the output

=end pod

method print ( Int $type_annotate -->  Str  ) {

  g_variant_print(
    self.get-native-object-no-reffing, $type_annotate
  );
}

sub g_variant_print ( N-GVariant $value, gboolean $type_annotate --> gchar-ptr )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:print-string:
=begin pod
=head2 print-string

Behaves as C<g_variant_print()>, but operates on a B<GString>.  If I<string> is non-C<Any> then it is appended to and returned.  Else, a new empty B<GString> is allocated and it is returned.

Returns: a B<GString> containing the string

  method print-string ( N-GObject $string, Int $type_annotate --> N-GObject )

=item N-GObject $string; (nullable) (default NULL): a B<GString>, or C<Any>
=item Int $type_annotate; C<1> if type information should be included in the output

=end pod

method print-string ( $string, Int $type_annotate --> N-GObject ) {
  my $no = …;
  $no .= get-native-object-no-reffing unless $no ~~ N-GObject;

  g_variant_print_string(
    self.get-native-object-no-reffing, $string, $type_annotate
  );
}

sub g_variant_print_string ( N-GVariant $value, N-GObject $string, gboolean $type_annotate --> N-GObject )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:hash:
=begin pod
=head2 hash

Generates a hash value for a B<GVariant> instance.  The output of this function is guaranteed to be the same for a given value only per-process.  It may change between different processor architectures or even different versions of GLib.  Do not use this function as a basis for building protocols or file formats.  The type of I<value> is B<gconstpointer> only to allow use of this function with B<GHashTable>.  I<value> must be a B<GVariant>.

Returns: a hash value corresponding to I<value>

  method hash ( Pointer $value --> UInt )

=item Pointer $value; (type GVariant): a basic B<GVariant> value as a B<gconstpointer>

=end pod

method hash ( Pointer $value --> UInt ) {

  g_variant_hash(
    self.get-native-object-no-reffing, $value
  );
}

sub g_variant_hash ( gpointer $value --> guint )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:equal:
=begin pod
=head2 equal

Checks if I<one> and I<two> have the same type and value.  The types of I<one> and I<two> are B<gconstpointer> only to allow use of this function with B<GHashTable>.  They must each be a B<GVariant>.

Returns: C<1> if I<one> and I<two> are equal

  method equal ( Pointer $one, Pointer $two --> Int )

=item Pointer $one; (type GVariant): a B<GVariant> instance
=item Pointer $two; (type GVariant): a B<GVariant> instance

=end pod

method equal ( Pointer $one, Pointer $two --> Int ) {

  g_variant_equal(
    self.get-native-object-no-reffing, $one, $two
  );
}

sub g_variant_equal ( gpointer $one, gpointer $two --> gboolean )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-normal-form:
=begin pod
=head2 get-normal-form

Gets a B<GVariant> instance that has the same value as I<value> and is trusted to be in normal form.  If I<value> is already trusted to be in normal form then a new reference to I<value> is returned.  If I<value> is not already trusted, then it is scanned to check if it is in normal form.  If it is found to be in normal form then it is marked as trusted and a new reference to it is returned.  If I<value> is found not to be in normal form then a new trusted B<GVariant> is created with the same value as I<value>.  It makes sense to call this function if you've received B<GVariant> data from untrusted sources and you want to ensure your serialised output is definitely in normal form.  If I<value> is already in normal form, a new reference will be returned (which will be floating if I<value> is floating). If it is not in normal form, the newly created B<GVariant> will be returned with a single non-floating reference. Typically, C<g_variant_take_ref()> should be called on the return value from this function to guarantee ownership of a single non-floating reference to it.

Returns: (transfer full): a trusted B<GVariant>

  method get-normal-form ( --> N-GVariant )


=end pod

method get-normal-form ( --> N-GVariant ) {

  g_variant_get_normal_form(
    self.get-native-object-no-reffing,
  );
}

sub g_variant_get_normal_form ( N-GVariant $value --> N-GVariant )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:is-normal-form:
=begin pod
=head2 is-normal-form



  method is-normal-form ( --> Int )


=end pod

method is-normal-form ( --> Int ) {

  g_variant_is_normal_form(
    self.get-native-object-no-reffing,
  );
}

sub g_variant_is_normal_form ( N-GVariant $value --> gboolean )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:byteswap:
=begin pod
=head2 byteswap

Performs a byteswapping operation on the contents of I<value>.  The result is that all multi-byte numeric data contained in I<value> is byteswapped.  That includes 16, 32, and 64bit signed and unsigned integers as well as file handles and double precision floating point values.  This function is an identity mapping on any value that does not contain multi-byte numeric data.  That include strings, booleans, bytes and containers containing only these things (recursively).  The returned value is always in normal form and is marked as trusted.

Returns: (transfer full): the byteswapped form of I<value>

  method byteswap ( --> N-GVariant )


=end pod

method byteswap ( --> N-GVariant ) {

  g_variant_byteswap(
    self.get-native-object-no-reffing,
  );
}

sub g_variant_byteswap ( N-GVariant $value --> N-GVariant )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_variant_new_from_bytes:
#`{{
=begin pod
=head2 _g_variant_new_from_bytes



  method _g_variant_new_from_bytes ( N-GVariantType $type, N-GObject $bytes, Int $trusted --> N-GVariant )

=item N-GVariantType $type;
=item N-GObject $bytes;
=item Int $trusted;

=end pod
}}

sub _g_variant_new_from_bytes ( N-GVariantType $type, N-GObject $bytes, gboolean $trusted --> N-GVariant )
  is native(&glib-lib)
  is symbol('g_variant_new_from_bytes')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_variant_new_from_data:
#`{{
=begin pod
=head2 _g_variant_new_from_data

Creates a new B<GVariant> instance from serialised data.  I<type> is the type of B<GVariant> instance that will be constructed. The interpretation of I<data> depends on knowing the type.  I<data> is not modified by this function and must remain valid with an unchanging value until such a time as I<notify> is called with I<user_data>.  If the contents of I<data> change before that time then the result is undefined.  If I<data> is trusted to be serialised data in normal form then I<trusted> should be C<1>.  This applies to serialised data created within this process or read from a trusted location on the disk (such as a file installed in /usr/lib alongside your application).  You should set trusted to C<0> if I<data> is read from the network, a file in the user's home directory, etc.  If I<data> was not stored in this machine's native endianness, any multi-byte numeric values in the returned variant will also be in non-native endianness. C<g_variant_byteswap()> can be used to recover the original values.  I<notify> will be called with I<user_data> when I<data> is no longer needed.  The exact time of this call is unspecified and might even be before this function returns.  Note: I<data> must be backed by memory that is aligned appropriately for the I<type> being loaded. Otherwise this function will internally create a copy of the memory (since GLib 2.60) or (in older versions) fail and exit the process.

Returns: (transfer none): a new floating B<GVariant> of type I<type>

  method _g_variant_new_from_data ( N-GVariantType $type, Pointer $data, UInt $size, Int $trusted, GDestroyNotify $notify, Pointer $user_data --> N-GVariant )

=item N-GVariantType $type; a definite B<GVariantType>
=item Pointer $data; (array length=size) (element-type guint8): the serialised data
=item UInt $size; the size of I<data>
=item Int $trusted; C<1> if I<data> is definitely in normal form
=item GDestroyNotify $notify; (scope async): function to call when I<data> is no longer needed
=item Pointer $user_data; data for I<notify>

=end pod
}}

sub _g_variant_new_from_data ( N-GVariantType $type, gpointer $data, gsize $size, gboolean $trusted, GDestroyNotify $notify, gpointer $user_data --> N-GVariant )
  is native(&glib-lib)
  is symbol('g_variant_new_from_data')
  { * }

#-------------------------------------------------------------------------------
#TM:0:iter-new:
=begin pod
=head2 iter-new

Creates a heap-allocated B<GVariantIter> for iterating over the items in I<value>.  Use C<g_variant_iter_free()> to free the return value when you no longer need it.  A reference is taken to I<value> and will be released only when C<g_variant_iter_free()> is called.

Returns: (transfer full): a new heap-allocated B<GVariantIter>

  method iter-new ( --> N-GVariantIter )


=end pod

method iter-new ( --> N-GVariantIter ) {

  g_variant_iter_new(
    self.get-native-object-no-reffing,
  );
}

sub g_variant_iter_new ( N-GVariant $value --> N-GVariantIter )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:iter-init:
=begin pod
=head2 iter-init

Initialises (without allocating) a B<GVariantIter>.  I<iter> may be completely uninitialised prior to this call; its old value is ignored.  The iterator remains valid for as long as I<value> exists, and need not be freed in any way.

Returns: the number of items in I<value>

  method iter-init ( N-GVariantIter $iter, N-GVariant $value --> UInt )

=item N-GVariantIter $iter; a pointer to a B<GVariantIter>
=item N-GVariant $value; a container B<GVariant>

=end pod

method iter-init ( N-GVariantIter $iter, N-GVariant $value --> UInt ) {
  my $no = …;
  $no .= get-native-object-no-reffing unless $no ~~ N-GVariant;

  g_variant_iter_init(
    self.get-native-object-no-reffing, $iter, $value
  );
}

sub g_variant_iter_init ( N-GVariantIter $iter, N-GVariant $value --> gsize )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:iter-copy:
=begin pod
=head2 iter-copy

Creates a new heap-allocated B<GVariantIter> to iterate over the container that was being iterated over by I<iter>.  Iteration begins on the new iterator from the current position of the old iterator but the two copies are independent past that point.  Use C<g_variant_iter_free()> to free the return value when you no longer need it.  A reference is taken to the container that I<iter> is iterating over and will be releated only when C<g_variant_iter_free()> is called.

Returns: (transfer full): a new heap-allocated B<GVariantIter>

  method iter-copy ( N-GVariantIter $iter --> N-GVariantIter )

=item N-GVariantIter $iter; a B<GVariantIter>

=end pod

method iter-copy ( N-GVariantIter $iter --> N-GVariantIter ) {
  my $no = …;
  $no .= get-native-object-no-reffing unless $no ~~ N-GVariant;

  g_variant_iter_copy(
    self.get-native-object-no-reffing, $iter
  );
}

sub g_variant_iter_copy ( N-GVariantIter $iter --> N-GVariantIter )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:iter-n-children:
=begin pod
=head2 iter-n-children

Queries the number of child items in the container that we are iterating over.  This is the total number of items -- not the number of items remaining.  This function might be useful for preallocation of arrays.

Returns: the number of children in the container

  method iter-n-children ( N-GVariantIter $iter --> UInt )

=item N-GVariantIter $iter; a B<GVariantIter>

=end pod

method iter-n-children ( N-GVariantIter $iter --> UInt ) {
  my $no = …;
  $no .= get-native-object-no-reffing unless $no ~~ N-GVariant;

  g_variant_iter_n_children(
    self.get-native-object-no-reffing, $iter
  );
}

sub g_variant_iter_n_children ( N-GVariantIter $iter --> gsize )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:iter-free:
=begin pod
=head2 iter-free

Frees a heap-allocated B<GVariantIter>.  Only call this function on iterators that were returned by C<g_variant_iter_new()> or C<g_variant_iter_copy()>.

  method iter-free ( N-GVariantIter $iter )

=item N-GVariantIter $iter; (transfer full): a heap-allocated B<GVariantIter>

=end pod

method iter-free ( N-GVariantIter $iter ) {
  my $no = …;
  $no .= get-native-object-no-reffing unless $no ~~ N-GVariant;

  g_variant_iter_free(
    self.get-native-object-no-reffing, $iter
  );
}

sub g_variant_iter_free ( N-GVariantIter $iter  )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:iter-next-value:
=begin pod
=head2 iter-next-value

Gets the next item in the container.  If no more items remain then C<Any> is returned.  Use C<g_variant_unref()> to drop your reference on the return value when you no longer need it.  Here is an example for iterating with C<g_variant_iter_next_value()>: |[<!-- language="C" -->  // recursively iterate a container void iterate_container_recursive (GVariant *container) { GVariantIter iter; GVariant *child;  g_variant_iter_init (&iter, container); while ((child = g_variant_iter_next_value (&iter))) { g_print ("type 'C<s>'\n", g_variant_get_type_string (child));  if (g_variant_is_container (child)) iterate_container_recursive (child);  g_variant_unref (child); } } ]|

Returns: (nullable) (transfer full): a B<GVariant>, or C<Any>

  method iter-next-value ( N-GVariantIter $iter --> N-GVariant )

=item N-GVariantIter $iter; a B<GVariantIter>

=end pod

method iter-next-value ( N-GVariantIter $iter --> N-GVariant ) {
  my $no = …;
  $no .= get-native-object-no-reffing unless $no ~~ N-GVariant;

  g_variant_iter_next_value(
    self.get-native-object-no-reffing, $iter
  );
}

sub g_variant_iter_next_value ( N-GVariantIter $iter --> N-GVariant )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:iter-next:
=begin pod
=head2 iter-next

Gets the next item in the container and unpacks it into the variable argument list according to I<format_string>, returning C<1>.  If no more items remain then C<0> is returned.  All of the pointers given on the variable arguments list of this function are assumed to point at uninitialised memory.  It is the responsibility of the caller to free all of the values returned by the unpacking process.  Here is an example for memory management with C<g_variant_iter_next()>: |[<!-- language="C" -->  // Iterates a dictionary of type 'a{sv}' void iterate_dictionary (GVariant *dictionary) { GVariantIter iter; GVariant *value; gchar *key;  g_variant_iter_init (&iter, dictionary); while (g_variant_iter_next (&iter, "{sv}", &key, &value)) { g_print ("Item 'C<s>' has type 'C<s>'\n", key, g_variant_get_type_string (value));  // must free data for ourselves g_variant_unref (value); g_free (key); } } ]|  For a solution that is likely to be more convenient to C programmers when dealing with loops, see C<g_variant_iter_loop()>.  I<format_string> determines the C types that are used for unpacking the values and also determines if the values are copied or borrowed.  See the section on [GVariant format strings][gvariant-format-strings-pointers].

Returns: C<1> if a value was unpacked, or C<0> if there as no value

  method iter-next ( N-GVariantIter $iter,  Str  $format_string --> Int )

=item N-GVariantIter $iter; a B<GVariantIter>
=item  Str  $format_string; a GVariant format string @...: the arguments to unpack the value into

=end pod

method iter-next ( N-GVariantIter $iter,  Str  $format_string --> Int ) {
  my $no = …;
  $no .= get-native-object-no-reffing unless $no ~~ N-GVariant;

  g_variant_iter_next(
    self.get-native-object-no-reffing, $iter, $format_string
  );
}

sub g_variant_iter_next ( N-GVariantIter $iter, gchar-ptr $format_string, Any $any = Any --> gboolean )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:iter-loop:
=begin pod
=head2 iter-loop

Gets the next item in the container and unpacks it into the variable argument list according to I<format_string>, returning C<1>.  If no more items remain then C<0> is returned.  On the first call to this function, the pointers appearing on the variable argument list are assumed to point at uninitialised memory. On the second and later calls, it is assumed that the same pointers will be given and that they will point to the memory as set by the previous call to this function.  This allows the previous values to be freed, as appropriate.  This function is intended to be used with a while loop as demonstrated in the following example.  This function can only be used when iterating over an array.  It is only valid to call this function with a string constant for the format string and the same string constant must be used each time.  Mixing calls to this function and C<g_variant_iter_next()> or C<g_variant_iter_next_value()> on the same iterator causes undefined behavior.  If you break out of a such a while loop using C<g_variant_iter_loop()> then you must free or unreference all the unpacked values as you would with C<g_variant_get()>. Failure to do so will cause a memory leak.  Here is an example for memory management with C<g_variant_iter_loop()>: |[<!-- language="C" -->  // Iterates a dictionary of type 'a{sv}' void iterate_dictionary (GVariant *dictionary) { GVariantIter iter; GVariant *value; gchar *key;  g_variant_iter_init (&iter, dictionary); while (g_variant_iter_loop (&iter, "{sv}", &key, &value)) { g_print ("Item 'C<s>' has type 'C<s>'\n", key, g_variant_get_type_string (value));  // no need to free 'key' and 'value' here // unless breaking out of this loop } } ]|  For most cases you should use C<g_variant_iter_next()>.  This function is really only useful when unpacking into B<GVariant> or B<GVariantIter> in order to allow you to skip the call to C<g_variant_unref()> or C<g_variant_iter_free()>.  For example, if you are only looping over simple integer and string types, C<g_variant_iter_next()> is definitely preferred.  For string types, use the '&' prefix to avoid allocating any memory at all (and thereby avoiding the need to free anything as well).  I<format_string> determines the C types that are used for unpacking the values and also determines if the values are copied or borrowed.  See the section on [GVariant format strings][gvariant-format-strings-pointers].

Returns: C<1> if a value was unpacked, or C<0> if there was no value

  method iter-loop ( N-GVariantIter $iter,  Str  $format_string --> Int )

=item N-GVariantIter $iter; a B<GVariantIter>
=item  Str  $format_string; a GVariant format string @...: the arguments to unpack the value into

=end pod

method iter-loop ( N-GVariantIter $iter,  Str  $format_string --> Int ) {
  my $no = …;
  $no .= get-native-object-no-reffing unless $no ~~ N-GVariant;

  g_variant_iter_loop(
    self.get-native-object-no-reffing, $iter, $format_string
  );
}

sub g_variant_iter_loop ( N-GVariantIter $iter, gchar-ptr $format_string, Any $any = Any --> gboolean )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:parse-error-quark:
=begin pod
=head2 parse-error-quark



  method parse-error-quark ( --> UInt )


=end pod

method parse-error-quark ( --> UInt ) {

  g_variant_parse_error_quark(
    self.get-native-object-no-reffing,
  );
}

sub g_variant_parse_error_quark (  --> GQuark )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:builder-new:
=begin pod
=head2 builder-new

Allocates and initialises a new B<GVariantBuilder>.  You should call C<g_variant_builder_unref()> on the return value when it is no longer needed.  The memory will not be automatically freed by any other call.  In most cases it is easier to place a B<GVariantBuilder> directly on the stack of the calling function and initialise it with C<g_variant_builder_init()>.

Returns: (transfer full): a B<GVariantBuilder>

  method builder-new ( N-GVariantType $type --> N-GVariantBuilder )

=item N-GVariantType $type; a container type

=end pod

method builder-new ( N-GVariantType $type --> N-GVariantBuilder ) {
  my $no = …;
  $no .= get-native-object-no-reffing unless $no ~~ N-GVariantType;

  g_variant_builder_new(
    self.get-native-object-no-reffing, $type
  );
}

sub g_variant_builder_new ( N-GVariantType $type --> N-GVariantBuilder )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:builder-unref:
=begin pod
=head2 builder-unref

Decreases the reference count on I<builder>.  In the event that there are no more references, releases all memory associated with the B<GVariantBuilder>.  Don't call this on stack-allocated B<GVariantBuilder> instances or bad things will happen.

  method builder-unref ( N-GVariantBuilder $builder )

=item N-GVariantBuilder $builder; (transfer full): a B<GVariantBuilder> allocated by C<g_variant_builder_new()>

=end pod

method builder-unref ( N-GVariantBuilder $builder ) {
  my $no = …;
  $no .= get-native-object-no-reffing unless $no ~~ N-GVariant;

  g_variant_builder_unref(
    self.get-native-object-no-reffing, $builder
  );
}

sub g_variant_builder_unref ( N-GVariantBuilder $builder  )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:builder-ref:
=begin pod
=head2 builder-ref

Increases the reference count on I<builder>.  Don't call this on stack-allocated B<GVariantBuilder> instances or bad things will happen.

Returns: (transfer full): a new reference to I<builder>

  method builder-ref ( N-GVariantBuilder $builder --> N-GVariantBuilder )

=item N-GVariantBuilder $builder; a B<GVariantBuilder> allocated by C<g_variant_builder_new()>

=end pod

method builder-ref ( N-GVariantBuilder $builder --> N-GVariantBuilder ) {
  my $no = …;
  $no .= get-native-object-no-reffing unless $no ~~ N-GVariant;

  g_variant_builder_ref(
    self.get-native-object-no-reffing, $builder
  );
}

sub g_variant_builder_ref ( N-GVariantBuilder $builder --> N-GVariantBuilder )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:builder-init:
=begin pod
=head2 builder-init

Initialises a B<GVariantBuilder> structure.  I<type> must be non-C<Any>.  It specifies the type of container to construct.  It can be an indefinite type such as C<G_VARIANT_TYPE_ARRAY> or a definite type such as "as" or "(ii)". Maybe, array, tuple, dictionary entry and variant-typed values may be constructed.  After the builder is initialised, values are added using C<g_variant_builder_add_value()> or C<g_variant_builder_add()>.  After all the child values are added, C<g_variant_builder_end()> frees the memory associated with the builder and returns the B<GVariant> that was created.  This function completely ignores the previous contents of I<builder>. On one hand this means that it is valid to pass in completely uninitialised memory.  On the other hand, this means that if you are initialising over top of an existing B<GVariantBuilder> you need to first call C<g_variant_builder_clear()> in order to avoid leaking memory.  You must not call C<g_variant_builder_ref()> or C<g_variant_builder_unref()> on a B<GVariantBuilder> that was initialised with this function.  If you ever pass a reference to a B<GVariantBuilder> outside of the control of your own code then you should assume that the person receiving that reference may try to use reference counting; you should use C<g_variant_builder_new()> instead of this function.

  method builder-init ( N-GVariantBuilder $builder, N-GVariantType $type )

=item N-GVariantBuilder $builder; a B<GVariantBuilder>
=item N-GVariantType $type; a container type

=end pod

method builder-init ( N-GVariantBuilder $builder, N-GVariantType $type ) {
  my $no = …;
  $no .= get-native-object-no-reffing unless $no ~~ N-GVariantType;

  g_variant_builder_init(
    self.get-native-object-no-reffing, $builder, $type
  );
}

sub g_variant_builder_init ( N-GVariantBuilder $builder, N-GVariantType $type  )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:builder-end:
=begin pod
=head2 builder-end

Ends the builder process and returns the constructed value.  It is not permissible to use I<builder> in any way after this call except for reference counting operations (in the case of a heap-allocated B<GVariantBuilder>) or by reinitialising it with C<g_variant_builder_init()> (in the case of stack-allocated). This means that for the stack-allocated builders there is no need to call C<g_variant_builder_clear()> after the call to C<g_variant_builder_end()>.  It is an error to call this function in any way that would create an inconsistent value to be constructed (ie: insufficient number of items added to a container with a specific number of children required).  It is also an error to call this function if the builder was created with an indefinite array or maybe type and no children have been added; in this case it is impossible to infer the type of the empty array.

Returns: (transfer none): a new, floating, B<GVariant>

  method builder-end ( N-GVariantBuilder $builder --> N-GVariant )

=item N-GVariantBuilder $builder; a B<GVariantBuilder>

=end pod

method builder-end ( N-GVariantBuilder $builder --> N-GVariant ) {
  my $no = …;
  $no .= get-native-object-no-reffing unless $no ~~ N-GVariant;

  g_variant_builder_end(
    self.get-native-object-no-reffing, $builder
  );
}

sub g_variant_builder_end ( N-GVariantBuilder $builder --> N-GVariant )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:builder-clear:
=begin pod
=head2 builder-clear

Releases all memory associated with a B<GVariantBuilder> without freeing the B<GVariantBuilder> structure itself.  It typically only makes sense to do this on a stack-allocated B<GVariantBuilder> if you want to abort building the value part-way through.  This function need not be called if you call C<g_variant_builder_end()> and it also doesn't need to be called on builders allocated with C<g_variant_builder_new()> (see C<g_variant_builder_unref()> for that).  This function leaves the B<GVariantBuilder> structure set to all-zeros. It is valid to call this function on either an initialised B<GVariantBuilder> or one that is set to all-zeros but it is not valid to call this function on uninitialised memory.

  method builder-clear ( N-GVariantBuilder $builder )

=item N-GVariantBuilder $builder; a B<GVariantBuilder>

=end pod

method builder-clear ( N-GVariantBuilder $builder ) {
  my $no = …;
  $no .= get-native-object-no-reffing unless $no ~~ N-GVariant;

  g_variant_builder_clear(
    self.get-native-object-no-reffing, $builder
  );
}

sub g_variant_builder_clear ( N-GVariantBuilder $builder  )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:builder-open:
=begin pod
=head2 builder-open

Opens a subcontainer inside the given I<builder>.  When done adding items to the subcontainer, C<g_variant_builder_close()> must be called. I<type> is the type of the container: so to build a tuple of several values, I<type> must include the tuple itself.  It is an error to call this function in any way that would cause an inconsistent value to be constructed (ie: adding too many values or a value of an incorrect type).  Example of building a nested variant: |[<!-- language="C" --> GVariantBuilder builder; guint32 some_number = C<get_number()>; g_autoptr (GHashTable) some_dict = C<get_dict()>; GHashTableIter iter; const gchar *key; const GVariant *value; g_autoptr (GVariant) output = NULL;  g_variant_builder_init (&builder, G_VARIANT_TYPE ("(ua{sv})")); g_variant_builder_add (&builder, "u", some_number); g_variant_builder_open (&builder, G_VARIANT_TYPE ("a{sv}"));  g_hash_table_iter_init (&iter, some_dict); while (g_hash_table_iter_next (&iter, (gpointer *) &key, (gpointer *) &value)) { g_variant_builder_open (&builder, G_VARIANT_TYPE ("{sv}")); g_variant_builder_add (&builder, "s", key); g_variant_builder_add (&builder, "v", value); g_variant_builder_close (&builder); }  g_variant_builder_close (&builder);  output = g_variant_builder_end (&builder); ]|

  method builder-open ( N-GVariantBuilder $builder, N-GVariantType $type )

=item N-GVariantBuilder $builder; a B<GVariantBuilder>
=item N-GVariantType $type; the B<GVariantType> of the container

=end pod

method builder-open ( N-GVariantBuilder $builder, N-GVariantType $type ) {
  my $no = …;
  $no .= get-native-object-no-reffing unless $no ~~ N-GVariantType;

  g_variant_builder_open(
    self.get-native-object-no-reffing, $builder, $type
  );
}

sub g_variant_builder_open ( N-GVariantBuilder $builder, N-GVariantType $type  )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:builder-close:
=begin pod
=head2 builder-close

Closes the subcontainer inside the given I<builder> that was opened by the most recent call to C<g_variant_builder_open()>.  It is an error to call this function in any way that would create an inconsistent value to be constructed (ie: too few values added to the subcontainer).

  method builder-close ( N-GVariantBuilder $builder )

=item N-GVariantBuilder $builder; a B<GVariantBuilder>

=end pod

method builder-close ( N-GVariantBuilder $builder ) {
  my $no = …;
  $no .= get-native-object-no-reffing unless $no ~~ N-GVariant;

  g_variant_builder_close(
    self.get-native-object-no-reffing, $builder
  );
}

sub g_variant_builder_close ( N-GVariantBuilder $builder  )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:builder-add-value:
=begin pod
=head2 builder-add-value

Adds I<value> to I<builder>.  It is an error to call this function in any way that would create an inconsistent value to be constructed.  Some examples of this are putting different types of items into an array, putting the wrong types or number of items in a tuple, putting more than one value into a variant, etc.  If I<value> is a floating reference (see C<g_variant_ref_sink()>), the I<builder> instance takes ownership of I<value>.

  method builder-add-value ( N-GVariantBuilder $builder, N-GVariant $value )

=item N-GVariantBuilder $builder; a B<GVariantBuilder>
=item N-GVariant $value; a B<GVariant>

=end pod

method builder-add-value ( N-GVariantBuilder $builder, N-GVariant $value ) {
  my $no = …;
  $no .= get-native-object-no-reffing unless $no ~~ N-GVariant;

  g_variant_builder_add_value(
    self.get-native-object-no-reffing, $builder, $value
  );
}

sub g_variant_builder_add_value ( N-GVariantBuilder $builder, N-GVariant $value  )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:builder-add:
=begin pod
=head2 builder-add

Adds to a B<GVariantBuilder>.  This call is a convenience wrapper that is exactly equivalent to calling C<g_variant_new()> followed by C<g_variant_builder_add_value()>.  Note that the arguments must be of the correct width for their types specified in I<format_string>. This can be achieved by casting them. See the [GVariant varargs documentation][gvariant-varargs].  This function might be used as follows:  |[<!-- language="C" -->  GVariant * make_pointless_dictionary (void) { GVariantBuilder builder; int i;  g_variant_builder_init (&builder, G_VARIANT_TYPE_ARRAY); for (i = 0; i < 16; i++) { gchar buf[3];  sprintf (buf, "C<d>", i); g_variant_builder_add (&builder, "{is}", i, buf); }  return g_variant_builder_end (&builder); } ]|

  method builder-add ( N-GVariantBuilder $builder,  Str  $format_string )

=item N-GVariantBuilder $builder; a B<GVariantBuilder>
=item  Str  $format_string; a B<GVariant> varargs format string @...: arguments, as per I<format_string>

=end pod

method builder-add ( N-GVariantBuilder $builder,  Str  $format_string ) {
  my $no = …;
  $no .= get-native-object-no-reffing unless $no ~~ N-GVariant;

  g_variant_builder_add(
    self.get-native-object-no-reffing, $builder, $format_string
  );
}

sub g_variant_builder_add ( N-GVariantBuilder $builder, gchar-ptr $format_string, Any $any = Any  )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:builder-add-parsed:
=begin pod
=head2 builder-add-parsed



  method builder-add-parsed ( N-GVariantBuilder $builder,  Str  $format )

=item N-GVariantBuilder $builder;
=item  Str  $format;

=end pod

method builder-add-parsed ( N-GVariantBuilder $builder,  Str  $format ) {
  my $no = …;
  $no .= get-native-object-no-reffing unless $no ~~ N-GVariant;

  g_variant_builder_add_parsed(
    self.get-native-object-no-reffing, $builder, $format
  );
}

sub g_variant_builder_add_parsed ( N-GVariantBuilder $builder, gchar-ptr $format, Any $any = Any  )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_variant_new:
#`{{
=begin pod
=head2 _g_variant_new



  method _g_variant_new (  Str  $format_string --> N-GVariant )

=item  Str  $format_string;

=end pod
}}

sub _g_variant_new ( gchar-ptr $format_string, Any $any = Any --> N-GVariant )
  is native(&glib-lib)
  is symbol('g_variant_new')
  { * }

#-------------------------------------------------------------------------------
#TM:0:get:
=begin pod
=head2 get

Deconstructs a B<GVariant> instance.  Think of this function as an analogue to C<scanf()>.  The arguments that are expected by this function are entirely determined by I<format_string>.  I<format_string> also restricts the permissible types of I<value>.  It is an error to give a value with an incompatible type.  See the section on [GVariant format strings][gvariant-format-strings]. Please note that the syntax of the format string is very likely to be extended in the future.  I<format_string> determines the C types that are used for unpacking the values and also determines if the values are copied or borrowed, see the section on [GVariant format strings][gvariant-format-strings-pointers].

  method get (  Str  $format_string )

=item  Str  $format_string; a B<GVariant> format string @...: arguments, as per I<format_string>

=end pod

method get (  Str  $format_string ) {

  g_variant_get(
    self.get-native-object-no-reffing, $format_string
  );
}

sub g_variant_get ( N-GVariant $value, gchar-ptr $format_string, Any $any = Any  )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_variant_new_va:
#`{{
=begin pod
=head2 _g_variant_new_va

This function is intended to be used by libraries based on B<GVariant> that want to provide C<g_variant_new()>-like functionality to their users.  The API is more general than C<g_variant_new()> to allow a wider range of possible uses.  I<format_string> must still point to a valid format string, but it only needs to be nul-terminated if I<endptr> is C<Any>.  If I<endptr> is non-C<Any> then it is updated to point to the first character past the end of the format string.  I<app> is a pointer to a B<va_list>.  The arguments, according to I<format_string>, are collected from this B<va_list> and the list is left pointing to the argument following the last.  Note that the arguments in I<app> must be of the correct width for their types specified in I<format_string> when collected into the B<va_list>. See the [GVariant varargs documentation][gvariant-varargs].  These two generalisations allow mixing of multiple calls to C<g_variant_new_va()> and C<g_variant_get_va()> within a single actual varargs call by the user.  The return value will be floating if it was a newly created GVariant instance (for example, if the format string was "(ii)").  In the case that the format_string was '*', '?', 'r', or a format starting with '@' then the collected B<GVariant> pointer will be returned unmodified, without adding any additional references.  In order to behave correctly in all cases it is necessary for the calling function to C<g_variant_ref_sink()> the return result before returning control to the user that originally provided the pointer. At this point, the caller will have their own full reference to the result.  This can also be done by adding the result to a container, or by passing it to another C<g_variant_new()> call.

Returns: a new, usually floating, B<GVariant>

  method _g_variant_new_va (  Str  $format_string,  CArray[Str]  $endptr, va_list $app --> N-GVariant )

=item  Str  $format_string; a string that is prefixed with a format string
=item  CArray[Str]  $endptr; (nullable) (default NULL): location to store the end pointer, or C<Any>
=item va_list $app; a pointer to a B<va_list>

=end pod
}}

sub _g_variant_new_va ( gchar-ptr $format_string, gchar-pptr $endptr, va_list $app --> N-GVariant )
  is native(&glib-lib)
  is symbol('g_variant_new_va')
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-va:
=begin pod
=head2 get-va

This function is intended to be used by libraries based on B<GVariant> that want to provide C<g_variant_get()>-like functionality to their users.  The API is more general than C<g_variant_get()> to allow a wider range of possible uses.  I<format_string> must still point to a valid format string, but it only need to be nul-terminated if I<endptr> is C<Any>.  If I<endptr> is non-C<Any> then it is updated to point to the first character past the end of the format string.  I<app> is a pointer to a B<va_list>.  The arguments, according to I<format_string>, are collected from this B<va_list> and the list is left pointing to the argument following the last.  These two generalisations allow mixing of multiple calls to C<g_variant_new_va()> and C<g_variant_get_va()> within a single actual varargs call by the user.  I<format_string> determines the C types that are used for unpacking the values and also determines if the values are copied or borrowed, see the section on [GVariant format strings][gvariant-format-strings-pointers].

  method get-va (  Str  $format_string,  CArray[Str]  $endptr, va_list $app )

=item  Str  $format_string; a string that is prefixed with a format string
=item  CArray[Str]  $endptr; (nullable) (default NULL): location to store the end pointer, or C<Any>
=item va_list $app; a pointer to a B<va_list>

=end pod

method get-va (  Str  $format_string,  CArray[Str]  $endptr, va_list $app ) {

  g_variant_get_va(
    self.get-native-object-no-reffing, $format_string, $endptr, $app
  );
}

sub g_variant_get_va ( N-GVariant $value, gchar-ptr $format_string, gchar-pptr $endptr, va_list $app  )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:check-format-string:
=begin pod
=head2 check-format-string

Checks if calling C<g_variant_get()> with I<format_string> on I<value> would be valid from a type-compatibility standpoint.  I<format_string> is assumed to be a valid format string (from a syntactic standpoint).  If I<copy_only> is C<1> then this function additionally checks that it would be safe to call C<g_variant_unref()> on I<value> immediately after the call to C<g_variant_get()> without invalidating the result.  This is only possible if deep copies are made (ie: there are no pointers to the data inside of the soon-to-be-freed B<GVariant> instance).  If this check fails then a C<g_critical()> is printed and C<0> is returned.  This function is meant to be used by functions that wish to provide varargs accessors to B<GVariant> values of uncertain values (eg: C<g_variant_lookup()> or C<g_menu_model_get_item_attribute()>).

Returns: C<1> if I<format_string> is safe to use

  method check-format-string (  Str  $format_string, Int $copy_only --> Int )

=item  Str  $format_string; a valid B<GVariant> format string
=item Int $copy_only; C<1> to ensure the format string makes deep copies

=end pod

method check-format-string (  Str  $format_string, Int $copy_only --> Int ) {

  g_variant_check_format_string(
    self.get-native-object-no-reffing, $format_string, $copy_only
  );
}

sub g_variant_check_format_string ( N-GVariant $value, gchar-ptr $format_string, gboolean $copy_only --> gboolean )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:parse:
=begin pod
=head2 parse



  method parse ( N-GVariantType $type,  Str  $text,  Str  $limit,  CArray[Str]  $endptr, N-GError $error --> N-GVariant )

=item N-GVariantType $type;
=item  Str  $text;
=item  Str  $limit;
=item  CArray[Str]  $endptr;
=item N-GError $error;

=end pod

method parse ( N-GVariantType $type,  Str  $text,  Str  $limit,  CArray[Str]  $endptr, N-GError $error --> N-GVariant ) {
  my $no = …;
  $no .= get-native-object-no-reffing unless $no ~~ N-GVariantType;

  g_variant_parse(
    self.get-native-object-no-reffing, $type, $text, $limit, $endptr, $error
  );
}

sub g_variant_parse ( N-GVariantType $type, gchar-ptr $text, gchar-ptr $limit, gchar-pptr $endptr, N-GError $error --> N-GVariant )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_variant_new_parsed:
#`{{
=begin pod
=head2 _g_variant_new_parsed



  method _g_variant_new_parsed (  Str  $format --> N-GVariant )

=item  Str  $format;

=end pod
}}

sub _g_variant_new_parsed ( gchar-ptr $format, Any $any = Any --> N-GVariant )
  is native(&glib-lib)
  is symbol('g_variant_new_parsed')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_variant_new_parsed_va:
#`{{
=begin pod
=head2 _g_variant_new_parsed_va



  method _g_variant_new_parsed_va (  Str  $format, va_list $app --> N-GVariant )

=item  Str  $format;
=item va_list $app;

=end pod
}}

sub _g_variant_new_parsed_va ( gchar-ptr $format, va_list $app --> N-GVariant )
  is native(&glib-lib)
  is symbol('g_variant_new_parsed_va')
  { * }

#-------------------------------------------------------------------------------
#TM:0:parse-error-print-context:
=begin pod
=head2 parse-error-print-context



  method parse-error-print-context ( N-GError $error,  Str  $source_str -->  Str  )

=item N-GError $error;
=item  Str  $source_str;

=end pod

method parse-error-print-context ( N-GError $error,  Str  $source_str -->  Str  ) {

  g_variant_parse_error_print_context(
    self.get-native-object-no-reffing, $error, $source_str
  );
}

sub g_variant_parse_error_print_context ( N-GError $error, gchar-ptr $source_str --> gchar-ptr )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:compare:
=begin pod
=head2 compare

Compares I<one> and I<two>.  The types of I<one> and I<two> are B<gconstpointer> only to allow use of this function with B<GTree>, B<GPtrArray>, etc.  They must each be a B<GVariant>.  Comparison is only defined for basic types (ie: booleans, numbers, strings).  For booleans, C<0> is less than C<1>.  Numbers are ordered in the usual way.  Strings are in ASCII lexographical order.  It is a programmer error to attempt to compare container values or two values that have types that are not exactly equal.  For example, you cannot compare a 32-bit signed integer with a 32-bit unsigned integer.  Also note that this function is not particularly well-behaved when it comes to comparison of doubles; in particular, the handling of incomparable values (ie: NaN) is undefined.  If you only require an equality comparison, C<g_variant_equal()> is more general.

Returns: negative value if a < b; zero if a = b; positive value if a > b.

  method compare ( Pointer $one, Pointer $two --> Int )

=item Pointer $one; (type GVariant): a basic-typed B<GVariant> instance
=item Pointer $two; (type GVariant): a B<GVariant> instance of the same type

=end pod

method compare ( Pointer $one, Pointer $two --> Int ) {

  g_variant_compare(
    self.get-native-object-no-reffing, $one, $two
  );
}

sub g_variant_compare ( gpointer $one, gpointer $two --> gint )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:dict-new:
=begin pod
=head2 dict-new

Allocates and initialises a new B<GVariantDict>.  You should call C<g_variant_dict_unref()> on the return value when it is no longer needed.  The memory will not be automatically freed by any other call.  In some cases it may be easier to place a B<GVariantDict> directly on the stack of the calling function and initialise it with C<g_variant_dict_init()>.  This is particularly useful when you are using B<GVariantDict> to construct a B<GVariant>.

Returns: (transfer full): a B<GVariantDict>

  method dict-new ( --> GVariantDict )


=end pod

method dict-new ( --> GVariantDict ) {

  g_variant_dict_new(
    self.get-native-object-no-reffing,
  );
}

sub g_variant_dict_new ( N-GVariant $from_asv --> GVariantDict )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:dict-init:
=begin pod
=head2 dict-init

Initialises a B<GVariantDict> structure.  If I<from_asv> is given, it is used to initialise the dictionary.  This function completely ignores the previous contents of I<dict>.  On one hand this means that it is valid to pass in completely uninitialised memory.  On the other hand, this means that if you are initialising over top of an existing B<GVariantDict> you need to first call C<g_variant_dict_clear()> in order to avoid leaking memory.  You must not call C<g_variant_dict_ref()> or C<g_variant_dict_unref()> on a B<GVariantDict> that was initialised with this function.  If you ever pass a reference to a B<GVariantDict> outside of the control of your own code then you should assume that the person receiving that reference may try to use reference counting; you should use C<g_variant_dict_new()> instead of this function.

  method dict-init ( GVariantDict $dict, N-GVariant $from_asv )

=item GVariantDict $dict; a B<GVariantDict>
=item N-GVariant $from_asv; (nullable): the initial value for I<dict>

=end pod

method dict-init ( GVariantDict $dict, N-GVariant $from_asv ) {
  my $no = …;
  $no .= get-native-object-no-reffing unless $no ~~ N-GVariant;

  g_variant_dict_init(
    self.get-native-object-no-reffing, $dict, $from_asv
  );
}

sub g_variant_dict_init ( GVariantDict $dict, N-GVariant $from_asv  )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:dict-lookup:
=begin pod
=head2 dict-lookup

Looks up a value in a B<GVariantDict>.  This function is a wrapper around C<g_variant_dict_lookup_value()> and C<g_variant_get()>.  In the case that C<Any> would have been returned, this function returns C<0>.  Otherwise, it unpacks the returned value and returns C<1>.  I<format_string> determines the C types that are used for unpacking the values and also determines if the values are copied or borrowed, see the section on [GVariant format strings][gvariant-format-strings-pointers].

Returns: C<1> if a value was unpacked

  method dict-lookup ( GVariantDict $dict,  Str  $key,  Str  $format_string --> Int )

=item GVariantDict $dict; a B<GVariantDict>
=item  Str  $key; the key to lookup in the dictionary
=item  Str  $format_string; a GVariant format string @...: the arguments to unpack the value into

=end pod

method dict-lookup ( GVariantDict $dict,  Str  $key,  Str  $format_string --> Int ) {

  g_variant_dict_lookup(
    self.get-native-object-no-reffing, $dict, $key, $format_string
  );
}

sub g_variant_dict_lookup ( GVariantDict $dict, gchar-ptr $key, gchar-ptr $format_string, Any $any = Any --> gboolean )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:dict-lookup-value:
=begin pod
=head2 dict-lookup-value

Looks up a value in a B<GVariantDict>.  If I<key> is not found in I<dictionary>, C<Any> is returned.  The I<expected_type> string specifies what type of value is expected. If the value associated with I<key> has a different type then C<Any> is returned.  If the key is found and the value has the correct type, it is returned.  If I<expected_type> was specified then any non-C<Any> return value will have this type.

Returns: (transfer full): the value of the dictionary key, or C<Any>

  method dict-lookup-value ( GVariantDict $dict,  Str  $key, N-GVariantType $expected_type --> N-GVariant )

=item GVariantDict $dict; a B<GVariantDict>
=item  Str  $key; the key to lookup in the dictionary
=item N-GVariantType $expected_type; (nullable): a B<GVariantType>, or C<Any>

=end pod

method dict-lookup-value ( GVariantDict $dict,  Str  $key, N-GVariantType $expected_type --> N-GVariant ) {
  my $no = …;
  $no .= get-native-object-no-reffing unless $no ~~ N-GVariantType;

  g_variant_dict_lookup_value(
    self.get-native-object-no-reffing, $dict, $key, $expected_type
  );
}

sub g_variant_dict_lookup_value ( GVariantDict $dict, gchar-ptr $key, N-GVariantType $expected_type --> N-GVariant )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:dict-contains:
=begin pod
=head2 dict-contains

Checks if I<key> exists in I<dict>.

Returns: C<1> if I<key> is in I<dict>

  method dict-contains ( GVariantDict $dict,  Str  $key --> Int )

=item GVariantDict $dict; a B<GVariantDict>
=item  Str  $key; the key to lookup in the dictionary

=end pod

method dict-contains ( GVariantDict $dict,  Str  $key --> Int ) {

  g_variant_dict_contains(
    self.get-native-object-no-reffing, $dict, $key
  );
}

sub g_variant_dict_contains ( GVariantDict $dict, gchar-ptr $key --> gboolean )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:dict-insert:
=begin pod
=head2 dict-insert

Inserts a value into a B<GVariantDict>.  This call is a convenience wrapper that is exactly equivalent to calling C<g_variant_new()> followed by C<g_variant_dict_insert_value()>.

  method dict-insert ( GVariantDict $dict,  Str  $key,  Str  $format_string )

=item GVariantDict $dict; a B<GVariantDict>
=item  Str  $key; the key to insert a value for
=item  Str  $format_string; a B<GVariant> varargs format string @...: arguments, as per I<format_string>

=end pod

method dict-insert ( GVariantDict $dict,  Str  $key,  Str  $format_string ) {

  g_variant_dict_insert(
    self.get-native-object-no-reffing, $dict, $key, $format_string
  );
}

sub g_variant_dict_insert ( GVariantDict $dict, gchar-ptr $key, gchar-ptr $format_string, Any $any = Any  )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:dict-insert-value:
=begin pod
=head2 dict-insert-value

Inserts (or replaces) a key in a B<GVariantDict>.  I<value> is consumed if it is floating.

  method dict-insert-value ( GVariantDict $dict,  Str  $key, N-GVariant $value )

=item GVariantDict $dict; a B<GVariantDict>
=item  Str  $key; the key to insert a value for
=item N-GVariant $value; the value to insert

=end pod

method dict-insert-value ( GVariantDict $dict,  Str  $key, N-GVariant $value ) {
  my $no = …;
  $no .= get-native-object-no-reffing unless $no ~~ N-GVariant;

  g_variant_dict_insert_value(
    self.get-native-object-no-reffing, $dict, $key, $value
  );
}

sub g_variant_dict_insert_value ( GVariantDict $dict, gchar-ptr $key, N-GVariant $value  )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:dict-remove:
=begin pod
=head2 dict-remove

Removes a key and its associated value from a B<GVariantDict>.

Returns: C<1> if the key was found and removed

  method dict-remove ( GVariantDict $dict,  Str  $key --> Int )

=item GVariantDict $dict; a B<GVariantDict>
=item  Str  $key; the key to remove

=end pod

method dict-remove ( GVariantDict $dict,  Str  $key --> Int ) {

  g_variant_dict_remove(
    self.get-native-object-no-reffing, $dict, $key
  );
}

sub g_variant_dict_remove ( GVariantDict $dict, gchar-ptr $key --> gboolean )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:dict-clear:
=begin pod
=head2 dict-clear

Releases all memory associated with a B<GVariantDict> without freeing the B<GVariantDict> structure itself.  It typically only makes sense to do this on a stack-allocated B<GVariantDict> if you want to abort building the value part-way through.  This function need not be called if you call C<g_variant_dict_end()> and it also doesn't need to be called on dicts allocated with g_variant_dict_new (see C<g_variant_dict_unref()> for that).  It is valid to call this function on either an initialised B<GVariantDict> or one that was previously cleared by an earlier call to C<g_variant_dict_clear()> but it is not valid to call this function on uninitialised memory.

  method dict-clear ( GVariantDict $dict )

=item GVariantDict $dict; a B<GVariantDict>

=end pod

method dict-clear ( GVariantDict $dict ) {

  g_variant_dict_clear(
    self.get-native-object-no-reffing, $dict
  );
}

sub g_variant_dict_clear ( GVariantDict $dict  )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:dict-end:
=begin pod
=head2 dict-end

Returns the current value of I<dict> as a B<GVariant> of type C<G_VARIANT_TYPE_VARDICT>, clearing it in the process.  It is not permissible to use I<dict> in any way after this call except for reference counting operations (in the case of a heap-allocated B<GVariantDict>) or by reinitialising it with C<g_variant_dict_init()> (in the case of stack-allocated).

Returns: (transfer none): a new, floating, B<GVariant>

  method dict-end ( GVariantDict $dict --> N-GVariant )

=item GVariantDict $dict; a B<GVariantDict>

=end pod

method dict-end ( GVariantDict $dict --> N-GVariant ) {

  g_variant_dict_end(
    self.get-native-object-no-reffing, $dict
  );
}

sub g_variant_dict_end ( GVariantDict $dict --> N-GVariant )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:dict-ref:
=begin pod
=head2 dict-ref

Increases the reference count on I<dict>.  Don't call this on stack-allocated B<GVariantDict> instances or bad things will happen.

Returns: (transfer full): a new reference to I<dict>

  method dict-ref ( GVariantDict $dict --> GVariantDict )

=item GVariantDict $dict; a heap-allocated B<GVariantDict>

=end pod

method dict-ref ( GVariantDict $dict --> GVariantDict ) {

  g_variant_dict_ref(
    self.get-native-object-no-reffing, $dict
  );
}

sub g_variant_dict_ref ( GVariantDict $dict --> GVariantDict )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:dict-unref:
=begin pod
=head2 dict-unref

Decreases the reference count on I<dict>.  In the event that there are no more references, releases all memory associated with the B<GVariantDict>.  Don't call this on stack-allocated B<GVariantDict> instances or bad things will happen.

  method dict-unref ( GVariantDict $dict )

=item GVariantDict $dict; (transfer full): a heap-allocated B<GVariantDict>

=end pod

method dict-unref ( GVariantDict $dict ) {

  g_variant_dict_unref(
    self.get-native-object-no-reffing, $dict
  );
}

sub g_variant_dict_unref ( GVariantDict $dict  )
  is native(&glib-lib)
  { * }
]]]

























##=finish
#-------------------------------------------------------------------------------
#TM:1:g_variant_get_type:
=begin pod
=head2 [g_variant_] get_type

Determines the type of I<value>.

The return value is valid for the lifetime of I<value> and must not
be freed.

Returns: a B<Gnome::Glib::VariantType>

  method g_variant_get_type ( --> N-GVariant )


=end pod

sub g_variant_get_type ( N-GVariant $value --> N-GVariantType )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:g_variant_get_type_string:
=begin pod
=head2 [g_variant_] get_type_string

Returns the type string of I<value>.  Unlike the result of calling
C<g_variant_type_peek_string()>, this string is nul-terminated.  This
string belongs to B<Gnome::Glib::Variant> and must not be freed.

Returns: the type string for the type of I<value>

  method g_variant_get_type_string ( --> Str )


=end pod

sub g_variant_get_type_string ( N-GVariant $value --> Str )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:g_variant_is_of_type:
=begin pod
=head2 [g_variant_] is_of_type

Checks if a value has a type matching the provided type.

Returns: C<1> if the type of I<value> matches I<type>

  method g_variant_is_of_type ( N-GVariant $type --> Int )

=item N-GVariant $type; a B<Gnome::Glib::VariantType>

=end pod

sub g_variant_is_of_type ( N-GVariant $value, N-GVariant $type --> int32 )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_is_container:
=begin pod
=head2 [g_variant_] is_container

Checks if I<value> is a container.

Returns: C<1> if I<value> is a container

  method g_variant_is_container ( --> Int )


=end pod

sub g_variant_is_container ( N-GVariant $value --> int32 )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:g_variant_classify:
=begin pod
=head2 g_variant_classify

Classifies I<value> according to its top-level type.

Returns: the B<Gnome::Glib::VariantClass> of I<value>

  method g_variant_classify ( --> int32 )

To get the enumerated value do

  GVariantClass(Buf.new($v.g-variant-classify).decode)

=end pod

sub g_variant_classify ( N-GVariant $value --> int32 )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:g_variant_new_boolean:
=begin pod
=head2 [g_variant_] new_boolean

Creates a new boolean B<Gnome::Glib::Variant> instance -- either C<1> or C<0>.

Returns: (transfer none): a floating reference to a new boolean B<Gnome::Glib::Variant> instance

  method g_variant_new_boolean ( Int $value --> N-GVariant )

=item Int $value; a B<gboolean> value

=end pod

sub g_variant_new_boolean ( int32 $value --> N-GVariant )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_new_byte:
=begin pod
=head2 [g_variant_] new_byte

Creates a new byte B<Gnome::Glib::Variant> instance.

Returns: (transfer none): a floating reference to a new byte B<Gnome::Glib::Variant> instance

  method g_variant_new_byte ( UInt $value --> N-GVariant )

=item UInt $value; a B<guint8> value

=end pod

sub g_variant_new_byte ( byte $value --> N-GVariant )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_new_int16:
=begin pod
=head2 [g_variant_] new_int16

Creates a new int16 B<Gnome::Glib::Variant> instance.

Returns: (transfer none): a floating reference to a new int16 B<Gnome::Glib::Variant> instance

  method g_variant_new_int16 ( Int $value --> N-GVariant )

=item Int $value; a B<gint16> value

=end pod

sub g_variant_new_int16 ( int16 $value --> N-GVariant )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_new_uint16:
=begin pod
=head2 [g_variant_] new_uint16

Creates a new uint16 B<Gnome::Glib::Variant> instance.

Returns: (transfer none): a floating reference to a new uint16 B<Gnome::Glib::Variant> instance

  method g_variant_new_uint16 ( UInt $value --> N-GVariant )

=item UInt $value; a B<guint16> value

=end pod

sub g_variant_new_uint16 ( uint16 $value --> N-GVariant )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_new_int32:
=begin pod
=head2 [g_variant_] new_int32

Creates a new int32 B<Gnome::Glib::Variant> instance.

Returns: (transfer none): a floating reference to a new int32 B<Gnome::Glib::Variant> instance

  method g_variant_new_int32 ( Int $value --> N-GVariant )

=item Int $value; a B<gint32> value

=end pod

sub g_variant_new_int32 ( int32 $value --> N-GVariant )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_new_uint32:
=begin pod
=head2 [g_variant_] new_uint32

Creates a new uint32 B<Gnome::Glib::Variant> instance.

Returns: (transfer none): a floating reference to a new uint32 B<Gnome::Glib::Variant> instance

  method g_variant_new_uint32 ( UInt $value --> N-GVariant )

=item UInt $value; a B<guint32> value

=end pod

sub g_variant_new_uint32 ( uint32 $value --> N-GVariant )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_new_int64:
=begin pod
=head2 [g_variant_] new_int64

Creates a new int64 B<Gnome::Glib::Variant> instance.

Returns: (transfer none): a floating reference to a new int64 B<Gnome::Glib::Variant> instance

  method g_variant_new_int64 ( Int $value --> N-GVariant )

=item Int $value; a B<gint64> value

=end pod

sub g_variant_new_int64 ( int64 $value --> N-GVariant )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_new_uint64:
=begin pod
=head2 [g_variant_] new_uint64

Creates a new uint64 B<Gnome::Glib::Variant> instance.

Returns: (transfer none): a floating reference to a new uint64 B<Gnome::Glib::Variant> instance

  method g_variant_new_uint64 ( UInt $value --> N-GVariant )

=item UInt $value; a B<guint64> value

=end pod

sub g_variant_new_uint64 ( uint64 $value --> N-GVariant )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_new_handle:
=begin pod
=head2 [g_variant_] new_handle

Creates a new handle B<Gnome::Glib::Variant> instance.

By convention, handles are indexes into an array of file descriptors
that are sent alongside a D-Bus message.  If you're not interacting
with D-Bus, you probably don't need them.

Returns: (transfer none): a floating reference to a new handle B<Gnome::Glib::Variant> instance

  method g_variant_new_handle ( Int $value --> N-GVariant )

=item Int $value; a B<gint32> value

=end pod

sub g_variant_new_handle ( int32 $value --> N-GVariant )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_new_double:
=begin pod
=head2 [g_variant_] new_double

Creates a new double B<Gnome::Glib::Variant> instance.

Returns: (transfer none): a floating reference to a new double B<Gnome::Glib::Variant> instance

  method g_variant_new_double ( Num $value --> N-GVariant )

=item Num $value; a B<gdouble> floating point value

=end pod

sub g_variant_new_double ( num64 $value --> N-GVariant )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_new_string:
=begin pod
=head2 [g_variant_] new_string

Creates a string B<Gnome::Glib::Variant> with the contents of I<string>.

I<string> must be valid UTF-8, and must not be C<Any>. To encode
potentially-C<Any> strings, use C<g_variant_new()> with `ms` as the
[format string][gvariant-format-strings-maybe-types].

Returns: (transfer none): a floating reference to a new string B<Gnome::Glib::Variant> instance

  method g_variant_new_string ( Str $string --> N-GVariant )

=item Str $string; a normal UTF-8 nul-terminated string

=end pod

sub g_variant_new_string ( Str $string --> N-GVariant )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_new_take_string:
=begin pod
=head2 [g_variant_] new_take_string

Creates a string B<Gnome::Glib::Variant> with the contents of I<string>.

I<string> must be valid UTF-8, and must not be C<Any>. To encode
potentially-C<Any> strings, use this with C<g_variant_new_maybe()>.

This function consumes I<string>.  C<g_free()> will be called on I<string>
when it is no longer required.

You must not modify or access I<string> in any other way after passing
it to this function.  It is even possible that I<string> is immediately
freed.

Returns: (transfer none): a floating reference to a new string
B<Gnome::Glib::Variant> instance

  method g_variant_new_take_string ( Str $string --> N-GVariant )

=item Str $string; a normal UTF-8 nul-terminated string

=end pod

sub g_variant_new_take_string ( Str $string --> N-GVariant )
  is native(&glib-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
#TM:0:g_variant_new_printf:
=begin pod
=head2 [g_variant_] new_printf

Creates a string-type GVariant using printf formatting.

This is similar to calling C<g_strdup_printf()> and then
C<g_variant_new_string()> but it saves a temporary variable and an
unnecessary copy.

Returns: (transfer none): a floating reference to a new string
B<Gnome::Glib::Variant> instance

  method g_variant_new_printf ( Str $format_string,  $2 --> N-GVariant )

=item Str $format_string; a printf-style format string @...: arguments for I<format_string>
=item  $2;

=end pod

sub g_variant_new_printf ( Str $format_string, Any $any = Any,  $2 --> N-GVariant )
  is native(&glib-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:0:g_variant_new_object_path:
=begin pod
=head2 [g_variant_] new_object_path

Creates a D-Bus object path B<Gnome::Glib::Variant> with the contents of I<string>.
I<string> must be a valid D-Bus object path.  Use
C<g_variant_is_object_path()> if you're not sure.

Returns: (transfer none): a floating reference to a new object path B<Gnome::Glib::Variant> instance

  method g_variant_new_object_path ( Str $object_path --> N-GVariant )

=item Str $object_path; a normal C nul-terminated string

=end pod

sub g_variant_new_object_path ( Str $object_path --> N-GVariant )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_is_object_path:
=begin pod
=head2 [g_variant_] is_object_path

Determines if a given string is a valid D-Bus object path.  You
should ensure that a string is a valid D-Bus object path before
passing it to C<g_variant_new_object_path()>.

A valid object path starts with `/` followed by zero or more
sequences of characters separated by `/` characters.  Each sequence
must contain only the characters `[A-Z][a-z][0-9]_`.  No sequence
(including the one following the final `/` character) may be empty.

Returns: C<1> if I<string> is a D-Bus object path

  method g_variant_is_object_path ( Str $string --> Int )

=item Str $string; a normal C nul-terminated string

=end pod

sub g_variant_is_object_path ( Str $string --> int32 )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_new_signature:
=begin pod
=head2 [g_variant_] new_signature

Creates a D-Bus type signature B<Gnome::Glib::Variant> with the contents of
I<string>.  I<string> must be a valid D-Bus type signature.  Use
C<g_variant_is_signature()> if you're not sure.

Returns: (transfer none): a floating reference to a new signature B<Gnome::Glib::Variant> instance

  method g_variant_new_signature ( Str $signature --> N-GVariant )

=item Str $signature; a normal C nul-terminated string

=end pod

sub g_variant_new_signature ( Str $signature --> N-GVariant )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_is_signature:
=begin pod
=head2 [g_variant_] is_signature

Determines if a given string is a valid D-Bus type signature.  You
should ensure that a string is a valid D-Bus type signature before
passing it to C<g_variant_new_signature()>.

D-Bus type signatures consist of zero or more definite B<Gnome::Glib::VariantType>
strings in sequence.

Returns: C<1> if I<string> is a D-Bus type signature

  method g_variant_is_signature ( Str $string --> Int )

=item Str $string; a normal C nul-terminated string

=end pod

sub g_variant_is_signature ( Str $string --> int32 )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_new_variant:
=begin pod
=head2 [g_variant_] new_variant

Boxes I<value>.  The result is a B<Gnome::Glib::Variant> instance representing a
variant containing the original value.

If I<child> is a floating reference (see C<g_variant_ref_sink()>), the new
instance takes ownership of I<child>.

Returns: (transfer none): a floating reference to a new variant B<Gnome::Glib::Variant> instance

  method g_variant_new_variant ( --> N-GVariant )


=end pod

sub g_variant_new_variant ( N-GVariant $value --> N-GVariant )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_new_strv:
=begin pod
=head2 [g_variant_] new_strv

Constructs an array of strings B<Gnome::Glib::Variant> from the given array of
strings.

If I<length> is -1 then I<strv> is C<Any>-terminated.

Returns: (transfer none): a new floating B<Gnome::Glib::Variant> instance

  method g_variant_new_strv ( CArray[Str] $strv, Int $length --> N-GVariant )

=item CArray[Str] $strv; (array length=length) (element-type utf8): an array of strings
=item Int $length; the length of I<strv>, or -1

=end pod

sub g_variant_new_strv ( CArray[Str] $strv, int64 $length --> N-GVariant )
  is native(&glib-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
#TM:0:g_variant_new_objv:
=begin pod
=head2 [g_variant_] new_objv

Constructs an array of object paths B<Gnome::Glib::Variant> from the given array of
strings.

Each string must be a valid B<Gnome::Glib::Variant> object path; see
C<g_variant_is_object_path()>.

If I<length> is -1 then I<strv> is C<Any>-terminated.

Returns: (transfer none): a new floating B<Gnome::Glib::Variant> instance

  method g_variant_new_objv ( CArray[Str] $strv, Int $length --> N-GVariant )

=item CArray[Str] $strv; (array length=length) (element-type utf8): an array of strings
=item Int $length; the length of I<strv>, or -1

=end pod

sub g_variant_new_objv ( CArray[Str] $strv, int64 $length --> N-GVariant )
  is native(&glib-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:0:g_variant_new_bytestring:
=begin pod
=head2 [g_variant_] new_bytestring

Creates an array-of-bytes B<Gnome::Glib::Variant> with the contents of I<string>.
This function is just like C<g_variant_new_string()> except that the
string need not be valid UTF-8.

The nul terminator character at the end of the string is stored in
the array.

Returns: (transfer none): a floating reference to a new bytestring B<Gnome::Glib::Variant> instance

  method g_variant_new_bytestring ( Str $string --> N-GVariant )

=item Str $string; (array zero-terminated=1) (element-type guint8): a normal nul-terminated string in no particular encoding

=end pod

sub g_variant_new_bytestring ( Str $string --> N-GVariant )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_new_bytestring_array:
=begin pod
=head2 [g_variant_] new_bytestring_array

Constructs an array of bytestring B<Gnome::Glib::Variant> from the given array of
strings.

If I<length> is -1 then I<strv> is C<Any>-terminated.

Returns: (transfer none): a new floating B<Gnome::Glib::Variant> instance

  method g_variant_new_bytestring_array ( CArray[Str] $strv, Int $length --> N-GVariant )

=item CArray[Str] $strv; (array length=length): an array of strings
=item Int $length; the length of I<strv>, or -1

=end pod

sub g_variant_new_bytestring_array ( CArray[Str] $strv, int64 $length --> N-GVariant )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_new_fixed_array:
=begin pod
=head2 [g_variant_] new_fixed_array

Constructs a new array B<Gnome::Glib::Variant> instance, where the elements are
of I<element_type> type.

I<elements> must be an array with fixed-sized elements.  Numeric types are
fixed-size as are tuples containing only other fixed-sized types.

I<element_size> must be the size of a single element in the array.
For example, if calling this function for an array of 32-bit integers,
you might say sizeof(gint32). This value isn't used except for the purpose
of a double-check that the form of the serialised data matches the caller's
expectation.

I<n_elements> must be the length of the I<elements> array.

Returns: (transfer none): a floating reference to a new array B<Gnome::Glib::Variant> instance

  method g_variant_new_fixed_array ( N-GVariant $element_type, Pointer $elements, UInt $n_elements, UInt $element_size --> N-GVariant )

=item N-GVariant $element_type; the B<Gnome::Glib::VariantType> of each element
=item Pointer $elements; a pointer to the fixed array of contiguous elements
=item UInt $n_elements; the number of elements
=item UInt $element_size; the size of each element

=end pod

sub g_variant_new_fixed_array ( N-GVariant $element_type, Pointer $elements, uint64 $n_elements, uint64 $element_size --> N-GVariant )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_get_boolean:
=begin pod
=head2 [g_variant_] get_boolean

Returns the boolean value of I<value>.

It is an error to call this function with a I<value> of any type
other than C<G_VARIANT_TYPE_BOOLEAN>.

Returns: C<1> or C<0>

  method g_variant_get_boolean ( --> Int )


=end pod

sub g_variant_get_boolean ( N-GVariant $value --> int32 )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_get_byte:
=begin pod
=head2 [g_variant_] get_byte

Returns the byte value of I<value>.

It is an error to call this function with a I<value> of any type
other than C<G_VARIANT_TYPE_BYTE>.

Returns: a B<guint8>

  method g_variant_get_byte ( --> UInt )


=end pod

sub g_variant_get_byte ( N-GVariant $value --> byte )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_get_int16:
=begin pod
=head2 [g_variant_] get_int16

Returns the 16-bit signed integer value of I<value>.

It is an error to call this function with a I<value> of any type
other than C<G_VARIANT_TYPE_INT16>.

Returns: a B<gint16>

  method g_variant_get_int16 ( --> Int )


=end pod

sub g_variant_get_int16 ( N-GVariant $value --> int16 )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_get_uint16:
=begin pod
=head2 [g_variant_] get_uint16

Returns the 16-bit unsigned integer value of I<value>.

It is an error to call this function with a I<value> of any type
other than C<G_VARIANT_TYPE_UINT16>.

Returns: a B<guint16>

  method g_variant_get_uint16 ( --> UInt )


=end pod

sub g_variant_get_uint16 ( N-GVariant $value --> uint16 )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_get_int32:
=begin pod
=head2 [g_variant_] get_int32

Returns the 32-bit signed integer value of I<value>.

It is an error to call this function with a I<value> of any type
other than C<G_VARIANT_TYPE_INT32>.

Returns: a B<gint32>

  method g_variant_get_int32 ( --> Int )


=end pod

sub g_variant_get_int32 ( N-GVariant $value --> int32 )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_get_uint32:
=begin pod
=head2 [g_variant_] get_uint32

Returns the 32-bit unsigned integer value of I<value>.

It is an error to call this function with a I<value> of any type
other than C<G_VARIANT_TYPE_UINT32>.

Returns: a B<guint32>

  method g_variant_get_uint32 ( --> UInt )


=end pod

sub g_variant_get_uint32 ( N-GVariant $value --> uint32 )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_get_int64:
=begin pod
=head2 [g_variant_] get_int64

Returns the 64-bit signed integer value of I<value>.

It is an error to call this function with a I<value> of any type
other than C<G_VARIANT_TYPE_INT64>.

Returns: a B<gint64>

  method g_variant_get_int64 ( --> Int )


=end pod

sub g_variant_get_int64 ( N-GVariant $value --> int64 )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_get_uint64:
=begin pod
=head2 [g_variant_] get_uint64

Returns the 64-bit unsigned integer value of I<value>.

It is an error to call this function with a I<value> of any type
other than C<G_VARIANT_TYPE_UINT64>.

Returns: a B<guint64>

  method g_variant_get_uint64 ( --> UInt )


=end pod

sub g_variant_get_uint64 ( N-GVariant $value --> uint64 )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_get_handle:
=begin pod
=head2 [g_variant_] get_handle

Returns the 32-bit signed integer value of I<value>.

It is an error to call this function with a I<value> of any type other
than C<G_VARIANT_TYPE_HANDLE>.

By convention, handles are indexes into an array of file descriptors
that are sent alongside a D-Bus message.  If you're not interacting
with D-Bus, you probably don't need them.

Returns: a B<gint32>

  method g_variant_get_handle ( --> Int )


=end pod

sub g_variant_get_handle ( N-GVariant $value --> int32 )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_get_double:
=begin pod
=head2 [g_variant_] get_double

Returns the double precision floating point value of I<value>.

It is an error to call this function with a I<value> of any type
other than C<G_VARIANT_TYPE_DOUBLE>.

Returns: a B<gdouble>

  method g_variant_get_double ( --> Num )


=end pod

sub g_variant_get_double ( N-GVariant $value --> num64 )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_get_variant:
=begin pod
=head2 [g_variant_] get_variant

Unboxes I<value>.  The result is the B<Gnome::Glib::Variant> instance that was
contained in I<value>.

Returns: (transfer full): the item contained in the variant

  method g_variant_get_variant ( --> N-GVariant )


=end pod

sub g_variant_get_variant ( N-GVariant $value --> N-GVariant )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_get_string:
=begin pod
=head2 [g_variant_] get_string

Returns the string value of a B<Gnome::Glib::Variant> instance with a string
type.  This includes the types C<G_VARIANT_TYPE_STRING>,
C<G_VARIANT_TYPE_OBJECT_PATH> and C<G_VARIANT_TYPE_SIGNATURE>.

The string will always be UTF-8 encoded, and will never be undefined.

If I<length> is defined then the length of the string (in bytes) is
returned there.  For trusted values, this information is already
known.  For untrusted values, a C<strlen()> will be performed.

It is an error to call this function with a I<value> of any type
other than those three.

The return value remains valid as long as I<value> exists.

Returns: (transfer none): the constant string, UTF-8 encoded

  method g_variant_get_string ( --> Str )

=end pod

sub g_variant_get_string ( N-GVariant $value --> Str ) {
  my uint64 $i;
  _g_variant_get_string( $value, $i)
}

sub _g_variant_get_string ( N-GVariant $value, uint64 $length is rw --> Str )
  is native(&glib-lib)
  is symbol('g_variant_get_string')
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_dup_string:
=begin pod
=head2 [g_variant_] dup_string

Similar to C<g_variant_get_string()> except that instead of returning
a constant string, the string is duplicated.

The string will always be UTF-8 encoded.

The return value must be freed using C<g_free()>.

Returns: (transfer full): a newly allocated string, UTF-8 encoded

  method g_variant_dup_string ( UInt $length --> Str )

=item UInt $length; (out): a pointer to a B<gsize>, to store the length

=end pod

sub g_variant_dup_string ( N-GVariant $value, uint64 $length --> Str )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_get_strv:
=begin pod
=head2 [g_variant_] get_strv

Gets the contents of an array of strings B<Gnome::Glib::Variant>.  This call
makes a shallow copy; the return result should be released with
C<g_free()>, but the individual strings must not be modified.

If I<length> is non-C<Any> then the number of elements in the result
is stored there.  In any case, the resulting array will be
C<Any>-terminated.

For an empty array, I<length> will be set to 0 and a pointer to a
C<Any> pointer will be returned.

Returns: (array length=length zero-terminated=1) (transfer container): an array of constant strings

  method g_variant_get_strv ( UInt $length --> CArray[Str] )

=item UInt $length; (out) (optional): the length of the result, or C<Any>

=end pod

sub g_variant_get_strv ( N-GVariant $value, uint64 $length --> CArray[Str] )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_dup_strv:
=begin pod
=head2 [g_variant_] dup_strv

Gets the contents of an array of strings B<Gnome::Glib::Variant>.  This call
makes a deep copy; the return result should be released with
C<g_strfreev()>.

If I<length> is non-C<Any> then the number of elements in the result
is stored there.  In any case, the resulting array will be
C<Any>-terminated.

For an empty array, I<length> will be set to 0 and a pointer to a
C<Any> pointer will be returned.

Returns: (array length=length zero-terminated=1) (transfer full): an array of strings

  method g_variant_dup_strv ( UInt $length --> CArray[Str] )

=item UInt $length; (out) (optional): the length of the result, or C<Any>

=end pod

sub g_variant_dup_strv ( N-GVariant $value, uint64 $length --> CArray[Str] )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_get_objv:
=begin pod
=head2 [g_variant_] get_objv

Gets the contents of an array of object paths B<Gnome::Glib::Variant>.  This call
makes a shallow copy; the return result should be released with
C<g_free()>, but the individual strings must not be modified.

If I<length> is non-C<Any> then the number of elements in the result
is stored there.  In any case, the resulting array will be
C<Any>-terminated.

For an empty array, I<length> will be set to 0 and a pointer to a
C<Any> pointer will be returned.

Returns: (array length=length zero-terminated=1) (transfer container): an array of constant strings

  method g_variant_get_objv ( UInt $length --> CArray[Str] )

=item UInt $length; (out) (optional): the length of the result, or C<Any>

=end pod

sub g_variant_get_objv ( N-GVariant $value, uint64 $length --> CArray[Str] )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_dup_objv:
=begin pod
=head2 [g_variant_] dup_objv

Gets the contents of an array of object paths B<Gnome::Glib::Variant>.  This call
makes a deep copy; the return result should be released with
C<g_strfreev()>.

If I<length> is non-C<Any> then the number of elements in the result
is stored there.  In any case, the resulting array will be
C<Any>-terminated.

For an empty array, I<length> will be set to 0 and a pointer to a
C<Any> pointer will be returned.

Returns: (array length=length zero-terminated=1) (transfer full): an array of strings

  method g_variant_dup_objv ( UInt $length --> CArray[Str] )

=item UInt $length; (out) (optional): the length of the result, or C<Any>

=end pod

sub g_variant_dup_objv ( N-GVariant $value, uint64 $length --> CArray[Str] )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_get_bytestring:
=begin pod
=head2 [g_variant_] get_bytestring

Returns the string value of a B<Gnome::Glib::Variant> instance with an
array-of-bytes type.  The string has no particular encoding.

If the array does not end with a nul terminator character, the empty
string is returned.  For this reason, you can always trust that a
non-C<Any> nul-terminated string will be returned by this function.

If the array contains a nul terminator character somewhere other than
the last byte then the returned string is the string, up to the first
such nul character.

C<g_variant_get_fixed_array()> should be used instead if the array contains
arbitrary data that could not be nul-terminated or could contain nul bytes.

It is an error to call this function with a I<value> that is not an
array of bytes.

The return value remains valid as long as I<value> exists.

Returns: (transfer none) (array zero-terminated=1) (element-type guint8):
the constant string

  method g_variant_get_bytestring ( --> Str )


=end pod

sub g_variant_get_bytestring ( N-GVariant $value --> Str )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_dup_bytestring:
=begin pod
=head2 [g_variant_] dup_bytestring

Similar to C<g_variant_get_bytestring()> except that instead of
returning a constant string, the string is duplicated.

The return value must be freed using C<g_free()>.

Returns: (transfer full) (array zero-terminated=1 length=length) (element-type guint8):
a newly allocated string

  method g_variant_dup_bytestring ( UInt $length --> Str )

=item UInt $length; (out) (optional) (default NULL): a pointer to a B<gsize>, to store the length (not including the nul terminator)

=end pod

sub g_variant_dup_bytestring ( N-GVariant $value, uint64 $length --> Str )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_get_bytestring_array:
=begin pod
=head2 [g_variant_] get_bytestring_array

Gets the contents of an array of array of bytes B<Gnome::Glib::Variant>.  This call
makes a shallow copy; the return result should be released with
C<g_free()>, but the individual strings must not be modified.

If I<length> is non-C<Any> then the number of elements in the result is
stored there.  In any case, the resulting array will be
C<Any>-terminated.

For an empty array, I<length> will be set to 0 and a pointer to a
C<Any> pointer will be returned.

Returns: (array length=length) (transfer container): an array of constant strings

  method g_variant_get_bytestring_array ( UInt $length --> CArray[Str] )

=item UInt $length; (out) (optional): the length of the result, or C<Any>

=end pod

sub g_variant_get_bytestring_array ( N-GVariant $value, uint64 $length --> CArray[Str] )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_dup_bytestring_array:
=begin pod
=head2 [g_variant_] dup_bytestring_array

Gets the contents of an array of array of bytes B<Gnome::Glib::Variant>.  This call
makes a deep copy; the return result should be released with
C<g_strfreev()>.

If I<length> is non-C<Any> then the number of elements in the result is
stored there.  In any case, the resulting array will be
C<Any>-terminated.

For an empty array, I<length> will be set to 0 and a pointer to a
C<Any> pointer will be returned.

Returns: (array length=length) (transfer full): an array of strings

  method g_variant_dup_bytestring_array ( UInt $length --> CArray[Str] )

=item UInt $length; (out) (optional): the length of the result, or C<Any>

=end pod

sub g_variant_dup_bytestring_array ( N-GVariant $value, uint64 $length --> CArray[Str] )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_new_maybe:
=begin pod
=head2 [g_variant_] new_maybe

Depending on if I<child> is C<Any>, either wraps I<child> inside of a
maybe container or creates a Nothing instance for the given I<type>.

At least one of I<child_type> and I<child> must be non-C<Any>.
If I<child_type> is non-C<Any> then it must be a definite type.
If they are both non-C<Any> then I<child_type> must be the type
of I<child>.

If I<child> is a floating reference (see C<g_variant_ref_sink()>), the new
instance takes ownership of I<child>.

Returns: (transfer none): a floating reference to a new B<Gnome::Glib::Variant> maybe instance

  method g_variant_new_maybe ( N-GVariant $child_type, N-GVariant $child --> N-GVariant )

=item N-GVariant $child_type; (nullable): the B<Gnome::Glib::VariantType> of the child, or C<Any>
=item N-GVariant $child; (nullable): the child value, or C<Any>

=end pod

sub g_variant_new_maybe ( N-GVariant $child_type, N-GVariant $child --> N-GVariant )
  is native(&glib-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
#TM:0:g_variant_new_array:
=begin pod
=head2 [g_variant_] new_array

Creates a new B<Gnome::Glib::Variant> array from I<children>.

I<child_type> must be non-C<Any> if I<n_children> is zero.  Otherwise, the
child type is determined by inspecting the first element of the
I<children> array.  If I<child_type> is non-C<Any> then it must be a
definite type.

The items of the array are taken from the I<children> array.  No entry
in the I<children> array may be C<Any>.

All items in the array must have the same type, which must be the
same as I<child_type>, if given.

If the I<children> are floating references (see C<g_variant_ref_sink()>), the
new instance takes ownership of them as if via C<g_variant_ref_sink()>.

Returns: (transfer none): a floating reference to a new B<Gnome::Glib::Variant> array

  method g_variant_new_array ( N-GVariant $child_type,  $GVariant * const *children, UInt $n_children --> N-GVariant )

=item N-GVariant $child_type; (nullable): the element type of the new array
=item  $GVariant * const *children; (nullable) (array length=n_children): an array of B<Gnome::Glib::Variant> pointers, the children
=item UInt $n_children; the length of I<children>

=end pod

sub g_variant_new_array ( N-GVariant $child_type,  $GVariant * const *children, uint64 $n_children --> N-GVariant )
  is native(&glib-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
#TM:0:g_variant_new_tuple:
=begin pod
=head2 [g_variant_] new_tuple

Creates a new tuple B<Gnome::Glib::Variant> out of the items in I<children>.  The
type is determined from the types of I<children>.  No entry in the
I<children> array may be C<Any>.

If I<n_children> is 0 then the unit tuple is constructed.

If the I<children> are floating references (see C<g_variant_ref_sink()>), the
new instance takes ownership of them as if via C<g_variant_ref_sink()>.

Returns: (transfer none): a floating reference to a new B<Gnome::Glib::Variant> tuple

  method g_variant_new_tuple (  $GVariant * const *children, UInt $n_children --> N-GVariant )

=item  $GVariant * const *children; (array length=n_children): the items to make the tuple out of
=item UInt $n_children; the length of I<children>

=end pod

sub g_variant_new_tuple (  $GVariant * const *children, uint64 $n_children --> N-GVariant )
  is native(&glib-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:0:g_variant_new_dict_entry:
=begin pod
=head2 [g_variant_] new_dict_entry

Creates a new dictionary entry B<Gnome::Glib::Variant>. I<key> and I<value> must be
non-C<Any>. I<key> must be a value of a basic type (ie: not a container).

If the I<key> or I<value> are floating references (see C<g_variant_ref_sink()>),
the new instance takes ownership of them as if via C<g_variant_ref_sink()>.

Returns: (transfer none): a floating reference to a new dictionary entry B<Gnome::Glib::Variant>

  method g_variant_new_dict_entry ( N-GVariant $value --> N-GVariant )

=item N-GVariant $value; a B<Gnome::Glib::Variant>, the value

=end pod

sub g_variant_new_dict_entry ( N-GVariant $key, N-GVariant $value --> N-GVariant )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_get_maybe:
=begin pod
=head2 [g_variant_] get_maybe

Given a maybe-typed B<Gnome::Glib::Variant> instance, extract its value.  If the
value is Nothing, then this function returns C<Any>.

Returns: (nullable) (transfer full): the contents of I<value>, or C<Any>

  method g_variant_get_maybe ( --> N-GVariant )


=end pod

sub g_variant_get_maybe ( N-GVariant $value --> N-GVariant )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_n_children:
=begin pod
=head2 [g_variant_] n_children



  method g_variant_n_children ( --> UInt )


=end pod

sub g_variant_n_children ( N-GVariant $value --> uint64 )
  is native(&glib-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
#TM:0:g_variant_get_child:
=begin pod
=head2 [g_variant_] get_child

Reads a child item out of a container B<Gnome::Glib::Variant> instance and
deconstructs it according to I<format_string>.  This call is
essentially a combination of C<g_variant_get_child_value()> and
C<g_variant_get()>.

I<format_string> determines the C types that are used for unpacking
the values and also determines if the values are copied or borrowed,
see the section on
[GVariant format strings][gvariant-format-strings-pointers].

  method g_variant_get_child ( UInt $index_, Str $format_string )

=item UInt $index_; the index of the child to deconstruct
=item Str $format_string; a B<Gnome::Glib::Variant> format string @...: arguments, as per I<format_string>

=end pod

sub g_variant_get_child ( N-GVariant $value, uint64 $index_, Str $format_string, Any $any = Any  )
  is native(&glib-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:0:g_variant_get_child_value:
=begin pod
=head2 [g_variant_] get_child_value



  method g_variant_get_child_value ( UInt $index --> N-GVariant )

=item UInt $index;

=end pod

sub g_variant_get_child_value ( N-GVariant $value, uint64 $index --> N-GVariant )
  is native(&glib-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
#TM:0:g_variant_lookup:
=begin pod
=head2 g_variant_lookup

Looks up a value in a dictionary B<Gnome::Glib::Variant>.

This function is a wrapper around C<g_variant_lookup_value()> and
C<g_variant_get()>.  In the case that C<Any> would have been returned,
this function returns C<0>.  Otherwise, it unpacks the returned
value and returns C<1>.

I<format_string> determines the C types that are used for unpacking
the values and also determines if the values are copied or borrowed,
see the section on
[GVariant format strings][gvariant-format-strings-pointers].

This function is currently implemented with a linear scan.  If you
plan to do many lookups then B<Gnome::Glib::VariantDict> may be more efficient.

Returns: C<1> if a value was unpacked

  method g_variant_lookup ( Str $key, Str $format_string --> Int )

=item Str $key; the key to lookup in the dictionary
=item Str $format_string; a GVariant format string @...: the arguments to unpack the value into

=end pod

sub g_variant_lookup ( N-GVariant $dictionary, Str $key, Str $format_string, Any $any = Any --> int32 )
  is native(&glib-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:0:g_variant_lookup_value:
=begin pod
=head2 [g_variant_] lookup_value

Looks up a value in a dictionary B<Gnome::Glib::Variant>.

This function works with dictionaries of the type a{s*} (and equally
well with type a{o*}, but we only further discuss the string case
for sake of clarity).

In the event that I<dictionary> has the type a{sv}, the I<expected_type>
string specifies what type of value is expected to be inside of the
variant. If the value inside the variant has a different type then
C<Any> is returned. In the event that I<dictionary> has a value type other
than v then I<expected_type> must directly match the value type and it is
used to unpack the value directly or an error occurs.

In either case, if I<key> is not found in I<dictionary>, C<Any> is returned.

If the key is found and the value has the correct type, it is
returned.  If I<expected_type> was specified then any non-C<Any> return
value will have this type.

This function is currently implemented with a linear scan.  If you
plan to do many lookups then B<Gnome::Glib::VariantDict> may be more efficient.

Returns: (transfer full): the value of the dictionary key, or C<Any>

  method g_variant_lookup_value ( Str $key, N-GVariant $expected_type --> N-GVariant )

=item Str $key; the key to lookup in the dictionary
=item N-GVariant $expected_type; (nullable): a B<Gnome::Glib::VariantType>, or C<Any>

=end pod

sub g_variant_lookup_value ( N-GVariant $dictionary, Str $key, N-GVariant $expected_type --> N-GVariant )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_get_fixed_array:
=begin pod
=head2 [g_variant_] get_fixed_array

Provides access to the serialised data for an array of fixed-sized
items.

I<value> must be an array with fixed-sized elements.  Numeric types are
fixed-size, as are tuples containing only other fixed-sized types.

I<element_size> must be the size of a single element in the array,
as given by the section on
[serialized data memory][gvariant-serialised-data-memory].

In particular, arrays of these fixed-sized types can be interpreted
as an array of the given C type, with I<element_size> set to the size
the appropriate type:
- C<G_VARIANT_TYPE_INT16> (etc.): B<gint16> (etc.)
- C<G_VARIANT_TYPE_BOOLEAN>: B<guchar> (not B<gboolean>!)
- C<G_VARIANT_TYPE_BYTE>: B<guint8>
- C<G_VARIANT_TYPE_HANDLE>: B<guint32>
- C<G_VARIANT_TYPE_DOUBLE>: B<gdouble>

For example, if calling this function for an array of 32-bit integers,
you might say `sizeof(gint32)`. This value isn't used except for the purpose
of a double-check that the form of the serialised data matches the caller's
expectation.

I<n_elements>, which must be non-C<Any>, is set equal to the number of
items in the array.

Returns: (array length=n_elements) (transfer none): a pointer to
the fixed array

  method g_variant_get_fixed_array ( UInt $n_elements, UInt $element_size --> Pointer )

=item UInt $n_elements; (out): a pointer to the location to store the number of items
=item UInt $element_size; the size of each element

=end pod

sub g_variant_get_fixed_array ( N-GVariant $value, uint64 $n_elements, uint64 $element_size --> Pointer )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_get_size:
=begin pod
=head2 [g_variant_] get_size



  method g_variant_get_size ( --> UInt )


=end pod

sub g_variant_get_size ( N-GVariant $value --> uint64 )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_get_data:
=begin pod
=head2 [g_variant_] get_data



  method g_variant_get_data ( --> Pointer )


=end pod

sub g_variant_get_data ( N-GVariant $value --> Pointer )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_get_data_as_bytes:
=begin pod
=head2 [g_variant_] get_data_as_bytes



  method g_variant_get_data_as_bytes ( --> N-GVariant )


=end pod

sub g_variant_get_data_as_bytes ( N-GVariant $value --> N-GVariant )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_store:
=begin pod
=head2 g_variant_store



  method g_variant_store ( Pointer $data )

=item Pointer $data;

=end pod

sub g_variant_store ( N-GVariant $value, Pointer $data  )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:g_variant_print:
=begin pod
=head2 g_variant_print

Pretty-prints I<value> in the format understood by C<g_variant_parse()>.

The format is described [here][gvariant-text].

If I<type_annotate> is C<1>, then type information is included in
the output.

Returns: (transfer full): a newly-allocated string holding the result.

  method g_variant_print ( Int $type_annotate --> Str )

=item Int $type_annotate; C<1> if type information should be included in the output

=end pod

sub g_variant_print ( N-GVariant $value, int32 $type_annotate --> Str )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
# See also https://developer.gnome.org/glib/stable/glib-Strings.html#GString
#struct GString {
#  gchar  *str;
#  gsize len;
#  gsize allocated_len;
#};
#`{{
#TM:0:g_variant_print_string:
=begin pod
=head2 [g_variant_] print_string

Behaves as C<g_variant_print()>, but operates on a B<GString>.

If I<string> is non-C<Any> then it is appended to and returned.  Else,
a new empty B<GString> is allocated and it is returned.

Returns: a B<GString> containing the string

  method g_variant_print_string ( GString $string, Int $type_annotate --> N-GVariant )

=item N-GVariant $string; (nullable) (default NULL): a B<GString>, or C<Any>
=item Int $type_annotate; C<1> if type information should be included in the output

=end pod

sub g_variant_print_string ( N-GVariant $value, N-GVariant $string, int32 $type_annotate --> N-GVariant )
  is native(&glib-lib)
  { * }
}}


#-------------------------------------------------------------------------------
#TM:0:g_variant_hash:
=begin pod
=head2 g_variant_hash

Generates a hash value for a B<Gnome::Glib::Variant> instance.

The output of this function is guaranteed to be the same for a given
value only per-process.  It may change between different processor
architectures or even different versions of GLib.  Do not use this
function as a basis for building protocols or file formats.

The type of I<value> is B<gconstpointer> only to allow use of this
function with B<GHashTable>.  I<value> must be a B<Gnome::Glib::Variant>.

Returns: a hash value corresponding to I<value>

  method g_variant_hash ( Pointer $value --> UInt )

=item Pointer $value; (type GVariant): a basic B<Gnome::Glib::Variant> value as a B<gconstpointer>

=end pod

sub g_variant_hash ( Pointer $value --> uint32 )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_equal:
=begin pod
=head2 g_variant_equal

Checks if I<one> and I<two> have the same type and value.

The types of I<one> and I<two> are B<gconstpointer> only to allow use of
this function with B<GHashTable>.  They must each be a B<Gnome::Glib::Variant>.

Returns: C<1> if I<one> and I<two> are equal

  method g_variant_equal ( Pointer $one, Pointer $two --> Int )

=item Pointer $one; (type GVariant): a B<Gnome::Glib::Variant> instance
=item Pointer $two; (type GVariant): a B<Gnome::Glib::Variant> instance

=end pod

sub g_variant_equal ( Pointer $one, Pointer $two --> int32 )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_get_normal_form:
=begin pod
=head2 [g_variant_] get_normal_form

Gets a B<Gnome::Glib::Variant> instance that has the same value as I<value> and is
trusted to be in normal form.

If I<value> is already trusted to be in normal form then a new
reference to I<value> is returned.

If I<value> is not already trusted, then it is scanned to check if it
is in normal form.  If it is found to be in normal form then it is
marked as trusted and a new reference to it is returned.

If I<value> is found not to be in normal form then a new trusted
B<Gnome::Glib::Variant> is created with the same value as I<value>.

It makes sense to call this function if you've received B<Gnome::Glib::Variant>
data from untrusted sources and you want to ensure your serialised
output is definitely in normal form.

If I<value> is already in normal form, a new reference will be returned
(which will be floating if I<value> is floating). If it is not in normal form,
the newly created B<Gnome::Glib::Variant> will be returned with a single non-floating
reference. Typically, C<g_variant_take_ref()> should be called on the return
value from this function to guarantee ownership of a single non-floating
reference to it.

Returns: (transfer full): a trusted B<Gnome::Glib::Variant>

  method g_variant_get_normal_form ( --> N-GVariant )


=end pod

sub g_variant_get_normal_form ( N-GVariant $value --> N-GVariant )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_is_normal_form:
=begin pod
=head2 [g_variant_] is_normal_form



  method g_variant_is_normal_form ( --> Int )


=end pod

sub g_variant_is_normal_form ( N-GVariant $value --> int32 )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_byteswap:
=begin pod
=head2 g_variant_byteswap

Performs a byteswapping operation on the contents of I<value>.  The
result is that all multi-byte numeric data contained in I<value> is
byteswapped.  That includes 16, 32, and 64bit signed and unsigned
integers as well as file handles and double precision floating point
values.

This function is an identity mapping on any value that does not
contain multi-byte numeric data.  That include strings, booleans,
bytes and containers containing only these things (recursively).

The returned value is always in normal form and is marked as trusted.

Returns: (transfer full): the byteswapped form of I<value>

  method g_variant_byteswap ( --> N-GVariant )


=end pod

sub g_variant_byteswap ( N-GVariant $value --> N-GVariant )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_new_from_bytes:
=begin pod
=head2 [g_variant_] new_from_bytes



  method g_variant_new_from_bytes ( N-GVariant $type, N-GVariant $bytes, Int $trusted --> N-GVariant )

=item N-GVariant $type;
=item N-GVariant $bytes;
=item Int $trusted;

=end pod

sub g_variant_new_from_bytes ( N-GVariant $type, N-GVariant $bytes, int32 $trusted --> N-GVariant )
  is native(&glib-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
#TM:0:g_variant_new_from_data:
=begin pod
=head2 [g_variant_] new_from_data

Creates a new B<Gnome::Glib::Variant> instance from serialised data.

I<type> is the type of B<Gnome::Glib::Variant> instance that will be constructed.
The interpretation of I<data> depends on knowing the type.

I<data> is not modified by this function and must remain valid with an
unchanging value until such a time as I<notify> is called with
I<user_data>.  If the contents of I<data> change before that time then
the result is undefined.

If I<data> is trusted to be serialised data in normal form then
I<trusted> should be C<1>.  This applies to serialised data created
within this process or read from a trusted location on the disk (such
as a file installed in /usr/lib alongside your application).  You
should set trusted to C<0> if I<data> is read from the network, a
file in the user's home directory, etc.

If I<data> was not stored in this machine's native endianness, any multi-byte
numeric values in the returned variant will also be in non-native
endianness. C<g_variant_byteswap()> can be used to recover the original values.

I<notify> will be called with I<user_data> when I<data> is no longer
needed.  The exact time of this call is unspecified and might even be
before this function returns.

Note: I<data> must be backed by memory that is aligned appropriately for the
I<type> being loaded. Otherwise this function will internally create a copy of
the memory (since GLib 2.60) or (in older versions) fail and exit the
process.

Returns: (transfer none): a new floating B<Gnome::Glib::Variant> of type I<type>

  method g_variant_new_from_data ( N-GVariant $type, Pointer $data, UInt $size, Int $trusted, GDestroyNotify $notify, Pointer $user_data --> N-GVariant )

=item N-GVariant $type; a definite B<Gnome::Glib::VariantType>
=item Pointer $data; (array length=size) (element-type guint8): the serialised data
=item UInt $size; the size of I<data>
=item Int $trusted; C<1> if I<data> is definitely in normal form
=item GDestroyNotify $notify; (scope async): function to call when I<data> is no longer needed
=item Pointer $user_data; data for I<notify>

=end pod

sub g_variant_new_from_data ( N-GVariant $type, Pointer $data, uint64 $size, int32 $trusted, GDestroyNotify $notify, Pointer $user_data --> N-GVariant )
  is native(&glib-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
#TM:0:g_variant_iter_new:
=begin pod
=head2 [g_variant_] iter_new

Creates a heap-allocated B<Gnome::Glib::VariantIter> for iterating over the items
in I<value>.

Use C<g_variant_iter_free()> to free the return value when you no longer
need it.

A reference is taken to I<value> and will be released only when
C<g_variant_iter_free()> is called.

Returns: (transfer full): a new heap-allocated B<Gnome::Glib::VariantIter>

  method g_variant_iter_new ( --> GVariantIter )


=end pod

sub g_variant_iter_new ( N-GVariant $value --> GVariantIter )
  is native(&glib-lib)
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

  method g_variant_iter_init ( GVariantIter $iter, N-GVariant $value --> UInt )

=item GVariantIter $iter; a pointer to a B<Gnome::Glib::VariantIter>
=item N-GVariant $value; a container B<Gnome::Glib::Variant>

=end pod

sub g_variant_iter_init ( GVariantIter $iter, N-GVariant $value --> uint64 )
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

  method g_variant_iter_copy ( GVariantIter $iter --> GVariantIter )

=item GVariantIter $iter; a B<Gnome::Glib::VariantIter>

=end pod

sub g_variant_iter_copy ( GVariantIter $iter --> GVariantIter )
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

  method g_variant_iter_n_children ( GVariantIter $iter --> UInt )

=item GVariantIter $iter; a B<Gnome::Glib::VariantIter>

=end pod

sub g_variant_iter_n_children ( GVariantIter $iter --> uint64 )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_iter_free:
=begin pod
=head2 [g_variant_] iter_free

Frees a heap-allocated B<Gnome::Glib::VariantIter>.  Only call this function on
iterators that were returned by C<g_variant_iter_new()> or
C<g_variant_iter_copy()>.

  method g_variant_iter_free ( GVariantIter $iter )

=item GVariantIter $iter; (transfer full): a heap-allocated B<Gnome::Glib::VariantIter>

=end pod

sub g_variant_iter_free ( GVariantIter $iter  )
  is native(&glib-lib)
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
GVariantIter iter;
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

  method g_variant_iter_next_value ( GVariantIter $iter --> N-GVariant )

=item GVariantIter $iter; a B<Gnome::Glib::VariantIter>

=end pod

sub g_variant_iter_next_value ( GVariantIter $iter --> N-GVariant )
  is native(&glib-lib)
  { * }

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
GVariantIter iter;
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

  method g_variant_iter_next ( GVariantIter $iter, Str $format_string --> Int )

=item GVariantIter $iter; a B<Gnome::Glib::VariantIter>
=item Str $format_string; a GVariant format string @...: the arguments to unpack the value into

=end pod

sub g_variant_iter_next ( GVariantIter $iter, Str $format_string, Any $any = Any --> int32 )
  is native(&glib-lib)
  { * }

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
GVariantIter iter;
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

  method g_variant_iter_loop ( GVariantIter $iter, Str $format_string --> Int )

=item GVariantIter $iter; a B<Gnome::Glib::VariantIter>
=item Str $format_string; a GVariant format string @...: the arguments to unpack the value into

=end pod

sub g_variant_iter_loop ( GVariantIter $iter, Str $format_string, Any $any = Any --> int32 )
  is native(&glib-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:0:g_variant_parse_error_quark:
=begin pod
=head2 [g_variant_] parse_error_quark



  method g_variant_parse_error_quark ( --> Int )


=end pod

sub g_variant_parse_error_quark (  --> int32 )
  is native(&glib-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
#TM:0:g_variant_builder_new:
=begin pod
=head2 [g_variant_] builder_new

Allocates and initialises a new B<Gnome::Glib::VariantBuilder>.

You should call C<g_variant_builder_unref()> on the return value when it
is no longer needed.  The memory will not be automatically freed by
any other call.

In most cases it is easier to place a B<Gnome::Glib::VariantBuilder> directly on
the stack of the calling function and initialise it with
C<g_variant_builder_init()>.

Returns: (transfer full): a B<Gnome::Glib::VariantBuilder>

  method g_variant_builder_new ( N-GVariant $type --> GVariantBuilder )

=item N-GVariant $type; a container type

=end pod

sub g_variant_builder_new ( N-GVariant $type --> GVariantBuilder )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_builder_unref:
=begin pod
=head2 [g_variant_] builder_unref

Decreases the reference count on I<builder>.

In the event that there are no more references, releases all memory
associated with the B<Gnome::Glib::VariantBuilder>.

Don't call this on stack-allocated B<Gnome::Glib::VariantBuilder> instances or bad
things will happen.

  method g_variant_builder_unref ( GVariantBuilder $builder )

=item GVariantBuilder $builder; (transfer full): a B<Gnome::Glib::VariantBuilder> allocated by C<g_variant_builder_new()>

=end pod

sub g_variant_builder_unref ( GVariantBuilder $builder  )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_builder_ref:
=begin pod
=head2 [g_variant_] builder_ref

Increases the reference count on I<builder>.

Don't call this on stack-allocated B<Gnome::Glib::VariantBuilder> instances or bad
things will happen.

Returns: (transfer full): a new reference to I<builder>

  method g_variant_builder_ref ( GVariantBuilder $builder --> GVariantBuilder )

=item GVariantBuilder $builder; a B<Gnome::Glib::VariantBuilder> allocated by C<g_variant_builder_new()>

=end pod

sub g_variant_builder_ref ( GVariantBuilder $builder --> GVariantBuilder )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_builder_init:
=begin pod
=head2 [g_variant_] builder_init

Initialises a B<Gnome::Glib::VariantBuilder> structure.

I<type> must be non-C<Any>.  It specifies the type of container to
construct.  It can be an indefinite type such as
C<G_VARIANT_TYPE_ARRAY> or a definite type such as "as" or "(ii)".
Maybe, array, tuple, dictionary entry and variant-typed values may be
constructed.

After the builder is initialised, values are added using
C<g_variant_builder_add_value()> or C<g_variant_builder_add()>.

After all the child values are added, C<g_variant_builder_end()> frees
the memory associated with the builder and returns the B<Gnome::Glib::Variant> that
was created.

This function completely ignores the previous contents of I<builder>.
On one hand this means that it is valid to pass in completely
uninitialised memory.  On the other hand, this means that if you are
initialising over top of an existing B<Gnome::Glib::VariantBuilder> you need to
first call C<g_variant_builder_clear()> in order to avoid leaking
memory.

You must not call C<g_variant_builder_ref()> or
C<g_variant_builder_unref()> on a B<Gnome::Glib::VariantBuilder> that was initialised
with this function.  If you ever pass a reference to a
B<Gnome::Glib::VariantBuilder> outside of the control of your own code then you
should assume that the person receiving that reference may try to use
reference counting; you should use C<g_variant_builder_new()> instead of
this function.

  method g_variant_builder_init ( GVariantBuilder $builder, N-GVariant $type )

=item GVariantBuilder $builder; a B<Gnome::Glib::VariantBuilder>
=item N-GVariant $type; a container type

=end pod

sub g_variant_builder_init ( GVariantBuilder $builder, N-GVariant $type  )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_builder_end:
=begin pod
=head2 [g_variant_] builder_end

Ends the builder process and returns the constructed value.

It is not permissible to use I<builder> in any way after this call
except for reference counting operations (in the case of a
heap-allocated B<Gnome::Glib::VariantBuilder>) or by reinitialising it with
C<g_variant_builder_init()> (in the case of stack-allocated). This
means that for the stack-allocated builders there is no need to
call C<g_variant_builder_clear()> after the call to
C<g_variant_builder_end()>.

It is an error to call this function in any way that would create an
inconsistent value to be constructed (ie: insufficient number of
items added to a container with a specific number of children
required).  It is also an error to call this function if the builder
was created with an indefinite array or maybe type and no children
have been added; in this case it is impossible to infer the type of
the empty array.

Returns: (transfer none): a new, floating, B<Gnome::Glib::Variant>

  method g_variant_builder_end ( GVariantBuilder $builder --> N-GVariant )

=item GVariantBuilder $builder; a B<Gnome::Glib::VariantBuilder>

=end pod

sub g_variant_builder_end ( GVariantBuilder $builder --> N-GVariant )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_builder_clear:
=begin pod
=head2 [g_variant_] builder_clear

Releases all memory associated with a B<Gnome::Glib::VariantBuilder> without
freeing the B<Gnome::Glib::VariantBuilder> structure itself.

It typically only makes sense to do this on a stack-allocated
B<Gnome::Glib::VariantBuilder> if you want to abort building the value part-way
through.  This function need not be called if you call
C<g_variant_builder_end()> and it also doesn't need to be called on
builders allocated with C<g_variant_builder_new()> (see
C<g_variant_builder_unref()> for that).

This function leaves the B<Gnome::Glib::VariantBuilder> structure set to all-zeros.
It is valid to call this function on either an initialised
B<Gnome::Glib::VariantBuilder> or one that is set to all-zeros but it is not valid
to call this function on uninitialised memory.

  method g_variant_builder_clear ( GVariantBuilder $builder )

=item GVariantBuilder $builder; a B<Gnome::Glib::VariantBuilder>

=end pod

sub g_variant_builder_clear ( GVariantBuilder $builder  )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_builder_open:
=begin pod
=head2 [g_variant_] builder_open

Opens a subcontainer inside the given I<builder>.  When done adding
items to the subcontainer, C<g_variant_builder_close()> must be called. I<type>
is the type of the container: so to build a tuple of several values, I<type>
must include the tuple itself.

It is an error to call this function in any way that would cause an
inconsistent value to be constructed (ie: adding too many values or
a value of an incorrect type).

Example of building a nested variant:
|[<!-- language="C" -->
GVariantBuilder builder;
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

  method g_variant_builder_open ( GVariantBuilder $builder, N-GVariant $type )

=item GVariantBuilder $builder; a B<Gnome::Glib::VariantBuilder>
=item N-GVariant $type; the B<Gnome::Glib::VariantType> of the container

=end pod

sub g_variant_builder_open ( GVariantBuilder $builder, N-GVariant $type  )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_builder_close:
=begin pod
=head2 [g_variant_] builder_close

Closes the subcontainer inside the given I<builder> that was opened by
the most recent call to C<g_variant_builder_open()>.

It is an error to call this function in any way that would create an
inconsistent value to be constructed (ie: too few values added to the
subcontainer).

  method g_variant_builder_close ( GVariantBuilder $builder )

=item GVariantBuilder $builder; a B<Gnome::Glib::VariantBuilder>

=end pod

sub g_variant_builder_close ( GVariantBuilder $builder  )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_builder_add_value:
=begin pod
=head2 [g_variant_] builder_add_value

Adds I<value> to I<builder>.

It is an error to call this function in any way that would create an
inconsistent value to be constructed.  Some examples of this are
putting different types of items into an array, putting the wrong
types or number of items in a tuple, putting more than one value into
a variant, etc.

If I<value> is a floating reference (see C<g_variant_ref_sink()>),
the I<builder> instance takes ownership of I<value>.

  method g_variant_builder_add_value ( GVariantBuilder $builder, N-GVariant $value )

=item GVariantBuilder $builder; a B<Gnome::Glib::VariantBuilder>
=item N-GVariant $value; a B<Gnome::Glib::Variant>

=end pod

sub g_variant_builder_add_value ( GVariantBuilder $builder, N-GVariant $value  )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_builder_add:
=begin pod
=head2 [g_variant_] builder_add

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
GVariantBuilder builder;
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

  method g_variant_builder_add ( GVariantBuilder $builder, Str $format_string )

=item GVariantBuilder $builder; a B<Gnome::Glib::VariantBuilder>
=item Str $format_string; a B<Gnome::Glib::Variant> varargs format string @...: arguments, as per I<format_string>

=end pod

sub g_variant_builder_add ( GVariantBuilder $builder, Str $format_string, Any $any = Any  )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_builder_add_parsed:
=begin pod
=head2 [g_variant_] builder_add_parsed



  method g_variant_builder_add_parsed ( GVariantBuilder $builder, Str $format )

=item GVariantBuilder $builder;
=item Str $format;

=end pod

sub g_variant_builder_add_parsed ( GVariantBuilder $builder, Str $format, Any $any = Any  )
  is native(&glib-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:0:_g_variant_new:

#`{{ only via new

Creates a new GVariant instance.

The type of the created instance and the arguments that are expected by this function are determined by format_string. Please note that the syntax of the format string is very likely to be extended in the future.

The first character of the format string must not be '*' '?' '@' or 'r'; in essence, a new Gnome::Glib::Variant must always be constructed by this function (and not merely passed through it unmodified).

Note that the arguments must be of the correct width for their types specified in format_string.

=begin comment
MyFlags some_flags = FLAG_ONE | FLAG_TWO;
const gchar *some_strings[] = { "a", "b", "c", NULL };
GVariant *new_variant;

new_variant = g_variant_new ("(t^as)",
                             // This cast is required.
                             (guint64) some_flags,
                             some_strings);
=end comment

  method _g_variant_new ( Str $type-string --> N-GVariant )

=item Str $format_string;

=end pod
}}

sub _g_variant_new ( Str $type-string, *@values --> N-GVariant ) {

  my @parameterList = ();
  @parameterList.push: Parameter.new(type => Str);         # $type_string

  my @n-values = ();
  my Bool $in-array = False;
  my Bool $in-tupple = False;
  my Bool $in-dict = False;

#note "call val: ", @values.perl;
  for $type-string.split('') {
#note "ts: $_";

    # split returns empty strings on either side -> ignore these
    when '' { }

    # Used for building or deconstructing boolean, byte and numeric types.
    when G_VARIANT_CLASS_BOOLEAN {
      @parameterList.push: Parameter.new(type => int32) unless $in-array;
      @n-values.push: shift @values unless $in-array;
    }

    when G_VARIANT_CLASS_BYTE {
      @parameterList.push: Parameter.new(type => int8) unless $in-array;
      @n-values.push: shift @values unless $in-array;
    }

    when G_VARIANT_CLASS_INT16 {
      @parameterList.push: Parameter.new(type => int16) unless $in-array;
      @n-values.push: shift @values unless $in-array;
    }

    when G_VARIANT_CLASS_UINT16 {
      @parameterList.push: Parameter.new(type => uint16) unless $in-array;
      @n-values.push: shift @values unless $in-array;
    }

    when G_VARIANT_CLASS_INT32 {
      @parameterList.push: Parameter.new(type => int32) unless $in-array;
      @n-values.push: shift @values unless $in-array;
    }

    when G_VARIANT_CLASS_UINT32 {
      @parameterList.push: Parameter.new(type => uint32) unless $in-array;
      @n-values.push: shift @values unless $in-array;
    }

    when G_VARIANT_CLASS_INT64 {
      @parameterList.push: Parameter.new(type => int64) unless $in-array;
      @n-values.push: shift @values unless $in-array;
    }

    when G_VARIANT_CLASS_UINT64 {
      @parameterList.push: Parameter.new(type => uint64) unless $in-array;
      @n-values.push: shift @values unless $in-array;
    }

#`{{
    when G_VARIANT_CLASS_HANDLE {
      @parameterList.push: Parameter.new(type => int32);
      @n-values.push: shift @values;
    }
}}

    when G_VARIANT_CLASS_DOUBLE {
      @parameterList.push: Parameter.new(type => num64) unless $in-array;
      @n-values.push: shift @values unless $in-array;
    }

    # Used for building or deconstructing string types.
    when G_VARIANT_CLASS_STRING {
      @parameterList.push: Parameter.new(type => Str) unless $in-array;
      @n-values.push: shift @values unless $in-array;
    }


#`{{

    when G_VARIANT_CLASS_OBJECT_PATH {
      @parameterList.push: Parameter.new(type => Str);
      @n-values.push: shift @values;
    }

    when G_VARIANT_CLASS_SIGNATURE {
      @parameterList.push: Parameter.new(type => Str);
      @n-values.push: shift @values;
    }

    # Used for building or deconstructing variant types
    when G_VARIANT_CLASS_VARIANT {
      @parameterList.push: Parameter.new(type => Pointer);
      @n-values.push: shift @values;
    }

    # Used for building or deconstructing maybe types
    when G_VARIANT_CLASS_MAYBE {
      @n-values.push: shift @values;
    }
}}
#`{{

    # Used for building or deconstructing arrays
    when G_VARIANT_CLASS_ARRAY {
      @n-values.push: shift @values;
      $in-array = True;
    }

}}
#`{{
    # Used for building or deconstructing tuples
    when G_VARIANT_CLASS_TUPLE {
      @n-values.push: shift @values;
    }

    #
    when ')' {
    }

    #Used for building or deconstructing dictionary entries
    when G_VARIANT_CLASS_DICT_ENTRY {
      @n-values.push: shift @values;
    }

    when '}' {
    }

    # Used as a prefix for a GVariant type string (not a prefix for a format
    # string, so @as is a valid format string but @^as is not). Denotes that a
    # pointer to a GVariant should be used in place of the normal C type or
    # types.
    when '@' {
    }

    # Equivalent to @*, @? and @r
    when '*' {
    }

    when '?' {
    }

    when 'r' {
    }

    # Used as a prefix for a GVariant type string (not a prefix for a format
    # string, so &s is a valid format string but &@s is not). Denotes that a C
    # pointer to serialised data should be used in place of the normal C type.
    when '&' {
    }

    # Used as a prefix on some specific types of format strings.
    when '^' {
    }
}}
    default {
      die X::Gnome.new(:message("Format character '$_' not yet supported"))
    }
  }


  # create signature
  my Signature $signature .= new(
    :params(|@parameterList),
    :returns(N-GVariant)
  );

  # get a pointer to the sub, then cast it to a sub with the proper
  # signature. after that, the sub can be called, returning a value.
  state $ptr = cglobal( &glib-lib, 'g_variant_new', Pointer);
  my Callable $f = nativecast( $signature, $ptr);

#note "Val: ", @n-values.perl;
#note "Sig: ", $signature.perl;

  $f( $type-string, |@n-values)
}


#`{{
#-------------------------------------------------------------------------------
#TM:0:g_variant_get:
=begin pod
=head2 g_variant_get

Deconstructs a B<Gnome::Glib::Variant> instance.

Think of this function as an analogue to C<scanf()>.

The arguments that are expected by this function are entirely determined by I<format_string>.  I<format_string> also restricts the permissible types of I<value>.  It is an error to give a value with an incompatible type.  See the section on [GVariant format strings][gvariant-format-strings]. Please note that the syntax of the format string is very likely to be extended in the future.

I<format_string> determines the C types that are used for unpacking the values and also determines if the values are copied or borrowed, see the section on [GVariant format strings][gvariant-format-strings-pointers].

  method g_variant_get ( Str $format_string )

=item Str $format_string; a B<Gnome::Glib::Variant> format string @...: arguments, as per I<format_string>

=end pod

sub g_variant_get ( N-GVariant $value, Str $format_string, Any $any = Any  )
  is native(&glib-lib)
  { * }
}}
#`{{
method get ( |c ) {
  g_variant_get( self.get-native-object-no-reffing, |c);
}

sub g_variant_get ( N-GVariant $value, Str $format_string --> N-GVariantIter ) {

  my N-GVariantIter $v;
  _g_variant_get( $value, $format_string, $v);
  $v
}

sub _g_variant_get (
  N-GVariant $value, Str $format_string, N-GVariantIter $v is rw
) is native(&glib-lib)
  is symbol('g_variant_get')
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
#TM:0:g_variant_new_va:
=begin pod
=head2 [g_variant_] new_va

This function is intended to be used by libraries based on
B<Gnome::Glib::Variant> that want to provide C<g_variant_new()>-like functionality
to their users.

The API is more general than C<g_variant_new()> to allow a wider range
of possible uses.

I<format_string> must still point to a valid format string, but it only
needs to be nul-terminated if I<endptr> is C<Any>.  If I<endptr> is
non-C<Any> then it is updated to point to the first character past the
end of the format string.

I<app> is a pointer to a B<va_list>.  The arguments, according to
I<format_string>, are collected from this B<va_list> and the list is left
pointing to the argument following the last.

Note that the arguments in I<app> must be of the correct width for their
types specified in I<format_string> when collected into the B<va_list>.
See the [GVariant varargs documentation][gvariant-varargs].

These two generalisations allow mixing of multiple calls to
C<g_variant_new_va()> and C<g_variant_get_va()> within a single actual
varargs call by the user.

The return value will be floating if it was a newly created GVariant
instance (for example, if the format string was "(ii)").  In the case
that the format_string was '*', '?', 'r', or a format starting with
'@' then the collected B<Gnome::Glib::Variant> pointer will be returned unmodified,
without adding any additional references.

In order to behave correctly in all cases it is necessary for the
calling function to C<g_variant_ref_sink()> the return result before
returning control to the user that originally provided the pointer.
At this point, the caller will have their own full reference to the
result.  This can also be done by adding the result to a container,
or by passing it to another C<g_variant_new()> call.

Returns: a new, usually floating, B<Gnome::Glib::Variant>

  method g_variant_new_va ( Str $format_string, CArray[Str] $endptr, va_list $app --> N-GVariant )

=item Str $format_string; a string that is prefixed with a format string
=item CArray[Str] $endptr; (nullable) (default NULL): location to store the end pointer, or C<Any>
=item va_list $app; a pointer to a B<va_list>

=end pod

sub g_variant_new_va ( Str $format_string, CArray[Str] $endptr, va_list $app --> N-GVariant )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_get_va:
=begin pod
=head2 [g_variant_] get_va

This function is intended to be used by libraries based on B<Gnome::Glib::Variant>
that want to provide C<g_variant_get()>-like functionality to their
users.

The API is more general than C<g_variant_get()> to allow a wider range
of possible uses.

I<format_string> must still point to a valid format string, but it only
need to be nul-terminated if I<endptr> is C<Any>.  If I<endptr> is
non-C<Any> then it is updated to point to the first character past the
end of the format string.

I<app> is a pointer to a B<va_list>.  The arguments, according to
I<format_string>, are collected from this B<va_list> and the list is left
pointing to the argument following the last.

These two generalisations allow mixing of multiple calls to
C<g_variant_new_va()> and C<g_variant_get_va()> within a single actual
varargs call by the user.

I<format_string> determines the C types that are used for unpacking
the values and also determines if the values are copied or borrowed,
see the section on
[GVariant format strings][gvariant-format-strings-pointers].

  method g_variant_get_va ( Str $format_string, CArray[Str] $endptr, va_list $app )

=item Str $format_string; a string that is prefixed with a format string
=item CArray[Str] $endptr; (nullable) (default NULL): location to store the end pointer, or C<Any>
=item va_list $app; a pointer to a B<va_list>

=end pod

sub g_variant_get_va ( N-GVariant $value, Str $format_string, CArray[Str] $endptr, va_list $app  )
  is native(&glib-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:0:g_variant_check_format_string:
=begin pod
=head2 [g_variant_] check_format_string

Checks if calling C<g_variant_get()> with I<format_string> on I<value> would
be valid from a type-compatibility standpoint.  I<format_string> is
assumed to be a valid format string (from a syntactic standpoint).

If I<copy_only> is C<1> then this function additionally checks that it
would be safe to call C<g_variant_unref()> on I<value> immediately after
the call to C<g_variant_get()> without invalidating the result.  This is
only possible if deep copies are made (ie: there are no pointers to
the data inside of the soon-to-be-freed B<Gnome::Glib::Variant> instance).  If this
check fails then a C<g_critical()> is printed and C<0> is returned.

This function is meant to be used by functions that wish to provide
varargs accessors to B<Gnome::Glib::Variant> values of uncertain values (eg:
C<g_variant_lookup()> or C<g_menu_model_get_item_attribute()>).

Returns: C<1> if I<format_string> is safe to use

  method g_variant_check_format_string ( Str $format_string, Int $copy_only --> Int )

=item Str $format_string; a valid B<Gnome::Glib::Variant> format string
=item Int $copy_only; C<1> to ensure the format string makes deep copies

=end pod

sub g_variant_check_format_string ( N-GVariant $value, Str $format_string, int32 $copy_only --> int32 )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:g_variant_parse:
=begin pod
=head2 g_variant_parse

Parses a GVariant from a text representation.

In the event that the parsing is successful, the resulting GVariant is returned.

In case of any error, NULL will be returned. If error is non-NULL then it will be set to reflect the error that occurred.

There may be implementation specific restrictions on deeply nested values, which would result in a G_VARIANT_PARSE_ERROR_RECURSION error. GVariant is guaranteed to handle nesting up to at least 64 levels.

  method g_variant_parse ( Str $type-string, Str $text --> List )

=item Str $type-string; String like it is used to create a Gnome::Glib::VariantType
=item Str $text; Textual representation of data.

The returned List has members
=item N-GVariant object. A native variant object
=item Gnome::Glib::Error. The error object. Test for C<.is-valid() ~~ False> to see if parsing went ok and that the variant object is defined.

An example

  # Create an empty Variant to be able to call the parse method
  my Gnome::Glib::Variant $v .= new(:native-object(N-GVariant));

  # Then create a native variant object holding an array of 2 unsigned integers
  my ( N-GVariant $nv, Gnome::Glib::Error $e) =
    $v.g-variant-parse( 'au', '[100,200]');

See also the L<GVariant Text Format|https://developer.gnome.org/glib/stable/gvariant-text.html>.

=end pod

sub g_variant_parse (
  Str:D $type-string, Str:D $text
  --> List
) {
  my Gnome::Glib::VariantType $vt .= new(:$type-string);
  my Gnome::Glib::Error $parse-error;
  my CArray[N-GError] $ne .= new(N-GError);
  my N-GVariant $v = _g_variant_parse(
    $vt.get-native-object, $text, Str, OpaquePointer, $ne
  );

  if ?$v {
    $parse-error = Gnome::Glib::Error.new(:native-object(N-GError))
  }

  else {
    $parse-error = Gnome::Glib::Error.new(:native-object($ne[0]))
  }

  ( $v, $parse-error)
}

sub _g_variant_parse (
  N-GVariantType $type, Str $text, Str $limit, OpaquePointer $endptr,
  CArray[N-GError] $error
  --> N-GVariant
) is native(&glib-lib)
  is symbol('g_variant_parse')
  { * }

#`{{
#-------------------------------------------------------------------------------
#TM:0:g_variant_new_parsed:
=begin pod
=head2 [g_variant_] new_parsed



  method g_variant_new_parsed ( Str $format --> N-GVariant )

=item Str $format;

=end pod

sub g_variant_new_parsed ( Str $format, Any $any = Any --> N-GVariant )
  is native(&glib-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
#TM:0:g_variant_new_parsed_va:
=begin pod
=head2 [g_variant_] new_parsed_va



  method g_variant_new_parsed_va ( Str $format, va_list $app --> N-GVariant )

=item Str $format;
=item va_list $app;

=end pod

sub g_variant_new_parsed_va ( Str $format, va_list $app --> N-GVariant )
  is native(&glib-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
#TM:0:g_variant_parse_error_print_context:
=begin pod
=head2 [g_variant_] parse_error_print_context



  method g_variant_parse_error_print_context ( N-GError $error, Str $source_str --> Str )

=item N-GError $error;
=item Str $source_str;

=end pod

sub g_variant_parse_error_print_context ( N-GError $error, Str $source_str --> Str )
  is native(&glib-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:0:g_variant_compare:
=begin pod
=head2 g_variant_compare

Compares I<one> and I<two>.

The types of I<one> and I<two> are B<gconstpointer> only to allow use of
this function with B<GTree>, B<GPtrArray>, etc.  They must each be a
B<Gnome::Glib::Variant>.

Comparison is only defined for basic types (ie: booleans, numbers,
strings).  For booleans, C<0> is less than C<1>.  Numbers are
ordered in the usual way.  Strings are in ASCII lexographical order.

It is a programmer error to attempt to compare container values or
two values that have types that are not exactly equal.  For example,
you cannot compare a 32-bit signed integer with a 32-bit unsigned
integer.  Also note that this function is not particularly
well-behaved when it comes to comparison of doubles; in particular,
the handling of incomparable values (ie: NaN) is undefined.

If you only require an equality comparison, C<g_variant_equal()> is more
general.

Returns: negative value if a < b;
zero if a = b;
positive value if a > b.

  method g_variant_compare ( Pointer $one, Pointer $two --> Int )

=item Pointer $one; (type GVariant): a basic-typed B<Gnome::Glib::Variant> instance
=item Pointer $two; (type GVariant): a B<Gnome::Glib::Variant> instance of the same type

=end pod

sub g_variant_compare ( Pointer $one, Pointer $two --> int32 )
  is native(&glib-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
#TM:0:g_variant_dict_new:
=begin pod
=head2 [g_variant_] dict_new

Allocates and initialises a new B<Gnome::Glib::VariantDict>.

You should call C<g_variant_dict_unref()> on the return value when it
is no longer needed.  The memory will not be automatically freed by
any other call.

In some cases it may be easier to place a B<Gnome::Glib::VariantDict> directly on
the stack of the calling function and initialise it with
C<g_variant_dict_init()>.  This is particularly useful when you are
using B<Gnome::Glib::VariantDict> to construct a B<Gnome::Glib::Variant>.

Returns: (transfer full): a B<Gnome::Glib::VariantDict>

  method g_variant_dict_new ( --> GVariantDict )


=end pod

sub g_variant_dict_new ( N-GVariant $from_asv --> GVariantDict )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_dict_init:
=begin pod
=head2 [g_variant_] dict_init

Initialises a B<Gnome::Glib::VariantDict> structure.

If I<from_asv> is given, it is used to initialise the dictionary.

This function completely ignores the previous contents of I<dict>.  On
one hand this means that it is valid to pass in completely
uninitialised memory.  On the other hand, this means that if you are
initialising over top of an existing B<Gnome::Glib::VariantDict> you need to first
call C<g_variant_dict_clear()> in order to avoid leaking memory.

You must not call C<g_variant_dict_ref()> or C<g_variant_dict_unref()> on a
B<Gnome::Glib::VariantDict> that was initialised with this function.  If you ever
pass a reference to a B<Gnome::Glib::VariantDict> outside of the control of your
own code then you should assume that the person receiving that
reference may try to use reference counting; you should use
C<g_variant_dict_new()> instead of this function.

  method g_variant_dict_init ( GVariantDict $dict, N-GVariant $from_asv )

=item GVariantDict $dict; a B<Gnome::Glib::VariantDict>
=item N-GVariant $from_asv; (nullable): the initial value for I<dict>

=end pod

sub g_variant_dict_init ( GVariantDict $dict, N-GVariant $from_asv  )
  is native(&glib-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
#TM:0:g_variant_dict_lookup:
=begin pod
=head2 [g_variant_] dict_lookup

Looks up a value in a B<Gnome::Glib::VariantDict>.

This function is a wrapper around C<g_variant_dict_lookup_value()> and
C<g_variant_get()>.  In the case that C<Any> would have been returned,
this function returns C<0>.  Otherwise, it unpacks the returned
value and returns C<1>.

I<format_string> determines the C types that are used for unpacking the
values and also determines if the values are copied or borrowed, see the
section on [GVariant format strings][gvariant-format-strings-pointers].

Returns: C<1> if a value was unpacked

  method g_variant_dict_lookup ( GVariantDict $dict, Str $key, Str $format_string --> Int )

=item GVariantDict $dict; a B<Gnome::Glib::VariantDict>
=item Str $key; the key to lookup in the dictionary
=item Str $format_string; a GVariant format string @...: the arguments to unpack the value into

=end pod

sub g_variant_dict_lookup ( GVariantDict $dict, Str $key, Str $format_string, Any $any = Any --> int32 )
  is native(&glib-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
#TM:0:g_variant_dict_lookup_value:
=begin pod
=head2 [g_variant_] dict_lookup_value

Looks up a value in a B<Gnome::Glib::VariantDict>.

If I<key> is not found in I<dictionary>, C<Any> is returned.

The I<expected_type> string specifies what type of value is expected.
If the value associated with I<key> has a different type then C<Any> is
returned.

If the key is found and the value has the correct type, it is
returned.  If I<expected_type> was specified then any non-C<Any> return
value will have this type.

Returns: (transfer full): the value of the dictionary key, or C<Any>

  method g_variant_dict_lookup_value ( GVariantDict $dict, Str $key, N-GVariant $expected_type --> N-GVariant )

=item GVariantDict $dict; a B<Gnome::Glib::VariantDict>
=item Str $key; the key to lookup in the dictionary
=item N-GVariant $expected_type; (nullable): a B<Gnome::Glib::VariantType>, or C<Any>

=end pod

sub g_variant_dict_lookup_value ( GVariantDict $dict, Str $key, N-GVariant $expected_type --> N-GVariant )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_dict_contains:
=begin pod
=head2 [g_variant_] dict_contains

Checks if I<key> exists in I<dict>.

Returns: C<1> if I<key> is in I<dict>

  method g_variant_dict_contains ( GVariantDict $dict, Str $key --> Int )

=item GVariantDict $dict; a B<Gnome::Glib::VariantDict>
=item Str $key; the key to lookup in the dictionary

=end pod

sub g_variant_dict_contains ( GVariantDict $dict, Str $key --> int32 )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_dict_insert:
=begin pod
=head2 [g_variant_] dict_insert

Inserts a value into a B<Gnome::Glib::VariantDict>.

This call is a convenience wrapper that is exactly equivalent to
calling C<g_variant_new()> followed by C<g_variant_dict_insert_value()>.

  method g_variant_dict_insert ( GVariantDict $dict, Str $key, Str $format_string )

=item GVariantDict $dict; a B<Gnome::Glib::VariantDict>
=item Str $key; the key to insert a value for
=item Str $format_string; a B<Gnome::Glib::Variant> varargs format string @...: arguments, as per I<format_string>

=end pod

sub g_variant_dict_insert ( GVariantDict $dict, Str $key, Str $format_string, Any $any = Any  )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_dict_insert_value:
=begin pod
=head2 [g_variant_] dict_insert_value

Inserts (or replaces) a key in a B<Gnome::Glib::VariantDict>.

I<value> is consumed if it is floating.

  method g_variant_dict_insert_value ( GVariantDict $dict, Str $key, N-GVariant $value )

=item GVariantDict $dict; a B<Gnome::Glib::VariantDict>
=item Str $key; the key to insert a value for
=item N-GVariant $value; the value to insert

=end pod

sub g_variant_dict_insert_value ( GVariantDict $dict, Str $key, N-GVariant $value  )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_dict_remove:
=begin pod
=head2 [g_variant_] dict_remove

Removes a key and its associated value from a B<Gnome::Glib::VariantDict>.

Returns: C<1> if the key was found and removed

  method g_variant_dict_remove ( GVariantDict $dict, Str $key --> Int )

=item GVariantDict $dict; a B<Gnome::Glib::VariantDict>
=item Str $key; the key to remove

=end pod

sub g_variant_dict_remove ( GVariantDict $dict, Str $key --> int32 )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_dict_clear:
=begin pod
=head2 [g_variant_] dict_clear

Releases all memory associated with a B<Gnome::Glib::VariantDict> without freeing
the B<Gnome::Glib::VariantDict> structure itself.

It typically only makes sense to do this on a stack-allocated
B<Gnome::Glib::VariantDict> if you want to abort building the value part-way
through.  This function need not be called if you call
C<g_variant_dict_end()> and it also doesn't need to be called on dicts
allocated with g_variant_dict_new (see C<g_variant_dict_unref()> for
that).

It is valid to call this function on either an initialised
B<Gnome::Glib::VariantDict> or one that was previously cleared by an earlier call
to C<g_variant_dict_clear()> but it is not valid to call this function
on uninitialised memory.

  method g_variant_dict_clear ( GVariantDict $dict )

=item GVariantDict $dict; a B<Gnome::Glib::VariantDict>

=end pod

sub g_variant_dict_clear ( GVariantDict $dict  )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_dict_end:
=begin pod
=head2 [g_variant_] dict_end

Returns the current value of I<dict> as a B<Gnome::Glib::Variant> of type
C<G_VARIANT_TYPE_VARDICT>, clearing it in the process.

It is not permissible to use I<dict> in any way after this call except
for reference counting operations (in the case of a heap-allocated
B<Gnome::Glib::VariantDict>) or by reinitialising it with C<g_variant_dict_init()> (in
the case of stack-allocated).

Returns: (transfer none): a new, floating, B<Gnome::Glib::Variant>

  method g_variant_dict_end ( GVariantDict $dict --> N-GVariant )

=item GVariantDict $dict; a B<Gnome::Glib::VariantDict>

=end pod

sub g_variant_dict_end ( GVariantDict $dict --> N-GVariant )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_dict_ref:
=begin pod
=head2 [g_variant_] dict_ref

Increases the reference count on I<dict>.

Don't call this on stack-allocated B<Gnome::Glib::VariantDict> instances or bad
things will happen.

Returns: (transfer full): a new reference to I<dict>

  method g_variant_dict_ref ( GVariantDict $dict --> GVariantDict )

=item GVariantDict $dict; a heap-allocated B<Gnome::Glib::VariantDict>

=end pod

sub g_variant_dict_ref ( GVariantDict $dict --> GVariantDict )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_variant_dict_unref:
=begin pod
=head2 [g_variant_] dict_unref

Decreases the reference count on I<dict>.

In the event that there are no more references, releases all memory
associated with the B<Gnome::Glib::VariantDict>.

Don't call this on stack-allocated B<Gnome::Glib::VariantDict> instances or bad
things will happen.

  method g_variant_dict_unref ( GVariantDict $dict )

=item GVariantDict $dict; (transfer full): a heap-allocated B<Gnome::Glib::VariantDict>

=end pod

sub g_variant_dict_unref ( GVariantDict $dict  )
  is native(&glib-lib)
  { * }
}}
