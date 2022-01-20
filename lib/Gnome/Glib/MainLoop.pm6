use v6;

#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Glib::MainLoop

The Main Event Loop — manages all available sources of events

=head1 Description

Note that this is a low level module, please take a look at B<Gnome::Gtk3::Main> first.

The main event loop manages all the available sources of events for GLib and GTK+ applications. These events can come from any number of different types of sources such as file descriptors (plain files, pipes or sockets) and timeouts.
=comment  New types of event sources can also be added using C<g_source_attach()>.

To allow multiple independent sets of sources to be handled in different threads, each source is associated with a I<MainContext>. A I<MainContext> can only be running in a single thread, but sources can be added to it and removed from it from other threads. All functions which operate on a I<MainContext> or a built-in N-GSource are thread-safe. Contexts are described by B<Gnome::Gio::MainContext>

Each event source is assigned a priority. The default priority, G_PRIORITY_DEFAULT, is 0. Values less than 0 denote higher priorities. Values greater than 0 denote lower priorities. Events from high priority sources are always processed before events from lower priority sources.

=comment Idle functions can also be added, and assigned a priority. These will be run whenever no events with a higher priority are ready to be processed.

The I<MainLoop> data type represents a main event loop. A I<MainLoop> is created with C<new()> or C<new(:context)>. After adding the initial event sources, C<run()> is called. This continuously checks for new events from each of the event sources and dispatches them. Finally, the processing of an event from one of the sources leading to a call to C<quit()> will exit the main loop, and C<run()> returns.

It is possible to create new instances of I<MainLoop> recursively. This is often used in GTK+ applications when showing modal dialog boxes. Note that event sources are associated with a particular I<MainContext>, and will be checked and dispatched for all main loops associated with that I<MainContext>.

GTK+ contains wrappers of some of these functions, e.g. gtk_main(), gtk_main_quit() and gtk_events_pending().


=begin comment
=head3 Creating new source types

One of the unusual features of the I<MainLoop> functionality is that new types of event source can be created and used in addition to the builtin type of event source. A new event source type is used for handling GDK events. A new source type is created by "deriving" from the N-GSource structure. The derived type of source is represented by a structure that has the N-GSource structure as a first element, and other elements specific to the new source type. To create an instance of the new source type, call g_source_new() passing in the size of the derived structure and a table of functions. These GSourceFuncs determine the behavior of the new source type.

New source types basically interact with the main context in two ways. Their prepare function in GSourceFuncs can set a timeout to determine the maximum amount of time that the main loop will sleep before checking the source again. In addition, or as well, the source can add file descriptors to the set that the main context checks using g_source_add_poll().
=end comment

=begin comment
=head3 Customizing the main loop iteration

Single iterations of a I<MainContext> can be run with g_main_context_iteration(). In some cases, more detailed control of exactly how the details of the main loop work is desired, for instance, when integrating the I<MainLoop> with an external main loop. In such cases, you can call the component functions of g_main_context_iteration() directly. These functions are g_main_context_prepare(), g_main_context_query(), g_main_context_check() and g_main_context_dispatch().
State of a Main Context

The operation of these functions can best be seen in terms of a state diagram, as shown in this image.

![](images/mainstates.png)

On UNIX, the GLib mainloop is incompatible with fork(). Any program using the mainloop must either exec() or exit() from the child without returning to the mainloop.
=end comment

=begin comment
=head3 Memory management of sources

There are two options for memory management of the user data passed to a N-GSource to be passed to its callback on invocation. This data is provided in calls to g_timeout_add(), g_timeout_add_full(), g_idle_add(), etc. and more generally, using g_source_set_callback(). This data is typically an object which ‘owns’ the timeout or idle callback, such as a widget or a network protocol implementation. In many cases, it is an error for the callback to be invoked after this owning object has been destroyed, as that results in use of freed memory.

The first, and preferred, option is to store the source ID returned by functions such as g_timeout_add() or g_source_attach(), and explicitly remove that source from the main context using g_source_remove() when the owning object is finalized. This ensures that the callback can only be invoked while the object is still alive.

The second option is to hold a strong reference to the object in the callback, and to release it in the callback’s GDestroyNotify. This ensures that the object is kept alive until after the source is finalized, which is guaranteed to be after it is invoked for the final time. The GDestroyNotify is another callback passed to the ‘full’ variants of N-GSource functions (for example, g_timeout_add_full()). It is called when the source is finalized, and is designed for releasing references like this.

One important caveat of this second approach is that it will keep the object alive indefinitely if the main loop is stopped before the N-GSource is invoked, which may be undesirable.
=end comment


=head1 Synopsis
=head2 Declaration

  unit class Gnome::Glib::MainLoop;
  also is Gnome::N::TopLevelClassSupport;


=comment head2 Example

=end pod

#-------------------------------------------------------------------------------
use NativeCall;

#use Gnome::N::X;
use Gnome::N::N-GObject;
use Gnome::N::NativeLib;
use Gnome::N::TopLevelClassSupport;
use Gnome::N::GlibToRakuTypes;

use Gnome::Glib::MainContext;

#-------------------------------------------------------------------------------
# See /usr/include/glib-2.0/gmain.h
unit class Gnome::Glib::MainLoop:auth<github:MARTIMM>:ver<0.1.0>;
also is Gnome::N::TopLevelClassSupport;

#-------------------------------------------------------------------------------
# /usr/include/glib-2.0/glib/gmain.h
# https://developer.gnome.org/glib/stable/glib-The-Main-Event-Loop.html
=begin pod
=head1 Types

=head2 Constants

=item G_PRIORITY_HIGH; Use this for high priority event sources. It is not used within GLib or GTK+.
=item G_PRIORITY_DEFAULT; Use this for default priority event sources. In GLib this priority is used when adding timeout functions with g_timeout_add(). In GDK this priority is used for events from the X server.
=item G_PRIORITY_HIGH_IDLE; Use this for high priority idle functions. GTK+ uses G_PRIORITY_HIGH_IDLE + 10 for resizing operations, and G_PRIORITY_HIGH_IDLE + 20 for redrawing operations. (This is done to ensure that any pending resizes are processed before any pending redraws, so that widgets are not redrawn twice unnecessarily.)
=item G_PRIORITY_DEFAULT_IDLE; Use this for default priority idle functions. In GLib this priority is used when adding idle functions with g_idle_add().
=item G_PRIORITY_LOW; Use this for very low priority background tasks. It is not used within GLib or GTK+.

=item G_SOURCE_REMOVE; Use this macro as the return value of a callback handler to leave the GSource in the main loop.
=item G_SOURCE_CONTINUE; Use this macro as the return value of a callback handler to remove the GSource from the main loop.

=end pod
#TT:1:constants:
constant G_PRIORITY_HIGH is export          = -100;
constant G_PRIORITY_DEFAULT is export       = 0;
constant G_PRIORITY_HIGH_IDLE is export     = 100;
constant G_PRIORITY_DEFAULT_IDLE is export  = 200;
constant G_PRIORITY_LOW is export           = 300;

constant G_SOURCE_REMOVE is export          = 0; # ~~ False
constant G_SOURCE_CONTINUE is export        = 1; # ~~ True


#-------------------------------------------------------------------------------
=begin pod
=head1 Methods
=head2 new

=head3 default, no options

Create a new Main object depending on the default context.

  multi method new ( )


=head3 :context

Create a new Main object depending on provided context.

  multi method new ( :context! )

=end pod

#TM:1:new():
#TM:4:new(:native-object):Gnome::N::TopLevelClassSupport
submethod BUILD ( *%options ) {

  # prevent creating wrong native-objects
  if self.^name eq 'Gnome::Glib::MainLoop' #`{{ or %options<GMain> }} {

    # check if native object is set by a parent class
    if self.is-valid { }

    # check if common options are handled by some parent
    elsif %options<native-object>:exists { }

    # process all other options
    else {
      my $no;
      if ? %options<context> {
        $no = %options<context>;
        $no .= _get-native-object-no-reffing unless $no ~~ N-GObject;
        $no = _g_main_loop_new( $no, False);
      }

      ##`{{ use this when the module is not made inheritable
      # check if there are unknown options
      elsif %options.elems {
        die X::Gnome.new(
          :message(
            'Unsupported, undefined, incomplete or wrongly typed options for ' ~
            self.^name ~ ': ' ~ %options.keys.join(', ')
          )
        );
      }
      #}}

      #`{{ when there are no defaults use this
      # check if there are any options
      elsif %options.elems == 0 {
        die X::Gnome.new(:message('No options specified ' ~ self.^name));
      }
      }}

      ##`{{ when there are defaults use this instead
      # create default object
      else {
        $no = _g_main_loop_new( N-GObject, False);
      }
      #}}

      self._set-native-object($no);
    }

    # only after creating the native-object, the gtype is known
    self._set-class-info('GMain');
  }
}

#-------------------------------------------------------------------------------
method native-object-ref ( $n-native-object ) {
  _g_main_loop_ref($n-native-object)
}

#-------------------------------------------------------------------------------
method native-object-unref ( $n-native-object ) {
  _g_main_loop_unref($n-native-object);
}

#-------------------------------------------------------------------------------
#TM:1:get-context:
=begin pod
=head2 get-context

Returns the B<Gnome::Glib::MainContext> of I<loop>.

  method get-context ( --> Gnome::Glib::MainContext )

=end pod

method get-context ( --> Gnome::Glib::MainContext ) {

  Gnome::Glib::MainContext.new(:native-object(
      g_main_loop_get_context(
        self._get-native-object-no-reffing
      )
    )
  );
}

sub g_main_loop_get_context ( N-GObject $loop --> N-GObject )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:is-running:
=begin pod
=head2 is-running


Checks to see if the main loop is currently being run via C<run()>.

Returns: C<True> if the mainloop is currently being run.

  method is-running ( --> Bool )

=end pod

method is-running (--> Bool ) {

  g_main_loop_is_running(
    self._get-native-object-no-reffing
  ).Bool;
}

sub g_main_loop_is_running ( N-GObject $loop --> gboolean )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_main_new:
#`{{
=begin pod
=head2 new


Creates a new B<Gnome::Glib::MainLoop> structure.

Returns: a new B<Gnome::Glib::MainLoop>.

  method new ( N-GObject $context, Int $is_running --> N-GObject )

=item N-GObject $context; (nullable): a B<Gnome::Glib::MainContext>  (if C<undefined>, the default context will be used).
=item Int $is_running; set to C<True> to indicate that the loop is running. This is not very important since calling C<run()> will set this to C<True> anyway.

=end pod

method new ( N-GObject $context, Int $is_running --> N-GObject ) {

  g_main_loop_new(
    self._get-native-object-no-reffing, $context, $is_running
  );
}
}}

sub _g_main_loop_new (
  N-GObject $context, gboolean $is_running --> N-GObject
) is symbol('g_main_loop_new')
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:quit:
=begin pod
=head2 quit

Stops a B<Gnome::Glib::MainLoop> from running. Any calls to C<run()> for the loop will return.

Note that sources that have already been dispatched when C<quit()> is called will still be executed.

  method quit ( )

=end pod

method quit ( ) {

  g_main_loop_quit(
    self._get-native-object-no-reffing
  );
}

sub g_main_loop_quit ( N-GObject $loop  )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:ref:
#`{{
=begin pod
=head2 ref

Increases the reference count on a B<Gnome::Glib::MainLoop> object by one.

Returns: I<loop>

  method ref ( N-GObject $loop --> N-GObject )

=item N-GObject $loop; a B<Gnome::Glib::MainLoop>

=end pod

method ref ( N-GObject $loop --> N-GObject ) {

  g_main_loop_ref(
    self._get-native-object-no-reffing, $loop
  );
}
}}

sub _g_main_loop_ref ( N-GObject $loop --> N-GObject )
  is symbol('g_main_loop_ref')
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:run:
=begin pod
=head2 run

Runs a main loop until C<quit()> is called on the loop. If this is called for the thread of the loop's B<Gnome::Glib::MainContext>, it will process events from the loop, otherwise it will simply wait.

  method run ( )

=end pod

method run ( ) {
  g_main_loop_run(self._get-native-object-no-reffing);
}

sub g_main_loop_run ( N-GObject $loop )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:timeout-add:
=begin pod
=head2 timeout-add

Sets a function to be called at regular intervals, with the default priority, C<G_PRIORITY_DEFAULT>. The function is called repeatedly until it returns C<False>, at which point the timeout is automatically destroyed and the function will not be called again. The first call to the function will be at the end of the first I<$interval>.

Note that timeout functions may be delayed, due to the processing of other event sources. Thus they should not be relied on for precise timing. After each call to the timeout function, the time of the next timeout is recalculated based on the current time and the given interval (it does not try to 'catch up' time lost in delays).

=comment See [memory management of sources][mainloop-memory-management] for details on how to handle the return value and memory management of I<data>.

If you want to have a timer in the "seconds" range and do not care about the exact time of the first call of the timer, use the C<timeout-add-seconds()> function; this function allows for more optimizations and more efficient system power usage.

This internally creates a main loop source using C<g-timeout-source-new()> and attaches it to the global B<Gnome::Glib::MainContext> using C<g-source-attach()>, so the callback will be invoked in whichever thread is running that main context. You can do these steps manually if you need greater control or to use a custom main context.

The interval given is in terms of monotonic time, not wall clock time. See C<g-get-monotonic-time()>.

Returns: the ID (greater than 0) of the event source.

  method timeout-add (
    UInt $interval,  -->
  )

=item UInt $interval; the time between calls to the function, in milliseconds (1/1000ths of a second)
=item
=item
=end pod

method timeout-add (
  UInt $interval, Any:D $handler-object, Str:D $handler-name, *%handler-data
  --> UInt
) {
  g_timeout_add(
    $interval,
    sub ( gpointer $ignore-user-data --> gboolean ) {
      $handler-object."$handler-name"(|%handler-data) ?? 1 !! 0
    },
    gpointer
  )
}

sub g_timeout_add (
  guint $interval,
  Callable $g-source-func ( Pointer $d --> gboolean ),
  gpointer $data
  --> guint
) is native(&glib-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
#TM:0:timeout-add-full:
=begin pod
=head2 timeout-add-full

Sets a function to be called at regular intervals, with the given priority. The function is called repeatedly until it returns C<False>, at which point the timeout is automatically destroyed and the function will not be called again. The I<notify> function is called when the timeout is destroyed. The first call to the function will be at the end of the first I<interval>.

Note that timeout functions may be delayed, due to the processing of other event sources. Thus they should not be relied on for precise timing. After each call to the timeout function, the time of the next timeout is recalculated based on the current time and the given interval (it does not try to 'catch up' time lost in delays).

See [memory management of sources][mainloop-memory-management] for details on how to handle the return value and memory management of I<data>.

This internally creates a main loop source using C<source-new()> and attaches it to the global B<Gnome::Glib::MainContext> using C<g-source-attach()>, so the callback will be invoked in whichever thread is running that main context. You can do these steps manually if you need greater control or to use a custom main context.

The interval given is in terms of monotonic time, not wall clock time. See C<g-get-monotonic-time()>.

Returns: the ID (greater than 0) of the event source.

  method timeout-add-full (
    Int $priority, UInt $interval, GSourceFunc $function,
    Pointer $data, GDestroyNotify $notify
    --> UInt
  )

=item Int $priority; the priority of the timeout source. Typically this will be in the range between B<Gnome::Glib::-PRIORITY-DEFAULT> and B<Gnome::Glib::-PRIORITY-HIGH>.
=item UInt $interval; the time between calls to the function, in milliseconds (1/1000ths of a second)
=item GSourceFunc $function; function to call
=item Pointer $data; data to pass to I<function>
=item GDestroyNotify $notify; function to call when the timeout is removed, or C<undefined>
=end pod

method timeout-add-full (
  Int $priority, UInt $interval, GSourceFunc $function, Pointer $data,
  GDestroyNotify $notify
  --> UInt
) {

  g_timeout_add_full(
    self._get-native-object-no-reffing, $priority, $interval, $function, $data, $notify
  )
}

sub g_timeout_add_full (
  gint $priority, guint $interval, GSourceFunc $function, gpointer $data, GDestroyNotify $notify --> guint
) is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:timeout-add-seconds:
=begin pod
=head2 timeout-add-seconds

Sets a function to be called at regular intervals with the default priority, B<Gnome::Glib::-PRIORITY-DEFAULT>. The function is called repeatedly until it returns C<False>, at which point the timeout is automatically destroyed and the function will not be called again.

This internally creates a main loop source using C<source-new-seconds()> and attaches it to the main loop context using C<g-source-attach()>. You can do these steps manually if you need greater control. Also see C<g-timeout-add-seconds-full()>.

Note that the first call of the timer may not be precise for timeouts of one second. If you need finer precision and have such a timeout, you may want to use C<g-timeout-add()> instead.

See [memory management of sources][mainloop-memory-management] for details on how to handle the return value and memory management of I<data>.

The interval given is in terms of monotonic time, not wall clock time. See C<g-get-monotonic-time()>.

Returns: the ID (greater than 0) of the event source.

  method timeout-add-seconds (
    UInt $interval, GSourceFunc $function, Pointer $data
    --> UInt
  )

=item UInt $interval; the time between calls to the function, in seconds
=item GSourceFunc $function; function to call
=item Pointer $data; data to pass to I<function>
=end pod

method timeout-add-seconds (
  UInt $interval, GSourceFunc $function, Pointer $data
  --> UInt
) {

  g_timeout_add_seconds(
    self._get-native-object-no-reffing, $interval, $function, $data
  )
}

sub g_timeout_add_seconds (
  guint $interval, GSourceFunc $function, gpointer $data --> guint
) is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:timeout-add-seconds-full:
=begin pod
=head2 timeout-add-seconds-full

Sets a function to be called at regular intervals, with I<priority>. The function is called repeatedly until it returns C<False>, at which point the timeout is automatically destroyed and the function will not be called again.

Unlike C<add()>, this function operates at whole second granularity. The initial starting point of the timer is determined by the implementation and the implementation is expected to group multiple timers together so that they fire all at the same time. To allow this grouping, the I<interval> to the first timer is rounded and can deviate up to one second from the specified interval. Subsequent timer iterations will generally run at the specified interval.

Note that timeout functions may be delayed, due to the processing of other event sources. Thus they should not be relied on for precise timing. After each call to the timeout function, the time of the next timeout is recalculated based on the current time and the given I<interval>

See [memory management of sources][mainloop-memory-management] for details on how to handle the return value and memory management of I<data>.

If you want timing more precise than whole seconds, use C<g-timeout-add()> instead.

The grouping of timers to fire at the same time results in a more power and CPU efficient behavior so if your timer is in multiples of seconds and you don't require the first timer exactly one second from now, the use of C<g-timeout-add-seconds()> is preferred over C<g-timeout-add()>.

This internally creates a main loop source using C<g-timeout-source-new-seconds()> and attaches it to the main loop context using C<g-source-attach()>. You can do these steps manually if you need greater control.

The interval given is in terms of monotonic time, not wall clock time. See C<g-get-monotonic-time()>.

Returns: the ID (greater than 0) of the event source.

  method timeout-add-seconds-full (
    Int $priority, UInt $interval, GSourceFunc $function,
    Pointer $data, GDestroyNotify $notify
    --> UInt
  )

=item Int $priority; the priority of the timeout source. Typically this will be in the range between B<Gnome::Glib::-PRIORITY-DEFAULT> and B<Gnome::Glib::-PRIORITY-HIGH>.
=item UInt $interval; the time between calls to the function, in seconds
=item GSourceFunc $function; function to call
=item Pointer $data; data to pass to I<function>
=item GDestroyNotify $notify; function to call when the timeout is removed, or C<undefined>
=end pod

method timeout-add-seconds-full (
  Int $priority, UInt $interval, GSourceFunc $function, Pointer $data,
  GDestroyNotify $notify
  --> UInt
) {

  g_timeout_add_seconds_full(
    self._get-native-object-no-reffing, $priority, $interval, $function, $data, $notify
  )
}

sub g_timeout_add_seconds_full (
  gint $priority, guint $interval, GSourceFunc $function, gpointer $data, GDestroyNotify $notify --> guint
) is native(&glib-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:1:unref:
#`{{
=begin pod
=head2 unref

Decreases the reference count on a B<Gnome::Glib::MainLoop> object by one. If the result is zero, free the loop and free all associated memory.

  method unref ( N-GObject $loop )

=item N-GObject $loop; a B<Gnome::Glib::MainLoop>

=end pod

method unref ( N-GObject $loop ) {

  g_main_loop_unref(
    self._get-native-object-no-reffing, $loop
  );
}
}}

sub _g_main_loop_unref ( N-GObject $loop  )
  is native(&glib-lib)
  is symbol('g_main_loop_unref')
  { * }
