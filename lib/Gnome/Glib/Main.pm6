use v6;

#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Glib::Error

The Main Event Loop — manages all available sources of events

=head1 Description

Note that this is a low level module, please take a look at B<Gnome::Gtk3::Main> first.

The main event loop manages all the available sources of events for GLib and GTK+ applications. These events can come from any number of different types of sources such as file descriptors (plain files, pipes or sockets) and timeouts. New types of event sources can also be added using C<g_source_attach()>.

To allow multiple independent sets of sources to be handled in different threads, each source is associated with a N-GMainContext. A N-GMainContext can only be running in a single thread, but sources can be added to it and removed from it from other threads. All functions which operate on a N-GMainContext or a built-in N-GSource are thread-safe.

Each event source is assigned a priority. The default priority, G_PRIORITY_DEFAULT, is 0. Values less than 0 denote higher priorities. Values greater than 0 denote lower priorities. Events from high priority sources are always processed before events from lower priority sources.

Idle functions can also be added, and assigned a priority. These will be run whenever no events with a higher priority are ready to be processed.

The N-GMainLoop data type represents a main event loop. A N-GMainLoop is created with g_main_loop_new(). After adding the initial event sources, g_main_loop_run() is called. This continuously checks for new events from each of the event sources and dispatches them. Finally, the processing of an event from one of the sources leads to a call to g_main_loop_quit() to exit the main loop, and g_main_loop_run() returns.

It is possible to create new instances of N-GMainLoop recursively. This is often used in GTK+ applications when showing modal dialog boxes. Note that event sources are associated with a particular N-GMainContext, and will be checked and dispatched for all main loops associated with that N-GMainContext.

GTK+ contains wrappers of some of these functions, e.g. gtk_main(), gtk_main_quit() and gtk_events_pending().
Creating new source types

=begin comment
One of the unusual features of the N-GMainLoop functionality is that new types of event source can be created and used in addition to the builtin type of event source. A new event source type is used for handling GDK events. A new source type is created by "deriving" from the N-GSource structure. The derived type of source is represented by a structure that has the N-GSource structure as a first element, and other elements specific to the new source type. To create an instance of the new source type, call g_source_new() passing in the size of the derived structure and a table of functions. These GSourceFuncs determine the behavior of the new source type.

New source types basically interact with the main context in two ways. Their prepare function in GSourceFuncs can set a timeout to determine the maximum amount of time that the main loop will sleep before checking the source again. In addition, or as well, the source can add file descriptors to the set that the main context checks using g_source_add_poll().
Customizing the main loop iteration
=end comment

Single iterations of a N-GMainContext can be run with g_main_context_iteration(). In some cases, more detailed control of exactly how the details of the main loop work is desired, for instance, when integrating the N-GMainLoop with an external main loop. In such cases, you can call the component functiN-GMainContextons of g_main_context_iteration() directly. These functions are g_main_context_prepare(), g_main_context_query(), g_main_context_check() and g_main_context_dispatch().
State of a Main Context

The operation of these functions can best be seen in terms of a state diagram, as shown in this image.

![](images/mainloop-states.png)

On UNIX, the GLib mainloop is incompatible with fork(). Any program using the mainloop must either exec() or exit() from the child without returning to the mainloop.
Memory management of sources

There are two options for memory management of the user data passed to a N-GSource to be passed to its callback on invocation. This data is provided in calls to g_timeout_add(), g_timeout_add_full(), g_idle_add(), etc. and more generally, using g_source_set_callback(). This data is typically an object which ‘owns’ the timeout or idle callback, such as a widget or a network protocol implementation. In many cases, it is an error for the callback to be invoked after this owning object has been destroyed, as that results in use of freed memory.

The first, and preferred, option is to store the source ID returned by functions such as g_timeout_add() or g_source_attach(), and explicitly remove that source from the main context using g_source_remove() when the owning object is finalized. This ensures that the callback can only be invoked while the object is still alive.

The second option is to hold a strong reference to the object in the callback, and to release it in the callback’s GDestroyNotify. This ensures that the object is kept alive until after the source is finalized, which is guaranteed to be after it is invoked for the final time. The GDestroyNotify is another callback passed to the ‘full’ variants of N-GSource functions (for example, g_timeout_add_full()). It is called when the source is finalized, and is designed for releasing references like this.

One important caveat of this second approach is that it will keep the object alive indefinitely if the main loop is stopped before the N-GSource is invoked, which may be undesirable.


=head1 Synopsis
=head2 Declaration

  unit class Gnome::Glib::Main;


=comment head2 Example

=end pod

#-------------------------------------------------------------------------------
use NativeCall;

use Gnome::N::X;
#use Gnome::N::N-GObject;
use Gnome::N::NativeLib;
use Gnome::N::GlibToRakuTypes;

#-------------------------------------------------------------------------------
# See /usr/include/glib-2.0/gmain.h
unit class Gnome::Glib::Main:auth<github:MARTIMM>;

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

=begin comment
=item G_SOURCE_REMOVE; Use this macro as the return value of a GSourceFunc to leave the GSource in the main loop.
=item G_SOURCE_CONTINUE; Use this macro as the return value of a GSourceFunc to remove the GSource from the main loop.
=end comment

=end pod
#TT:0:constants:
constant G_PRIORITY_HIGH is export          = -100;
constant G_PRIORITY_DEFAULT is export       = 0;
constant G_PRIORITY_HIGH_IDLE is export     = 100;
constant G_PRIORITY_DEFAULT_IDLE is export  = 200;
constant G_PRIORITY_LOW is export           = 300;

constant G_SOURCE_REMOVE is export          = 0; # ~~ False
constant G_SOURCE_CONTINUE is export        = 1; # ~~ True

#-------------------------------------------------------------------------------
=begin pod
=head2 class N-GMainContext

The N-GMainContext struct is an opaque data type representing a set of sources to be handled in a main loop.
=end pod

#TT:1:N-GMainContext:
class N-GMainContext
  is repr('CPointer')
  is export
  { }

#-------------------------------------------------------------------------------
=begin pod
=head2 class N-GSource

The N-GSource struct is an opaque data type representing a set of sources to be handled in a main loop.
=end pod

#TT:1:N-GSource:
class N-GSource
  is repr('CPointer')
  is export
  { }

#-------------------------------------------------------------------------------
=begin pod
=head2 class N-GMainLoop

The N-GSource struct is an opaque data type representing a set of sources to be handled in a main loop.
=end pod

#TT:1:N-GMainLoop:
class N-GMainLoop
  is repr('CPointer')
  is export
  { }

#-------------------------------------------------------------------------------
=begin pod
=head1 Methods
=head2 new

=head3 default, no options

Create a new Main object.

  multi method new ( )

=end pod

#TM:1:new():
#TM:4:new(:native-object):Gnome::N::TopLevelClassSupport
#TM:4:new(:build-id):Gnome::GObject::Object
#submethod BUILD ( *%options ) { }

#-------------------------------------------------------------------------------
# no pod. user does not have to know about it.
method FALLBACK ( $native-sub is copy, |c ) {

  CATCH { .note; die; }

  $native-sub ~~ s:g/ '-' /_/ if $native-sub.index('-');
#  die X::Gnome.new(:message(
#    "Native sub name '$native-sub' made too short. Keep at least one '-' or '_'."
#    )
#  ) unless $native-sub.index('_') >= 0;

  my Callable $s;
  try { $s = &::("g_main_$native-sub"); };
  try { $s = &::("g_$native-sub"); } unless ?$s;
  try { $s = &::($native-sub); } if !$s and $native-sub ~~ m/^ 'g_' /;

  $s(|c)
}



#-------------------------------------------------------------------------------
#TM:0:g_main_context_new:
=begin pod
=head2 [[g_] main_] context_new

Creates a new B<N-GMainContext> structure.

Returns: the new B<N-GMainContext>

  method g_main_context_new ( --> N-GMainContext )


=end pod

sub g_main_context_new (  --> N-GMainContext )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_main_context_ref:
=begin pod
=head2 [[g_] main_] context_ref

Increases the reference count on a B<N-GMainContext> object by one.

Returns: the I<context> that was passed in (since 2.6)

  method g_main_context_ref ( N-GMainContext $context --> N-GMainContext )

=item N-GMainContext $context; a B<N-GMainContext>

=end pod

sub g_main_context_ref ( N-GMainContext $context --> N-GMainContext )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_main_context_unref:
=begin pod
=head2 [[g_] main_] context_unref

Decreases the reference count on a B<N-GMainContext> object by one. If the result is zero, free the context and free all associated memory.

  method g_main_context_unref ( N-GMainContext $context )

=item N-GMainContext $context; a B<N-GMainContext>

=end pod

sub g_main_context_unref ( N-GMainContext $context  )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_main_context_default:
=begin pod
=head2 [[g_] main_] context_default

Returns the global default main context. This is the main context used for main loop functions when a main loop is not explicitly specified, and corresponds to the "main" main loop. See also C<g_main_context_get_thread_default()>.

Returns: (transfer none): the global default main context.

  method g_main_context_default ( --> N-GMainContext )

=end pod

sub g_main_context_default (  --> N-GMainContext )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_main_context_iteration:
=begin pod
=head2 [[g_] main_] context_iteration

Runs a single iteration for the given main loop. This involves checking to see if any event sources are ready to be processed, then if no events sources are ready and I<may_block> is C<1>, waiting for a source to become ready, then dispatching the highest priority events sources that are ready. Otherwise, if I<may_block> is C<0> sources are not waited to become ready, only those highest priority events sources will be dispatched (if any), that are ready at this given moment without further waiting.  Note that even when I<may_block> is C<1>, it is still possible for C<g_main_context_iteration()> to return C<0>, since the wait may be interrupted for other reasons than an event source becoming ready.

Returns: C<1> if events were dispatched.

  method g_main_context_iteration ( N-GMainContext $context, Int $may_block --> Int )

=item N-GMainContext $context; (nullable): a B<N-GMainContext> (if C<Any>, the default context will be used)
=item Int $may_block; whether the call may block.

=end pod

sub g_main_context_iteration ( N-GMainContext $context, gboolean $may_block --> gboolean )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_main_context_pending:
=begin pod
=head2 [[g_] main_] context_pending

Checks if any sources have pending events for the given context.

Returns: C<1> if events are pending.

  method g_main_context_pending ( N-GMainContext $context --> Int )

=item N-GMainContext $context; (nullable): a B<N-GMainContext> (if C<Any>, the default context will be used)

=end pod

sub g_main_context_pending ( N-GMainContext $context --> gboolean )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_main_context_find_source_by_id:
=begin pod
=head2 [[g_] main_] context_find_source_by_id

Finds a B<N-GSource> given a pair of context and ID.  It is a programmer error to attempt to lookup a non-existent source.  More specifically: source IDs can be reissued after a source has been destroyed and therefore it is never valid to use this function with a source ID which may have already been removed.  An example is when scheduling an idle to run in another thread with C<g_idle_add()>: the idle may already have run and been removed by the time this function is called on its (now invalid) source ID.  This source ID may have been reissued, leading to the operation being performed against the wrong source.

Returns: (transfer none): the B<N-GSource>

  method g_main_context_find_source_by_id ( N-GMainContext $context, UInt $source_id --> N-GSource )

=item N-GMainContext $context; (nullable): a B<N-GMainContext> (if C<Any>, the default context will be used)
=item UInt $source_id; the source ID, as returned by C<g_source_get_id()>.

=end pod

sub g_main_context_find_source_by_id ( N-GMainContext $context, guint $source_id --> N-GSource )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_main_context_find_source_by_user_data:
=begin pod
=head2 [[g_] main_] context_find_source_by_user_data

Finds a source with the given user data for the callback.  If multiple sources exist with the same user data, the first one found will be returned.

Returns: (transfer none): the source, if one was found, otherwise C<Any>

  method g_main_context_find_source_by_user_data ( N-GMainContext $context, Pointer $user_data --> N-GSource )

=item N-GMainContext $context; a B<N-GMainContext>
=item Pointer $user_data; the user_data for the callback.

=end pod

sub g_main_context_find_source_by_user_data ( N-GMainContext $context, gpointer $user_data --> N-GSource )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_main_context_wakeup:
=begin pod
=head2 [[g_] main_] context_wakeup

If I<context> is currently blocking in C<g_main_context_iteration()> waiting for a source to become ready, cause it to stop blocking and return.  Otherwise, cause the next invocation of C<g_main_context_iteration()> to return without blocking.  This API is useful for low-level control over B<N-GMainContext>; for example, integrating it with main loop implementations such as B<N-GMainLoop>.  Another related use for this function is when implementing a main loop with a termination condition, computed from multiple threads:  |[<!-- language="C" -->  B<define> NUM_TASKS 10 static volatile gint tasks_remaining = NUM_TASKS; ...   while (g_atomic_int_get (&tasks_remaining) != 0) g_main_context_iteration (NULL, TRUE); ]|   Then in a thread: |[<!-- language="C" -->  C<perform_work()>;  if (g_atomic_int_dec_and_test (&tasks_remaining)) g_main_context_wakeup (NULL); ]|

  method g_main_context_wakeup ( N-GMainContext $context )

=item N-GMainContext $context; a B<N-GMainContext>

=end pod

sub g_main_context_wakeup ( N-GMainContext $context  )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_main_context_acquire:
=begin pod
=head2 [[g_] main_] context_acquire

Tries to become the owner of the specified context. If some other thread is the owner of the context, returns C<0> immediately. Ownership is properly recursive: the owner can require ownership again and will release ownership when C<g_main_context_release()> is called as many times as C<g_main_context_acquire()>.  You must be the owner of a context before you can call C<g_main_context_prepare()>, C<g_main_context_query()>, C<g_main_context_check()>, C<g_main_context_dispatch()>.

Returns: C<1> if the operation succeeded, and this thread is now the owner of I<context>.

  method g_main_context_acquire ( N-GMainContext $context --> Int )

=item N-GMainContext $context; a B<N-GMainContext>

=end pod

sub g_main_context_acquire ( N-GMainContext $context --> gboolean )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_main_context_release:
=begin pod
=head2 [[g_] main_] context_release

Releases ownership of a context previously acquired by this thread with C<g_main_context_acquire()>. If the context was acquired multiple times, the ownership will be released only when C<g_main_context_release()> is called as many times as it was acquired.

  method g_main_context_release ( N-GMainContext $context )

=item N-GMainContext $context; a B<N-GMainContext>

=end pod

sub g_main_context_release ( N-GMainContext $context  )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_main_context_is_owner:
=begin pod
=head2 [[g_] main_] context_is_owner

Determines whether this thread holds the (recursive) ownership of this B<N-GMainContext>. This is useful to know before waiting on another thread that may be blocking to get ownership of I<context>.

Returns: C<1> if current thread is owner of I<context>.

  method g_main_context_is_owner ( N-GMainContext $context --> Int )

=item N-GMainContext $context; a B<N-GMainContext>

=end pod

sub g_main_context_is_owner ( N-GMainContext $context --> gboolean )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_main_context_prepare:
=begin pod
=head2 [[g_] main_] context_prepare

Prepares to poll sources within a main loop. The resulting information for polling is determined by calling C<g_main_context_query()>.  You must have successfully acquired the context with C<g_main_context_acquire()> before you may call this function.

Returns: C<1> if some source is ready to be dispatched prior to polling.

  method g_main_context_prepare ( N-GMainContext $context, Int-ptr $priority --> Int )

=item N-GMainContext $context; a B<N-GMainContext>
=item Int-ptr $priority; location to store priority of highest priority source already ready.

=end pod

sub g_main_context_prepare ( N-GMainContext $context, gint-ptr $priority --> gboolean )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_main_context_dispatch:
=begin pod
=head2 [[g_] main_] context_dispatch

Dispatches all pending sources.  You must have successfully acquired the context with C<g_main_context_acquire()> before you may call this function.

  method g_main_context_dispatch ( N-GMainContext $context )

=item N-GMainContext $context; a B<N-GMainContext>

=end pod

sub g_main_context_dispatch ( N-GMainContext $context  )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_main_depth:
=begin pod
=head2 [g_] main_depth

Returns the depth of the stack of calls to C<g_main_context_dispatch()> on any B<N-GMainContext> in the current thread. That is, when called from the toplevel, it gives 0. When called from within a callback from C<g_main_context_iteration()> (or C<g_main_loop_run()>, etc.) it returns 1. When called from within  a callback to a recursive call to C<g_main_context_iteration()>, it returns 2. And so forth.  This function is useful in a situation like the following: Imagine an extremely simple "garbage collected" system.  |[<!-- language="C" -->  static GList *free_list;  gpointer allocate_memory (gsize size) {  gpointer result = g_malloc (size); free_list = g_list_prepend (free_list, result); return result; }  void free_allocated_memory (void) { GList *l; for (l = free_list; l; l = l->next); g_free (l->data); g_list_free (free_list); free_list = NULL; }  [...]  while (TRUE);  { g_main_context_iteration (NULL, TRUE); C<free_allocated_memory()>; } ]|  This works from an application, however, if you want to do the same thing from a library, it gets more difficult, since you no longer control the main loop. You might think you can simply use an idle function to make the call to C<free_allocated_memory()>, but that doesn't work, since the idle function could be called from a recursive callback. This can be fixed by using C<g_main_depth()>  |[<!-- language="C" -->  gpointer allocate_memory (gsize size) {  FreeListBlock *block = g_new (FreeListBlock, 1); block->mem = g_malloc (size); block->depth = C<g_main_depth()>;    free_list = g_list_prepend (free_list, block); return block->mem; }  void free_allocated_memory (void) { GList *l;   int depth = C<g_main_depth()>; for (l = free_list; l; ); { GList *next = l->next; FreeListBlock *block = l->data; if (block->depth > depth) { g_free (block->mem); g_free (block); free_list = g_list_delete_link (free_list, l); }   l = next; } } ]|  There is a temptation to use C<g_main_depth()> to solve problems with reentrancy. For instance, while waiting for data to be received from the network in response to a menu item, the menu item might be selected again. It might seem that one could make the menu item's callback return immediately and do nothing if C<g_main_depth()> returns a value greater than 1. However, this should be avoided since the user then sees selecting the menu item do nothing. Furthermore, you'll find yourself adding these checks all over your code, since there are doubtless many, many things that the user could do. Instead, you can use the following techniques:  1. Use C<gtk_widget_set_sensitive()> or modal dialogs to prevent the user from interacting with elements while the main loop is recursing.  2. Avoid main loop recursion in situations where you can't handle arbitrary  callbacks. Instead, structure your code so that you simply return to the main loop and then get called again when there is more work to do.

Returns: The main loop recursion level in the current thread

  method g_main_depth ( --> Int )


=end pod

sub g_main_depth (  --> gint )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_main_current_source:
=begin pod
=head2 [[g_] main_] current_source

Returns the currently firing source for this thread.

Returns: (transfer none): The currently firing source or C<Any>.

  method g_main_current_source ( --> N-GSource )


=end pod

sub g_main_current_source (  --> N-GSource )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_main_context_push_thread_default:
=begin pod
=head2 [[g_] main_] context_push_thread_default

Acquires I<context> and sets it as the thread-default context for the current thread. This will cause certain asynchronous operations (such as most [gio][gio]-based I/O) which are started in this thread to run under I<context> and deliver their results to its main loop, rather than running under the global default context in the main thread. Note that calling this function changes the context returned by C<g_main_context_get_thread_default()>, not the one returned by C<g_main_context_default()>, so it does not affect the context used by functions like C<g_idle_add()>.  Normally you would call this function shortly after creating a new thread, passing it a B<N-GMainContext> which will be run by a B<N-GMainLoop> in that thread, to set a new default context for all async operations in that thread. In this case you may not need to ever call C<g_main_context_pop_thread_default()>, assuming you want the new B<N-GMainContext> to be the default for the whole lifecycle of the thread.  If you don't have control over how the new thread was created (e.g. in the new thread isn't newly created, or if the thread life cycle is managed by a B<GThreadPool>), it is always suggested to wrap the logic that needs to use the new B<N-GMainContext> inside a C<g_main_context_push_thread_default()> / C<g_main_context_pop_thread_default()> pair, otherwise threads that are re-used will end up never explicitly releasing the B<N-GMainContext> reference they hold.  In some cases you may want to schedule a single operation in a non-default context, or temporarily use a non-default context in the main thread. In that case, you can wrap the call to the asynchronous operation inside a C<g_main_context_push_thread_default()> / C<g_main_context_pop_thread_default()> pair, but it is up to you to ensure that no other asynchronous operations accidentally get started while the non-default context is active.  Beware that libraries that predate this function may not correctly handle being used from a thread with a thread-default context. Eg, see C<g_file_supports_thread_contexts()>.

  method g_main_context_push_thread_default ( N-GMainContext $context )

=item N-GMainContext $context; (nullable): a B<N-GMainContext>, or C<Any> for the global default context

=end pod

sub g_main_context_push_thread_default ( N-GMainContext $context  )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_main_context_pop_thread_default:
=begin pod
=head2 [[g_] main_] context_pop_thread_default

Pops I<context> off the thread-default context stack (verifying that it was on the top of the stack).

  method g_main_context_pop_thread_default ( N-GMainContext $context )

=item N-GMainContext $context; (nullable): a B<N-GMainContext> object, or C<Any>

=end pod

sub g_main_context_pop_thread_default ( N-GMainContext $context  )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_main_context_get_thread_default:
=begin pod
=head2 [[g_] main_] context_get_thread_default

Gets the thread-default B<N-GMainContext> for this thread. Asynchronous operations that want to be able to be run in contexts other than the default one should call this method or C<g_main_context_ref_thread_default()> to get a B<N-GMainContext> to add their B<N-GSources> to. (Note that even in single-threaded programs applications may sometimes want to temporarily push a non-default context, so it is not safe to assume that this will always return C<Any> if you are running in the default thread.)  If you need to hold a reference on the context, use C<g_main_context_ref_thread_default()> instead.

Returns: (transfer none): the thread-default B<N-GMainContext>, or C<Any> if the thread-default context is the global default context.

  method g_main_context_get_thread_default ( --> N-GMainContext )


=end pod

sub g_main_context_get_thread_default (  --> N-GMainContext )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_main_context_ref_thread_default:
=begin pod
=head2 [[g_] main_] context_ref_thread_default

Gets the thread-default B<N-GMainContext> for this thread, as with C<g_main_context_get_thread_default()>, but also adds a reference to it with C<g_main_context_ref()>. In addition, unlike C<g_main_context_get_thread_default()>, if the thread-default context is the global default context, this will return that B<N-GMainContext> (with a ref added to it) rather than returning C<Any>.

Returns: (transfer full): the thread-default B<N-GMainContext>. Unref with C<g_main_context_unref()> when you are done with it.

  method g_main_context_ref_thread_default ( --> N-GMainContext )


=end pod

sub g_main_context_ref_thread_default (  --> N-GMainContext )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_main_loop_new:
=begin pod
=head2 [[g_] main_] loop_new

Creates a new B<N-GMainLoop> structure.

Returns: a new B<N-GMainLoop>.

  method g_main_loop_new ( N-GMainContext $context, Int $is_running --> N-GMainLoop )

=item N-GMainContext $context; (nullable): a B<N-GMainContext>  (if C<Any>, the default context will be used).
=item Int $is_running; set to C<1> to indicate that the loop is running. This is not very important since calling C<g_main_loop_run()> will set this to C<1> anyway.

=end pod

sub g_main_loop_new ( N-GMainContext $context, gboolean $is_running --> N-GMainLoop )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_main_loop_run:
=begin pod
=head2 [[g_] main_] loop_run

Runs a main loop until C<g_main_loop_quit()> is called on the loop. If this is called for the thread of the loop's B<N-GMainContext>, it will process events from the loop, otherwise it will simply wait.

  method g_main_loop_run ( N-GMainLoop $loop )

=item N-GMainLoop $loop; a B<N-GMainLoop>

=end pod

sub g_main_loop_run ( N-GMainLoop $loop  )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_main_loop_quit:
=begin pod
=head2 [[g_] main_] loop_quit

Stops a B<N-GMainLoop> from running. Any calls to C<g_main_loop_run()> for the loop will return.   Note that sources that have already been dispatched when  C<g_main_loop_quit()> is called will still be executed.

  method g_main_loop_quit ( N-GMainLoop $loop )

=item N-GMainLoop $loop; a B<N-GMainLoop>

=end pod

sub g_main_loop_quit ( N-GMainLoop $loop  )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_main_loop_ref:
=begin pod
=head2 [[g_] main_] loop_ref

Increases the reference count on a B<N-GMainLoop> object by one.

Returns: I<loop>

  method g_main_loop_ref ( N-GMainLoop $loop --> N-GMainLoop )

=item N-GMainLoop $loop; a B<N-GMainLoop>

=end pod

sub g_main_loop_ref ( N-GMainLoop $loop --> N-GMainLoop )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_main_loop_unref:
=begin pod
=head2 [[g_] main_] loop_unref

Decreases the reference count on a B<N-GMainLoop> object by one. If the result is zero, free the loop and free all associated memory.

  method g_main_loop_unref ( N-GMainLoop $loop )

=item N-GMainLoop $loop; a B<N-GMainLoop>

=end pod

sub g_main_loop_unref ( N-GMainLoop $loop  )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_main_loop_is_running:
=begin pod
=head2 [[g_] main_] loop_is_running

Checks to see if the main loop is currently being run via C<g_main_loop_run()>.

Returns: C<1> if the mainloop is currently being run.

  method g_main_loop_is_running ( N-GMainLoop $loop --> Int )

=item N-GMainLoop $loop; a B<N-GMainLoop>.

=end pod

sub g_main_loop_is_running ( N-GMainLoop $loop --> gboolean )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_main_loop_get_context:
=begin pod
=head2 [[g_] main_] loop_get_context

Returns the B<N-GMainContext> of I<loop>.

Returns: (transfer none): the B<N-GMainContext> of I<loop>

  method g_main_loop_get_context ( N-GMainLoop $loop --> N-GMainContext )

=item N-GMainLoop $loop; a B<N-GMainLoop>.

=end pod

sub g_main_loop_get_context ( N-GMainLoop $loop --> N-GMainContext )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_main_context_invoke_full:
=begin pod
=head2 [[g_] main_] context_invoke_full

Invokes a function in such a way that I<context> is owned during the invocation of I<function>.  This function is the same as C<g_main_context_invoke()> except that it lets you specify the priority in case I<function> ends up being scheduled as an idle and also lets you give a B<GDestroyNotify> for I<data>.  I<notify> should not assume that it is called from any particular thread or with any particular context acquired.

  method g_main_context_invoke_full (
    N-GMainContext $context, Int $priority,
    GSourceFunc $function, Pointer $data,
    GDestroyNotify $notify
  )

=item N-GMainContext $context; (nullable): a B<N-GMainContext>, or C<Any>
=item Int $priority; the priority at which to run I<function>
=item GSourceFunc $function; function to call
=item Pointer $data; data to pass to I<function>
=item GDestroyNotify $notify; (nullable): a function to call when I<data> is no longer in use, or C<Any>.

=end pod

#sub GSourceFunc ( &c:(gpointer --> gboolean) ) { }
#sub GDestroyNotify ( &c:(OpaquePointer) ) { }


sub g_main_context_invoke_full (
  N-GMainContext $context, gint $priority,
  Callable $function ( gpointer --> gboolean ),
  gpointer $data, Callable $notify ( OpaquePointer )
) is native(&glib-lib)
  { * }










=finish

#`{{
#-------------------------------------------------------------------------------
#TM:0:g_main_context_find_source_by_funcs_user_data:
=begin pod
=head2 [[g_] main_] context_find_source_by_funcs_user_data

Finds a source with the given source functions and user data.  If multiple sources exist with the same source function and user data, the first one found will be returned.

Returns: (transfer none): the source, if one was found, otherwise C<Any>

  method g_main_context_find_source_by_funcs_user_data ( N-GMainContext $context, GSourceFuncs $funcs, Pointer $user_data --> N-GSource )

=item N-GMainContext $context; (nullable): a B<N-GMainContext> (if C<Any>, the default context will be used).
=item GSourceFuncs $funcs; the I<source_funcs> passed to C<g_source_new()>.
=item Pointer $user_data; the user data from the callback.

=end pod

sub g_main_context_find_source_by_funcs_user_data ( N-GMainContext $context, GSourceFuncs $funcs, gpointer $user_data --> N-GSource )
  is native(&glib-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
#TM:0:g_main_context_query:
=begin pod
=head2 [[g_] main_] context_query

Determines information necessary to poll this main loop.  You must have successfully acquired the context with C<g_main_context_acquire()> before you may call this function.

Returns: the number of records actually stored in I<fds>, or, if more than I<n_fds> records need to be stored, the number of records that need to be stored.

  method g_main_context_query ( N-GMainContext $context, Int $max_priority, Int-ptr $timeout_, GPollFD $fds, Int $n_fds --> Int )

=item N-GMainContext $context; a B<N-GMainContext>
=item Int $max_priority; maximum priority source to check
=item Int-ptr $timeout_; (out): location to store timeout to be used in polling
=item GPollFD $fds; (out caller-allocates) (array length=n_fds): location to store B<GPollFD> records that need to be polled.
=item Int $n_fds; (in): length of I<fds>.

=end pod

sub g_main_context_query ( N-GMainContext $context, gint $max_priority, gint-ptr $timeout_, GPollFD $fds, gint $n_fds --> gint )
  is native(&glib-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
#TM:0:g_main_context_check:
=begin pod
=head2 [[g_] main_] context_check

Passes the results of polling back to the main loop.  You must have successfully acquired the context with C<g_main_context_acquire()> before you may call this function.

Returns: C<1> if some sources are ready to be dispatched.

  method g_main_context_check ( N-GMainContext $context, Int $max_priority, GPollFD $fds, Int $n_fds --> Int )

=item N-GMainContext $context; a B<N-GMainContext>
=item Int $max_priority; the maximum numerical priority of sources to check
=item GPollFD $fds; (array length=n_fds): array of B<GPollFD>'s that was passed to the last call to C<g_main_context_query()>
=item Int $n_fds; return value of C<g_main_context_query()>

=end pod

sub g_main_context_check ( N-GMainContext $context, gint $max_priority, GPollFD $fds, gint $n_fds --> gboolean )
  is native(&glib-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
#TM:0:g_main_context_set_poll_func:
=begin pod
=head2 [[g_] main_] context_set_poll_func

Sets the function to use to handle polling of file descriptors. It will be used instead of the C<poll()> system call  (or GLib's replacement function, which is used where  C<poll()> isn't available).  This function could possibly be used to integrate the GLib event loop with an external event loop.

  method g_main_context_set_poll_func ( N-GMainContext $context, GPollFunc $func )

=item N-GMainContext $context; a B<N-GMainContext>
=item GPollFunc $func; the function to call to poll all file descriptors

=end pod

sub g_main_context_set_poll_func ( N-GMainContext $context, GPollFunc $func  )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_main_context_get_poll_func:
=begin pod
=head2 [[g_] main_] context_get_poll_func

Gets the poll function set by C<g_main_context_set_poll_func()>.

Returns: the poll function

  method g_main_context_get_poll_func ( N-GMainContext $context --> GPollFunc )

=item N-GMainContext $context; a B<N-GMainContext>

=end pod

sub g_main_context_get_poll_func ( N-GMainContext $context --> GPollFunc )
  is native(&glib-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
#TM:0:g_main_context_add_poll:
=begin pod
=head2 [[g_] main_] context_add_poll

Adds a file descriptor to the set of file descriptors polled for this context. This will very seldom be used directly. Instead a typical event source will use C<g_source_add_unix_fd()> instead.

  method g_main_context_add_poll ( N-GMainContext $context, GPollFD $fd, Int $priority )

=item N-GMainContext $context; (nullable): a B<N-GMainContext> (or C<Any> for the default context)
=item GPollFD $fd; a B<GPollFD> structure holding information about a file descriptor to watch.
=item Int $priority; the priority for this file descriptor which should be the same as the priority used for C<g_source_attach()> to ensure that the file descriptor is polled whenever the results may be needed.

=end pod

sub g_main_context_add_poll ( N-GMainContext $context, GPollFD $fd, gint $priority  )
  is native(&glib-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
#TM:0:g_main_context_remove_poll:
=begin pod
=head2 [[g_] main_] context_remove_poll

Removes file descriptor from the set of file descriptors to be polled for a particular context.

  method g_main_context_remove_poll ( N-GMainContext $context, GPollFD $fd )

=item N-GMainContext $context; a B<N-GMainContext>
=item GPollFD $fd; a B<GPollFD> descriptor previously added with C<g_main_context_add_poll()>

=end pod

sub g_main_context_remove_poll ( N-GMainContext $context, GPollFD $fd  )
  is native(&glib-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
#TM:0:g_source_new:
=begin pod
=head2 g_source_new

Creates a new B<N-GSource> structure. The size is specified to allow creating structures derived from B<N-GSource> that contain additional data. The size passed in must be at least `sizeof (N-GSource)`.  The source will not initially be associated with any B<N-GMainContext> and must be added to one with C<g_source_attach()> before it will be executed.

Returns: the newly-created B<N-GSource>.

  method g_source_new ( GSourceFuncs $source_funcs, UInt $struct_size --> N-GSource )

=item GSourceFuncs $source_funcs; structure containing functions that implement the sources behavior.
=item UInt $struct_size; size of the B<N-GSource> structure to create.

=end pod

sub g_source_new ( GSourceFuncs $source_funcs, guint $struct_size --> N-GSource )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_source_ref:
=begin pod
=head2 g_source_ref

Increases the reference count on a source by one.

Returns: I<source>

  method g_source_ref ( N-GSource $source --> N-GSource )

=item N-GSource $source; a B<N-GSource>

=end pod

sub g_source_ref ( N-GSource $source --> N-GSource )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_source_unref:
=begin pod
=head2 g_source_unref

Decreases the reference count of a source by one. If the resulting reference count is zero the source and associated memory will be destroyed.

  method g_source_unref ( N-GSource $source )

=item N-GSource $source; a B<N-GSource>

=end pod

sub g_source_unref ( N-GSource $source  )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_source_attach:
=begin pod
=head2 g_source_attach

Adds a B<N-GSource> to a I<context> so that it will be executed within that context. Remove it by calling C<g_source_destroy()>.

Returns: the ID (greater than 0) for the source within the  B<N-GMainContext>.

  method g_source_attach ( N-GSource $source, N-GMainContext $context --> UInt )

=item N-GSource $source; a B<N-GSource>
=item N-GMainContext $context; (nullable): a B<N-GMainContext> (if C<Any>, the default context will be used)

=end pod

sub g_source_attach ( N-GSource $source, N-GMainContext $context --> guint )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_source_destroy:
=begin pod
=head2 g_source_destroy

Removes a source from its B<N-GMainContext>, if any, and mark it as destroyed.  The source cannot be subsequently added to another context. It is safe to call this on sources which have already been removed from their context.

  method g_source_destroy ( N-GSource $source )

=item N-GSource $source; a B<N-GSource>

=end pod

sub g_source_destroy ( N-GSource $source  )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_source_set_priority:
=begin pod
=head2 g_source_set_priority

Sets the priority of a source. While the main loop is being run, a source will be dispatched if it is ready to be dispatched and no sources at a higher (numerically smaller) priority are ready to be dispatched.  A child source always has the same priority as its parent.  It is not permitted to change the priority of a source once it has been added as a child of another source.

  method g_source_set_priority ( N-GSource $source, Int $priority )

=item N-GSource $source; a B<N-GSource>
=item Int $priority; the new priority.

=end pod

sub g_source_set_priority ( N-GSource $source, gint $priority  )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_source_get_priority:
=begin pod
=head2 g_source_get_priority

Gets the priority of a source.

Returns: the priority of the source

  method g_source_get_priority ( N-GSource $source --> Int )

=item N-GSource $source; a B<N-GSource>

=end pod

sub g_source_get_priority ( N-GSource $source --> gint )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_source_set_can_recurse:
=begin pod
=head2 g_source_set_can_recurse

Sets whether a source can be called recursively. If I<can_recurse> is C<1>, then while the source is being dispatched then this source will be processed normally. Otherwise, all processing of this source is blocked until the dispatch function returns.

  method g_source_set_can_recurse ( N-GSource $source, Int $can_recurse )

=item N-GSource $source; a B<N-GSource>
=item Int $can_recurse; whether recursion is allowed for this source

=end pod

sub g_source_set_can_recurse ( N-GSource $source, gboolean $can_recurse  )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_source_get_can_recurse:
=begin pod
=head2 g_source_get_can_recurse

Checks whether a source is allowed to be called recursively. see C<g_source_set_can_recurse()>.

Returns: whether recursion is allowed.

  method g_source_get_can_recurse ( N-GSource $source --> Int )

=item N-GSource $source; a B<N-GSource>

=end pod

sub g_source_get_can_recurse ( N-GSource $source --> gboolean )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_source_get_id:
=begin pod
=head2 g_source_get_id

Returns the numeric ID for a particular source. The ID of a source is a positive integer which is unique within a particular main loop  context. The reverse mapping from ID to source is done by C<g_main_context_find_source_by_id()>.  You can only call this function while the source is associated to a B<N-GMainContext> instance; calling this function before C<g_source_attach()> or after C<g_source_destroy()> yields undefined behavior. The ID returned is unique within the B<N-GMainContext> instance passed to C<g_source_attach()>.

Returns: the ID (greater than 0) for the source

  method g_source_get_id ( N-GSource $source --> UInt )

=item N-GSource $source; a B<N-GSource>

=end pod

sub g_source_get_id ( N-GSource $source --> guint )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_source_get_context:
=begin pod
=head2 g_source_get_context

Gets the B<N-GMainContext> with which the source is associated.  You can call this on a source that has been destroyed, provided that the B<N-GMainContext> it was attached to still exists (in which case it will return that B<N-GMainContext>). In particular, you can always call this function on the source returned from C<g_main_current_source()>. But calling this function on a source whose B<N-GMainContext> has been destroyed is an error.

Returns: (transfer none) (nullable): the B<N-GMainContext> with which the source is associated, or C<Any> if the context has not yet been added to a source.

  method g_source_get_context ( N-GSource $source --> N-GMainContext )

=item N-GSource $source; a B<N-GSource>

=end pod

sub g_source_get_context ( N-GSource $source --> N-GMainContext )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_source_set_callback:
=begin pod
=head2 g_source_set_callback

Sets the callback function for a source. The callback for a source is called from the source's dispatch function.  The exact type of I<func> depends on the type of source; ie. you should not count on I<func> being called with I<data> as its first parameter. Cast I<func> with C<G_SOURCE_FUNC()> to avoid warnings about incompatible function types.  See [memory management of sources][mainloop-memory-management] for details on how to handle memory management of I<data>.  Typically, you won't use this function. Instead use functions specific to the type of source you are using, such as C<g_idle_add()> or C<g_timeout_add()>.  It is safe to call this function multiple times on a source which has already been attached to a context. The changes will take effect for the next time the source is dispatched after this call returns.

  method g_source_set_callback ( N-GSource $source, GSourceFunc $func, Pointer $data, GDestroyNotify $notify )

=item N-GSource $source; the source
=item GSourceFunc $func; a callback function
=item Pointer $data; the data to pass to callback function
=item GDestroyNotify $notify; (nullable): a function to call when I<data> is no longer in use, or C<Any>.

=end pod

sub g_source_set_callback ( N-GSource $source, GSourceFunc $func, gpointer $data, GDestroyNotify $notify  )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_source_set_funcs:
=begin pod
=head2 g_source_set_funcs

Sets the source functions (can be used to override  default implementations) of an unattached source.

  method g_source_set_funcs ( N-GSource $source, GSourceFuncs $funcs )

=item N-GSource $source; a B<N-GSource>
=item GSourceFuncs $funcs; the new B<GSourceFuncs>

=end pod

sub g_source_set_funcs ( N-GSource $source, GSourceFuncs $funcs  )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_source_is_destroyed:
=begin pod
=head2 g_source_is_destroyed

Returns whether I<source> has been destroyed.  This is important when you operate upon your objects  from within idle handlers, but may have freed the object  before the dispatch of your idle handler.  |[<!-- language="C" -->  static gboolean  idle_callback (gpointer data) { SomeWidget *self = data;   C<GDK_THREADS_ENTER()>; // do stuff with self self->idle_id = 0; C<GDK_THREADS_LEAVE()>;   return G_SOURCE_REMOVE; }   static void  some_widget_do_stuff_later (SomeWidget *self) { self->idle_id = g_idle_add (idle_callback, self); }   static void  some_widget_finalize (GObject *object) { SomeWidget *self = SOME_WIDGET (object);   if (self->idle_id) g_source_remove (self->idle_id);   G_OBJECT_CLASS (parent_class)->finalize (object); } ]|  This will fail in a multi-threaded application if the  widget is destroyed before the idle handler fires due  to the use after free in the callback. A solution, to  this particular problem, is to check to if the source has already been destroy within the callback.  |[<!-- language="C" -->  static gboolean  idle_callback (gpointer data) { SomeWidget *self = data;   C<GDK_THREADS_ENTER()>; if (!g_source_is_destroyed (C<g_main_current_source()>)) { // do stuff with self } C<GDK_THREADS_LEAVE()>;   return FALSE; } ]|  Calls to this function from a thread other than the one acquired by the B<N-GMainContext> the B<N-GSource> is attached to are typically redundant, as the source could be destroyed immediately after this function returns. However, once a source is destroyed it cannot be un-destroyed, so this function can be used for opportunistic checks from any thread.

Returns: C<1> if the source has been destroyed

  method g_source_is_destroyed ( N-GSource $source --> Int )

=item N-GSource $source; a B<N-GSource>

=end pod

sub g_source_is_destroyed ( N-GSource $source --> gboolean )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_source_set_name:
=begin pod
=head2 g_source_set_name

Sets a name for the source, used in debugging and profiling. The name defaults to B<NULL>.  The source name should describe in a human-readable way what the source does. For example, "X11 event queue" or "GTK+ repaint idle handler" or whatever it is.  It is permitted to call this function multiple times, but is not recommended due to the potential performance impact.  For example, one could change the name in the "check" function of a B<GSourceFuncs> to include details like the event type in the source name.  Use caution if changing the name while another thread may be accessing it with C<g_source_get_name()>; that function does not copy the value, and changing the value will free it while the other thread may be attempting to use it.

  method g_source_set_name ( N-GSource $source,  Str  $name )

=item N-GSource $source; a B<N-GSource>
=item  Str  $name; debug name for the source

=end pod

sub g_source_set_name ( N-GSource $source, gchar-ptr $name  )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_source_get_name:
=begin pod
=head2 g_source_get_name

Gets a name for the source, used in debugging and profiling.  The name may be B<NULL> if it has never been set with C<g_source_set_name()>.

Returns: the name of the source

  method g_source_get_name ( N-GSource $source -->  Str  )

=item N-GSource $source; a B<N-GSource>

=end pod

sub g_source_get_name ( N-GSource $source --> gchar-ptr )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_source_set_name_by_id:
=begin pod
=head2 g_source_set_name_by_id

Sets the name of a source using its ID.  This is a convenience utility to set source names from the return value of C<g_idle_add()>, C<g_timeout_add()>, etc.  It is a programmer error to attempt to set the name of a non-existent source.  More specifically: source IDs can be reissued after a source has been destroyed and therefore it is never valid to use this function with a source ID which may have already been removed.  An example is when scheduling an idle to run in another thread with C<g_idle_add()>: the idle may already have run and been removed by the time this function is called on its (now invalid) source ID.  This source ID may have been reissued, leading to the operation being performed against the wrong source.

  method g_source_set_name_by_id ( UInt $tag,  Str  $name )

=item UInt $tag; a B<N-GSource> ID
=item  Str  $name; debug name for the source

=end pod

sub g_source_set_name_by_id ( guint $tag, gchar-ptr $name  )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_source_set_ready_time:
=begin pod
=head2 g_source_set_ready_time

Sets a B<N-GSource> to be dispatched when the given monotonic time is reached (or passed).  If the monotonic time is in the past (as it always will be if I<ready_time> is 0) then the source will be dispatched immediately.  If I<ready_time> is -1 then the source is never woken up on the basis of the passage of time.  Dispatching the source does not reset the ready time.  You should do so yourself, from the source dispatch function.  Note that if you have a pair of sources where the ready time of one suggests that it will be delivered first but the priority for the other suggests that it would be delivered first, and the ready time for both sources is reached during the same main context iteration, then the order of dispatch is undefined.  It is a no-op to call this function on a B<N-GSource> which has already been destroyed with C<g_source_destroy()>.  This API is only intended to be used by implementations of B<N-GSource>. Do not call this API on a B<N-GSource> that you did not create.

  method g_source_set_ready_time ( N-GSource $source, Int $ready_time )

=item N-GSource $source; a B<N-GSource>
=item Int $ready_time; the monotonic time at which the source will be ready, 0 for "immediately", -1 for "never"

=end pod

sub g_source_set_ready_time ( N-GSource $source, gint64 $ready_time  )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_source_get_ready_time:
=begin pod
=head2 g_source_get_ready_time

Gets the "ready time" of I<source>, as set by C<g_source_set_ready_time()>.  Any time before the current monotonic time (including 0) is an indication that the source will fire immediately.

Returns: the monotonic ready time, -1 for "never"

  method g_source_get_ready_time ( N-GSource $source --> Int )

=item N-GSource $source; a B<N-GSource>

=end pod

sub g_source_get_ready_time ( N-GSource $source --> gint64 )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_source_add_unix_fd:
=begin pod
=head2 g_source_add_unix_fd

Monitors I<fd> for the IO events in I<events>.  The tag returned by this function can be used to remove or modify the monitoring of the fd using C<g_source_remove_unix_fd()> or C<g_source_modify_unix_fd()>.  It is not necessary to remove the fd before destroying the source; it will be cleaned up automatically.  This API is only intended to be used by implementations of B<N-GSource>. Do not call this API on a B<N-GSource> that you did not create.  As the name suggests, this function is not available on Windows.

Returns: (not nullable): an opaque tag

  method g_source_add_unix_fd ( N-GSource $source, Int $fd, GIOCondition $events --> Pointer )

=item N-GSource $source; a B<N-GSource>
=item Int $fd; the fd to monitor
=item GIOCondition $events; an event mask

=end pod

sub g_source_add_unix_fd ( N-GSource $source, gint $fd, GIOCondition $events --> gpointer )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_source_modify_unix_fd:
=begin pod
=head2 g_source_modify_unix_fd

Updates the event mask to watch for the fd identified by I<tag>.  I<tag> is the tag returned from C<g_source_add_unix_fd()>.  If you want to remove a fd, don't set its event mask to zero. Instead, call C<g_source_remove_unix_fd()>.  This API is only intended to be used by implementations of B<N-GSource>. Do not call this API on a B<N-GSource> that you did not create.  As the name suggests, this function is not available on Windows.

  method g_source_modify_unix_fd ( N-GSource $source, Pointer $tag, GIOCondition $new_events )

=item N-GSource $source; a B<N-GSource>
=item Pointer $tag; (not nullable): the tag from C<g_source_add_unix_fd()>
=item GIOCondition $new_events; the new event mask to watch

=end pod

sub g_source_modify_unix_fd ( N-GSource $source, gpointer $tag, GIOCondition $new_events  )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_source_remove_unix_fd:
=begin pod
=head2 g_source_remove_unix_fd

Reverses the effect of a previous call to C<g_source_add_unix_fd()>.  You only need to call this if you want to remove an fd from being watched while keeping the same source around.  In the normal case you will just want to destroy the source.  This API is only intended to be used by implementations of B<N-GSource>. Do not call this API on a B<N-GSource> that you did not create.  As the name suggests, this function is not available on Windows.

  method g_source_remove_unix_fd ( N-GSource $source, Pointer $tag )

=item N-GSource $source; a B<N-GSource>
=item Pointer $tag; (not nullable): the tag from C<g_source_add_unix_fd()>

=end pod

sub g_source_remove_unix_fd ( N-GSource $source, gpointer $tag  )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_source_query_unix_fd:
=begin pod
=head2 g_source_query_unix_fd

Queries the events reported for the fd corresponding to I<tag> on I<source> during the last poll.  The return value of this function is only defined when the function is called from the check or dispatch functions for I<source>.  This API is only intended to be used by implementations of B<N-GSource>. Do not call this API on a B<N-GSource> that you did not create.  As the name suggests, this function is not available on Windows.

Returns: the conditions reported on the fd

  method g_source_query_unix_fd ( N-GSource $source, Pointer $tag --> GIOCondition )

=item N-GSource $source; a B<N-GSource>
=item Pointer $tag; (not nullable): the tag from C<g_source_add_unix_fd()>

=end pod

sub g_source_query_unix_fd ( N-GSource $source, gpointer $tag --> GIOCondition )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_source_set_callback_indirect:
=begin pod
=head2 g_source_set_callback_indirect

Sets the callback function storing the data as a refcounted callback "object". This is used internally. Note that calling  C<g_source_set_callback_indirect()> assumes an initial reference count on I<callback_data>, and thus I<callback_funcs>->unref will eventually be called once more than I<callback_funcs>->ref.  It is safe to call this function multiple times on a source which has already been attached to a context. The changes will take effect for the next time the source is dispatched after this call returns.

  method g_source_set_callback_indirect ( N-GSource $source, Pointer $callback_data, N-GSourceCallbackFuncs $callback_funcs )

=item N-GSource $source; the source
=item Pointer $callback_data; pointer to callback data "object"
=item N-GSourceCallbackFuncs $callback_funcs; functions for reference counting I<callback_data> and getting the callback and data

=end pod

sub g_source_set_callback_indirect ( N-GSource $source, gpointer $callback_data, N-GSourceCallbackFuncs $callback_funcs  )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_source_add_poll:
=begin pod
=head2 g_source_add_poll

Adds a file descriptor to the set of file descriptors polled for this source. This is usually combined with C<g_source_new()> to add an event source. The event source's check function will typically test the I<revents> field in the B<GPollFD> struct and return C<1> if events need to be processed.  This API is only intended to be used by implementations of B<N-GSource>. Do not call this API on a B<N-GSource> that you did not create.  Using this API forces the linear scanning of event sources on each main loop iteration.  Newly-written event sources should try to use C<g_source_add_unix_fd()> instead of this API.

  method g_source_add_poll ( N-GSource $source, GPollFD $fd )

=item N-GSource $source; a B<N-GSource>
=item GPollFD $fd; a B<GPollFD> structure holding information about a file descriptor to watch.

=end pod

sub g_source_add_poll ( N-GSource $source, GPollFD $fd  )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_source_remove_poll:
=begin pod
=head2 g_source_remove_poll

Removes a file descriptor from the set of file descriptors polled for this source.   This API is only intended to be used by implementations of B<N-GSource>. Do not call this API on a B<N-GSource> that you did not create.

  method g_source_remove_poll ( N-GSource $source, GPollFD $fd )

=item N-GSource $source; a B<N-GSource>
=item GPollFD $fd; a B<GPollFD> structure previously passed to C<g_source_add_poll()>.

=end pod

sub g_source_remove_poll ( N-GSource $source, GPollFD $fd  )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_source_add_child_source:
=begin pod
=head2 g_source_add_child_source

Adds I<child_source> to I<source> as a "polled" source; when I<source> is added to a B<N-GMainContext>, I<child_source> will be automatically added with the same priority, when I<child_source> is triggered, it will cause I<source> to dispatch (in addition to calling its own callback), and when I<source> is destroyed, it will destroy I<child_source> as well. (I<source> will also still be dispatched if its own prepare/check functions indicate that it is ready.)  If you don't need I<child_source> to do anything on its own when it triggers, you can call C<g_source_set_dummy_callback()> on it to set a callback that does nothing (except return C<1> if appropriate).  I<source> will hold a reference on I<child_source> while I<child_source> is attached to it.  This API is only intended to be used by implementations of B<N-GSource>. Do not call this API on a B<N-GSource> that you did not create.

  method g_source_add_child_source ( N-GSource $source, N-GSource $child_source )

=item N-GSource $source; a B<N-GSource>
=item N-GSource $child_source; a second B<N-GSource> that I<source> should "poll"

=end pod

sub g_source_add_child_source ( N-GSource $source, N-GSource $child_source  )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_source_remove_child_source:
=begin pod
=head2 g_source_remove_child_source

Detaches I<child_source> from I<source> and destroys it.  This API is only intended to be used by implementations of B<N-GSource>. Do not call this API on a B<N-GSource> that you did not create.

  method g_source_remove_child_source ( N-GSource $source, N-GSource $child_source )

=item N-GSource $source; a B<N-GSource>
=item N-GSource $child_source; a B<N-GSource> previously passed to C<g_source_add_child_source()>.

=end pod

sub g_source_remove_child_source ( N-GSource $source, N-GSource $child_source  )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_source_get_time:
=begin pod
=head2 g_source_get_time

Gets the time to be used when checking this source. The advantage of calling this function over calling C<g_get_monotonic_time()> directly is that when checking multiple sources, GLib can cache a single value instead of having to repeatedly get the system monotonic time.  The time here is the system monotonic time, if available, or some other reasonable alternative otherwise.  See C<g_get_monotonic_time()>.

Returns: the monotonic time in microseconds

  method g_source_get_time ( N-GSource $source --> Int )

=item N-GSource $source; a B<N-GSource>

=end pod

sub g_source_get_time ( N-GSource $source --> gint64 )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_idle_source_new:
=begin pod
=head2 g_idle_source_new

Creates a new idle source.  The source will not initially be associated with any B<N-GMainContext> and must be added to one with C<g_source_attach()> before it will be executed. Note that the default priority for idle sources is C<G_PRIORITY_DEFAULT_IDLE>, as compared to other sources which have a default priority of C<G_PRIORITY_DEFAULT>.

Returns: the newly-created idle source

  method g_idle_source_new ( --> N-GSource )


=end pod

sub g_idle_source_new (  --> N-GSource )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_child_watch_source_new:
=begin pod
=head2 g_child_watch_source_new

Creates a new child_watch source.  The source will not initially be associated with any B<N-GMainContext> and must be added to one with C<g_source_attach()> before it will be executed.  Note that child watch sources can only be used in conjunction with `g_spawn...` when the C<G_SPAWN_DO_NOT_REAP_CHILD> flag is used.  Note that on platforms where B<GPid> must be explicitly closed (see C<g_spawn_close_pid()>) I<pid> must not be closed while the source is still active. Typically, you will want to call C<g_spawn_close_pid()> in the callback function for the source.  On POSIX platforms, the following restrictions apply to this API due to limitations in POSIX process interfaces:  * I<pid> must be a child of this process * I<pid> must be positive * the application must not call `waitpid` with a non-positive first argument, for instance in another thread * the application must not wait for I<pid> to exit by any other mechanism, including `waitpid(pid, ...)` or a second child-watch source for the same I<pid> * the application must not ignore SIGCHILD  If any of those conditions are not met, this and related APIs will not work correctly. This can often be diagnosed via a GLib warning stating that `ECHILD` was received by `waitpid`.  Calling `waitpid` for specific processes other than I<pid> remains a valid thing to do.

Returns: the newly-created child watch source

  method g_child_watch_source_new ( GPid $pid --> N-GSource )

=item GPid $pid; process to watch. On POSIX the positive pid of a child process. On Windows a handle for a process (which doesn't have to be a child).

=end pod

sub g_child_watch_source_new ( GPid $pid --> N-GSource )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_timeout_source_new:
=begin pod
=head2 g_timeout_source_new

Creates a new timeout source.  The source will not initially be associated with any B<N-GMainContext> and must be added to one with C<g_source_attach()> before it will be executed.  The interval given is in terms of monotonic time, not wall clock time.  See C<g_get_monotonic_time()>.

Returns: the newly-created timeout source

  method g_timeout_source_new ( UInt $interval --> N-GSource )

=item UInt $interval; the timeout interval in milliseconds.

=end pod

sub g_timeout_source_new ( guint $interval --> N-GSource )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_timeout_source_new_seconds:
=begin pod
=head2 g_timeout_source_new_seconds

Creates a new timeout source.  The source will not initially be associated with any B<N-GMainContext> and must be added to one with C<g_source_attach()> before it will be executed.  The scheduling granularity/accuracy of this timeout source will be in seconds.  The interval given is in terms of monotonic time, not wall clock time. See C<g_get_monotonic_time()>.

Returns: the newly-created timeout source

  method g_timeout_source_new_seconds ( UInt $interval --> N-GSource )

=item UInt $interval; the timeout interval in seconds

=end pod

sub g_timeout_source_new_seconds ( guint $interval --> N-GSource )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_get_current_time:
=begin pod
=head2 g_get_current_time

Equivalent to the UNIX C<gettimeofday()> function, but portable.  You may find C<g_get_real_time()> to be more convenient.

  method g_get_current_time ( GTimeVal $result )

=item GTimeVal $result; B<GTimeVal> structure in which to store current time.

=end pod

sub g_get_current_time ( GTimeVal $result  )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_get_monotonic_time:
=begin pod
=head2 g_get_monotonic_time

Queries the system monotonic time.  The monotonic clock will always increase and doesn't suffer discontinuities when the user (or NTP) changes the system time.  It may or may not continue to tick during times where the machine is suspended.  We try to use the clock that corresponds as closely as possible to the passage of time as measured by system calls such as C<poll()> but it may not always be possible to do this.

Returns: the monotonic time, in microseconds

  method g_get_monotonic_time ( --> Int )


=end pod

sub g_get_monotonic_time (  --> gint64 )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_get_real_time:
=begin pod
=head2 g_get_real_time

Queries the system wall-clock time.  This call is functionally equivalent to C<g_get_current_time()> except that the return value is often more convenient than dealing with a B<GTimeVal>.  You should only use this call if you are actually interested in the real wall-clock time.  C<g_get_monotonic_time()> is probably more useful for measuring intervals.

Returns: the number of microseconds since January 1, 1970 UTC.

  method g_get_real_time ( --> Int )


=end pod

sub g_get_real_time (  --> gint64 )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_source_remove:
=begin pod
=head2 g_source_remove

Removes the source with the given ID from the default main context. You must use C<g_source_destroy()> for sources added to a non-default main context.  The ID of a B<N-GSource> is given by C<g_source_get_id()>, or will be returned by the functions C<g_source_attach()>, C<g_idle_add()>, C<g_idle_add_full()>, C<g_timeout_add()>, C<g_timeout_add_full()>, C<g_child_watch_add()>, C<g_child_watch_add_full()>, C<g_io_add_watch()>, and C<g_io_add_watch_full()>.  It is a programmer error to attempt to remove a non-existent source.  More specifically: source IDs can be reissued after a source has been destroyed and therefore it is never valid to use this function with a source ID which may have already been removed.  An example is when scheduling an idle to run in another thread with C<g_idle_add()>: the idle may already have run and been removed by the time this function is called on its (now invalid) source ID.  This source ID may have been reissued, leading to the operation being performed against the wrong source.

Returns: For historical reasons, this function always returns C<1>

  method g_source_remove ( UInt $tag --> Int )

=item UInt $tag; the ID of the source to remove.

=end pod

sub g_source_remove ( guint $tag --> gboolean )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_source_remove_by_user_data:
=begin pod
=head2 g_source_remove_by_user_data

Removes a source from the default main loop context given the user data for the callback. If multiple sources exist with the same user data, only one will be destroyed.

Returns: C<1> if a source was found and removed.

  method g_source_remove_by_user_data ( Pointer $user_data --> Int )

=item Pointer $user_data; the user_data for the callback.

=end pod

sub g_source_remove_by_user_data ( gpointer $user_data --> gboolean )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_source_remove_by_funcs_user_data:
=begin pod
=head2 g_source_remove_by_funcs_user_data

Removes a source from the default main loop context given the source functions and user data. If multiple sources exist with the same source functions and user data, only one will be destroyed.

Returns: C<1> if a source was found and removed.

  method g_source_remove_by_funcs_user_data ( GSourceFuncs $funcs, Pointer $user_data --> Int )

=item GSourceFuncs $funcs; The I<source_funcs> passed to C<g_source_new()>
=item Pointer $user_data; the user data for the callback

=end pod

sub g_source_remove_by_funcs_user_data ( GSourceFuncs $funcs, gpointer $user_data --> gboolean )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_clear_handle_id:
=begin pod
=head2 g_clear_handle_id

Clears a numeric handler, such as a B<N-GSource> ID.  I<tag_ptr> must be a valid pointer to the variable holding the handler.  If the ID is zero then this function does nothing. Otherwise, C<clear_func()> is called with the ID as a parameter, and the tag is set to zero.  A macro is also included that allows this function to be used without pointer casts.

  method g_clear_handle_id ( guInt-ptr $tag_ptr, GClearHandleFunc $clear_func )

=item guInt-ptr $tag_ptr; (not nullable): a pointer to the handler ID
=item GClearHandleFunc $clear_func; (not nullable): the function to call to clear the handler

=end pod

sub g_clear_handle_id ( gugint-ptr $tag_ptr, GClearHandleFunc $clear_func  )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_timeout_add_full:
=begin pod
=head2 g_timeout_add_full

Sets a function to be called at regular intervals, with the given priority.  The function is called repeatedly until it returns C<0>, at which point the timeout is automatically destroyed and the function will not be called again.  The I<notify> function is called when the timeout is destroyed.  The first call to the function will be at the end of the first I<interval>.  Note that timeout functions may be delayed, due to the processing of other event sources. Thus they should not be relied on for precise timing. After each call to the timeout function, the time of the next timeout is recalculated based on the current time and the given interval (it does not try to 'catch up' time lost in delays).  See [memory management of sources][mainloop-memory-management] for details on how to handle the return value and memory management of I<data>.  This internally creates a main loop source using C<g_timeout_source_new()> and attaches it to the global B<N-GMainContext> using C<g_source_attach()>, so the callback will be invoked in whichever thread is running that main context. You can do these steps manually if you need greater control or to use a custom main context.  The interval given is in terms of monotonic time, not wall clock time. See C<g_get_monotonic_time()>.

Returns: the ID (greater than 0) of the event source.

  method g_timeout_add_full ( Int $priority, UInt $interval, GSourceFunc $function, Pointer $data, GDestroyNotify $notify --> UInt )

=item Int $priority; the priority of the timeout source. Typically this will be in the range between B<G_PRIORITY_DEFAULT> and B<G_PRIORITY_HIGH>.
=item UInt $interval; the time between calls to the function, in milliseconds (1/1000ths of a second)
=item GSourceFunc $function; function to call
=item Pointer $data; data to pass to I<function>
=item GDestroyNotify $notify; (nullable): function to call when the timeout is removed, or C<Any>

=end pod

sub g_timeout_add_full ( gint $priority, guint $interval, GSourceFunc $function, gpointer $data, GDestroyNotify $notify --> guint )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_timeout_add:
=begin pod
=head2 g_timeout_add

Sets a function to be called at regular intervals, with the default priority, B<G_PRIORITY_DEFAULT>.  The function is called repeatedly until it returns C<0>, at which point the timeout is automatically destroyed and the function will not be called again.  The first call to the function will be at the end of the first I<interval>.  Note that timeout functions may be delayed, due to the processing of other event sources. Thus they should not be relied on for precise timing. After each call to the timeout function, the time of the next timeout is recalculated based on the current time and the given interval (it does not try to 'catch up' time lost in delays).  See [memory management of sources][mainloop-memory-management] for details on how to handle the return value and memory management of I<data>.  If you want to have a timer in the "seconds" range and do not care about the exact time of the first call of the timer, use the C<g_timeout_add_seconds()> function; this function allows for more optimizations and more efficient system power usage.  This internally creates a main loop source using C<g_timeout_source_new()> and attaches it to the global B<N-GMainContext> using C<g_source_attach()>, so the callback will be invoked in whichever thread is running that main context. You can do these steps manually if you need greater control or to use a custom main context.  The interval given is in terms of monotonic time, not wall clock time.  See C<g_get_monotonic_time()>.

Returns: the ID (greater than 0) of the event source.

  method g_timeout_add ( UInt $interval, GSourceFunc $function, Pointer $data --> UInt )

=item UInt $interval; the time between calls to the function, in milliseconds (1/1000ths of a second)
=item GSourceFunc $function; function to call
=item Pointer $data; data to pass to I<function>

=end pod

sub g_timeout_add ( guint $interval, GSourceFunc $function, gpointer $data --> guint )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_timeout_add_seconds_full:
=begin pod
=head2 g_timeout_add_seconds_full

Sets a function to be called at regular intervals, with I<priority>. The function is called repeatedly until it returns C<0>, at which point the timeout is automatically destroyed and the function will not be called again.  Unlike C<g_timeout_add()>, this function operates at whole second granularity. The initial starting point of the timer is determined by the implementation and the implementation is expected to group multiple timers together so that they fire all at the same time. To allow this grouping, the I<interval> to the first timer is rounded and can deviate up to one second from the specified interval. Subsequent timer iterations will generally run at the specified interval.  Note that timeout functions may be delayed, due to the processing of other event sources. Thus they should not be relied on for precise timing. After each call to the timeout function, the time of the next timeout is recalculated based on the current time and the given I<interval>  See [memory management of sources][mainloop-memory-management] for details on how to handle the return value and memory management of I<data>.  If you want timing more precise than whole seconds, use C<g_timeout_add()> instead.  The grouping of timers to fire at the same time results in a more power and CPU efficient behavior so if your timer is in multiples of seconds and you don't require the first timer exactly one second from now, the use of C<g_timeout_add_seconds()> is preferred over C<g_timeout_add()>.  This internally creates a main loop source using  C<g_timeout_source_new_seconds()> and attaches it to the main loop context  using C<g_source_attach()>. You can do these steps manually if you need  greater control.  The interval given is in terms of monotonic time, not wall clock time.  See C<g_get_monotonic_time()>.

Returns: the ID (greater than 0) of the event source.

  method g_timeout_add_seconds_full ( Int $priority, UInt $interval, GSourceFunc $function, Pointer $data, GDestroyNotify $notify --> UInt )

=item Int $priority; the priority of the timeout source. Typically this will be in the range between B<G_PRIORITY_DEFAULT> and B<G_PRIORITY_HIGH>.
=item UInt $interval; the time between calls to the function, in seconds
=item GSourceFunc $function; function to call
=item Pointer $data; data to pass to I<function>
=item GDestroyNotify $notify; (nullable): function to call when the timeout is removed, or C<Any>

=end pod

sub g_timeout_add_seconds_full ( gint $priority, guint $interval, GSourceFunc $function, gpointer $data, GDestroyNotify $notify --> guint )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_timeout_add_seconds:
=begin pod
=head2 g_timeout_add_seconds

Sets a function to be called at regular intervals with the default priority, B<G_PRIORITY_DEFAULT>. The function is called repeatedly until it returns C<0>, at which point the timeout is automatically destroyed and the function will not be called again.  This internally creates a main loop source using C<g_timeout_source_new_seconds()> and attaches it to the main loop context using C<g_source_attach()>. You can do these steps manually if you need greater control. Also see C<g_timeout_add_seconds_full()>.  Note that the first call of the timer may not be precise for timeouts of one second. If you need finer precision and have such a timeout, you may want to use C<g_timeout_add()> instead.  See [memory management of sources][mainloop-memory-management] for details on how to handle the return value and memory management of I<data>.  The interval given is in terms of monotonic time, not wall clock time.  See C<g_get_monotonic_time()>.

Returns: the ID (greater than 0) of the event source.

  method g_timeout_add_seconds ( UInt $interval, GSourceFunc $function, Pointer $data --> UInt )

=item UInt $interval; the time between calls to the function, in seconds
=item GSourceFunc $function; function to call
=item Pointer $data; data to pass to I<function>

=end pod

sub g_timeout_add_seconds ( guint $interval, GSourceFunc $function, gpointer $data --> guint )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_child_watch_add_full:
=begin pod
=head2 g_child_watch_add_full

Sets a function to be called when the child indicated by I<pid>  exits, at the priority I<priority>.  If you obtain I<pid> from C<g_spawn_async()> or C<g_spawn_async_with_pipes()>  you will need to pass B<G_SPAWN_DO_NOT_REAP_CHILD> as flag to  the spawn function for the child watching to work.  In many programs, you will want to call C<g_spawn_check_exit_status()> in the callback to determine whether or not the child exited successfully.  Also, note that on platforms where B<GPid> must be explicitly closed (see C<g_spawn_close_pid()>) I<pid> must not be closed while the source is still active.  Typically, you should invoke C<g_spawn_close_pid()> in the callback function for the source.  GLib supports only a single callback per process id. On POSIX platforms, the same restrictions mentioned for C<g_child_watch_source_new()> apply to this function.  This internally creates a main loop source using  C<g_child_watch_source_new()> and attaches it to the main loop context  using C<g_source_attach()>. You can do these steps manually if you  need greater control.

Returns: the ID (greater than 0) of the event source.

  method g_child_watch_add_full ( Int $priority, GPid $pid, GChildWatchFunc $function, Pointer $data, GDestroyNotify $notify --> UInt )

=item Int $priority; the priority of the idle source. Typically this will be in the range between B<G_PRIORITY_DEFAULT_IDLE> and B<G_PRIORITY_HIGH_IDLE>.
=item GPid $pid; process to watch. On POSIX the positive pid of a child process. On Windows a handle for a process (which doesn't have to be a child).
=item GChildWatchFunc $function; function to call
=item Pointer $data; data to pass to I<function>
=item GDestroyNotify $notify; (nullable): function to call when the idle is removed, or C<Any>

=end pod

sub g_child_watch_add_full ( gint $priority, GPid $pid, GChildWatchFunc $function, gpointer $data, GDestroyNotify $notify --> guint )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_child_watch_add:
=begin pod
=head2 g_child_watch_add

Sets a function to be called when the child indicated by I<pid>  exits, at a default priority, B<G_PRIORITY_DEFAULT>.  If you obtain I<pid> from C<g_spawn_async()> or C<g_spawn_async_with_pipes()>  you will need to pass B<G_SPAWN_DO_NOT_REAP_CHILD> as flag to  the spawn function for the child watching to work.  Note that on platforms where B<GPid> must be explicitly closed (see C<g_spawn_close_pid()>) I<pid> must not be closed while the source is still active. Typically, you will want to call C<g_spawn_close_pid()> in the callback function for the source.  GLib supports only a single callback per process id. On POSIX platforms, the same restrictions mentioned for C<g_child_watch_source_new()> apply to this function.  This internally creates a main loop source using  C<g_child_watch_source_new()> and attaches it to the main loop context  using C<g_source_attach()>. You can do these steps manually if you  need greater control.

Returns: the ID (greater than 0) of the event source.

  method g_child_watch_add ( GPid $pid, GChildWatchFunc $function, Pointer $data --> UInt )

=item GPid $pid; process id to watch. On POSIX the positive pid of a child process. On Windows a handle for a process (which doesn't have to be a child).
=item GChildWatchFunc $function; function to call
=item Pointer $data; data to pass to I<function>

=end pod

sub g_child_watch_add ( GPid $pid, GChildWatchFunc $function, gpointer $data --> guint )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_idle_add:
=begin pod
=head2 g_idle_add

Adds a function to be called whenever there are no higher priority events pending to the default main loop. The function is given the default idle priority, B<G_PRIORITY_DEFAULT_IDLE>.  If the function returns C<0> it is automatically removed from the list of event sources and will not be called again.  See [memory management of sources][mainloop-memory-management] for details on how to handle the return value and memory management of I<data>.  This internally creates a main loop source using C<g_idle_source_new()> and attaches it to the global B<N-GMainContext> using C<g_source_attach()>, so the callback will be invoked in whichever thread is running that main context. You can do these steps manually if you need greater control or to use a custom main context.

Returns: the ID (greater than 0) of the event source.

  method g_idle_add ( GSourceFunc $function, Pointer $data --> UInt )

=item GSourceFunc $function; function to call
=item Pointer $data; data to pass to I<function>.

=end pod

sub g_idle_add ( GSourceFunc $function, gpointer $data --> guint )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_idle_add_full:
=begin pod
=head2 g_idle_add_full

Adds a function to be called whenever there are no higher priority events pending.  If the function returns C<0> it is automatically removed from the list of event sources and will not be called again.  See [memory management of sources][mainloop-memory-management] for details on how to handle the return value and memory management of I<data>.  This internally creates a main loop source using C<g_idle_source_new()> and attaches it to the global B<N-GMainContext> using C<g_source_attach()>, so the callback will be invoked in whichever thread is running that main context. You can do these steps manually if you need greater control or to use a custom main context.

Returns: the ID (greater than 0) of the event source.

  method g_idle_add_full ( Int $priority, GSourceFunc $function, Pointer $data, GDestroyNotify $notify --> UInt )

=item Int $priority; the priority of the idle source. Typically this will be in the range between B<G_PRIORITY_DEFAULT_IDLE> and B<G_PRIORITY_HIGH_IDLE>.
=item GSourceFunc $function; function to call
=item Pointer $data; data to pass to I<function>
=item GDestroyNotify $notify; (nullable): function to call when the idle is removed, or C<Any>

=end pod

sub g_idle_add_full ( gint $priority, GSourceFunc $function, gpointer $data, GDestroyNotify $notify --> guint )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_idle_remove_by_data:
=begin pod
=head2 g_idle_remove_by_data

Removes the idle function with the given data.

Returns: C<1> if an idle source was found and removed.

  method g_idle_remove_by_data ( Pointer $data --> Int )

=item Pointer $data; the data for the idle source's callback.

=end pod

sub g_idle_remove_by_data ( gpointer $data --> gboolean )
  is native(&glib-lib)
  { * }
}}


#`{{
#-------------------------------------------------------------------------------
#TM:0:g_main_context_invoke:
=begin pod
=head2 [[g_] main_] context_invoke

Invokes a function in such a way that I<context> is owned during the invocation of I<function>.  If I<context> is C<Any> then the global default main context — as returned by C<g_main_context_default()> — is used.  If I<context> is owned by the current thread, I<function> is called directly.  Otherwise, if I<context> is the thread-default main context of the current thread and C<g_main_context_acquire()> succeeds, then I<function> is called and C<g_main_context_release()> is called afterwards.  In any other case, an idle source is created to call I<function> and that source is attached to I<context> (presumably to be run in another thread).  The idle source is attached with B<G_PRIORITY_DEFAULT> priority.  If you want a different priority, use C<g_main_context_invoke_full()>.  Note that, as with normal idle functions, I<function> should probably return C<0>.  If it returns C<1>, it will be continuously run in a loop (and may prevent this call from returning).

  method g_main_context_invoke ( N-GMainContext $context, GSourceFunc $function, Pointer $data )

=item N-GMainContext $context; (nullable): a B<N-GMainContext>, or C<Any>
=item GSourceFunc $function; function to call
=item Pointer $data; data to pass to I<function>

=end pod

sub g_main_context_invoke ( N-GMainContext $context, GSourceFunc $function, gpointer $data  )
  is native(&glib-lib)
  { * }

}}















=finish

#`{{
sub g_idle_add ( &Handler ( OpaquePointer $h_data), OpaquePointer $data )
  returns int32
  is native(&glib-lib)
  is export
  { * }
}}

sub g_idle_source_new ( )
  returns OpaquePointer   # N-GSource
  is native(&gtk-lib)
  { * }

sub g_main_context_default ( )
  returns OpaquePointer     # GMainContext
  is native(&gtk-lib)
  { * }

# $context ~~ GMainContext is an opaque pointer
sub g_main_context_get_thread_default ( )
  returns OpaquePointer     # GMainContext
  is native(&gtk-lib)
  { * }

sub g_main_context_invoke (
  OpaquePointer $context,
  &sourceFunction ( OpaquePointer --> int32 ), OpaquePointer
  ) is native(&gtk-lib)
    { * }

sub g_main_context_invoke_full (
  OpaquePointer $context, int32 $priority,
  &sourceFunction ( OpaquePointer --> int32 ), OpaquePointer,
  &destroyNotify ( OpaquePointer )
  ) is native(&gtk-lib)
    { * }

sub g_main_context_new ( )
  returns OpaquePointer     # GMainContext
  is native(&gtk-lib)
  { * }

sub g_main_context_pop_thread_default ( OpaquePointer $context )
  is native(&gtk-lib)
  { * }

sub g_main_context_push_thread_default ( OpaquePointer $context )
  is native(&gtk-lib)
  { * }

# N-GMainLoop is returned
sub g_main_loop_new ( OpaquePointer $context, int32 $is_running )
  returns OpaquePointer
  is native(&gtk-lib)
  { * }

sub g_main_loop_quit ( OpaquePointer $loop )
  is native(&gtk-lib)
  { * }

sub g_main_loop_run ( OpaquePointer $loop )
  is native(&gtk-lib)
  { * }

sub g_source_attach ( OpaquePointer $source, OpaquePointer $context )
  returns uint32
  is native(&gtk-lib)
  { * }

# remove when on other main loop
sub g_source_destroy ( OpaquePointer $source )
  is native(&gtk-lib)
  { * }

# remove when on default main loop
sub g_source_remove ( uint32 $tag )
  returns int32
  is native(&gtk-lib)
  { * }

sub g_timeout_add (
  int32 $interval, &Handler ( OpaquePointer, --> int32 ), OpaquePointer
  ) returns int32
    is native(&gtk-lib)
    { * }

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
method FALLBACK ( $native-sub is copy, |c ) {

  $native-sub ~~ s:g/ '-' /_/ if $native-sub.index('-');
  die X::Gnome.new(:message(
      "Native sub name '$native-sub' made too short. Keep at least one '-' or '_'."
    )
  ) unless $native-sub.index('_') >= 0;

  my Callable $s;
  try { $s = &::("g_main_$native-sub"); };
  try { $s = &::("g_$native-sub"); } unless ?$s;
  try { $s = &::($native-sub); } if !$s and $native-sub ~~ m/^ 'g_' /;

#  CATCH { test-catch-exception( $_, $native-sub); }
  CATCH { .note; die; }

  test-call-without-natobj( $s, |c)
}
