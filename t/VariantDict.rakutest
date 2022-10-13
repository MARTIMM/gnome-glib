use v6;
#use lib '../gnome-native/lib';
#use lib '../gnome-glib/lib';
use NativeCall;
use Test;


use Gnome::Glib::Error;
use Gnome::Glib::Variant;
use Gnome::Glib::VariantDict;
use Gnome::Glib::VariantType;

#use Gnome::N::X;
#Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
my Gnome::Glib::Variant $v;
my Gnome::Glib::VariantDict $vd;
my Gnome::Glib::VariantType $vt;
#-------------------------------------------------------------------------------
subtest 'variant dict', {
  $vd .= new(
    :variant(
      Gnome::Glib::Variant.new(:parse(Q:q/{ 'width': <350>, 'height': <200>}/))
    )
  );
  ok $vd.is-valid, '.new(:variant)';

  $vd.insert-value( 'vd01', Gnome::Glib::Variant.new(:parse('-40')));
  ok $vd.contains('vd01'), '.insert-value() / .contains()';
  is $vd.lookup-value( 'width', 'i').get-int32, 350, '.lookup-value()';
  nok $vd.lookup-value( 'width', 'u').is-valid, 'lookup wrong type';

  ok $vd.remove('width'), '.remove()';

  $v .= new(:native-object($vd.end));
  ok $v.is-valid, '.end()';
  $vd.clear-object;
  diag 'dict entries: ' ~ $v.print(False);
}

#-------------------------------------------------------------------------------
done-testing;
