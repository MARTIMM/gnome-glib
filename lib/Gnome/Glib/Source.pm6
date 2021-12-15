#TL:1:Gnome::Glib::Source:

use v6;
#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Glib::Source

manages all available sources of events

=comment ![](images/X.png)

=head1 Description

To get a bigger picture, you can read the description of class B<Gnome::Glib::MainContext>.


=head1 Synopsis
=head2 Declaration

  unit class Gnome::Glib::Source;
  also is Gnome::N::TopLevelClassSupport;


=comment head2 Uml Diagram

=comment ![](plantuml/.svg)


=begin comment
=head2 Inheriting this class

Inheriting is done in a special way in that it needs a call from new() to get the native object created by the class you are inheriting from.

  use Gnome::Glib::Source;

  unit class MyGuiClass;
  also is Gnome::Glib::Source;

  submethod new ( |c ) {
    # let the Gnome::Glib::Source class process the options
    self.bless( :N-GObject, |c);
  }

  submethod BUILD ( ... ) {
    ...
  }

=end comment
=comment head2 Example

=end pod
#-------------------------------------------------------------------------------
use NativeCall;

#use Gnome::N::X;
use Gnome::N::NativeLib;
use Gnome::N::N-GObject;
use Gnome::N::GlibToRakuTypes;
use Gnome::N::TopLevelClassSupport;

#-------------------------------------------------------------------------------
unit class Gnome::Glib::Source:auth<github:MARTIMM>:ver<0.1.0>;
also is Gnome::N::TopLevelClassSupport;


#`{{
#-------------------------------------------------------------------------------
=begin pod
=head1 Types

=head2 N-GSourceFuncs

The C<N-GSourceFuncs> struct contains a table of functions used to handle event sources in a generic manner.

For idle sources, the prepare and check functions always return TRUE to indicate that the source is always ready to be processed. The prepare function also returns a timeout value of 0 to ensure that the poll() call doesn't block (since that would be time wasted which could have been spent running the idle function).

For timeout sources, the prepare and check functions both return TRUE if the timeout interval has expired. The prepare function also returns a timeout value to ensure that the poll() call doesn't block too long and miss the next timeout.

For file descriptor sources, the prepare function typically returns FALSE, since it must wait until poll() has been called before it knows whether any events need to be processed. It sets the returned timeout to -1 to indicate that it doesn't mind how long the poll() call blocks. In the check function, it tests the results of the poll() call to see if the required condition has been met, and returns TRUE if so.

The structure of N-GSourceFuncs is

  class N-GSourceFuncs is repr('CStruct') {
    has Callable $.prepare ( N-GObject $source, gint $timeout --> gboolean ) is rw;
    has Callable $.check ( N-GObject $source --> gboolean ) is rw;
    has Callable $.dispatch (
    N-GObject source, GSourceFunc $callback, gpointer $user_data
    --> gboolean
  ) is rw;
    has Callable $.finalize ( N-GObject $source) is rw;
  };


=item function prepare

Called before all the file descriptors are polled. If the source can determine that it is ready here (without waiting for the results of the poll() call) it should return TRUE. It can also return a timeout_ value which should be the maximum timeout (in milliseconds) which should be passed to the poll() call. The actual timeout used will be -1 if all sources returned -1, or it will be the minimum of all the timeout_ values returned which were >= 0. Since 2.36 this may be NULL, in which case the effect is as if the function always returns FALSE with a timeout of -1. If prepare returns a timeout and the source also has a ready time set, then the lower of the two will be used.

  sub prepare ( N-GObject $source, gint $timeout --> gboolean )

=item function check

Called after all the file descriptors are polled. The source should return TRUE if it is ready to be dispatched. Note that some time may have passed since the previous prepare function was called, so the source should be checked again here. Since 2.36 this may be NULL, in which case the effect is as if the function always returns FALSE.


=item function dispatch

Called to dispatch the event source, after it has returned TRUE in either its prepare or its check function, or if a ready time has been reached. The dispatch function receives a callback function and user data. The callback function may be NULL if the source was never connected to a callback using g_source_set_callback(). The dispatch function should call the callback function with user_data and whatever additional parameters are needed for this type of event source. The return value of the dispatch function should be G_SOURCE_REMOVE if the source should be removed or G_SOURCE_CONTINUE to keep it.


=item function finalize

Called when the source is finalized. At this point, the source will have been destroyed, had its callback cleared, and have been removed from its GMainContext, but it will still have its final reference count, so methods can be called on it from within this function.

=end pod

subset GSourceFuncPrepare of Routine
  where .signature ~~ :( N-GObject $source, gint $timeout --> gboolean );
subset GSourceFuncCheck of Routine where .signature ~~ :( N-GObject $source --> gboolean );
subset GSourceFuncDispatch of Routine
  where .signature ~~ :(
    N-GObject source, GSourceFunc $callback, gpointer $user_data
    --> gboolean
  );
subset GSourceFuncFinalize of Routine where .signature ~~ :( N-GObject $source);

#TT:0:N-GSourceFuncs:
class N-GSourceFuncs is repr('CStruct') {
  has GSourceFuncPrepare $.prepare is rw;
  has GSourceFuncCheck $.check is rw;
  has GSourceFuncDispatch $.dispatch is rw;
  has GSourceFuncFinalize $.finalize is rw;
};
}}

#-------------------------------------------------------------------------------
=begin pod
=head1 Methods
=head2 new

=head3 :idle

Create a new Source object to run processes in idle time. The source will not initially be associated with any B<Gnome::Glib::MainContext> and must be added to one with C<attach()> before it will be executed. Note that the default priority for idle sources is C<G-PRIORITY-DEFAULT-IDLE>, as compared to other sources which have a default priority of C<G-PRIORITY-DEFAULT>.

  multi method new ( :idle! )


=head3 :timout

Creates a new timeout source. The source will not initially be associated with any B<Gnome::Glib::MainContext> and must be added to one with C<attach()> before it will be executed.

The interval given is in terms of monotonic time, not wall clock time. See C<get-monotonic-time()>.

  multi method new ( Int :$timeout!, Bool :$seconds = False )

=item UInt $interval; the timeout interval in milliseconds.


=head3 :native-object

Create a Source object using a native object from elsewhere. See also B<Gnome::N::TopLevelClassSupport>.

  multi method new ( N-GObject :$native-object! )

=end pod

#TM:1:new(:idle):
#TM:4:new(:native-object):Gnome::N::TopLevelClassSupport
submethod BUILD ( *%options ) {

  # prevent creating wrong native-objects
  if self.^name eq 'Gnome::Glib::Source' #`{{ or %options<GSource> }} {

    # check if native object is set by a parent class
    if self.is-valid { }

    # check if common options are handled by some parent
    elsif %options<native-object>:exists { }
    elsif %options<build-id>:exists { }

    # process all other options
    else {
      my $no;
      if %options<idle>:exists {
        $no = _g_idle_source_new;
      }

      elsif ? %options<timeout> {
        my Bool $seconds = %options<seconds> // False;
        if $seconds {
          $no = _g_timeout_source_new_seconds(%options<timeout>);
        }

        else {
          $no = _g_timeout_source_new(%options<timeout>);
        }
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

      ##`{{ when there are no defaults use this
      # check if there are any options
      elsif %options.elems == 0 {
        die X::Gnome.new(:message('No options specified ' ~ self.^name));
      }
      #}}

      #`{{ when there are defaults use this instead
      # create default object
      else {
        $no = _g_source_new();
      }
      }}

      self._set-native-object($no);
    }

    # only after creating the native-object, the gtype is known
    self._set-class-info('GSource');
  }
}

#-------------------------------------------------------------------------------
method native-object-ref ( $n-native-object --> N-GObject ) {
  _g_source_ref($n-native-object)
}

#-------------------------------------------------------------------------------
method native-object-unref ( $n-native-object ) {
  _g_source_unref($n-native-object)
}

#`{{
#-------------------------------------------------------------------------------
#TM:0:add-child-source:
=begin pod
=head2 add-child-source

Adds I<child-source> to I<source> as a "polled" source; when I<source> is added to a B<Gnome::Glib::MainContext>, I<child-source> will be automatically added with the same priority, when I<child-source> is triggered, it will cause I<source> to dispatch (in addition to calling its own callback), and when I<source> is destroyed, it will destroy I<child-source> as well. (I<source> will also still be dispatched if its own prepare/check functions indicate that it is ready.)

If you don't need I<child-source> to do anything on its own when it triggers, you can call C<set-dummy-callback()> on it to set a callback that does nothing (except return C<True> if appropriate).

I<source> will hold a reference on I<child-source> while I<child-source> is attached to it.

This API is only intended to be used by implementations of B<Gnome::Glib::Source>. Do not call this API on a B<Gnome::Glib::Source> that you did not create.

  method add-child-source ( N-GObject $child_source )

=item N-GObject $child_source; a second B<Gnome::Glib::Source> that I<source> should "poll"
=end pod

method add-child-source ( N-GObject $child_source ) {

  g_source_add_child_source(
    self._get-native-object-no-reffing, $child_source
  );
}

sub g_source_add_child_source (
  N-GObject $source, N-GObject $child_source
) is native(&glib-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
#TM:0:add-poll:
=begin pod
=head2 add-poll

Adds a file descriptor to the set of file descriptors polled for this source. This is usually combined with C<new()> to add an event source. The event source's check function will typically test the I<revents> field in the B<Gnome::Glib::PollFD> struct and return C<True> if events need to be processed.

This API is only intended to be used by implementations of B<Gnome::Glib::Source>. Do not call this API on a B<Gnome::Glib::Source> that you did not create.

Using this API forces the linear scanning of event sources on each main loop iteration. Newly-written event sources should try to use C<g-source-add-unix-fd()> instead of this API.

  method add-poll ( GPollFD $fd )

=item GPollFD $fd; a B<Gnome::Glib::PollFD> structure holding information about a file descriptor to watch.
=end pod

method add-poll ( GPollFD $fd ) {

  g_source_add_poll(
    self._get-native-object-no-reffing, $fd
  );
}

sub g_source_add_poll (
  N-GObject $source, GPollFD $fd
) is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:add-unix-fd:
=begin pod
=head2 add-unix-fd

Monitors I<fd> for the IO events in I<events>.

The tag returned by this function can be used to remove or modify the monitoring of the fd using C<remove-unix-fd()> or C<g-source-modify-unix-fd()>.

It is not necessary to remove the fd before destroying the source; it will be cleaned up automatically.

This API is only intended to be used by implementations of B<Gnome::Glib::Source>. Do not call this API on a B<Gnome::Glib::Source> that you did not create.

As the name suggests, this function is not available on Windows.

Returns: an opaque tag

  method add-unix-fd ( Int $fd, GIOCondition $events --> Pointer )

=item Int $fd; the fd to monitor
=item GIOCondition $events; an event mask
=end pod

method add-unix-fd ( Int $fd, GIOCondition $events --> Pointer ) {

  g_source_add_unix_fd(
    self._get-native-object-no-reffing, $fd, $events
  )
}

sub g_source_add_unix_fd (
  N-GObject $source, gint $fd, GIOCondition $events --> gpointer
) is native(&glib-lib)
  { * }
}}
}}

#-------------------------------------------------------------------------------
#TM:0:attach:
=begin pod
=head2 attach

Adds a B<Gnome::Glib::Source> to a I<context> so that it will be executed within that context. Remove it by calling C<destroy()>.

Returns: the ID (greater than 0) for the source within the B<Gnome::Glib::MainContext>.

  method attach ( N-GObject $context --> UInt )

=item N-GObject $context; a B<Gnome::Glib::MainContext> (if C<undefined>, the default context will be used)
=end pod

method attach ( $context is copy --> UInt ) {
  $context .= _get-native-object-no-reffing unless $context ~~ N-GObject;
  g_source_attach( self._get-native-object-no-reffing, $context)
}

sub g_source_attach (
  N-GObject $source, N-GObject $context --> guint
) is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:destroy:
=begin pod
=head2 destroy

Removes a source from its B<Gnome::Glib::MainContext>, if any, and mark it as destroyed. The source cannot be subsequently added to another context. It is safe to call this on sources which have already been removed from their context.

  method destroy ( )

=end pod

method destroy ( ) {
  g_source_destroy(self._get-native-object-no-reffing);
}

sub g_source_destroy ( N-GObject $source )
  is native(&glib-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
#TM:0:g-child-watch-add:
=begin pod
=head2 g-child-watch-add

Sets a function to be called when the child indicated by I<pid> exits, at a default priority, C<G-PRIORITY-DEFAULT>.

If you obtain I<pid> from C<g-spawn-async()> or C<g-spawn-async-with-pipes()> you will need to pass B<Gnome::Glib::-SPAWN-DO-NOT-REAP-CHILD> as flag to the spawn function for the child watching to work.

Note that on platforms where B<Gnome::Glib::Pid> must be explicitly closed (see C<g-spawn-close-pid()>) I<pid> must not be closed while the source is still active. Typically, you will want to call C<g-spawn-close-pid()> in the callback function for the source.

GLib supports only a single callback per process id. On POSIX platforms, the same restrictions mentioned for C<g-child-watch-source-new()> apply to this function.

This internally creates a main loop source using C<g-child-watch-source-new()> and attaches it to the main loop context using C<attach()>. You can do these steps manually if you need greater control.

Returns: the ID (greater than 0) of the event source.

  method g-child-watch-add ( GPid $pid, GChildWatchFunc $function, Pointer $data --> UInt )

=item GPid $pid; process id to watch. On POSIX the positive pid of a child process. On Windows a handle for a process (which doesn't have to be a child).
=item GChildWatchFunc $function; function to call
=item Pointer $data; data to pass to I<function>
=end pod

method g-child-watch-add ( GPid $pid, GChildWatchFunc $function, Pointer $data --> UInt ) {

  g_child_watch_add(
    self._get-native-object-no-reffing, $pid, $function, $data
  )
}

sub g_child_watch_add (
  GPid $pid, GChildWatchFunc $function, gpointer $data --> guint
) is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g-child-watch-add-full:
=begin pod
=head2 g-child-watch-add-full

Sets a function to be called when the child indicated by I<pid> exits, at the priority I<priority>.

If you obtain I<pid> from C<g-spawn-async()> or C<g-spawn-async-with-pipes()> you will need to pass B<Gnome::Glib::-SPAWN-DO-NOT-REAP-CHILD> as flag to the spawn function for the child watching to work.

In many programs, you will want to call C<g-spawn-check-exit-status()> in the callback to determine whether or not the child exited successfully.

Also, note that on platforms where B<Gnome::Glib::Pid> must be explicitly closed (see C<g-spawn-close-pid()>) I<pid> must not be closed while the source is still active. Typically, you should invoke C<g-spawn-close-pid()> in the callback function for the source.

GLib supports only a single callback per process id. On POSIX platforms, the same restrictions mentioned for C<g-child-watch-source-new()> apply to this function.

This internally creates a main loop source using C<g-child-watch-source-new()> and attaches it to the main loop context using C<attach()>. You can do these steps manually if you need greater control.

Returns: the ID (greater than 0) of the event source.

  method g-child-watch-add-full ( Int $priority, GPid $pid, GChildWatchFunc $function, Pointer $data, GDestroyNotify $notify --> UInt )

=item Int $priority; the priority of the idle source. Typically this will be in the range between C<G-PRIORITY-DEFAULT-IDLE> and C<G-PRIORITY-HIGH-IDLE>.
=item GPid $pid; process to watch. On POSIX the positive pid of a child process. On Windows a handle for a process (which doesn't have to be a child).
=item GChildWatchFunc $function; function to call
=item Pointer $data; data to pass to I<function>
=item GDestroyNotify $notify; function to call when the idle is removed, or C<undefined>
=end pod

method g-child-watch-add-full ( Int $priority, GPid $pid, GChildWatchFunc $function, Pointer $data, GDestroyNotify $notify --> UInt ) {

  g_child_watch_add_full(
    self._get-native-object-no-reffing, $priority, $pid, $function, $data, $notify
  )
}

sub g_child_watch_add_full (
  gint $priority, GPid $pid, GChildWatchFunc $function, gpointer $data, GDestroyNotify $notify --> guint
) is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g-child-watch-source-new:
=begin pod
=head2 g-child-watch-source-new

Creates a new child-watch source.

The source will not initially be associated with any B<Gnome::Glib::MainContext> and must be added to one with C<attach()> before it will be executed.

Note that child watch sources can only be used in conjunction with `g-spawn...` when the C<G-SPAWN-DO-NOT-REAP-CHILD> flag is used.

Note that on platforms where B<Gnome::Glib::Pid> must be explicitly closed (see C<g-spawn-close-pid()>) I<pid> must not be closed while the source is still active. Typically, you will want to call C<g-spawn-close-pid()> in the callback function for the source.

On POSIX platforms, the following restrictions apply to this API due to limitations in POSIX process interfaces:

* I<pid> must be a child of this process * I<pid> must be positive * the application must not call `waitpid` with a non-positive first argument, for instance in another thread * the application must not wait for I<pid> to exit by any other mechanism, including `waitpid(pid, ...)` or a second child-watch source for the same I<pid> * the application must not ignore SIGCHILD

If any of those conditions are not met, this and related APIs will not work correctly. This can often be diagnosed via a GLib warning stating that `ECHILD` was received by `waitpid`.

Calling `waitpid` for specific processes other than I<pid> remains a valid thing to do.

Returns: the newly-created child watch source

  method g-child-watch-source-new ( GPid $pid --> N-GObject )

=item GPid $pid; process to watch. On POSIX the positive pid of a child process. On Windows a handle for a process (which doesn't have to be a child).
=end pod

method g-child-watch-source-new ( GPid $pid --> N-GObject ) {

  g_child_watch_source_new(
    self._get-native-object-no-reffing, $pid
  )
}

sub g_child_watch_source_new (
  GPid $pid --> N-GObject
) is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g-clear-handle-id:
=begin pod
=head2 g-clear-handle-id

Clears a numeric handler, such as a B<Gnome::Glib::Source> ID.

I<tag-ptr> must be a valid pointer to the variable holding the handler.

If the ID is zero then this function does nothing. Otherwise, C<clear-func()> is called with the ID as a parameter, and the tag is set to zero.

A macro is also included that allows this function to be used without pointer casts.

  method g-clear-handle-id ( guInt-ptr $tag_ptr, GClearHandleFunc $clear_func )

=item guInt-ptr $tag_ptr; a pointer to the handler ID
=item GClearHandleFunc $clear_func; the function to call to clear the handler
=end pod

method g-clear-handle-id ( guInt-ptr $tag_ptr, GClearHandleFunc $clear_func ) {

  g_clear_handle_id(
    self._get-native-object-no-reffing, $tag_ptr, $clear_func
  );
}

sub g_clear_handle_id (
  gugint-ptr $tag_ptr, GClearHandleFunc $clear_func
) is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g-get-current-time:
=begin pod
=head2 g-get-current-time

Equivalent to the UNIX C<gettimeofday()> function, but portable.

You may find C<g-get-real-time()> to be more convenient.

  method g-get-current-time ( GTimeVal $result )

=item GTimeVal $result; B<Gnome::Glib::TimeVal> structure in which to store current time.
=end pod

method g-get-current-time ( GTimeVal $result ) {

  g_get_current_time(
    self._get-native-object-no-reffing, $result
  );
}

sub g_get_current_time (
  GTimeVal $result
) is native(&glib-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:0:get-monotonic-time:
=begin pod
=head2 get-monotonic-time

Queries the system monotonic time.

The monotonic clock will always increase and doesn't suffer discontinuities when the user (or NTP) changes the system time. It may or may not continue to tick during times where the machine is suspended.

We try to use the clock that corresponds as closely as possible to the passage of time as measured by system calls such as C<poll()> but it may not always be possible to do this.

Returns: the monotonic time, in microseconds

  method get-monotonic-time ( --> Int )

=end pod

method get-monotonic-time ( --> Int ) {
  g_get_monotonic_time
}

sub g_get_monotonic_time ( --> gint64 )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-real-time:
=begin pod
=head2 get-real-time

Queries the system wall-clock time.

This call is functionally equivalent to C<g-get-current-time()> except that the return value is often more convenient than dealing with a B<Gnome::Glib::TimeVal>.

You should only use this call if you are actually interested in the real wall-clock time. C<g-get-monotonic-time()> is probably more useful for measuring intervals.

Returns: the number of microseconds since January 1, 1970 UTC.

  method get-real-time ( --> Int )

=end pod

method get-real-time ( --> Int ) {

  g_get_real_time
}

sub g_get_real_time ( --> gint64 )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-can-recurse:
=begin pod
=head2 get-can-recurse

Checks whether a source is allowed to be called recursively. see C<set-can-recurse()>.

Returns: whether recursion is allowed.

  method get-can-recurse ( --> Bool )

=end pod

method get-can-recurse ( --> Bool ) {

  g_source_get_can_recurse(
    self._get-native-object-no-reffing,
  ).Bool
}

sub g_source_get_can_recurse (
  N-GObject $source --> gboolean
) is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-context:
=begin pod
=head2 get-context

Gets the B<Gnome::Glib::MainContext> with which the source is associated.

You can call this on a source that has been destroyed, provided that the B<Gnome::Glib::MainContext> it was attached to still exists (in which case it will return that B<Gnome::Glib::MainContext>). In particular, you can always call this function on the source returned from C<g-main-current-source()>. But calling this function on a source whose B<Gnome::Glib::MainContext> has been destroyed is an error.

Returns: the B<Gnome::Glib::MainContext> with which the source is associated, or C<undefined> if the context has not yet been added to a source.

  method get-context ( --> N-GObject )

=end pod

method get-context ( --> N-GObject ) {

  g_source_get_context(
    self._get-native-object-no-reffing,
  )
}

sub g_source_get_context (
  N-GObject $source --> N-GObject
) is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-id:
=begin pod
=head2 get-id

Returns the numeric ID for a particular source. The ID of a source is a positive integer which is unique within a particular main loop context. The reverse mapping from ID to source is done by C<g-main-context-find-source-by-id()>.

You can only call this function while the source is associated to a B<Gnome::Glib::MainContext> instance; calling this function before C<attach()> or after C<g-source-destroy()> yields undefined behavior. The ID returned is unique within the B<Gnome::Glib::MainContext> instance passed to C<g-source-attach()>.

Returns: the ID (greater than 0) for the source

  method get-id ( --> UInt )

=end pod

method get-id ( --> UInt ) {
  g_source_get_id(self._get-native-object-no-reffing)
}

sub g_source_get_id (
  N-GObject $source --> guint
) is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-name:
=begin pod
=head2 get-name

Gets a name for the source, used in debugging and profiling. The name may be B<NULL> if it has never been set with C<set-name()>.

Returns: the name of the source

  method get-name ( --> Str )

=end pod

method get-name ( --> Str ) {
  g_source_get_name(self._get-native-object-no-reffing)
}

sub g_source_get_name (
  N-GObject $source --> gchar-ptr
) is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-priority:
=begin pod
=head2 get-priority

Gets the priority of a source.

Returns: the priority of the source

  method get-priority ( --> Int )

=end pod

method get-priority ( --> Int ) {
  g_source_get_priority(self._get-native-object-no-reffing)
}

sub g_source_get_priority (
  N-GObject $source --> gint
) is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-ready-time:
=begin pod
=head2 get-ready-time

Gets the "ready time" of I<source>, as set by C<set-ready-time()>.

Any time before the current monotonic time (including 0) is an indication that the source will fire immediately.

Returns: the monotonic ready time, -1 for "never"

  method get-ready-time ( --> Int )

=end pod

method get-ready-time ( --> Int ) {
  g_source_get_ready_time(self._get-native-object-no-reffing)
}

sub g_source_get_ready_time (
  N-GObject $source --> gint64
) is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-time:
=begin pod
=head2 get-time

Gets the time to be used when checking this source. The advantage of calling this function over calling C<g-get-monotonic-time()> directly is that when checking multiple sources, GLib can cache a single value instead of having to repeatedly get the system monotonic time.

The time here is the system monotonic time, if available, or some other reasonable alternative otherwise. See C<g-get-monotonic-time()>.

Returns: the monotonic time in microseconds

  method get-time ( --> Int )

=end pod

method get-time ( --> Int ) {
  g_source_get_time(self._get-native-object-no-reffing)
}

sub g_source_get_time (
  N-GObject $source --> gint64
) is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:idle-add:
=begin pod
=head2 idle-add

Adds a function to be called whenever there are no higher priority events pending to the default main loop. The function is given the default idle priority, C<G-PRIORITY-DEFAULT-IDLE>. If the function returns C<False> it is automatically removed from the list of event sources and will not be called again.

=comment See [memory management of sources][mainloop-memory-management] for details on how to handle the return value and memory management of I<data>.

This internally creates a main loop source using C<g-idle-source-new()> and attaches it to the global B<Gnome::Glib::MainContext> using C<attach()>, so the callback will be invoked in whichever thread is running that main context. You can do these steps manually if you need greater control or to use a custom main context.

Returns: the ID (greater than 0) of the event source.

  method idle-add (
    Any:D $handler-object, Str:D $method, *%user-options
    --> UInt
  )

=item $handler-object; User object where $method is defined
=item Str $method; name of callback handler
=item %user-options; optional named arguments to be provided to the callback

=end pod

method idle-add (
  Any:D $handler-object, Str:D $method, *%user-options
  --> UInt
) {
  die X::Gnome.new(:message("Method $method or handler object not found"))
    unless $handler-object.^can($method);

  g_idle_add(
    sub ( gpointer $d --> gboolean ) {
      $handler-object."$method"(|%user-options);
    },
    gpointer
  )
}

sub g_idle_add (
  Callable $func ( gpointer --> gboolean ),
  gpointer $data --> guint
) is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:idle-add-full:
=begin pod
=head2 idle-add-full

Adds a function to be called whenever there are no higher priority events pending. If the function returns C<False> it is automatically removed from the list of event sources and will not be called again.

=comment See [memory management of sources][mainloop-memory-management] for details on how to handle the return value and memory management of I<data>.

This internally creates a main loop source using C<g-idle-source-new()> and attaches it to the global B<Gnome::Glib::MainContext> using C<attach()>, so the callback will be invoked in whichever thread is running that main context. You can do these steps manually if you need greater control or to use a custom main context.

Returns: the ID (greater than 0) of the event source.

  method idle-add-full (
    Int $priority,
    Any:D $handler-object, Str:D $method, Str $method-notify = Str,
    *%user-options
    --> UInt
  )

=item Int $priority; the priority of the idle source. Typically this will be in the range between C<G-PRIORITY-DEFAULT-IDLE> and C<G-PRIORITY-HIGH-IDLE>.
=item $handler-object; User object where both methods are defined
=item Str $method; name of callback handler
=item Str $method-notify; name of callback handler. Ignored when $method-notify is undefined. This function is called when the source is removed.
=item %user-options; optional named arguments to be provided to both callbacks
=end pod

method idle-add-full (
  Int $priority,
  Any:D $handler-object, Str:D $method, Str $method-notify = Str,
  *%user-options
  --> UInt
) {
  die X::Gnome.new(:message("Method $method or handler object not found"))
    unless $handler-object.^can($method);

  if ?$method-notify and $handler-object.can($method-notify) {
    g_idle_add_full(
      $priority,
      sub ( gpointer $d --> gboolean ) {
        $handler-object."$method"(|%user-options);
      }, gpointer,
      sub ( gpointer $d ) {
        $handler-object."$method-notify"(|%user-options);
      },
    )
  }

  else {
    g_idle_add_full(
      $priority,
      sub ( gpointer $d --> gboolean ) {
        $handler-object."$method"(|%user-options);
      }, gpointer,
      Nil
    )
  }
}

sub g_idle_add_full (
  gint $priority,
  Callable $func ( gpointer --> gboolean ), gpointer $data,
  Callable $notify ( gpointer )
  --> guint
) is native(&glib-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
#TM:0:idle-remove-by-data:
=begin pod
=head2 idle-remove-by-data

Removes the idle function with the given data.

Returns: C<True> if an idle source was found and removed.

  method idle-remove-by-data ( Pointer $data --> Bool )

=item Pointer $data; the data for the idle source's callback.
=end pod

method idle-remove-by-data ( Pointer $data --> Bool ) {

  g_idle_remove_by_data(
    self._get-native-object-no-reffing, $data
  ).Bool
}

sub g_idle_remove_by_data (
  gpointer $data --> gboolean
) is native(&glib-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:1:_g_idle_source_new:
#`{{
=begin pod
=head2 g-idle-source-new

Creates a new idle source.

The source will not initially be associated with any B<Gnome::Glib::MainContext> and must be added to one with C<attach()> before it will be executed. Note that the default priority for idle sources is C<G-PRIORITY-DEFAULT-IDLE>, as compared to other sources which have a default priority of C<G-PRIORITY-DEFAULT>.

Returns: the newly-created idle source

  method g-idle-source-new ( --> N-GObject )

=end pod

method g-idle-source-new ( --> N-GObject ) {

  g_idle_source_new
}
}}

sub _g_idle_source_new ( --> N-GObject )
  is native(&glib-lib)
  is symbol('g_idle_source_new')
  { * }

#`{{
#-------------------------------------------------------------------------------
#TM:0:is-destroyed:
=begin pod
=head2 is-destroyed

Returns whether I<source> has been destroyed.

This is important when you operate upon your objects from within idle handlers, but may have freed the object before the dispatch of your idle handler.

=begin comment
static gboolean
idle_callback (gpointer data)
{
  SomeWidget *self = data;

  GDK_THREADS_ENTER ();
  // do stuff with self
  self->idle_id = 0;
  GDK_THREADS_LEAVE ();

  return G_SOURCE_REMOVE;
}

static void
some_widget_do_stuff_later (SomeWidget *self)
{
  self->idle_id = g_idle_add (idle_callback, self);
}

static void
some_widget_finalize (GObject *object)
{
  SomeWidget *self = SOME_WIDGET (object);

  if (self->idle_id)
    g_source_remove (self->idle_id);

  G_OBJECT_CLASS (parent_class)->finalize (object);
}
=end comment

This will fail in a multi-threaded application if the widget is destroyed before the idle handler fires due to the use after free in the callback. A solution, to this particular problem, is to check to if the source has already been destroy within the callback.

=begin comment
static gboolean
idle_callback (gpointer data)
{
  SomeWidget *self = data;

  GDK_THREADS_ENTER ();
  if (!g_source_is_destroyed (g_main_current_source ()))
    {
      // do stuff with self
    }
  GDK_THREADS_LEAVE ();

  return FALSE;
}
=end comment

Calls to this function from a thread other than the one acquired by the B<Gnome::Glib::MainContext> the B<Gnome::Glib::Source> is attached to are typically redundant, as the source could be destroyed immediately after this function returns. However, once a source is destroyed it cannot be un-destroyed, so this function can be used for opportunistic checks from any thread.

Returns: C<True> if the source has been destroyed

  method is-destroyed ( --> Bool )

=end pod

method is-destroyed ( --> Bool ) {
  g_source_is_destroyed(self._get-native-object-no-reffing).Bool
}

sub g_source_is_destroyed (
  N-GObject $source --> gboolean
) is native(&glib-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
#TM:0:modify-unix-fd:
=begin pod
=head2 modify-unix-fd

Updates the event mask to watch for the fd identified by I<tag>.

I<tag> is the tag returned from C<add-unix-fd()>.

If you want to remove a fd, don't set its event mask to zero. Instead, call C<g-source-remove-unix-fd()>.

This API is only intended to be used by implementations of B<Gnome::Glib::Source>. Do not call this API on a B<Gnome::Glib::Source> that you did not create.

As the name suggests, this function is not available on Windows.

  method modify-unix-fd ( Pointer $tag, GIOCondition $new_events )

=item Pointer $tag; the tag from C<add-unix-fd()>
=item GIOCondition $new_events; the new event mask to watch
=end pod

method modify-unix-fd ( Pointer $tag, GIOCondition $new_events ) {

  g_source_modify_unix_fd(
    self._get-native-object-no-reffing, $tag, $new_events
  );
}

sub g_source_modify_unix_fd (
  N-GObject $source, gpointer $tag, GIOCondition $new_events
) is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:query-unix-fd:
=begin pod
=head2 query-unix-fd

Queries the events reported for the fd corresponding to I<tag> on I<source> during the last poll.

The return value of this function is only defined when the function is called from the check or dispatch functions for I<source>.

This API is only intended to be used by implementations of B<Gnome::Glib::Source>. Do not call this API on a B<Gnome::Glib::Source> that you did not create.

As the name suggests, this function is not available on Windows.

Returns: the conditions reported on the fd

  method query-unix-fd ( Pointer $tag --> GIOCondition )

=item Pointer $tag; the tag from C<add-unix-fd()>
=end pod

method query-unix-fd ( Pointer $tag --> GIOCondition ) {

  g_source_query_unix_fd(
    self._get-native-object-no-reffing, $tag
  )
}

sub g_source_query_unix_fd (
  N-GObject $source, gpointer $tag --> GIOCondition
) is native(&glib-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:0:_g_source_ref:
#`{{
=begin pod
=head2 ref

Increases the reference count on a source by one.

Returns: I<source>

  method ref ( --> N-GObject )

=end pod

method ref ( --> N-GObject ) {

  g_source_ref(
    self._get-native-object-no-reffing,
  )
}
}}

sub _g_source_ref (
  N-GObject $source --> N-GObject
) is native(&glib-lib)
  is symbol('g_source_ref')
  { * }

#-------------------------------------------------------------------------------
#TM:0:remove:
=begin pod
=head2 remove

Removes the source with the given ID from the default main context. You must use C<destroy()> for sources added to a non-default main context.

The ID of a B<Gnome::Glib::Source> is given by C<g-source-get-id()>, or will be returned by the functions C<g-source-attach()>, C<g-idle-add()>, C<g-idle-add-full()>, C<g-timeout-add()>, C<g-timeout-add-full()>, C<g-child-watch-add()>, C<g-child-watch-add-full()>, C<g-io-add-watch()>, and C<g-io-add-watch-full()>.

It is a programmer error to attempt to remove a non-existent source.

More specifically: source IDs can be reissued after a source has been destroyed and therefore it is never valid to use this function with a source ID which may have already been removed. An example is when scheduling an idle to run in another thread with C<g-idle-add()>: the idle may already have run and been removed by the time this function is called on its (now invalid) source ID. This source ID may have been reissued, leading to the operation being performed against the wrong source.

Returns: For historical reasons, this function always returns C<True>

  method remove ( UInt $tag --> Bool )

=item UInt $tag; the ID of the source to remove.
=end pod

method remove ( UInt $tag --> Bool ) {

  g_source_remove(
    self._get-native-object-no-reffing, $tag
  ).Bool
}

sub g_source_remove (
  guint $tag --> gboolean
) is native(&glib-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
#TM:0:remove-by-funcs-user-data:
=begin pod
=head2 remove-by-funcs-user-data

Removes a source from the default main loop context given the source functions and user data. If multiple sources exist with the same source functions and user data, only one will be destroyed.

Returns: C<True> if a source was found and removed.

  method remove-by-funcs-user-data ( N-GSourceFuncs $funcs, Pointer $user_data --> Bool )

=item N-GSourceFuncs $funcs; The I<source-funcs> passed to C<new()>
=item Pointer $user_data; the user data for the callback
=end pod

method remove-by-funcs-user-data ( N-GSourceFuncs $funcs, Pointer $user_data --> Bool ) {

  g_source_remove_by_funcs_user_data(
    self._get-native-object-no-reffing, $funcs, $user_data
  ).Bool
}

sub g_source_remove_by_funcs_user_data (
  N-GSourceFuncs $funcs, gpointer $user_data --> gboolean
) is native(&glib-lib)
  { * }
}}
#`{{
#-------------------------------------------------------------------------------
#TM:0:remove-by-user-data:
=begin pod
=head2 remove-by-user-data

Removes a source from the default main loop context given the user data for the callback. If multiple sources exist with the same user data, only one will be destroyed.

Returns: C<True> if a source was found and removed.

  method remove-by-user-data ( Pointer $user_data --> Bool )

=item Pointer $user_data; the user-data for the callback.
=end pod

method remove-by-user-data ( Pointer $user_data --> Bool ) {

  g_source_remove_by_user_data(
    self._get-native-object-no-reffing, $user_data
  ).Bool
}

sub g_source_remove_by_user_data (
  gpointer $user_data --> gboolean
) is native(&glib-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:0:remove-child-source:
=begin pod
=head2 remove-child-source

Detaches I<child-source> from I<source> and destroys it.

This API is only intended to be used by implementations of B<Gnome::Glib::Source>. Do not call this API on a B<Gnome::Glib::Source> that you did not create.

  method remove-child-source ( N-GObject $child_source )

=item N-GObject $child_source; a B<Gnome::Glib::Source> previously passed to C<add-child-source()>.
=end pod

method remove-child-source ( N-GObject $child_source ) {

  g_source_remove_child_source(
    self._get-native-object-no-reffing, $child_source
  );
}

sub g_source_remove_child_source (
  N-GObject $source, N-GObject $child_source
) is native(&glib-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
#TM:0:remove-poll:
=begin pod
=head2 remove-poll

Removes a file descriptor from the set of file descriptors polled for this source.

This API is only intended to be used by implementations of B<Gnome::Glib::Source>. Do not call this API on a B<Gnome::Glib::Source> that you did not create.

  method remove-poll ( GPollFD $fd )

=item GPollFD $fd; a B<Gnome::Glib::PollFD> structure previously passed to C<add-poll()>.
=end pod

method remove-poll ( GPollFD $fd ) {

  g_source_remove_poll(
    self._get-native-object-no-reffing, $fd
  );
}

sub g_source_remove_poll (
  N-GObject $source, GPollFD $fd
) is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:remove-unix-fd:
=begin pod
=head2 remove-unix-fd

Reverses the effect of a previous call to C<add-unix-fd()>.

You only need to call this if you want to remove an fd from being watched while keeping the same source around. In the normal case you will just want to destroy the source.

This API is only intended to be used by implementations of B<Gnome::Glib::Source>. Do not call this API on a B<Gnome::Glib::Source> that you did not create.

As the name suggests, this function is not available on Windows.

  method remove-unix-fd ( Pointer $tag )

=item Pointer $tag; the tag from C<add-unix-fd()>
=end pod

method remove-unix-fd ( Pointer $tag ) {

  g_source_remove_unix_fd(
    self._get-native-object-no-reffing, $tag
  );
}

sub g_source_remove_unix_fd (
  N-GObject $source, gpointer $tag
) is native(&glib-lib)
  { * }
}}


#-------------------------------------------------------------------------------
#TM:0:set-callback:
=begin pod
=head2 set-callback

Sets the callback function for a source. The callback for a source is called from the source's dispatch function.

=comment The exact type of I<func> depends on the type of source; ie. you should not count on I<func> being called with I<data> as its first parameter. Cast I<func> with C<G-SOURCE-FUNC()> to avoid warnings about incompatible function types.

=comment See [memory management of sources][mainloop-memory-management] for details on how to handle memory management of I<data>.

Typically, you won't use this function. Instead use functions specific to the type of source you are using, such as C<g-idle-add()> or C<g-timeout-add()>.

It is safe to call this function multiple times on a source which has already been attached to a context. The changes will take effect for the next time the source is dispatched after this call returns.

  method set-callback (
    Any:D $handler-object, Str:D $method, Str $method-notify = Str,
    *%user-options
  )

=item $handler-object; User object where both methods are defined
=item Str $method; name of callback handler
=item Str $method-notify; name of callback handler. Ignored when $method-notify is undefined. This function is called when the source is removed.
=item %user-options; optional named arguments to be provided to both callbacks

=end pod

method set-callback (
  Any:D $handler-object, Str:D $method, Str $method-notify = Str,
  *%user-options
) {
  die X::Gnome.new(:message("Method $method or handler object not found"))
    unless $handler-object.^can($method);

  if ?$method-notify and $handler-object.can($method-notify) {
    g_source_set_callback(
      self._get-native-object-no-reffing,
      sub ( gpointer $d --> gboolean ) {
        $handler-object."$method"(|%user-options);
      }, gpointer,
      sub ( gpointer $d ) {
        $handler-object."$method-notify"(|%user-options);
      },
    )
  }

  else {

    g_source_set_callback(
      self._get-native-object-no-reffing,
      sub ( gpointer $d --> gboolean ) {
        $handler-object."$method"(|%user-options);
      }, gpointer,
      Callable
    )
  }
}

sub g_source_set_callback (
  N-GObject $source,
  Callable $func ( gpointer --> gboolean ),
  gpointer $data,
  Callable $notify ( gpointer )
) is native(&glib-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
# TM:0:set-callback-indirect:
=begin pod
=head2 set-callback-indirect

Sets the callback function storing the data as a refcounted callback "object". This is used internally. Note that calling C<set-callback-indirect()> assumes an initial reference count on I<callback-data>, and thus I<callback-funcs>->unref will eventually be called once more than I<callback-funcs>->ref.

It is safe to call this function multiple times on a source which has already been attached to a context. The changes will take effect for the next time the source is dispatched after this call returns.

  method set-callback-indirect ( Pointer $callback_data, N-GObjectCallbackFuncs $callback_funcs )

=item Pointer $callback_data; pointer to callback data "object"
=item N-GObjectCallbackFuncs $callback_funcs; functions for reference counting I<callback-data> and getting the callback and data
=end pod

method set-callback-indirect ( Pointer $callback_data, N-GObjectCallbackFuncs $callback_funcs ) {

  g_source_set_callback_indirect(
    self._get-native-object-no-reffing, $callback_data, $callback_funcs
  );
}

sub g_source_set_callback_indirect (
  N-GObject $source, gpointer $callback_data, N-GObjectCallbackFuncs $callback_funcs
) is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:set-can-recurse:
=begin pod
=head2 set-can-recurse

Sets whether a source can be called recursively. If I<can-recurse> is C<True>, then while the source is being dispatched then this source will be processed normally. Otherwise, all processing of this source is blocked until the dispatch function returns.

  method set-can-recurse ( Bool $can_recurse )

=item Bool $can_recurse; whether recursion is allowed for this source
=end pod

method set-can-recurse ( Bool $can_recurse ) {

  g_source_set_can_recurse(
    self._get-native-object-no-reffing, $can_recurse
  );
}

sub g_source_set_can_recurse (
  N-GObject $source, gboolean $can_recurse
) is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:set-funcs:
=begin pod
=head2 set-funcs

Sets the source functions (can be used to override default implementations) of an unattached source.

  method set-funcs ( N-GSourceFuncs $funcs )

=item N-GSourceFuncs $funcs; the new B<Gnome::Glib::SourceFuncs>
=end pod

method set-funcs ( N-GSourceFuncs $funcs ) {

  g_source_set_funcs(
    self._get-native-object-no-reffing, $funcs
  );
}

sub g_source_set_funcs (
  N-GObject $source, N-GSourceFuncs $funcs
) is native(&glib-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:0:set-name:
=begin pod
=head2 set-name

Sets a name for the source, used in debugging and profiling. The name defaults to B<NULL>.

The source name should describe in a human-readable way what the source does. For example, "X11 event queue" or "GTK+ repaint idle handler" or whatever it is.

It is permitted to call this function multiple times, but is not recommended due to the potential performance impact. For example, one could change the name in the "check" function of a B<Gnome::Glib::SourceFuncs> to include details like the event type in the source name.

Use caution if changing the name while another thread may be accessing it with C<get-name()>; that function does not copy the value, and changing the value will free it while the other thread may be attempting to use it.

  method set-name ( Str $name )

=item Str $name; debug name for the source
=end pod

method set-name ( Str $name ) {
  g_source_set_name(self._get-native-object-no-reffing, $name);
}

sub g_source_set_name (
  N-GObject $source, gchar-ptr $name
) is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:set-name-by-id:
=begin pod
=head2 set-name-by-id

Sets the name of a source using its ID.

This is a convenience utility to set source names from the return value of C<g-idle-add()>, C<timeout-add()>, etc.

It is a programmer error to attempt to set the name of a non-existent source.

More specifically: source IDs can be reissued after a source has been destroyed and therefore it is never valid to use this function with a source ID which may have already been removed. An example is when scheduling an idle to run in another thread with C<g-idle-add()>: the idle may already have run and been removed by the time this function is called on its (now invalid) source ID. This source ID may have been reissued, leading to the operation being performed against the wrong source.

  method set-name-by-id ( UInt $tag, Str $name )

=item UInt $tag; a B<Gnome::Glib::Source> ID
=item Str $name; debug name for the source
=end pod

method set-name-by-id ( UInt $tag, Str $name ) {

  g_source_set_name_by_id(
    self._get-native-object-no-reffing, $tag, $name
  );
}

sub g_source_set_name_by_id (
  guint $tag, gchar-ptr $name
) is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:set-priority:
=begin pod
=head2 set-priority

Sets the priority of a source. While the main loop is being run, a source will be dispatched if it is ready to be dispatched and no sources at a higher (numerically smaller) priority are ready to be dispatched.

A child source always has the same priority as its parent. It is not permitted to change the priority of a source once it has been added as a child of another source.

  method set-priority ( Int $priority )

=item Int $priority; the new priority.
=end pod

method set-priority ( Int $priority ) {

  g_source_set_priority(
    self._get-native-object-no-reffing, $priority
  );
}

sub g_source_set_priority (
  N-GObject $source, gint $priority
) is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:set-ready-time:
=begin pod
=head2 set-ready-time

Sets a B<Gnome::Glib::Source> to be dispatched when the given monotonic time is reached (or passed). If the monotonic time is in the past (as it always will be if I<ready-time> is 0) then the source will be dispatched immediately.

If I<ready-time> is -1 then the source is never woken up on the basis of the passage of time.

Dispatching the source does not reset the ready time. You should do so yourself, from the source dispatch function.

Note that if you have a pair of sources where the ready time of one suggests that it will be delivered first but the priority for the other suggests that it would be delivered first, and the ready time for both sources is reached during the same main context iteration, then the order of dispatch is undefined.

It is a no-op to call this function on a B<Gnome::Glib::Source> which has already been destroyed with C<destroy()>.

This API is only intended to be used by implementations of B<Gnome::Glib::Source>. Do not call this API on a B<Gnome::Glib::Source> that you did not create.

  method set-ready-time ( Int $ready_time )

=item Int $ready_time; the monotonic time at which the source will be ready, 0 for "immediately", -1 for "never"
=end pod

method set-ready-time ( Int $ready_time ) {

  g_source_set_ready_time(
    self._get-native-object-no-reffing, $ready_time
  );
}

sub g_source_set_ready_time (
  N-GObject $source, gint64 $ready_time
) is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:timeout-add:
=begin pod
=head2 timeout-add

Sets a function to be called at regular intervals, with the default priority, C<G-PRIORITY-DEFAULT>. The function is called repeatedly until it returns C<False>, at which point the timeout is automatically destroyed and the function will not be called again. The first call to the function will be at the end of the first I<$interval>.

Note that timeout functions may be delayed, due to the processing of other event sources. Thus they should not be relied on for precise timing. After each call to the timeout function, the time of the next timeout is recalculated based on the current time and the given interval (it does not try to 'catch up' time lost in delays).

=comment See [memory management of sources][mainloop-memory-management] for details on how to handle the return value and memory management of I<data>.

If you want to have a timer in the "seconds" range and do not care about the exact time of the first call of the timer, use the C<timeout-add-seconds()> function; this function allows for more optimizations and more efficient system power usage.

=comment This internally creates a main loop source using C<g-timeout-source-new()> and attaches it to the global B<Gnome::Glib::MainContext> using C<attach()>, so the callback will be invoked in whichever thread is running that main context. You can do these steps manually if you need greater control or to use a custom main context.

The interval given is in terms of monotonic time, not wall clock time. See C<get-monotonic-time()>.

Returns: the ID (greater than 0) of the event source.

  method timeout-add (
    UInt $interval,
    Any:D $handler-object, Str:D $method, *%user-options
    --> UInt
  )

=item UInt $interval; the time between calls to the function, in milliseconds (1/1000ths of a second)
=item $handler-object; User object where $method is defined
=item Str $method; name of callback handler
=item %user-options; optional named arguments to be provided to the callback
=end pod


method timeout-add (
  UInt $interval, Any:D $handler-object, Str:D $method, *%user-options
  --> UInt
) {
  die X::Gnome.new(:message("Method $method or handler object not found"))
    unless $handler-object.^can($method);

  g_timeout_add(
    $interval,
    sub ( gpointer $d --> gboolean ) {
      $handler-object."$method"(|%user-options);
    },
    gpointer
  )
}

sub g_timeout_add (
  guint $interval,
  Callable $func ( gpointer --> gboolean ),
  gpointer $data --> guint
) is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:timeout-add-full:
=begin pod
=head2 timeout-add-full

Sets a function to be called at regular intervals, with the given priority. The function is called repeatedly until it returns C<False>, at which point the timeout is automatically destroyed and the function will not be called again. The I<notify> function is called when the timeout is destroyed. The first call to the function will be at the end of the first I<interval>.

Note that timeout functions may be delayed, due to the processing of other event sources. Thus they should not be relied on for precise timing. After each call to the timeout function, the time of the next timeout is recalculated based on the current time and the given interval (it does not try to 'catch up' time lost in delays).

=comment See [memory management of sources][mainloop-memory-management] for details on how to handle the return value and memory management of I<data>.

This internally creates a main loop source using C<g-timeout-source-new()> and attaches it to the global B<Gnome::Glib::MainContext> using C<attach()>, so the callback will be invoked in whichever thread is running that main context. You can do these steps manually if you need greater control or to use a custom main context.

The interval given is in terms of monotonic time, not wall clock time. See C<g-get-monotonic-time()>.

Returns: the ID (greater than 0) of the event source.

  method timeout-add-full (
    Int $priority, UInt $interval,
    Any:D $handler-object, Str:D $method, Str $method-notify = Str,
    *%user-options
    --> UInt
  )

=item Int $priority; the priority of the timeout source. Typically this will be in the range between C<G-PRIORITY-DEFAULT> and C<G-PRIORITY-HIGH>.
=item UInt $interval; the time between calls to the function, in milliseconds (1/1000ths of a second)
=item $handler-object; User object where both methods are defined
=item Str $method; name of callback handler
=item Str $method-notify; name of callback handler. Ignored when $method-notify is undefined. This function is called when the source is removed.
=item %user-options; optional named arguments to be provided to both callbacks
=end pod

method timeout-add-full (
  Int $priority, UInt $interval,
  Any:D $handler-object, Str:D $method, Str $method-notify = Str,
  *%user-options
  --> UInt
) {
  die X::Gnome.new(:message("Method $method or handler object not found"))
    unless $handler-object.^can($method);

  if ?$method-notify and $handler-object.can($method-notify) {
    g_timeout_add_full(
      $priority, $interval,
      sub ( gpointer $d --> gboolean ) {
        $handler-object."$method"(|%user-options);
      }, gpointer,
      sub ( gpointer $d ) {
        $handler-object."$method-notify"(|%user-options);
      },
    )
  }

  else {
    g_timeout_add_full(
      $priority, $interval,
      sub ( gpointer $d --> gboolean ) {
        $handler-object."$method"(|%user-options);
      }, gpointer,
      Nil
    )
  }
}

sub g_timeout_add_full (
  gint $priority, guint $interval,
  Callable $func ( gpointer --> gboolean ), gpointer $data,
  Callable $notify ( gpointer )
  --> guint
) is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:timeout-add-seconds:
=begin pod
=head2 timeout-add-seconds

Sets a function to be called at regular intervals with the default priority, C<G-PRIORITY-DEFAULT>. The function is called repeatedly until it returns C<False>, at which point the timeout is automatically destroyed and the function will not be called again.

This internally creates a main loop source using C<g-timeout-source-new-seconds()> and attaches it to the main loop context using C<attach()>. You can do these steps manually if you need greater control. Also see C<timeout-add-seconds-full()>.

Note that the first call of the timer may not be precise for timeouts of one second. If you need finer precision and have such a timeout, you may want to use C<timeout-add()> instead.

=comment See [memory management of sources][mainloop-memory-management] for details on how to handle the return value and memory management of I<data>.

The interval given is in terms of monotonic time, not wall clock time. See C<g-get-monotonic-time()>.

Returns: the ID (greater than 0) of the event source.

  method timeout-add-seconds (
    UInt $interval, Any:D $handler-object, Str:D $method, *%user-options
    --> UInt
  )

=item UInt $interval; the time between calls to the function, in seconds
=item $handler-object; User object where $method is defined
=item Str $method; name of callback handler
=item %user-options; optional named arguments to be provided to the callback
=end pod

method timeout-add-seconds (
  UInt $interval, Any:D $handler-object, Str:D $method, *%user-options
  --> UInt
) {
  g_timeout_add_seconds(
    $interval,
    sub ( gpointer $d --> gboolean ) {
      $handler-object."$method"(|%user-options);
    },
    gpointer
  )
}

sub g_timeout_add_seconds (
  guint $interval,
  Callable $func ( gpointer --> gboolean ),
  gpointer $data --> guint
) is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:timeout-add-seconds-full:
=begin pod
=head2 timeout-add-seconds-full

Sets a function to be called at regular intervals, with I<priority>. The function is called repeatedly until it returns C<False>, at which point the timeout is automatically destroyed and the function will not be called again.

Unlike C<timeout-add()>, this function operates at whole second granularity. The initial starting point of the timer is determined by the implementation and the implementation is expected to group multiple timers together so that they fire all at the same time. To allow this grouping, the I<$interval> to the first timer is rounded and can deviate up to one second from the specified interval. Subsequent timer iterations will generally run at the specified interval.

Note that timeout functions may be delayed, due to the processing of other event sources. Thus they should not be relied on for precise timing. After each call to the timeout function, the time of the next timeout is recalculated based on the current time and the given I<$interval>

=comment See [memory management of sources][mainloop-memory-management] for details on how to handle the return value and memory management of I<data>.

If you want timing more precise than whole seconds, use C<timeout-add()> instead.

The grouping of timers to fire at the same time results in a more power and CPU efficient behavior so if your timer is in multiples of seconds and you don't require the first timer exactly one second from now, the use of C<timeout-add-seconds()> is preferred over C<timeout-add()>.

This internally creates a main loop source using C<timeout-source-new-seconds()> and attaches it to the main loop context using C<attach()>. You can do these steps manually if you need greater control.

The interval given is in terms of monotonic time, not wall clock time. See C<get-monotonic-time()>.

Returns: the ID (greater than 0) of the event source.

  method timeout-add-seconds-full (
    Int $priority, UInt $interval,
    Any:D $handler-object, Str:D $method, Str $method-notify = Str,
    *%user-options
    --> UInt
  )

=item Int $priority; the priority of the timeout source. Typically this will be in the range between C<G-PRIORITY-DEFAULT> and C<G-PRIORITY-HIGH>.
=item UInt $interval; the time between calls to the function, in seconds
=item $handler-object; User object where both methods are defined
=item Str $method; name of callback handler
=item Str $method-notify; name of callback handler. Ignored when $method-notify is undefined. This function is called when the source is removed.
=item %user-options; optional named arguments to be provided to both callbacks
=end pod

method timeout-add-seconds-full (
  Int $priority, UInt $interval,
  Any:D $handler-object, Str:D $method, Str $method-notify = Str,
  *%user-options
  --> UInt
) {
  die X::Gnome.new(:message("Method $method or handler object not found"))
    unless $handler-object.^can($method);

  if ?$method-notify and $handler-object.can($method-notify) {
    g_timeout_add_seconds_full(
      $priority, $interval,
      sub ( gpointer $d --> gboolean ) {
        $handler-object."$method"(|%user-options);
      }, gpointer,
      sub ( gpointer $d ) {
        $handler-object."$method-notify"(|%user-options);
      },
    )
  }

  else {
    g_timeout_add_seconds_full(
      $priority, $interval,
      sub ( gpointer $d --> gboolean ) {
        $handler-object."$method"(|%user-options);
      }, gpointer,
      Nil
    )
  }
}

sub g_timeout_add_seconds_full (
  gint $priority, guint $interval,
  Callable $func ( gpointer --> gboolean ),
  gpointer $data,
  Callable $notify ( gpointer )
  --> guint
) is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_timeout_source_new:
#`{{
=begin pod
=head2 g-timeout-source-new

Creates a new timeout source.

The source will not initially be associated with any B<Gnome::Glib::MainContext> and must be added to one with C<attach()> before it will be executed.

The interval given is in terms of monotonic time, not wall clock time. See C<g-get-monotonic-time()>.

Returns: the newly-created timeout source

  method g-timeout-source-new ( UInt $interval --> N-GObject )

=item UInt $interval; the timeout interval in milliseconds.
=end pod

method g-timeout-source-new ( UInt $interval --> N-GObject ) {

  g_timeout_source_new(
    self._get-native-object-no-reffing, $interval
  )
}
}}

sub _g_timeout_source_new ( guint $interval --> N-GObject )
  is native(&glib-lib)
  is symbol('g_timeout_source_new')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_timeout_source_new_seconds:
#`{{
=begin pod
=head2 g-timeout-source-new-seconds

Creates a new timeout source.

The source will not initially be associated with any B<Gnome::Glib::MainContext> and must be added to one with C<attach()> before it will be executed.

The scheduling granularity/accuracy of this timeout source will be in seconds.

The interval given is in terms of monotonic time, not wall clock time. See C<g-get-monotonic-time()>.

Returns: the newly-created timeout source

  method g-timeout-source-new-seconds ( UInt $interval --> N-GObject )

=item UInt $interval; the timeout interval in seconds
=end pod

method g-timeout-source-new-seconds ( UInt $interval --> N-GObject ) {

  g_timeout_source_new_seconds(
    self._get-native-object-no-reffing, $interval
  )
}
}}

sub _g_timeout_source_new_seconds (
  guint $interval --> N-GObject
) is native(&glib-lib)
  is symbol('g_timeout_source_new_seconds')
  { * }

#-------------------------------------------------------------------------------
#TM:0:_g_source_unref:
#`{{
=begin pod
=head2 unref

Decreases the reference count of a source by one. If the resulting reference count is zero the source and associated memory will be destroyed.

  method unref ( )

=end pod

method unref ( ) {

  g_source_unref(
    self._get-native-object-no-reffing,
  );
}
}}

sub _g_source_unref (
  N-GObject $source
) is native(&glib-lib)
  is symbol('g_source_unref')
  { * }

#`{{
#-------------------------------------------------------------------------------
#TM:1:_g_source_new:
#`{{
=begin pod
=head2 _g_source_new

Creates a new B<Gnome::Glib::Source> structure. The size is specified to allow creating structures derived from B<Gnome::Glib::Source> that contain additional data. The size passed in must be at least `sizeof (N-GObject)`.

The source will not initially be associated with any B<Gnome::Glib::MainContext> and must be added to one with C<attach()> before it will be executed.

Returns: the newly-created B<Gnome::Glib::Source>.

  method _g_source_new ( N-GSourceFuncs $source_funcs, UInt $struct_size --> N-GObject )

=item N-GSourceFuncs $source_funcs; structure containing functions that implement the sources behavior.
=item UInt $struct_size; size of the B<Gnome::Glib::Source> structure to create.
=end pod
}}

sub _g_source_new ( N-GSourceFuncs $source_funcs, guint $struct_size --> N-GObject )
  is native(&glib-lib)
  is symbol('g_source_new')
  { * }
}}
