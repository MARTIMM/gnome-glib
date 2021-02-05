use v6;
#use lib '../gnome-native/lib';
use NativeCall;
use Test;

use Gnome::N::N-GVariant;
use Gnome::Glib::Variant;
use Gnome::Glib::VariantType;

#-------------------------------------------------------------------------------
my Gnome::Glib::VariantType $vt;
my Gnome::Glib::Variant $v;

#-------------------------------------------------------------------------------
subtest 'ISA test', {
  $v .= new(:native-object(N-GVariant));
  isa-ok $v, Gnome::Glib::Variant, '.new(:native-object)';
  nok $v.is-valid, 'undefined obj not valid';

  $v .= new( :type-string<u>, :value(40));
  ok $v.is-valid, 'valid object';
  is $v.get-type-string, 'u', '.new( :type-string<u>, :value)';
  $v.clear-object;
}

#-------------------------------------------------------------------------------
subtest 'Other init steps', {

  # 'ai' = array of signed int32
  my Array $array = [];
  $array.push: Gnome::Glib::Variant.new( :type-string<i>, :value(40));
  $array.push: Gnome::Glib::Variant.new( :type-string<i>, :value(42));
  $v .= new(:$array);
  is $v.get-type-string, 'ai', '.new(:array)';
  $v.clear-object;

  # 'b' = boolean
  $v .= new(:boolean);
  is $v.get-type-string, 'b', '.new(:boolean)';
  $v.clear-object;

  # 'y' = byte
  $v .= new(:byte(0xfa));
  is $v.get-type-string, 'y', '.new(:byte)';
  $v.clear-object;

  # 'ay' = byte-string
  $v .= new(:byte-string<abcdef>);
  is $v.get-type-string, 'ay', '.new(:byte-string)';
  $v.clear-object;

  # 'aay' = byte-string-array
  $v .= new(:byte-string-array([<abc def ghi>]));
  is $v.get-type-string, 'aay', '.new(:byte-string-array)';
  $v.clear-object;

  # 'd' = double
  $v .= new(:double(10.2));
  is $v.get-type-string, 'd', '.new(:double)';
  $v.clear-object;

  # 'n' = int16
  $v .= new(:int16(0x2f05));
  is $v.get-type-string, 'n', '.new(:int16)';
  $v.clear-object;

  # 'i' = int32
  $v .= new(:int32(0x2f05002a));
  is $v.get-type-string, 'i', '.new(:int32)';
  $v.clear-object;

  # 'x' = int64
  $v .= new(:int64(0x2f05002a_2f05002a));
  is $v.get-type-string, 'x', '.new(:int64)';
  $v.clear-object;

  # 's' = string
  $v .= new(:string('asjemenou zeg!'));
  is $v.get-type-string, 's', '.new(:string)';
  $v.clear-object;

  # 'as' = string array
  $v .= new(:strv([<abc def ghi αβ ⓒ™⅔>]));
  is $v.get-type-string, 'as', '.new(:strv)';
  $v.clear-object;

  # '(isx)' = tuple of int32, string, int64
  my Array $tuple = [];
  $tuple.push: Gnome::Glib::Variant.new( :type-string<i>, :value(40));
  $tuple.push: Gnome::Glib::Variant.new( :type-string<s>, :value<fourtyone>);
  $tuple.push: Gnome::Glib::Variant.new( :type-string<x>, :value(42));
  $v .= new(:$tuple);
  is $v.get-type-string, '(isx)', '.new(:tuple)';
  $v.clear-object;

  # 'q' = uint16
  $v .= new(:uint16(23));
  is $v.get-type-string, 'q', '.new(:uint16)';
  $v.clear-object;

  # 'u' = uint32
  $v .= new(:uint32(456));
  is $v.get-type-string, 'u', '.new(:uint32)';
  $v.clear-object;

  # 't' = uint64
  $v .= new(:uint64(0x654dfa));
  is $v.get-type-string, 't', '.new(:uint64)';
  $v.clear-object;

  # 'v' = variant
  $v .= new(:variant(Gnome::Glib::Variant.new( :type-string<i>, :value(40))));
  is $v.get-type-string, 'v', '.new(:variant)';
  $v.clear-object;


  $v .= new( :type-string<(sub)>, :parse('("abc",20,true)'));
  is $v.get-type-string, '(sub)', '.new( :type-string, :parse)';
  $v.clear-object;

#`{{
  # '' =
  $v .= new(:());
  is $v.get-type-string, '', '.new(:)';
  $v.clear-object;

}}
}

#-------------------------------------------------------------------------------
subtest 'Other tests', {

  # '(isx)' = tuple of int32, string, int64
  my Array $tuple = [];
  $tuple.push: Gnome::Glib::Variant.new( :type-string<i>, :value(40));
  $tuple.push: Gnome::Glib::Variant.new( :type-string<s>, :value<fourtyone>);
  $tuple.push: Gnome::Glib::Variant.new( :type-string<x>, :value(42));
  $v .= new(:$tuple);
  is $v.get-type-string, '(isx)', '.get-type-string()';
  is $v.get-type.dup-string, '(isx)', '.get-type()';
  is $v.print(False), '(40, \'fourtyone\', 42)', '.print()';
  $v.clear-object;

  $v .= new(:boolean(True));
  ok $v.get-boolean, '.get-boolean()';
  $v.clear-object;

  $v .= new(:byte(23));
  is $v.get-byte, 23, '.get-byte()';
  $v.clear-object;

  $v .= new(:byte-string<uytnbv>);
  is $v.get-bytestring, 'uytnbv', '.get-bytestring,()';
  $v.clear-object;

  $v .= new(:byte-string-array([<abc def ghi>]));
  is $v.get-bytestring-array, [<abc def ghi>], '.get-bytestring-array()';
  $v.clear-object;

  $v .= new(:double(2.2));
  is $v.get-double, 22e-1, '.get-double()';
  $v.clear-object;

  $v .= new(:int16(456));
  is $v.get-int16, 456, '.get-int16()';
  $v.clear-object;

  $v .= new(:int32(-456));
  is $v.get-int32, -456, '.get-int32()';
  $v.clear-object;

  $v .= new(:int64(678678));
  is $v.get-int64, 678678, '.get-int64()';
  $v.clear-object;

  $v .= new(:string<hgfhagsdfhgasd>);
  is $v.get-string, 'hgfhagsdfhgasd', '.get-string()';
  $v.clear-object;

  $v .= new(:strv([<abc def ghi>]));
  is $v.get-strv, [<abc def ghi>], '.get-strv()';
  $v.clear-object;

  $v .= new(:uint16(42));
  is $v.get-uint16, 42, '.get-uint16()';
  $v.clear-object;

  $v .= new(:uint32(345));
  is $v.get-uint32, 345, '.get-uint32()';
  $v.clear-object;

  $v .= new(:uint64(45656));
  is $v.get-uint64, 45656, '.get-uint64()';
  $v.clear-object;

  $v .= new(:variant(Gnome::Glib::Variant.new( :type-string<i>, :value(40))));
  is $v.get-variant.get-int32, 40, '.get-variant()';
  ok $v.is-container, '.is-container()';
  ok $v.is-of-type(Gnome::Glib::VariantType.new(:type-string<v>)),
    '.is-of-type()';

  $v.clear-object;


#`{{
  $v .= new(:());
  is $v.get-, , '.get-()';
  $v.clear-object;
}}
}


done-testing;
exit;

=finish
use Gnome::Glib::Error;

use Gnome::N::X;
#Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
my Gnome::Glib::VariantType $vt;
my Gnome::Glib::Variant $v;

#-------------------------------------------------------------------------------
subtest 'ISA test', {
}

#-------------------------------------------------------------------------------
# set environment variable 'raku-test-all' if rest must be tested too.
unless %*ENV<raku_test_all>:exists {
  done-testing;
  exit;
}

#-------------------------------------------------------------------------------
#Gnome::N::debug(:on);
subtest 'Manipulations', {
  my ( N-GVariant $nv2, Gnome::Glib::Error $e) =
    $v.g-variant-parse( 'u', '.100');

#  note "V & E: ", $v.perl(), ', ', $e.perl();
#  note "E: ", $e.message unless $v2.is-valid;
  ok $e.is-valid, '.g-variant-parse() failed';
  like $e.message, /:s invalid character in number/, $e.message;
#Gnome::N::debug(:off);

  ( $nv2, $e) = $v.g-variant-parse( 'u', '100');
  nok $e.is-valid, '.g-variant-parse() unsigned int ok';

  ( $nv2, $e) = $v.g-variant-parse( '(sub)', '("abc",20,true)');
  nok $e.is-valid, '.g-variant-parse() tuple ok';
#note $e.message if $e.is-valid;

  ( $nv2, $e) = $v.g-variant-parse( 'au', '[100,200]');
  nok $e.is-valid, '.g-variant-parse() array ok';

  my Gnome::Glib::Variant $v2 .= new(:native-object($nv2));
  $vt .= new(:native-object($v2.get-type));
  is $vt.peek-string, 'au', '.get-type()';
  is $v2.get-type-string, 'au', '.get-type-string()';
  ok $v2.is-of-type($vt), '.is-of-type()';
  ok $v2.is-container, '.is-container()';
  is GVariantClass(Buf.new($v2.g-variant-classify).decode),
     G_VARIANT_CLASS_ARRAY, '.g-variant-classify()';

  my Gnome::Glib::Variant $v3 .= new(:native-object($v2.new-boolean(True)));
  is $v3.get-type-string, 'b', '.new-boolean()';
}

#-------------------------------------------------------------------------------
done-testing;
