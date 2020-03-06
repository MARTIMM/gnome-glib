use v6;
use NativeCall;
use Test;

use Gnome::Glib::VariantType;

use Gnome::N::X;
#Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
my Gnome::Glib::VariantType $vt;
#-------------------------------------------------------------------------------
subtest 'ISA test', {
  $vt .= new(:type-string<b>);
  isa-ok $vt, Gnome::Glib::VariantType, '.new()';
  ok $vt.is-valid, '.is-valid()';

  my Gnome::Glib::VariantType $vt2 .= new(
    :native-object($vt.g_variant_type_copy)
  );
  isa-ok $vt2, Gnome::Glib::VariantType, '.g_variant_type_copy()';
  ok $vt2.is-valid, '.new(:native-object)';
#  ok $vt.variant-type-equal($vt2), '.variant-type-equal()';

  $vt2.clear-object;
  nok $vt2.is-valid, '.clear-object()';
}

#-------------------------------------------------------------------------------
subtest 'Manipulations', {
  ok $vt.is-basic, '.is-basic()';

  nok $vt.string-is-valid('bii'),
      '.string-is-valid() "bii" not valid';
  ok $vt.string-is-valid('(bii)'),
      '.string-is-valid() "(bii)" valid';

  $vt .= new(:type-string<(aby)>);
  ok $vt.is-container, '.is-container()';
  ok $vt.is-tuple, '.is-tuple()';
  is $vt.get-string-length, 5, '.get-string-length()';
  ok $vt.is-definite, '.is-definite()';
#  is $vt.n-items, 4, '.n-items()';

  $vt .= new(:type-string<ai>);
  ok $vt.is-array, '.is-array()';

  $vt .= new(:type-string<mi>);
  ok $vt.is-maybe, '.is-maybe()';

  $vt .= new(:type-string<{sb}>);
  ok $vt.is-dict-entry, '.is-dict-entry()';

  $vt .= new(:type-string<{sb}>);
  is $vt.peek-string, '{sb}', '.peek-string()';

  $vt .= new(:type-string<*>);
  nok $vt.is-definite, 'not definite';
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
