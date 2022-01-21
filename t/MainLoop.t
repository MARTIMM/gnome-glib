
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
  $ml .= new;
  isa-ok $ml, Gnome::Glib::MainLoop, '.new()';
  $ml.clear-object;

  $ml .= new(:context(Gnome::Glib::MainContext.new(:default)));
  isa-ok $ml, Gnome::Glib::MainLoop, '.new(:context)';
  isa-ok $ml.get-context, Gnome::Glib::MainContext, '.get-context()';
  $ml.clear-object;
}

#-------------------------------------------------------------------------------
# set environment variable 'raku-test-all' if rest must be tested too.
unless %*ENV<raku_test_all>:exists {
  done-testing;
  exit;
}

#-------------------------------------------------------------------------------
subtest "start thread with a new context", {
  class ContextHandlers {
    has $.handler-invoked = False;
    has $count = 0;

    method handler1 ( Str :$opt1, Bool :$invoke-full = False --> gboolean ) {
#CATCH { .note; }

      diag [~] $*THREAD.id, ' handler1 called: ', $count,
           ', invoke-full: ', $invoke-full;
      is $opt1, 'o1', 'Option :opt1 received';
      $!handler-invoked = True;

      # return G_SOURCE_CONTINUE 3x, the method will then be recalled 3 times
      if ++$count > 2 {
        $count = 0;
        diag $*THREAD.id ~ ' Return G_SOURCE_REMOVE';
        G_SOURCE_REMOVE
      }

      else {
        diag $*THREAD.id ~ ' Return G_SOURCE_CONTINUE';
        G_SOURCE_CONTINUE
      }
    }

    method notify ( Str :$opt2 ) {
#CATCH { .note; }
      diag "$*THREAD.id(), In notify handler";
      is $opt2, 'o2', 'option :opt2 received';
    }
  }

  my ContextHandlers $ch .= new;

  # there is an error when initialized both times with :default;
  #   (process:818039): GLib-CRITICAL **: 17:54:09.597:
  #   g_main_context_push_thread_default: assertion 'acquired_context' failed
  my Gnome::Glib::MainContext $main-context1 .= new;
  my Gnome::Glib::MainLoop $loop .= new(:context($main-context1));

  diag "$*THREAD.id(), Start thread";
  my Promise $p = start {
#CATCH { .note; }
    # wait for loop to start
    sleep(.3);

    #---------------------------------------------------------------------------
    subtest "manipulations ...", {
      $mc .= new(:default);
      ok $mc.acquire, '.acquire()';
      nok $mc.iteration(False), '.iteration()';
      nok $mc.pending, '.pending()';
      ok $mc.is-owner, '.is-owner()';
#      ok 1, $mc.dispatch // '.dispatch()';
      ok 1, $mc.wakeup // '.wakeup()';
      ok 1, $mc.release // '.release()';
    }

    ok $loop.is-running, '.is-running()';

    diag "$*THREAD.id(), " ~
         "Use .context-new\() and " ~
         ".push_thread_default\() to create and push " ~
         "a new context to invoke handler on thread";

    # This part is important that it happens in the thread where the
    # function is invoked in that context! The context must be
    # different than the one above that is used to create the loop
    my Gnome::Glib::MainContext $main-context2 .= new;
    $main-context2.push-thread-default;

#    diag "$*THREAD.id(), Use .invoke-full() to invoke sub on thread";

    $main-context2.invoke( $ch, 'handler1', :opt1<o1>);

    $main-context2.invoke-raw(
      -> Pointer $d { $ch.'handler1'(:opt1<o1>); },
    );

    if %*ENV<appveyor_tests>:exists {
      diag 'tests of invoke-full*() skipped; windows makes an infinite loop of it …';
    }

    else {
      $main-context2.invoke-full(
        G_PRIORITY_DEFAULT, $ch, 'handler1', $ch, 'notify',
        :opt1<o1>, :opt2<o2>, :invoke-full
      );

      $main-context2.invoke-full-raw(
        G_PRIORITY_DEFAULT,
        -> Pointer $d { $ch.'handler1'( :opt1<o1>, :invoke-full); },
        -> Pointer $d { $ch.'notify'( :opt2<o2>); },
      );
    }

    diag [~] $*THREAD.id(), ', ',
         'Use .pop-thread-default() to remove the context';
    $main-context2.pop-thread-default;

    $loop.quit;
    'test done'
  }

  diag "$*THREAD.id(), Start loop with .run\()";
  $loop.run;
  diag "$*THREAD.id(), Loop stopped";

  await $p;
  is $p.result, 'test done', 'Result promise ok';
}

#-------------------------------------------------------------------------------
subtest 'timeout-add', {
  class Timeout {
    method tom-poes-do-something ( Str :$task, :$loop --> Int ) {
      state Int $count = 1;
      diag "Tom Poes, please $task $count times";
      if $count++ >= 5 {
        $loop.quit;
        G_SOURCE_REMOVE
      }

      else {
        G_SOURCE_CONTINUE
      }
    }
  }

  my Gnome::Glib::MainLoop $loop .= new;

  my Timeout $to .= new;
  my Int $esid = $loop.timeout-add(
    100, $to, 'tom-poes-do-something', :task<jump>, :$loop
  );
  ok $esid > 0, '.timeout-add(): ' ~ $esid;
  $loop.run;
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
  #$w.add($m);

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
