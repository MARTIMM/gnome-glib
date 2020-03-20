use v6;
#use lib '../gnome-native/lib';
use NativeCall;
use Test;

use Gnome::N::N-GVariant;
use Gnome::Glib::Error;
use Gnome::Glib::Variant;
use Gnome::Glib::VariantType;

use Gnome::N::X;
#Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
my Gnome::Glib::VariantType $vt;
my Gnome::Glib::Variant $v;

#-------------------------------------------------------------------------------
subtest 'ISA test', {
  $v .= new(:native-object(N-GVariant));
  isa-ok $v, Gnome::Glib::Variant, '.new(:native-object)';
  nok $v.is-valid, 'undefined obj not valid';

  # 'u' = unsigned int32
  $v .= new( :type-string<u>, :values(40));
  isa-ok $v, Gnome::Glib::Variant, '.new(:type-string<u>, :values)';
  ok $v.is-valid, 'object ok';
#`{{
  # 'ai' = array of int32
  $v .= new( :type-string<ai>, :values( [ -1, 0, 1]));
  isa-ok $v, Gnome::Glib::Variant, '.new(:type-string<ai>, :values)';
  ok $v.is-valid, 'object ok';
}}
  dies-ok(
    { $v .= new( :type-string(G_VARIANT_CLASS_VARIANT), :values($v)); },
    'variant not yet supported'
  );

  # 'au' = array of unsigned int
  $v .= new( :type-string<au>, :data-string<[10,11]>);
  isa-ok $v, Gnome::Glib::Variant, '.new(:type-string<au>,:data-string)';
  ok $v.is-valid, 'object ok';

  $v.clear-object;
  nok $v.is-valid, '.clear-object()';
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

#`{{
#-------------------------------------------------------------------------------
subtest 'Inherit ...', {
}

#-------------------------------------------------------------------------------
subtest 'Interface ...', {
}

#-------------------------------------------------------------------------------
subtest 'Properties ...', {
}

#-------------------------------------------------------------------------------
subtest 'Themes ...', {
}

#-------------------------------------------------------------------------------
subtest 'Signals ...', {
}
}}

#-------------------------------------------------------------------------------
done-testing;
