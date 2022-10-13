use v6;
#use lib '../gnome-native/lib';
use NativeCall;
use Test;

use Gnome::Glib::VariantType;

use Gnome::N::X;
#Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
my Gnome::Glib::VariantType $vt;
my Gnome::Glib::VariantType $vt2;
#-------------------------------------------------------------------------------
subtest 'ISA test', {
  $vt .= new(:type-string<b>);
  isa-ok $vt, Gnome::Glib::VariantType, '.new(:type-string)';
  ok $vt.is-valid, '.is-valid()';

  $vt2 .= new(:array($vt));
  is $vt2.dup-string, 'ab', '.new(:array): ' ~ $vt2.dup-string;
  $vt2.clear-object;

  $vt2 .= new(:maybe($vt));
  is $vt2.dup-string, 'mb', '.new(:maybe): ' ~ $vt2.dup-string;
  $vt2.clear-object;

  my Gnome::Glib::VariantType $vt-a .= new(:type-string<s>);
  my Gnome::Glib::VariantType $vt-b .= new(:type-string<i>);
  $vt2 .= new(:tuple($vt,$vt-a,$vt-b));
  is $vt2.dup-string, '(bsi)', '.new(:tuple): ' ~ $vt2.dup-string;
  $vt2.clear-object;

  $vt2 = $vt.copy;
  isa-ok $vt2, Gnome::Glib::VariantType, '.copy()';
  ok $vt2.is-valid, '.new(:native-object)';
  ok $vt.equal($vt2), '.equal()';

  $vt2.clear-object;
  nok $vt2.is-valid, '.clear-object()';
}

#-------------------------------------------------------------------------------
# set environment variable 'raku-test-all' if rest must be tested too.
unless %*ENV<raku_test_all>:exists {
  done-testing;
  exit;
}

#-------------------------------------------------------------------------------
subtest 'Manipulations', {
  ok $vt.is-basic, '.is-basic()';

  nok $vt.string-is-valid('bii'),
      '.string-is-valid() "bii" not valid';
  ok $vt.string-is-valid('(bii)'),
      '.string-is-valid() "(bii)" valid';

  $vt .= new(:type-string<ai>);
  ok $vt.is-subtype-of($vt), '.is-subtype-of()';
  is $vt.element.dup-string, 'i', '.element(): ' ~ $vt.dup-string;

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

  $vt .= new(:type-string<v>);
  ok $vt.is-variant, '.is-variant()';

  # array is not a hash
  $vt .= new(:type-string<a{sd}>);
  nok $vt.is-variant, '.is-hash()';

  $vt .= new(:type-string<{sb}>);
  ok 1, '.hash(): ' ~ $vt.hash;
  is $vt.key.dup-string, 's', '.key()';
  is $vt.value.dup-string, 'b', '.value()';

  $vt .= new(:type-string<*>);
  nok $vt.is-definite, 'not definite';

  $vt .= new(:type-string<(aby)>);
  is $vt.first.dup-string, 'ab', '.first(): ' ~ $vt.dup-string;
  is $vt.first.next.dup-string, 'y', '.next(): ' ~ $vt.dup-string;
  is $vt.n-items, 2, '.n-items()';
}

#`{{
#-------------------------------------------------------------------------------
subtest 'Inherit Gnome::Glib::VariantType', {
  class MyClass is Gnome::Glib::VariantType {
    method new ( |c ) {
      self.bless( :GVariantType, |c);
    }

    submethod BUILD ( *%options ) {

    }
  }

  my MyClass $mgc .= new;
  isa-ok $mgc, Gnome::Glib::VariantType, '.new()';
}

#-------------------------------------------------------------------------------
subtest 'Interface ...', {
}

#-------------------------------------------------------------------------------
subtest 'Properties ...', {
  use Gnome::GObject::Value;
  use Gnome::GObject::Type;

  #my Gnome::Glib::VariantType $vt .= new;

  sub test-property (
    $type, Str $prop, Str $routine, $value,
    Bool :$approx = False, Bool :$is-local = False
  ) {
    my Gnome::GObject::Value $gv .= new(:init($type));
    $vt.get-property( $prop, $gv);
    my $gv-value = $gv."$routine"();
    if $approx {
      is-approx $gv-value, $value,
        "property $prop, value: " ~ $gv-value;
    }

    # dependency on local settings might result in different values
    elsif $is-local {
      if $gv-value ~~ /$value/ {
        like $gv-value, /$value/, "property $prop, value: " ~ $gv-value;
      }

      else {
        ok 1, "property $prop, value: " ~ $gv-value;
      }
    }

    else {
      is $gv-value, $value,
        "property $prop, value: " ~ $gv-value;
    }
    $gv.clear-object;
  }

  # example calls
  #test-property( G_TYPE_BOOLEAN, 'homogeneous', 'get-boolean', 0);
  #test-property( G_TYPE_STRING, 'label', 'get-string', '...');
  #test-property( G_TYPE_FLOAT, 'xalign', 'get-float', 23e-2, :approx);
}

#-------------------------------------------------------------------------------
subtest 'Themes ...', {
}

#-------------------------------------------------------------------------------
subtest 'Signals ...', {
  use Gnome::Gtk3::Main;
  use Gnome::N::GlibToRakuTypes;

  my Gnome::Gtk3::Main $main .= new;

  class SignalHandlers {
    has Bool $!signal-processed = False;

    method ... (
      'any-args',
      Gnome::Glib::VariantType() :$_native-object, gulong :$_handler-id
      # --> ...
    ) {

      isa-ok $_widget, Gnome::Glib::VariantType;
      $!signal-processed = True;
    }

    method signal-emitter ( Gnome::Glib::VariantType :$widget --> Str ) {

      while $main.gtk-events-pending() { $main.iteration-do(False); }

      $widget.emit-by-name(
        'signal',
      #  'any-args',
      #  :return-type(int32),
      #  :parameters([int32,])
      );
      is $!signal-processed, True, '\'...\' signal processed';

      while $main.gtk-events-pending() { $main.iteration-do(False); }

      #$!signal-processed = False;
      #$widget.emit-by-name(
      #  'signal',
      #  'any-args',
      #  :return-type(int32),
      #  :parameters([int32,])
      #);
      #is $!signal-processed, True, '\'...\' signal processed';

      while $main.gtk-events-pending() { $main.iteration-do(False); }
      sleep(0.4);
      $main.gtk-main-quit;

      'done'
    }
  }

  my Gnome::Glib::VariantType $vt .= new;

  #my Gnome::Gtk3::Window $w .= new;
  #$w.add($m);

  my SignalHandlers $sh .= new;
  $vt.register-signal( $sh, 'method', 'signal');

  my Promise $p = $vt.start-thread(
    $sh, 'signal-emitter',
    # G_PRIORITY_DEFAULT,       # enable 'use Gnome::Glib::Main'
    # :!new-context,
    # :start-time(now + 1)
  );

  is $main.gtk-main-level, 0, "loop level 0";
  $main.gtk-main;
  #is $main.gtk-main-level, 0, "loop level is 0 again";

  is $p.result, 'done', 'emitter finished';
}
}}

#-------------------------------------------------------------------------------
done-testing;
