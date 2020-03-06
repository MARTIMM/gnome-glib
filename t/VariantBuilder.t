use v6;
use lib '../gnome-native/lib';
use NativeCall;
use Test;

use Gnome::Glib::Error;
use Gnome::Glib::Variant;
use Gnome::Glib::VariantBuilder;
use Gnome::Glib::VariantType;

#use Gnome::N::X;
#Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
my Gnome::Glib::Variant $v;
my Gnome::Glib::VariantType $vt;
my Gnome::Glib::VariantBuilder $vb;
#-------------------------------------------------------------------------------
subtest 'ISA test', {
  $vb .= new(:native-object(N-GVariantBuilder));
  isa-ok $vb, Gnome::Glib::VariantBuilder, '.new(:native-object)';
  nok $vb.is-valid, 'undefined obj not valid';

  $vb .= new(:type-string<au>);
  isa-ok $vb, Gnome::Glib::VariantBuilder, '.new(:type-string)';
  ok $vb.is-valid, 'object ok';

  $vt .= new(:type-string<ai>);
  $vb .= new(:type($vt));
  isa-ok $vb, Gnome::Glib::VariantBuilder, '.new(:type)';

#`{{
#  $vb .= new( :type-string<ui>, :values([ 40, -40]));
  $vb .= new( :type-string<u>, :values([10]));
  isa-ok $vb, Gnome::Glib::VariantBuilder, '.new(:type-string,:values)';
  ok $vb.is-valid, 'object ok';
}}

  $vb.variant-builder-clear;
  ok $vb.is-valid, '.variant-builder-clear()';


  $vt .= new(:type-string<ai>);
#note $vt.is-valid;
  $vb.variant-builder-init($vt);

#Gnome::N::debug(:on);
  # a tuple with two values; int followed by unsigned int
  $vb.variant-builder-init('(iu)');
  $v .= new( :type-string<i>, :data-string<-10>);
  $vb.add-value($v);
  $v .= new( :type-string<u>, :data-string<11>);
  $vb.add-value($v);
#Gnome::N::debug(:off);


  # an array of dictionaries
  $vb.variant-builder-init(G_VARIANT_TYPE_ARRAY);
  $vb.add-parsed('{"width": <600>, "data": <10>}');
  $vb.add-parsed('{"title": <"mr">}');

  $vb.clear-object;
  nok $vb.is-valid, '.clear-object()';
}

#`{{
#-------------------------------------------------------------------------------
subtest 'Manipulations', {
  my ( N-GVariant $nv2, Gnome::Glib::Error $e) =
    $vb.g-variant-parse( 'u', '.100');

#  note "V & E: ", $vb.perl(), ', ', $e.perl();
#  note "E: ", $e.message unless $v2.is-valid;
  ok $e.is-valid, '.g-variant-parse() failed';
  like $e.message, /:s invalid character in number/, $e.message;

  ( $nv2, $e) = $vb.g-variant-parse( 'u', '100');
  nok $e.is-valid, '.g-variant-parse() unsigned int ok';

  ( $nv2, $e) = $vb.g-variant-parse( '(sub)', '("abc",20,true)');
  nok $e.is-valid, '.g-variant-parse() tuple ok';
note $e.message if $e.is-valid;

  ( $nv2, $e) = $vb.g-variant-parse( 'au', '[100,200]');
  nok $e.is-valid, '.g-variant-parse() array ok';

  my Gnome::Glib::Variant $vb2 .= new(:native-object($nv2));
}
}}

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
