
use v6;
use NativeCall;
use Test;

use Gnome::Glib::Main;

#use Gnome::N::X;
#Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
my Gnome::Glib::Main $m;
#-------------------------------------------------------------------------------
subtest 'ISA test', {
  $m .= new;
  isa-ok $m, Gnome::Glib::Main, '.new()';
}

#`{{
#-------------------------------------------------------------------------------
subtest 'Manipulations', {
}

#-------------------------------------------------------------------------------
subtest 'Inherit Gnome::Glib::Main', {
  class MyClass is Gnome::Glib::Main {
    method new ( |c ) {
      self.bless( :GMain, |c);
    }

    submethod BUILD ( *%options ) {

    }
  }

  my MyClass $mgc .= new;
  isa-ok $mgc, Gnome::Glib::Main, '.new()';
}

#-------------------------------------------------------------------------------
subtest 'Interface ...', {
}

#-------------------------------------------------------------------------------
subtest 'Properties ...', {
  use Gnome::GObject::Value;
  use Gnome::GObject::Type;

  #my Gnome::Glib::Main $m .= new;

  sub test-property ( $type, Str $prop, Str $routine, $value ) {
    my Gnome::GObject::Value $gv .= new(:init($type));
    $m.get-property( $prop, $gv);
    my $gv-value = $gv."$routine"();
    is $gv-value, $value, "property $prop";
    $gv.clear-object;
  }

  # example call
  #test-property( G_TYPE_BOOLEAN, 'homogeneous', 'get-boolean', 0);
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
      Gnome::Glib::Main :$_widget, gulong :$_handler-id
      # --> ...
    ) {

      isa-ok $_widget, Gnome::Glib::Main;
      $!signal-processed = True;
    }

    method signal-emitter ( Gnome::Glib::Main :$widget --> Str ) {

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

  my Gnome::Glib::Main $m .= new;

  #my Gnome::Gtk3::Window $w .= new;
  #$w.container-add($m);

  my SignalHandlers $sh .= new;
  $m.register-signal( $sh, 'method', 'signal');

  my Promise $p = $m.start-thread(
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
