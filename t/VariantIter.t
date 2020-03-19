use v6;
#use lib '../gnome-native/lib';
#use NativeCall;
use Test;


use Gnome::N::N-GVariant;
use Gnome::N::N-GVariantIter;
#use Gnome::N::N-GVariantBuilder;
#use Gnome::Glib::Error;
use Gnome::Glib::VariantBuilder;
use Gnome::Glib::Variant;
use Gnome::Glib::VariantIter;
use Gnome::Glib::VariantType;


use Gnome::N::X;
#Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
my Gnome::Glib::VariantType $vt;
my Gnome::Glib::Variant $v;
my Gnome::Glib::VariantIter $vi;
my Gnome::Glib::VariantBuilder $vb;

#-------------------------------------------------------------------------------
subtest 'ISA test', {
  dies-ok(
    { $vi .= new; },
    'must use an option'
  );

  $v .= new( :type-string<au>, :data-string<[10,11]>);
  $vi .= new(:variant($v));
  isa-ok $vi, Gnome::Glib::VariantIter, '.new(:variant)';
  ok $vi.is-valid, '.is-valid()';

# g_variant_iter_free() does not recognize that the native object is
# created using g_variant_iter_new(). It generates the following error;
#   (VariantIter.t:15871): GLib-CRITICAL **: 16:48:48.278: g_variant_iter_free:
#   assertion 'is_valid_heap_iter (iter)' failed
# Maybe it is caused by copying the native object back and forth
#
#  $vi.clear-object;
#  nok $vi.is-valid, '.clear-object()';
}

#-------------------------------------------------------------------------------
subtest 'Manipulations', {
  $vb .= new(:type-string<as>);
  $vb.add-parsed("'when'");
  $vb.add-parsed("'in'");
  $vb.add-parsed("'the'");
  $vb.add-parsed("'course'");
  $v .= new(:native-object($vb.variant-builder-end));

# gnome message gets out again;
#   (VariantIter.t:18864): GLib-CRITICAL **: 18:32:07.455: g_variant_iter_free:
#   assertion 'is_valid_heap_iter (iter)' failed
#
# this is because new() calls clear-object() which calls native-object-unref()
# which calls _g_variant_iter_free()
  $vi .= new(:native-object($v.g-variant-get('as')));


  $vb.clear-object;
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
