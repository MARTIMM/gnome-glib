#TL:1:Gnome::Glib::Variant:

use v6;
#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Glib::Variant

Strongly typed value datatype

=head1 Description

B<Gnome::Glib::Variant> is a variant datatype; it can contain one or more values along with information about the type of the values.

A B<Gnome::Glib::Variant> may contain simple types, like an integer, or a boolean value; or complex types, like an array of two strings, or a dictionary of key value pairs. A B<Gnome::Glib::Variant> is also immutable: once it's been created neither its type nor its content can be modified further.

B<Gnome::Glib::Variant> is useful whenever data needs to be serialized, for example when sending method parameters in DBus, or when saving settings using B<Gnome::Glib::Settings>.

When creating a new B<Gnome::Glib::Variant>, you pass the data you want to store in it along with a string representing the type of data you wish to pass to it.

For instance, if you want to create a B<Gnome::Glib::Variant> holding an integer value you can use:

  my Gnome::Glib::Variant $v .= new(
    :type-string<u>, :value(42)
  );

The string "u" in the first argument tells B<Gnome::Glib::Variant> that the data passed to the constructor (40) is going to be an unsigned 32 bit integer.

As an alternative you can write

  my Gnome::Glib::Variant $v .= new(:parse('-42'));

where the default used type is a signed 32 bit integer. To use an other integer type, write the type with it.

  my Gnome::Glib::Variant $v .= new(:parse('uint64 42'));

More advanced examples of B<Gnome::Glib::Variant> in use can be found in documentation for GVariant format strings.

The range of possible values is determined by the type.

The type system used by B<Gnome::Glib::Variant> is B<Gnome::Glib::VariantType>.

B<Gnome::Glib::Variant> instances always have a type and a value (which are given at construction time). The type and value of a B<Gnome::Glib::Variant> instance can never change other than by the B<Gnome::Glib::Variant> itself being destroyed. A B<Gnome::Glib::Variant> cannot contain a pointer.

=comment B<Gnome::Glib::Variant> is reference counted using C<g_variant_ref()> and C<g_variant_unref()>.  B<Gnome::Glib::Variant> also has floating reference counts -- see C<g_variant_ref_sink()>.

B<Gnome::Glib::Variant> is completely threadsafe.  A B<Gnome::Glib::Variant> instance can be concurrently accessed in any way from any number of threads without problems.

B<Gnome::Glib::Variant> is heavily optimised for dealing with data in serialised form.  It works particularly well with data located in memory-mapped files.  It can perform nearly all deserialisation operations in a small constant time, usually touching only a single memory page. Serialised B<Gnome::Glib::Variant> data can also be sent over the network.

B<Gnome::Glib::Variant> is largely compatible with D-Bus.  Almost all types of B<Gnome::Glib::Variant> instances can be sent over D-Bus.  See B<Gnome::Glib::VariantType> for exceptions.  (However, B<Gnome::Glib::Variant>'s serialisation format is not the same as the serialisation format of a D-Bus message body: use B<GDBusMessage>, in the gio library, for those.)

For space-efficiency, the B<Gnome::Glib::Variant> serialisation format does not automatically include the variant's length, type or endianness, which must either be implied from context (such as knowledge that a particular file format always contains a little-endian C<G_VARIANT_TYPE_VARIANT> which occupies the whole length of the file) or supplied out-of-band (for instance, a length, type and/or endianness indicator could be placed at the beginning of a file, network message or network stream).

A B<Gnome::Glib::Variant>'s size is limited mainly by any lower level operating system constraints, such as the number of bits in B<gsize>.  For example, it is reasonable to have a 2GB file mapped into memory with B<GMappedFile>, and call C<g_variant_new_from_data()> on it.

For convenience to C programmers, B<Gnome::Glib::Variant> features powerful varargs-based value construction and destruction.  This feature is designed to be embedded in other libraries.

=comment There is a Python-inspired text language for describing B<Gnome::Glib::Variant> values.  B<Gnome::Glib::Variant> includes a printer for this language and a parser with type inferencing.


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

To put the entire example together, for our dictionary mapping strings to variants (with two entries, as given above), we are using 91 bytes of memory for type information, 29 bytes of memory for the serialised data, 16 bytes for buffer management and 24 bytes for the B<Gnome::Glib::Variant> instance, or a total of 160 bytes, plus malloc overhead.  If we were to use C<g_variant_get_child_value()> to access the two dictionary entries, we would use an additional 48 bytes.  If we were to have other dictionaries of the same type, we would use more memory for the serialised data and buffer management for those dictionaries, but the type information would be shared.

=head2 See Also

[Gnome::Glib::VariantType](VariantType.html), [variant format strings](https://developer.gnome.org/glib/stable/gvariant-format-strings.html), [variant text format](https://developer.gnome.org/glib/stable/gvariant-text.html).

 =item L<Variant dictionaries|VariantDict.html>
 =item L<Variant types|VariantType.html>
 =item L<Variant format strings|https://developer.gnome.org/glib/stable/gvariant-format-strings.html>
 =item L<Variant text format|https://developer.gnome.org/glib/stable/gvariant-text.html>

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
use Gnome::N::GlibToRakuTypes;

use Gnome::Glib::N-GVariant;
use Gnome::Glib::N-GVariantType;
use Gnome::Glib::Error;
use Gnome::Glib::VariantType;

#-------------------------------------------------------------------------------
unit class Gnome::Glib::Variant:auth<github:MARTIMM>:ver<0.2.0>;
also is Gnome::N::TopLevelClassSupport;

#-------------------------------------------------------------------------------
=begin pod
=head1 Types
=end pod

#-------------------------------------------------------------------------------
=begin pod
=head2 GVariantClass

The range of possible top-level types of GVariant instances.


=item G_VARIANT_CLASS_BOOLEAN; The GVariant is a boolean.
=item G_VARIANT_CLASS_BYTE; The GVariant is a byte.
=item G_VARIANT_CLASS_INT16; The GVariant is a signed 16 bit integer.
=item G_VARIANT_CLASS_UINT16; The GVariant is an unsigned 16 bit integer.
=item G_VARIANT_CLASS_INT32; The GVariant is a signed 32 bit integer.
=item G_VARIANT_CLASS_UINT32; The GVariant is an unsigned 32 bit integer.
=item G_VARIANT_CLASS_INT64; The GVariant is a signed 64 bit integer.
=item G_VARIANT_CLASS_UINT64; The GVariant is an unsigned 64 bit integer.
=item G_VARIANT_CLASS_HANDLE; The GVariant is a file handle index.
=item G_VARIANT_CLASS_DOUBLE; The GVariant is a double precision floating point value.
=item G_VARIANT_CLASS_STRING; The GVariant is a normal string.
=item G_VARIANT_CLASS_OBJECT_PATH; The GVariant is a D-Bus object path string.
=item G_VARIANT_CLASS_SIGNATURE; The GVariant is a D-Bus signature string.
=item G_VARIANT_CLASS_VARIANT; The GVariant is a variant.
=item G_VARIANT_CLASS_MAYBE; The GVariant is a maybe-typed value.
=item G_VARIANT_CLASS_ARRAY; The GVariant is an array.
=item G_VARIANT_CLASS_TUPLE; The GVariant is a tuple.
=item G_VARIANT_CLASS_DICT_ENTRY; The GVariant is a dictionary entry.
=end pod

#TT:0:GVariantClass
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
=head1 Methods
=head2 new

=head3 :array

Create a new Variant object. The type of the array elements is taken from the first element.

  multi method new ( Array :$array! )

=head4 Example

Create a Variant array type containing integers;

  my Array $array = [];
  for 40, 41, 42 -> $value {
    $array.push: Gnome::Glib::Variant.new( :type-string<i>, :$value);
  }
  my Gnome::Glib::Variant $v .= new(:$array);
  say $v.get-type-string;      # ai

=head3 :boolean

Creates a new boolean Variant -- either C<True> or C<False>. Note that the value in the variant is stored as an integer. Its type becomes 'b'.

  multi method new ( Bool :$boolean! )


=head3 :byte

Creates a new byte Variant. Its type becomes 'y'.

  multi method new ( Int :$byte! )


=head3 :byte-string

Creates a new byte-string Variant. Its type becomes 'ay' which is essentially an array of bytes. This can be an ascii type of string which does not have to be UTF complient.

  multi method new ( Str :$byte-string! )


=head3 :byte-string-array

Creates a new byte-string-array Variant. Its type becomes 'aay'. which is essentially an array of an array of bytes.

  multi method new ( Array :$byte-string-array! )


=head3 :dict

Creates a new dictionary Variant. Its type becomes '{}'.

  multi method new ( List :$dict! )

The List C<$dict> has two values, a I<key> and a I<value> and must both be valid B<Gnome::Glib::Variant> objects. I<key> must be a value of a basic type (ie: not a container). It will mostly be a string (variant type 's').

=head4 Example

  my Gnome::Glib::Variant $v .= new(
    :dict(
      Gnome::Glib::Variant.new(:parse<width>),
      Gnome::Glib::Variant.new(:parse<200>)
    )
  );

  say $v.print; #

=head3 :double

Creates a new double Variant. Its type becomes 'd'.

  multi method new ( Num :$double! )


=head3 :int16

Creates a new int16 Variant. Its type becomes 'n'.

  multi method new ( Int :$int16! )


=head3 :int32

Creates a new int32 Variant. Its type becomes 'i'.

  multi method new ( Int :$int32! )


=head3 :int64

Creates a new int64 Variant. Its type becomes 'x'.

  multi method new ( Int :$int64! )


=head3 :string

Creates a new string Variant. Its type becomes 's'.

  multi method new ( Str :$string! )


=head3 :strv

Creates a new string array Variant. Its type becomes 'as'.

  multi method new ( Array :$strv! )

=head4 Example

  my Gnome::Glib::Variant $v .= new(:string-array([<abc def ghi αβ ⓒ™⅔>]));
  say $v.get-type-string; #    as


=head3 :tuple

Creates a new tuple Variant. Its type becomes ''.

  multi method new ( Array :$tuple! )

=head4 Example

  my Array $tuple = [];
  $tuple.push: Gnome::Glib::Variant.new( :type-string<i>, :value(40));
  $tuple.push: Gnome::Glib::Variant.new( :type-string<s>, :value<fourtyone>);
  $tuple.push: Gnome::Glib::Variant.new( :type-string<x>, :value(42));
  my Gnome::Glib::Variant $v .= new(:$tuple);
  say $v.get-type-string; #    (isx)


=head3 :uint16

Creates a new uint16 Variant. Its type becomes 'q'.

  multi method new ( UInt :$uint16! )


=head3 :uint32

Creates a new uint32 Variant. Its type becomes 'u'.

  multi method new ( UInt :$uint32! )


=head3 :uint64

Creates a new uint64 Variant. Its type becomes 't'.

  multi method new ( UInt :$uint64! )


=head3 :variant

Creates a new variant Variant. Its type becomes 'v'.

  multi method new ( N-GVariant :$variant! )

=head4 Example

  my Gnome::Glib::Variant $v .= new(
    :variant(Gnome::Glib::Variant.new( :type-string<i>, :value(40)))
  );
  say $v.get-type-string; #    v


=head3 :type-string, :parse

Create a new Variant object by parsing the type and data provided in strings. The format of the parse string is L<described here|https://developer.gnome.org/glib/stable/gvariant-text.html>.

  multi method new ( Str :$type-string?, Str :$parse! )

=head4 Example

Create a Variant tuple containing a string, an unsigned integer and a boolean (Note the lowercase 'true'!);

  my Gnome::Glib::Variant $v .= new(
    :type-string<(sub)>, :parse('("abc",20,true)')
  );

Because the values in the :parse string take the default types you can also leave out the type string;

  my Gnome::Glib::Variant $v .= new(:parse('("abc",20,true)'));


=head3 :type-string, :value

Create a new Variant object by parsing the type and a provided value. The type strings are simple like (unsigned) integer ('u' or 'i') but no arrays ('a') etc.

  multi method new ( Str :$type-string!, Any :$value! )


=head3 :native-object

Create a Variant object using a native object from elsewhere. See also B<Gnome::N::TopLevelClassSupport>.

  multi method new ( N-GObject :$native-object! )

=end pod

#TM:1:new(:array):
#TM:1:new(:boolean):
#TM:1:new(:byte):
#TM:1:new(:byte-string):
#TM:1:new(:byte-string-array):
#TM:1:new(:dict):
#TM:1:new(:double):
#TM:1:new(:int16):
#TM:1:new(:int32):
#TM:1:new(:int64):
#TM:1:new(:string):
#TM:1:new(:strv):
#TM:1:new(:tuple):
#TM:1:new(:uint16):
#TM:1:new(:uint32):
#TM:1:new(:uint64):
#TM:1:new(:variant):
#TM:1:new(:type-string,:values):
#TM:1:new(:type-string,:parse):
#TM:4:new(:native-object):Gnome::N::TopLevelClassSupport
submethod BUILD ( *%options ) {

  # prevent creating wrong native-objects
  if self.^name eq 'Gnome::Glib::Variant' #`{{or ?%options<GVariant>}} {

    # check if native object is set by other parent class BUILDers
    if self.is-valid { }

    elsif %options<native-object>:exists { }

    # process all other options
    else {
      my $no;

      if %options<array>:exists {
        my Gnome::Glib::VariantType $vt .= new(
          :type-string(%options<array>[0].get-type-string)
        );

        my Int $i = 0;
        my $children = CArray[N-GVariant].new;
        for @(%options<array>) -> $no is copy {
          $no .= get-native-object unless $no ~~ N-GVariant;
          $children[$i++] = $no;
        }

        $no = _g_variant_new_array( $vt.get-native-object, $children, $i);
      }

      elsif %options<boolean>:exists {
        $no = _g_variant_new_boolean(%options<boolean>.Int);
      }

      elsif %options<byte>:exists {
        $no = _g_variant_new_byte(%options<byte>);
      }

      elsif %options<byte-string>:exists {
        $no = _g_variant_new_bytestring(%options<byte-string>);
      }

      elsif %options<byte-string-array>:exists {
        my Int $i = 0;
        my $ba = CArray[Str].new;
        for @(%options<byte-string-array>) -> $s {
          $ba[$i++] = $s;
        }
        $no = _g_variant_new_bytestring_array( $ba, $i);
      }

      elsif %options<dict>:exists {
        my $no1 = %options<dict>[0];
        $no1 .= get-native-object-no-reffing unless $no1 ~~ N-GVariant;
        my $no2 = %options<dict>[1];
        $no2 .= get-native-object-no-reffing unless $no2 ~~ N-GVariant;

        $no = _g_variant_new_dict_entry( $no1, $no2);
      }

      elsif %options<double>:exists {
        $no = _g_variant_new_double(%options<double>.Num);
      }

      elsif %options<int16>:exists {
        $no = _g_variant_new_int16(%options<int16>);
      }

      elsif %options<int32>:exists {
        $no = _g_variant_new_int32(%options<int32>);
      }

      elsif %options<int64>:exists {
        $no = _g_variant_new_int64(%options<int64>);
      }

      elsif %options<string>:exists {
        $no = _g_variant_new_string(%options<string>);
      }

      elsif %options<strv>:exists {
        my Int $i = 0;
        my $ba = CArray[Str].new;
        for @(%options<strv>) -> $s {
          $ba[$i++] = $s;
        }
        $no = _g_variant_new_strv( $ba, $i);
      }

      elsif %options<tuple>:exists {
        my Int $i = 0;
        my $children = CArray[N-GVariant].new;
        for @(%options<tuple>) -> $no is copy {
          $no .= get-native-object unless $no ~~ N-GVariant;
          $children[$i++] = $no;
        }

        $no = _g_variant_new_tuple( $children, $i);
      }

      elsif %options<uint16>:exists {
        $no = _g_variant_new_uint16(%options<uint16>);
      }

      elsif %options<uint32>:exists {
        $no = _g_variant_new_uint32(%options<uint32>);
      }

      elsif %options<uint64>:exists {
        $no = _g_variant_new_uint64(%options<uint64>);
      }

      elsif %options<variant>:exists {
        $no = %options<variant>;
        $no .= get-native-object unless $no ~~ N-GVariant;
        $no = _g_variant_new_variant($no);
      }

#`{{
      elsif %options<>:exists {
        $no = _g_variant_new_(%options<>);
      }

}}

      elsif %options<parse>:exists {
        my Gnome::Glib::Error $e;
        ( $no, $e) = _g_variant_parse(|%options);

        die X::Gnome.new(
          :message("\nVariant parse error: $e.message()")
        ) if $e.is-valid;
      }

      elsif %options<value>:exists {
        $no = _g_variant_new( %options<type-string> // '', %options<value>);
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


#`{{
#-------------------------------------------------------------------------------
# TM:0:byteswap:
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
}}
#`{{
#-------------------------------------------------------------------------------
#TM:0:check-format-string:
=begin pod
=head2 check-format-string

Checks if calling C<g_variant_get()> with I<format_string> on I<value> would be valid from a type-compatibility standpoint.  I<format_string> is assumed to be a valid format string (from a syntactic standpoint).  If I<copy_only> is C<1> then this function additionally checks that it would be safe to call C<g_variant_unref()> on I<value> immediately after the call to C<g_variant_get()> without invalidating the result.  This is only possible if deep copies are made (ie: there are no pointers to the data inside of the soon-to-be-freed B<N-GVariant> instance).  If this check fails then a C<g_critical()> is printed and C<0> is returned.  This function is meant to be used by functions that wish to provide varargs accessors to B<N-GVariant> values of uncertain values (eg: C<g_variant_lookup()> or C<g_menu_model_get_item_attribute()>).

Returns: C<1> if I<format_string> is safe to use

  method check-format-string (  Str  $format_string, Int $copy_only --> Int )

=item  Str  $format_string; a valid B<N-GVariant> format string
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
}}
#`{{
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
}}
#`{{
#-------------------------------------------------------------------------------
#TM:0:compare:
=begin pod
=head2 compare

Compares I<one> and I<two>.  The types of I<one> and I<two> are B<gconstpointer> only to allow use of this function with B<GTree>, B<GPtrArray>, etc.  They must each be a B<N-GVariant>.  Comparison is only defined for basic types (ie: booleans, numbers, strings).  For booleans, C<0> is less than C<1>.  Numbers are ordered in the usual way.  Strings are in ASCII lexographical order.  It is a programmer error to attempt to compare container values or two values that have types that are not exactly equal.  For example, you cannot compare a 32-bit signed integer with a 32-bit unsigned integer.  Also note that this function is not particularly well-behaved when it comes to comparison of doubles; in particular, the handling of incomparable values (ie: NaN) is undefined.  If you only require an equality comparison, C<g_variant_equal()> is more general.

Returns: negative value if a < b; zero if a = b; positive value if a > b.

  method compare ( Pointer $one, Pointer $two --> Int )

=item Pointer $one; (type GVariant): a basic-typed B<N-GVariant> instance
=item Pointer $two; (type GVariant): a B<N-GVariant> instance of the same type

=end pod

method compare ( Pointer $one, Pointer $two --> Int ) {

  g_variant_compare(
    self.get-native-object-no-reffing, $one, $two
  );
}

sub g_variant_compare ( gpointer $one, gpointer $two --> gint )
  is native(&glib-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
# TM:0:dup-bytestring:
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
# TM:0:dup-bytestring-array:
=begin pod
=head2 dup-bytestring-array

Gets the contents of an array of array of bytes B<N-GVariant>.  This call makes a deep copy; the return result should be released with C<g_strfreev()>.  If I<length> is non-C<Any> then the number of elements in the result is stored there.  In any case, the resulting array will be C<Any>-terminated.  For an empty array, I<length> will be set to 0 and a pointer to a C<Any> pointer will be returned.

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
# TM:0:dup-objv:
=begin pod
=head2 dup-objv

Gets the contents of an array of object paths B<N-GVariant>.  This call makes a deep copy; the return result should be released with C<g_strfreev()>.  If I<length> is non-C<Any> then the number of elements in the result is stored there.  In any case, the resulting array will be C<Any>-terminated.  For an empty array, I<length> will be set to 0 and a pointer to a C<Any> pointer will be returned.

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
# TM:0:dup-string:
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
# TM:0:dup-strv:
=begin pod
=head2 dup-strv

Gets the contents of an array of strings B<N-GVariant>.  This call makes a deep copy; the return result should be released with C<g_strfreev()>.  If I<length> is non-C<Any> then the number of elements in the result is stored there.  In any case, the resulting array will be C<Any>-terminated.  For an empty array, I<length> will be set to 0 and a pointer to a C<Any> pointer will be returned.

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
}}

#`{{
#-------------------------------------------------------------------------------
#TM:0:equal:
=begin pod
=head2 equal

Checks if I<one> and I<two> have the same type and value.  The types of I<one> and I<two> are B<gconstpointer> only to allow use of this function with B<GHashTable>.  They must each be a B<N-GVariant>.

Returns: C<1> if I<one> and I<two> are equal

  method equal ( Pointer $one, Pointer $two --> Int )

=item Pointer $one; (type GVariant): a B<N-GVariant> instance
=item Pointer $two; (type GVariant): a B<N-GVariant> instance

=end pod

method equal ( Pointer $one, Pointer $two --> Int ) {

  g_variant_equal(
    self.get-native-object-no-reffing, $one, $two
  );
}

sub g_variant_equal ( gpointer $one, gpointer $two --> gboolean )
  is native(&glib-lib)
  { * }
}}
#`{{
#-------------------------------------------------------------------------------
#TM:0:get:
=begin pod
=head2 get

Deconstructs a B<N-GVariant> instance.  Think of this function as an analogue to C<scanf()>.  The arguments that are expected by this function are entirely determined by I<format_string>.  I<format_string> also restricts the permissible types of I<value>.  It is an error to give a value with an incompatible type.  See the section on GVariant format strings. Please note that the syntax of the format string is very likely to be extended in the future.  I<format_string> determines the C types that are used for unpacking the values and also determines if the values are copied or borrowed

  method get (  Str  $format_string )

=item  Str  $format_string; a B<N-GVariant> format string @...: arguments, as per I<format_string>

=end pod

method get (  Str  $format_string ) {

  g_variant_get(
    self.get-native-object-no-reffing, $format_string
  );
}

sub g_variant_get ( N-GVariant $value, gchar-ptr $format_string, Any $any = Any  )
  is native(&glib-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:1:get-boolean:
=begin pod
=head2 get-boolean

Returns the boolean value of I<value>.  It is an error to call this function with a I<value> of any type other than C<G_VARIANT_TYPE_BOOLEAN>.

Returns: C<True> or C<False>

  method get-boolean ( --> Bool )


=end pod

method get-boolean ( --> Bool ) {

  g_variant_get_boolean(
    self.get-native-object-no-reffing,
  ).Bool;
}

sub g_variant_get_boolean ( N-GVariant $value --> gboolean )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:get-byte:
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
#TM:1:get-bytestring:
=begin pod
=head2 get-bytestring

Returns the string value of a B<N-GVariant> instance with an array-of-bytes type.  The string has no particular encoding.

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
#TM:1:get-bytestring-array:
=begin pod
=head2 get-bytestring-array

Gets the contents of an array of array of bytes B<N-GVariant>.

  method get-bytestring-array ( -->  Array[Str]  )

=end pod

method get-bytestring-array ( -->  Array[Str]  ) {

  my CArray[Str] $ai8 = g_variant_get_bytestring_array(
    self.get-native-object-no-reffing, my gsize $length
  );

  my Array[Str] $a .= new;
  for ^$length -> $i {
    $a[$i] = $ai8[$i];
  }

  $a
}

sub g_variant_get_bytestring_array (
  N-GVariant $value, gsize $length is rw --> gchar-pptr
) is native(&glib-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
# TM:0:get-child:
=begin pod
=head2 get-child

Reads a child item out of a container B<N-GVariant> instance and deconstructs it according to I<format_string>.  This call is essentially a combination of C<g_variant_get_child_value()> and C<g_variant_get()>.  I<format_string> determines the C types that are used for unpacking the values and also determines if the values are copied or borrowed, see the section on [GVariant format strings][gvariant-format-strings-pointers].

  method get-child ( UInt $index_,  Str  $format_string )

=item UInt $index_; the index of the child to deconstruct
=item  Str  $format_string; a B<N-GVariant> format string @...: arguments, as per I<format_string>

=end pod

method get-child ( UInt $index_,  Str  $format_string ) {

  g_variant_get_child(
    self.get-native-object-no-reffing, $index_, $format_string
  );
}

sub g_variant_get_child ( N-GVariant $value, gsize $index_, gchar-ptr $format_string, Any $any = Any  )
  is native(&glib-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
# TM:0:get-child-value:
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
}}
#`{{
#-------------------------------------------------------------------------------
# TM:0:get-data:
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
}}

#`{{
#-------------------------------------------------------------------------------
#TM:0:get-data-as-bytes:
=begin pod
=head2 get-data-as-bytes


  method get-data-as-bytes ( --> N-GBytes )


=end pod

method get-data-as-bytes ( --> N-GBytes ) {

  g_variant_get_data_as_bytes(
    self.get-native-object-no-reffing,
  );
}

sub g_variant_get_data_as_bytes ( N-GVariant $value --> N-GBytes )
  is native(&glib-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:1:get-double:
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

#`{{
#-------------------------------------------------------------------------------
# TM:0:get-fixed-array:
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
}}
#`{{
#-------------------------------------------------------------------------------
# TM:0:get-handle:
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
}}

#-------------------------------------------------------------------------------
#TM:1:get-int16:
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
#TM:1:get-int32:
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
#TM:1:get-int64:
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

#`{{
#-------------------------------------------------------------------------------
#TM:0:get-maybe:
=begin pod
=head2 get-maybe

Given a maybe-typed B<N-GVariant> instance, extract its value.  If the value is Nothing, then this function returns C<Any>.

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
}}
#`{{
#-------------------------------------------------------------------------------
# TM:0:get-normal-form:
=begin pod
=head2 get-normal-form

Gets a B<N-GVariant> instance that has the same value as I<value> and is trusted to be in normal form.  If I<value> is already trusted to be in normal form then a new reference to I<value> is returned.  If I<value> is not already trusted, then it is scanned to check if it is in normal form.  If it is found to be in normal form then it is marked as trusted and a new reference to it is returned.  If I<value> is found not to be in normal form then a new trusted B<N-GVariant> is created with the same value as I<value>.  It makes sense to call this function if you've received B<N-GVariant> data from untrusted sources and you want to ensure your serialised output is definitely in normal form.  If I<value> is already in normal form, a new reference will be returned (which will be floating if I<value> is floating). If it is not in normal form, the newly created B<N-GVariant> will be returned with a single non-floating reference. Typically, C<g_variant_take_ref()> should be called on the return value from this function to guarantee ownership of a single non-floating reference to it.

Returns: (transfer full): a trusted B<N-GVariant>

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
}}
#`{{
#-------------------------------------------------------------------------------
# TM:0:get-objv:
=begin pod
=head2 get-objv

Gets the contents of an array of object paths B<N-GVariant>.  This call makes a shallow copy; the return result should be released with C<g_free()>, but the individual strings must not be modified.  If I<length> is non-C<Any> then the number of elements in the result is stored there.  In any case, the resulting array will be C<Any>-terminated.  For an empty array, I<length> will be set to 0 and a pointer to a C<Any> pointer will be returned.

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
}}
#`{{
#-------------------------------------------------------------------------------
# TM:0:get-size:
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
}}

#-------------------------------------------------------------------------------
#TM:1:get-string:
=begin pod
=head2 get-string

Returns the string value of a B<N-GVariant> instance with a string type.

  method get-string ( -->  Str  )

=end pod

method get-string ( -->  Str  ) {

  my Str $s = g_variant_get_string(
    self.get-native-object-no-reffing, my gsize $length
  );

  $s
}

sub g_variant_get_string (
  N-GVariant $value, gsize $length is rw --> gchar-ptr
) is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:get-strv:
=begin pod
=head2 get-strv

Gets the contents of an array of strings B<N-GVariant>. This call makes a shallow copy.

  method get-strv ( --> Array[Str]  )

=end pod

method get-strv ( --> Array[Str]  ) {

  my CArray[Str] $astr = g_variant_get_strv(
    self.get-native-object-no-reffing, my gsize $length
  );

  my Array[Str] $a .= new;
  for ^$length -> $i {
    $a[$i] = $astr[$i];
  }

  $a
}

sub g_variant_get_strv ( N-GVariant $value, gsize $length is rw --> gchar-pptr )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:get-type:
=begin pod
=head2 get-type

Determines the type of I<value>.  The return value is valid for the lifetime of I<value> and must not be freed.

Returns: a B<GVariantType>

  method get-type ( --> Gnome::Glib::Variant )


=end pod

method get-type ( --> Gnome::Glib::VariantType ) {

  Gnome::Glib::VariantType.new(
    :native-object(g_variant_get_type(self.get-native-object-no-reffing))
  );
}

sub g_variant_get_type ( N-GVariant $value --> N-GVariantType )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:get-type-string:
=begin pod
=head2 get-type-string

Returns the type string of I<value>.  Unlike the result of calling C<g_variant_type_peek_string()>, this string is nul-terminated.  This string belongs to B<N-GVariant> and must not be freed.

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
#TM:1:get-uint16:
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
#TM:1:get-uint32:
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
#TM:1:get-uint64:
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

#`{{
#-------------------------------------------------------------------------------
# TM:0:get-va:
=begin pod
=head2 get-va

This function is intended to be used by libraries based on B<N-GVariant> that want to provide C<g_variant_get()>-like functionality to their users.  The API is more general than C<g_variant_get()> to allow a wider range of possible uses.  I<format_string> must still point to a valid format string, but it only need to be nul-terminated if I<endptr> is C<Any>.  If I<endptr> is non-C<Any> then it is updated to point to the first character past the end of the format string.  I<app> is a pointer to a B<va_list>.  The arguments, according to I<format_string>, are collected from this B<va_list> and the list is left pointing to the argument following the last.  These two generalisations allow mixing of multiple calls to C<g_variant_new_va()> and C<g_variant_get_va()> within a single actual varargs call by the user.  I<format_string> determines the C types that are used for unpacking the values and also determines if the values are copied or borrowed, see the section on [GVariant format strings][gvariant-format-strings-pointers].

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
}}

#-------------------------------------------------------------------------------
#TM:1:get-variant:
=begin pod
=head2 get-variant

Unboxes I<value>. The result is the B<Gnome::Glib::Variant> that was contained in I<value>.

Returns: the item contained in the variant

  method get-variant ( --> Gnome::Glib::Variant )


=end pod

method get-variant ( --> Gnome::Glib::Variant ) {

  Gnome::Glib::Variant.new(
    :native-object(g_variant_get_variant(self.get-native-object-no-reffing))
  );
}

sub g_variant_get_variant ( N-GVariant $value --> N-GVariant )
  is native(&glib-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
# TM:0:hash:
=begin pod
=head2 hash

Generates a hash value for a B<N-GVariant> instance.  The output of this function is guaranteed to be the same for a given value only per-process.  It may change between different processor architectures or even different versions of GLib.  Do not use this function as a basis for building protocols or file formats.  The type of I<value> is B<gconstpointer> only to allow use of this function with B<GHashTable>.  I<value> must be a B<N-GVariant>.

Returns: a hash value corresponding to I<value>

  method hash ( Pointer $value --> UInt )

=item Pointer $value; (type GVariant): a basic B<N-GVariant> value as a B<gconstpointer>

=end pod

method hash ( Pointer $value --> UInt ) {

  g_variant_hash(
    self.get-native-object-no-reffing, $value
  );
}

sub g_variant_hash ( gpointer $value --> guint )
  is native(&glib-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:1:is-container:
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

#`{{
#-------------------------------------------------------------------------------
# TM:0:is-floating:
=begin pod
=head2 is-floating



  method is-floating ( --> Int )


=end pod

method is-floating ( --> Int ) {

  g_variant_is_floating(
    self.get-native-object-no-reffing,
  );
}

sub g_variant_is_floating ( N-GVariant $value --> gboolean )
  is native(&glib-lib)
  { * }
}}
#`{{
#-------------------------------------------------------------------------------
# TM:0:is-normal-form:
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
}}
#`{{
#-------------------------------------------------------------------------------
# TM:0:is-object-path:
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
}}

#-------------------------------------------------------------------------------
#TM:1:is-of-type:
=begin pod
=head2 is-of-type

Checks if a value has a type matching the provided type.

Returns: C<True> if the type of I<value> matches I<type>

  method is-of-type ( N-GVariantType $type --> Bool )

=item N-GVariantType $type; a B<GVariantType>

=end pod

method is-of-type ( $type --> Bool ) {
  my $no = $type;
  $no .= get-native-object-no-reffing unless $no ~~ N-GVariantType;

  g_variant_is_of_type(
    self.get-native-object-no-reffing, $no
  ).Bool;
}

sub g_variant_is_of_type ( N-GVariant $value, N-GVariantType $type --> gboolean )
  is native(&glib-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
# TM:0:is-signature:
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
}}

#`{{
#-------------------------------------------------------------------------------
#TM:0:lookup:
=begin pod
=head2 lookup

Looks up a value in a dictionary B<N-GVariant>.  This function is a wrapper around C<g_variant_lookup_value()> and C<g_variant_get()>.  In the case that C<Any> would have been returned, this function returns C<0>.  Otherwise, it unpacks the returned value and returns C<1>.  I<format_string> determines the C types that are used for unpacking the values and also determines if the values are copied or borrowed, see the section on [GVariant format strings][gvariant-format-strings-pointers].  This function is currently implemented with a linear scan.  If you plan to do many lookups then B<N-GVariantDict> may be more efficient.

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
}}

#`{{

#-------------------------------------------------------------------------------
# TM:0:lookup-value:
=begin pod
=head2 lookup-value

Looks up a value in a dictionary B<N-GVariant>. This function works with dictionaries of the type a{s*} (and equally well with type a{o*}, but we only further discuss the string case for sake of clarity). In the event that I<dictionary> has the type a{sv}, the I<expected_type> string specifies what type of value is expected to be inside of the variant. If the value inside the variant has a different type then undefined is returned. In the event that I<dictionary> has a value type other than v then I<expected_type> must directly match the value type and it is used to unpack the value directly or an error occurs.  In either case, if I<key> is not found in I<dictionary>, C<Any> is returned.  If the key is found and the value has the correct type, it is returned.  If I<expected_type> was specified then any non-C<Any> return value will have this type.  This function is currently implemented with a linear scan.  If you plan to do many lookups then B<N-GVariantDict> may be more efficient.

Returns: (transfer full): the value of the dictionary key, or C<Any>

  method lookup-value (  Str  $key, N-GVariantType $expected_type --> N-GVariant )

=item  Str  $key; the key to lookup in the dictionary
=item N-GVariantType $expected_type; (nullable): a B<GVariantType>, or C<Any>

=end pod

method lookup-value (
  Str $key, N-GVariantType $expected_type --> N-GVariant
) {
  my $no = $expected_type;
  $no .= get-native-object-no-reffing unless $no ~~ N-GVariantType;

  g_variant_lookup_value(
    self.get-native-object-no-reffing, $key, $no
  );
}

sub g_variant_lookup_value (
  N-GVariant $dictionary, gchar-ptr $key, N-GVariantType $expected_type
  --> N-GVariant
) is native(&glib-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
# TM:0:n-children:
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
}}

#-------------------------------------------------------------------------------
#TM:1:_g_variant_parse:
#`{{
=begin pod
=head2 parse

Parses a GVariant from a text representation.

In the event that the parsing is successful, the resulting GVariant is returned.

In case of any error, NULL will be returned. If error is non-NULL then it will be set to reflect the error that occurred.

There may be implementation specific restrictions on deeply nested values, which would result in a G_VARIANT_PARSE_ERROR_RECURSION error. GVariant is guaranteed to handle nesting up to at least 64 levels.

  method g_variant_parse ( Str $type-string, Str $text --> List )

=item Str $type-string; String like it is used to create a Gnome::Glib::VariantType. May be undefined.
=item Str $text; Textual representation of data.

The returned List has members
=item N-GVariant object. A native variant object
=item Gnome::Glib::Error. The error object. Test for C<.is-valid() ~~ False> to see if parsing went ok and that the variant object is defined.

=end pod
}}

sub _g_variant_parse ( Str :$type-string = '', Str:D :$parse --> List ) {

  my N-GVariantType $nvt;
  if ?$type-string {
    $nvt = Gnome::Glib::VariantType.new(
      :$type-string
    ).get-native-object-no-reffing;
  }

  else {
    $nvt = N-GVariantType;
  }

  my Gnome::Glib::Error $parse-error;
  my CArray[N-GError] $ne .= new(N-GError);
  my N-GVariant $v = g_variant_parse( $nvt, $parse, Str, gchar-pptr, $ne);

  if ?$v {
    $parse-error = Gnome::Glib::Error.new(:native-object(N-GError))
  }

  else {
    $parse-error = Gnome::Glib::Error.new(:native-object($ne[0]))
  }

  ( $v, $parse-error)
}

sub g_variant_parse (
  N-GVariantType $type, gchar-ptr $text, gchar-ptr $limit,
  gchar-pptr $endptr, CArray[N-GError] $error --> N-GVariant
) is native(&glib-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
# TM:0:parse-error-print-context:
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
}}
#`{{
#-------------------------------------------------------------------------------
# TM:0:parse-error-quark:
=begin pod
=head2 parse-error-quark

Error domain for GVariant text format parsing. Specific error codes are not currently defined for this domain. See GError for information on error

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
}}

#-------------------------------------------------------------------------------
#TM:1:print:
=begin pod
=head2 print

Pretty-prints I<value> in the format understood by C<parse()>. If I<$type_annotate> is C<True>, then type information is included in the output.

Returns: a newly-allocated string holding the result.

  method print ( Bool $type_annotate = False --> Str )

=item Int $type_annotate; C<True> if type information should be included in the output

=end pod

method print ( Bool $type_annotate = False --> Str ) {

  g_variant_print(
    self.get-native-object-no-reffing, $type_annotate.Int
  );
}

sub g_variant_print ( N-GVariant $value, gboolean $type_annotate --> gchar-ptr )
  is native(&glib-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
# TM:0:print-string:
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
}}

#-------------------------------------------------------------------------------
#TM:1:_g_variant_ref:
sub _g_variant_ref ( N-GVariant $value --> N-GVariant )
  is native(&glib-lib)
  is symbol('g_variant_ref')
  { * }

#`{{
#-------------------------------------------------------------------------------
#TM:0:ref-sink:
=begin pod
=head2 ref-sink

  method ref-sink ( --> N-GVariant )


=end pod

method ref-sink ( --> N-GVariant ) {

  g_variant_ref_sink(
    self.get-native-object-no-reffing,
  );
}

sub g_variant_ref_sink ( N-GVariant $value --> N-GVariant )
  is native(&glib-lib)
  { * }
}}
#`{{
#-------------------------------------------------------------------------------
# TM:0:store:
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
}}
#`{{
#-------------------------------------------------------------------------------
#TM:0:take-ref:
=begin pod
=head2 take-ref

  method take-ref ( --> N-GVariant )

=end pod

method take-ref ( --> N-GVariant ) {

  g_variant_take_ref(
    self.get-native-object-no-reffing,
  );
}

sub g_variant_take_ref ( N-GVariant $value --> N-GVariant )
  is native(&glib-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:1:_g_variant_unref:
sub _g_variant_unref ( N-GVariant $value  )
  is native(&glib-lib)
  is symbol('g_variant_unref')
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

#sub _g_variant_new ( gchar-ptr $format_string, Any $any = Any --> N-GVariant )
#  is native(&glib-lib)
#  is symbol('g_variant_new')
#  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_variant_new_array:
#`{{
=begin pod
=head2 _g_variant_new_array

Creates a new B<N-GVariant> array from I<children>.  I<child_type> must be non-C<Any> if I<n_children> is zero.  Otherwise, the child type is determined by inspecting the first element of the I<children> array.  If I<child_type> is non-C<Any> then it must be a definite type.  The items of the array are taken from the I<children> array.  No entry in the I<children> array may be C<Any>.  All items in the array must have the same type, which must be the same as I<child_type>, if given.  If the I<children> are floating references (see C<g_variant_ref_sink()>), the new instance takes ownership of them as if via C<g_variant_ref_sink()>.

Returns: (transfer none): a floating reference to a new B<N-GVariant> array

  method _g_variant_new_array ( N-GVariantType $child_type,  $GVariant * const *children, UInt $n_children --> N-GVariant )

=item N-GVariantType $child_type; (nullable): the element type of the new array
=item  $GVariant * const *children; (nullable) (array length=n_children): an array of B<N-GVariant> pointers, the children
=item UInt $n_children; the length of I<children>

=end pod
}}

sub _g_variant_new_array (
  N-GVariantType $child_type, CArray[N-GVariant] $children,
  gsize $n_children --> N-GVariant
) is native(&glib-lib)
  is symbol('g_variant_new_array')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_variant_new_boolean:
#`{{
=begin pod
=head2 _g_variant_new_boolean

Creates a new boolean B<N-GVariant> instance -- either C<1> or C<0>.

Returns: (transfer none): a floating reference to a new boolean B<N-GVariant> instance

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

Creates a new byte B<N-GVariant> instance.

Returns: (transfer none): a floating reference to a new byte B<N-GVariant> instance

  method _g_variant_new_byte ( UInt $value --> N-GVariant )

=item UInt $value; a B<guint8> value

=end pod
}}

sub _g_variant_new_byte ( guint8 $value --> N-GVariant )
  is native(&glib-lib)
  is symbol('g_variant_new_byte')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_variant_new_bytestring:
#`{{
=begin pod
=head2 _g_variant_new_bytestring

Creates an array-of-bytes B<N-GVariant> with the contents of I<string>. This function is just like C<g_variant_new_string()> except that the string need not be valid UTF-8.  The nul terminator character at the end of the string is stored in the array.

Returns: (transfer none): a floating reference to a new bytestring B<N-GVariant> instance

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

Constructs an array of bytestring B<N-GVariant> from the given array of strings.  If I<length> is -1 then I<strv> is C<Any>-terminated.

Returns: (transfer none): a new floating B<N-GVariant> instance

  method _g_variant_new_bytestring_array (  CArray[Str]  $strv, Int $length --> N-GVariant )

=item  CArray[Str]  $strv; (array length=length): an array of strings
=item Int $length; the length of I<strv>, or -1

=end pod
}}

sub _g_variant_new_bytestring_array (
  gchar-pptr $strv, gssize $length --> N-GVariant
) is native(&glib-lib)
  is symbol('g_variant_new_bytestring_array')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_variant_new_dict_entry:
#`{{

=begin pod
=head2 dict-entry

Creates a new dictionary entry B<Gnome::Glib::VariantDict>. I<key> and I<value> must be defined. I<key> must be a value of a basic type (ie: not a container).

=comment  If the I<key> or I<value> are floating references (see C<g_variant_ref_sink()>), the new instance takes ownership of them as if via C<g_variant_ref_sink()>.

Returns: a floating reference to a new dictionary entry B<Gnome::Glib::VariantDict>

  method _g_variant_new_dict_entry ( N-GVariant $key, N-GVariant $value --> N-GVariant )

=item N-GVariant $value; a B<Gnome::Glib::VariantDict>, the value

=end pod
}}

sub _g_variant_new_dict_entry (
  N-GVariant $key, N-GVariant $value --> N-GVariant
) is native(&glib-lib)
  is symbol('g_variant_new_dict_entry')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_variant_new_double:
#`{{
=begin pod
=head2 _g_variant_new_double

Creates a new double B<N-GVariant> instance.

Returns: (transfer none): a floating reference to a new double B<N-GVariant> instance

  method _g_variant_new_double ( Num $value --> N-GVariant )

=item Num $value; a B<gdouble> floating point value

=end pod
}}

sub _g_variant_new_double ( gdouble $value --> N-GVariant )
  is native(&glib-lib)
  is symbol('g_variant_new_double')
  { * }

#`{{
#-------------------------------------------------------------------------------
# TM:1:_g_variant_new_fixed_array:
#`{{
=begin pod
=head2 _g_variant_new_fixed_array

Constructs a new array B<N-GVariant> instance, where the elements are of I<element_type> type.  I<elements> must be an array with fixed-sized elements.  Numeric types are fixed-size as are tuples containing only other fixed-sized types.  I<element_size> must be the size of a single element in the array. For example, if calling this function for an array of 32-bit integers, you might say sizeof(gint32). This value isn't used except for the purpose of a double-check that the form of the serialised data matches the caller's expectation.  I<n_elements> must be the length of the I<elements> array.

Returns: (transfer none): a floating reference to a new array B<N-GVariant> instance

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
}}

#`{{
#-------------------------------------------------------------------------------
# TM:1:_g_variant_new_from_bytes:
#`{{
=begin pod
=head2 _g_variant_new_from_bytes



  method _g_variant_new_from_bytes ( N-GVariantType $type, N-GBytes $bytes, Int $trusted --> N-GVariant )

=item N-GVariantType $type;
=item N-GObject $bytes;
=item Int $trusted;

=end pod
}}

sub _g_variant_new_from_bytes ( N-GVariantType $type, N-GBytes $bytes, gboolean $trusted --> N-GVariant )
  is native(&glib-lib)
  is symbol('g_variant_new_from_bytes')
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
# TM:1:_g_variant_new_from_data:
#`{{
=begin pod
=head2 _g_variant_new_from_data

Creates a new B<N-GVariant> instance from serialised data.  I<type> is the type of B<N-GVariant> instance that will be constructed. The interpretation of I<data> depends on knowing the type.  I<data> is not modified by this function and must remain valid with an unchanging value until such a time as I<notify> is called with I<user_data>.  If the contents of I<data> change before that time then the result is undefined.  If I<data> is trusted to be serialised data in normal form then I<trusted> should be C<1>.  This applies to serialised data created within this process or read from a trusted location on the disk (such as a file installed in /usr/lib alongside your application).  You should set trusted to C<0> if I<data> is read from the network, a file in the user's home directory, etc.  If I<data> was not stored in this machine's native endianness, any multi-byte numeric values in the returned variant will also be in non-native endianness. C<g_variant_byteswap()> can be used to recover the original values.  I<notify> will be called with I<user_data> when I<data> is no longer needed.  The exact time of this call is unspecified and might even be before this function returns.  Note: I<data> must be backed by memory that is aligned appropriately for the I<type> being loaded. Otherwise this function will internally create a copy of the memory (since GLib 2.60) or (in older versions) fail and exit the process.

Returns: (transfer none): a new floating B<N-GVariant> of type I<type>

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
}}

#`{{
#-------------------------------------------------------------------------------
# TM:1:_g_variant_new_handle:
#`{{
=begin pod
=head2 _g_variant_new_handle

Creates a new handle B<N-GVariant> instance.  By convention, handles are indexes into an array of file descriptors that are sent alongside a D-Bus message.  If you're not interacting with D-Bus, you probably don't need them.

Returns: (transfer none): a floating reference to a new handle B<N-GVariant> instance

  method _g_variant_new_handle ( Int $value --> N-GVariant )

=item Int $value; a B<gint32> value

=end pod
}}

sub _g_variant_new_handle ( gint32 $value --> N-GVariant )
  is native(&glib-lib)
  is symbol('g_variant_new_handle')
  { * }
}}

#-------------------------------------------------------------------------------
#TM:1:_g_variant_new_int16:
#`{{
=begin pod
=head2 _g_variant_new_int16

Creates a new int16 B<N-GVariant> instance.

Returns: (transfer none): a floating reference to a new int16 B<N-GVariant> instance

  method _g_variant_new_int16 ( Int $value --> N-GVariant )

=item Int $value; a B<gint16> value

=end pod
}}

sub _g_variant_new_int16 ( gint16 $value --> N-GVariant )
  is native(&glib-lib)
  is symbol('g_variant_new_int16')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_variant_new_int32:
#`{{
=begin pod
=head2 _g_variant_new_int32

Creates a new int32 B<N-GVariant> instance.

Returns: (transfer none): a floating reference to a new int32 B<N-GVariant> instance

  method _g_variant_new_int32 ( Int $value --> N-GVariant )

=item Int $value; a B<gint32> value

=end pod
}}

sub _g_variant_new_int32 ( gint32 $value --> N-GVariant )
  is native(&glib-lib)
  is symbol('g_variant_new_int32')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_variant_new_int64:
#`{{
=begin pod
=head2 _g_variant_new_int64

Creates a new int64 B<N-GVariant> instance.

Returns: (transfer none): a floating reference to a new int64 B<N-GVariant> instance

  method _g_variant_new_int64 ( Int $value --> N-GVariant )

=item Int $value; a B<gint64> value

=end pod
}}

sub _g_variant_new_int64 ( gint64 $value --> N-GVariant )
  is native(&glib-lib)
  is symbol('g_variant_new_int64')
  { * }

#`{{
#-------------------------------------------------------------------------------
# TM:1:_g_variant_new_maybe:
#`{{
=begin pod
=head2 _g_variant_new_maybe

Depending on if I<child> is C<Any>, either wraps I<child> inside of a maybe container or creates a Nothing instance for the given I<type>.  At least one of I<child_type> and I<child> must be non-C<Any>. If I<child_type> is non-C<Any> then it must be a definite type. If they are both non-C<Any> then I<child_type> must be the type of I<child>.  If I<child> is a floating reference (see C<g_variant_ref_sink()>), the new instance takes ownership of I<child>.

Returns: (transfer none): a floating reference to a new B<N-GVariant> maybe instance

  method _g_variant_new_maybe ( N-GVariantType $child_type, N-GVariant $child --> N-GVariant )

=item N-GVariantType $child_type; (nullable): the B<GVariantType> of the child, or C<Any>
=item N-GVariant $child; (nullable): the child value, or C<Any>

=end pod
}}

sub _g_variant_new_maybe ( N-GVariantType $child_type, N-GVariant $child --> N-GVariant )
  is native(&glib-lib)
  is symbol('g_variant_new_maybe')
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
# TM:1:_g_variant_new_object_path:
#`{{
=begin pod
=head2 _g_variant_new_object_path

Creates a D-Bus object path B<N-GVariant> with the contents of I<string>. I<string> must be a valid D-Bus object path.  Use C<g_variant_is_object_path()> if you're not sure.

Returns: (transfer none): a floating reference to a new object path B<N-GVariant> instance

  method _g_variant_new_object_path (  Str  $object_path --> N-GVariant )

=item  Str  $object_path; a normal C nul-terminated string

=end pod
}}

sub _g_variant_new_object_path ( gchar-ptr $object_path --> N-GVariant )
  is native(&glib-lib)
  is symbol('g_variant_new_object_path')
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
# TM:1:_g_variant_new_objv:
#`{{
=begin pod
=head2 _g_variant_new_objv

Constructs an array of object paths B<N-GVariant> from the given array of strings.  Each string must be a valid B<N-GVariant> object path; see C<g_variant_is_object_path()>.  If I<length> is -1 then I<strv> is C<Any>-terminated.

Returns: (transfer none): a new floating B<N-GVariant> instance

  method _g_variant_new_objv (  CArray[Str]  $strv, Int $length --> N-GVariant )

=item  CArray[Str]  $strv; (array length=length) (element-type utf8): an array of strings
=item Int $length; the length of I<strv>, or -1

=end pod
}}

sub _g_variant_new_objv ( gchar-pptr $strv, gssize $length --> N-GVariant )
  is native(&glib-lib)
  is symbol('g_variant_new_objv')
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
# TM:1:_g_variant_new_parsed:
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
}}

#`{{
#-------------------------------------------------------------------------------
# TM:1:_g_variant_new_parsed_va:
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
}}

#`{{
#-------------------------------------------------------------------------------
# TM:1:_g_variant_new_printf:
#`{{
=begin pod
=head2 _g_variant_new_printf

Creates a string-type GVariant using printf formatting.  This is similar to calling C<g_strdup_printf()> and then C<g_variant_new_string()> but it saves a temporary variable and an unnecessary copy.

Returns: (transfer none): a floating reference to a new string B<N-GVariant> instance

  method _g_variant_new_printf (  Str  $format_string,  $2 --> N-GVariant )

=item  Str  $format_string; a printf-style format string @...: arguments for I<format_string>
=item  $2;

=end pod
}}

sub _g_variant_new_printf ( gchar-ptr $format_string, Any $any = Any,  $2 --> N-GVariant )
  is native(&glib-lib)
  is symbol('g_variant_new_printf')
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
#TM:0:_g_variant_new_signature:
#`{{
=begin pod
=head2 _g_variant_new_signature

Creates a D-Bus type signature B<N-GVariant> with the contents of I<string>.  I<string> must be a valid D-Bus type signature.  Use C<g_variant_is_signature()> if you're not sure.

Returns: (transfer none): a floating reference to a new signature B<N-GVariant> instance

  method _g_variant_new_signature (  Str  $signature --> N-GVariant )

=item  Str  $signature; a normal C nul-terminated string

=end pod
}}

sub _g_variant_new_signature ( gchar-ptr $signature --> N-GVariant )
  is native(&glib-lib)
  is symbol('g_variant_new_signature')
  { * }
}}

#-------------------------------------------------------------------------------
#TM:1:_g_variant_new_string:
#`{{
=begin pod
=head2 _g_variant_new_string

Creates a string B<N-GVariant> with the contents of I<string>.  I<string> must be valid UTF-8, and must not be C<Any>. To encode potentially-C<Any> strings, use C<g_variant_new()> with `ms` as the [format string][gvariant-format-strings-maybe-types].

Returns: (transfer none): a floating reference to a new string B<N-GVariant> instance

  method _g_variant_new_string (  Str  $string --> N-GVariant )

=item  Str  $string; a normal UTF-8 nul-terminated string

=end pod
}}

sub _g_variant_new_string ( gchar-ptr $string --> N-GVariant )
  is native(&glib-lib)
  is symbol('g_variant_new_string')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_variant_new_strv:
#`{{
=begin pod
=head2 _g_variant_new_strv

Constructs an array of strings B<N-GVariant> from the given array of strings.  If I<length> is -1 then I<strv> is C<Any>-terminated.

Returns: (transfer none): a new floating B<N-GVariant> instance

  method _g_variant_new_strv (  CArray[Str]  $strv, Int $length --> N-GVariant )

=item  CArray[Str]  $strv; (array length=length) (element-type utf8): an array of strings
=item Int $length; the length of I<strv>, or -1

=end pod
}}

sub _g_variant_new_strv ( gchar-pptr $strv, gssize $length --> N-GVariant )
  is native(&glib-lib)
  is symbol('g_variant_new_strv')
  { * }

#`{{
#-------------------------------------------------------------------------------
# TM:1:_g_variant_new_take_string:
#`{{
=begin pod
=head2 _g_variant_new_take_string

Creates a string B<N-GVariant> with the contents of I<string>.  I<string> must be valid UTF-8, and must not be C<Any>. To encode potentially-C<Any> strings, use this with C<g_variant_new_maybe()>.  This function consumes I<string>.  C<g_free()> will be called on I<string> when it is no longer required.  You must not modify or access I<string> in any other way after passing it to this function.  It is even possible that I<string> is immediately freed.

Returns: (transfer none): a floating reference to a new string B<N-GVariant> instance

  method _g_variant_new_take_string (  Str  $string --> N-GVariant )

=item  Str  $string; a normal UTF-8 nul-terminated string

=end pod
}}

sub _g_variant_new_take_string ( gchar-ptr $string --> N-GVariant )
  is native(&glib-lib)
  is symbol('g_variant_new_take_string')
  { * }
}}

#-------------------------------------------------------------------------------
#TM:1:_g_variant_new_tuple:
#`{{
=begin pod
=head2 _g_variant_new_tuple

Creates a new tuple B<N-GVariant> out of the items in I<children>.  The type is determined from the types of I<children>.  No entry in the I<children> array may be C<Any>.  If I<n_children> is 0 then the unit tuple is constructed.  If the I<children> are floating references (see C<g_variant_ref_sink()>), the new instance takes ownership of them as if via C<g_variant_ref_sink()>.

Returns: (transfer none): a floating reference to a new B<N-GVariant> tuple

  method _g_variant_new_tuple (  $GVariant * const *children, UInt $n_children --> N-GVariant )

=item  $GVariant * const *children; (array length=n_children): the items to make the tuple out of
=item UInt $n_children; the length of I<children>

=end pod
}}

sub _g_variant_new_tuple ( CArray[N-GVariant] $children, gsize $n_children --> N-GVariant )
  is native(&glib-lib)
  is symbol('g_variant_new_tuple')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_variant_new_uint16:
#`{{
=begin pod
=head2 _g_variant_new_uint16

Creates a new uint16 B<N-GVariant> instance.

Returns: (transfer none): a floating reference to a new uint16 B<N-GVariant> instance

  method _g_variant_new_uint16 ( UInt $value --> N-GVariant )

=item UInt $value; a B<guint16> value

=end pod
}}

sub _g_variant_new_uint16 ( guint16 $value --> N-GVariant )
  is native(&glib-lib)
  is symbol('g_variant_new_uint16')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_variant_new_uint32:
#`{{
=begin pod
=head2 _g_variant_new_uint32

Creates a new uint32 B<N-GVariant> instance.

Returns: (transfer none): a floating reference to a new uint32 B<N-GVariant> instance

  method _g_variant_new_uint32 ( UInt $value --> N-GVariant )

=item UInt $value; a B<guint32> value

=end pod
}}

sub _g_variant_new_uint32 ( guint32 $value --> N-GVariant )
  is native(&glib-lib)
  is symbol('g_variant_new_uint32')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_variant_new_uint64:
#`{{
=begin pod
=head2 _g_variant_new_uint64

Creates a new uint64 B<N-GVariant> instance.

Returns: (transfer none): a floating reference to a new uint64 B<N-GVariant> instance

  method _g_variant_new_uint64 ( UInt $value --> N-GVariant )

=item UInt $value; a B<guint64> value

=end pod
}}

sub _g_variant_new_uint64 ( guint64 $value --> N-GVariant )
  is native(&glib-lib)
  is symbol('g_variant_new_uint64')
  { * }

#`{{
#-------------------------------------------------------------------------------
# TM:1:_g_variant_new_va:
#`{{
=begin pod
=head2 _g_variant_new_va

This function is intended to be used by libraries based on B<N-GVariant> that want to provide C<g_variant_new()>-like functionality to their users.  The API is more general than C<g_variant_new()> to allow a wider range of possible uses.  I<format_string> must still point to a valid format string, but it only needs to be nul-terminated if I<endptr> is C<Any>.  If I<endptr> is non-C<Any> then it is updated to point to the first character past the end of the format string.  I<app> is a pointer to a B<va_list>.  The arguments, according to I<format_string>, are collected from this B<va_list> and the list is left pointing to the argument following the last.  Note that the arguments in I<app> must be of the correct width for their types specified in I<format_string> when collected into the B<va_list>. See the [GVariant varargs documentation][gvariant-varargs].  These two generalisations allow mixing of multiple calls to C<g_variant_new_va()> and C<g_variant_get_va()> within a single actual varargs call by the user.  The return value will be floating if it was a newly created GVariant instance (for example, if the format string was "(ii)").  In the case that the format_string was '*', '?', 'r', or a format starting with '@' then the collected B<N-GVariant> pointer will be returned unmodified, without adding any additional references.  In order to behave correctly in all cases it is necessary for the calling function to C<g_variant_ref_sink()> the return result before returning control to the user that originally provided the pointer. At this point, the caller will have their own full reference to the result.  This can also be done by adding the result to a container, or by passing it to another C<g_variant_new()> call.

Returns: a new, usually floating, B<N-GVariant>

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
}}

#-------------------------------------------------------------------------------
#TM:1:_g_variant_new_variant:
#`{{
=begin pod
=head2 _g_variant_new_variant

Boxes I<value>.  The result is a B<N-GVariant> instance representing a variant containing the original value.  If I<child> is a floating reference (see C<g_variant_ref_sink()>), the new instance takes ownership of I<child>.

Returns: (transfer none): a floating reference to a new variant B<N-GVariant> instance

  method _g_variant_new_variant ( --> N-GVariant )


=end pod
}}

sub _g_variant_new_variant ( N-GVariant $value --> N-GVariant )
  is native(&glib-lib)
  is symbol('g_variant_new_variant')
  { * }
