
use v6;
use NativeCall;
use Test;

use Gnome::N::GlibToRakuTypes;

use Gnome::Glib::MainLoop;
use Gnome::Glib::MainContext;

#use Gnome::N::X;
#Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
my Gnome::Glib::MainLoop $ml;
my Gnome::Glib::MainContext $mc;
#-------------------------------------------------------------------------------
subtest 'ISA test', {
  $mc .= new;
  isa-ok $mc, Gnome::Glib::MainContext, '.new()';
  $mc.clear-object;

  $mc .= new(:default);
  isa-ok $mc, Gnome::Glib::MainContext, '.new(:default)';
  $mc.clear-object;

  $mc .= new(:thread-default);
  isa-ok $mc, Gnome::Glib::MainContext, '.new(:thread-default)';
  $mc.clear-object;
}

#-------------------------------------------------------------------------------
# test rest in MainLoop.t
#-------------------------------------------------------------------------------

done-testing;



=finish

#-------------------------------------------------------------------------------
subtest 'Manipulations', {
  class ContextHandlers {
    has $.handler-invoked = False;

    method handler1 ( Str :$opt1 --> gboolean ) {
      diag "handler1 called";
      is $opt1, 'o1', 'option received';
      $!handler-invoked = True;
      G_SOURCE_REMOVE
    }
  }

  my ContextHandlers $ch .= new;
  $ml .= new(:context($ch));
  $mc .= new(:default);

  $mc.invoke( $ch, 'handler1', :opt1<o1>);
#  sleep(0.5);
  ok $ch.handler-invoked, '.invoke()';
}

#`{{
#-------------------------------------------------------------------------------
subtest "start thread with a new context", {
  my Gnome::Glib::MainContext $main-context1 .= new(:default);
  my Gnome::Glib::MainLoop $loop .= new(:context($main-context1));

  diag "$*THREAD.id(), Start thread";
  my Promise $p = start {
    # wait for loop to start
    sleep(1.1);

    diag "$*THREAD.id(), " ~
         "Use g_main_context_new\() and " ~
         "g_main_context_push_thread_default\() to create and push " ~
         "a new context to invoke handler on thread";

    # This part is important that it happens in the thread where the
    # function is invoked in that context! The context must be
    # different than the one above to create the loop
    my Gnome::Glib::MainContext $main-context2 .= new;
    $gmain.context-push-thread-default($main-context2);

    diag "$*THREAD.id(), " ~
         "Use g-main-context-invoke-full() to invoke sub on thread";

    $gmain.context-invoke-full(
      $main-context2, G_PRIORITY_DEFAULT, &handler,
      OpaquePointer, &notify
    );

    diag "$*THREAD.id(), " ~
         "Use g-main-context-pop-thread-default\() to remove the context";
    $gmain.context-pop-thread-default($main-context2);

    'test done'
  }

  diag "$*THREAD.id(), start loop with g-main-loop-run\()";
  $gmain.loop-run($loop);
  diag "$*THREAD.id(), loop stopped";

  await $p;
  is $p.result, 'test done', 'result promise ok';
}
}}

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
