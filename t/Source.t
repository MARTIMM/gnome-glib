use v6;
use NativeCall;
use Test;

use Gnome::Glib::Source;
use Gnome::Glib::MainContext;

#use Gnome::N::X;
#Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
my Gnome::Glib::Source $s;
my Gnome::Glib::MainContext $mc;
#-------------------------------------------------------------------------------
subtest 'ISA test', {
  $s .= new(:idle);
  isa-ok $s, Gnome::Glib::Source, '.new(:idle)';

  $s .= new(:timeout(10));
  isa-ok $s, Gnome::Glib::Source, '.new(:timeout)';

  $s .= new(:timeout(10),:seconds);
  isa-ok $s, Gnome::Glib::Source, '.new( :timeout, :seconds)';
}

#-------------------------------------------------------------------------------
# set environment variable 'raku-test-all' if rest must be tested too.
unless %*ENV<raku_test_all>:exists {
  done-testing;
  exit;
}

#-------------------------------------------------------------------------------
subtest 'Manipulations', {
  $s .= new(:timeout(10));
  $s.set-name('ten-msec-timout-source');
  is $s.get-name, 'ten-msec-timout-source', '.set-name() / .get-name()';


  $mc .= new(:default);
  $s.attach($mc);

  $s.clear-object;
  nok $s.is-valid, '.clear-object()';
}

#-------------------------------------------------------------------------------
done-testing;

=finish


#-------------------------------------------------------------------------------
subtest 'Inherit Gnome::Glib::Source', {
  class MyClass is Gnome::Glib::Source {
    method new ( |c ) {
      self.bless( :GSource, |c);
    }

    submethod BUILD ( *%options ) {

    }
  }

  my MyClass $mgc .= new;
  isa-ok $mgc, Gnome::Glib::Source, '.new()';
}

#-------------------------------------------------------------------------------
subtest 'Interface ...', {
}

#-------------------------------------------------------------------------------
subtest 'Properties ...', {
  use Gnome::GObject::Value;
  use Gnome::GObject::Type;

  #my Gnome::Glib::Source $s .= new;

  sub test-property (
    $type, Str $prop, Str $routine, $value,
    Bool :$approx = False, Bool :$is-local = False
  ) {
    my Gnome::GObject::Value $gv .= new(:init($type));
    $s.get-property( $prop, $gv);
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
      Gnome::Glib::Source() :$_native-object, gulong :$_handler-id
      # --> ...
    ) {

      isa-ok $_widget, Gnome::Glib::Source;
      $!signal-processed = True;
    }

    method signal-emitter ( Gnome::Glib::Source :$widget --> Str ) {

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

  my Gnome::Glib::Source $s .= new;

  #my Gnome::Gtk3::Window $w .= new;
  #$w.add($m);

  my SignalHandlers $sh .= new;
  $s.register-signal( $sh, 'method', 'signal');

  my Promise $p = $s.start-thread(
    $sh, 'signal-emitter',
    # :!new-context,
    # :start-time(now + 1)
  );

  is $main.gtk-main-level, 0, "loop level 0";
  $main.gtk-main;
  #is $main.gtk-main-level, 0, "loop level is 0 again";

  is $p.result, 'done', 'emitter finished';
}
