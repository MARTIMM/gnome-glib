#TL:1:Gnome::Glib::List:

use v6;
#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Glib::List

linked lists that can be iterated over in both directions

=comment ![](images/X.png)

=head1 Description

The B<Gnome::Glib::List> structure and its associated functions provide a standard doubly-linked list data structure.

Each element in the list contains a piece of data, together with pointers which link to the previous and next elements in the list. Using these pointers it is possible to move through the list in both directions (unlike the singly-linked list, which only allows movement through the list in the forward direction).

The double linked list does not keep track of the number of items and does not keep track of both the start and end of the list. The data contained in each element can be either simple values like integer or real numbers or pointers to any type of data.

Note that most of the list functions expect to be passed a pointer to the first element in the list.

To create an empty list just call C<.new>.

Raku does have plenty ways of its own two handle data for any kind of problem so a doubly linked list is note really needed. This class, however, is provided (partly) to handle returned information from other GTK+ methods. E.g. A Container can return child widgets in a List like this.


=comment To remove elements, use C<g_list_remove()>.

To navigate in a list, use C<g_list_first()>, C<g_list_last()>, C<next()>, C<previous()>.

To find elements in the list use C<g_list_nth()>, C<g_list_nth_data()>, C<g_list_foreach()> and C<g_list_find_custom()>.

=comment To find the index of an element use C<g_list_position()> and C<g_list_index()>.

To free the entire list, use C<clear-object()> which invalidates the list after freeing the memory.

Most of the time there is no need to manipulate the list because many of the GTK+ functions will return a list of e.g. children in a container which only need to be examined.

=head1 Synopsis
=head2 Declaration

  unit class Gnome::Glib::List;
  also is Gnome::N::TopLevelClassSupport;

=head2 Example 1

To visit all elements in the list, use a loop over the list:

  my Gnome::Glib::List $ll = $list;
  while ?$ll {
    ... do something with data in $ll.data ...
    $ll .= next;
  }

=head2 Example 2

To call a function for each element in the list, use C<g_list_foreach()>.

  class H {
    method h ( Gnome::Glib::List $hl, Int $hi, Pointer $hd ) {
     ... do something with the list item $hl at index $hi and data $hd ...
    }

    ...
  }

  $list.list-foreach( H.new, 'h');

=end pod
#-------------------------------------------------------------------------------
use NativeCall;

use Gnome::N::X;
use Gnome::N::N-GObject;
use Gnome::N::NativeLib;
use Gnome::N::TopLevelClassSupport;

#-------------------------------------------------------------------------------
# See /usr/include/glib-2.0/glib/glist.h
# https://developer.gnome.org/glib/stable/glib-Doubly-Linked-Lists.html
unit class Gnome::Glib::List:auth<github:MARTIMM>;
also is Gnome::N::TopLevelClassSupport;

#-------------------------------------------------------------------------------
=begin pod
=head1 Types
=head2 class N-GList

Structure to create a doubly linked list.
=end pod

#TT:1:N-GList:
class N-GList is repr('CStruct') is export {
  has Pointer $.data;
  has N-GList $.next;
  has N-GList $.prev;
}

#-------------------------------------------------------------------------------
=begin pod
=head1 Methods
=head2 new

Create a new plain object.

  multi method new ( )

Create a new list object using an other native list object.

  multi method new ( N-GList :$native-object! )

=end pod

#TM:1:new():
#TM:4:new(:native-object):Gnome::N::TopLevelClassSupport
submethod BUILD ( *%options ) {

  # prevent creating wrong widgets
  if self.^name eq 'Gnome::Glib::List' or %options<List> {

    # skip if object is already set by parent
    if self.is-valid { }

    # process all named arguments
    elsif ? %options<empty> {
      Gnome::N::deprecate( '.new(:empty)', '.new()', '0.15.5', '0.18.0');
      self.set-native-object(N-GList);
    }

    elsif ? %options<glist> {
      my $no = %options<glist>;
      $no .= get-native-object if $no ~~ Gnome::Glib::List;
      self.set-native-object($no);

      Gnome::N::deprecate(
        '.new(:glist)', '.new(:native-object)', '0.15.5', '0.18.0'
      );
    }

    else { #if ? %options<empty> {
      self.set-native-object(N-GList);
    }

    # only after creating the native-object, the gtype is known
    self.set-class-info('GList');
  }
}

#-------------------------------------------------------------------------------
# no pod. user does not have to know about it.
method _fallback ( $native-sub --> Callable ) {

  my Callable $s;
  try { $s = &::("g_list_$native-sub"); };
  try { $s = &::("g_$native-sub"); } unless ?$s;
  try { $s = &::($native-sub); } if !$s and $native-sub ~~ m/^ 'g_' /;

  self.set-class-name-of-sub('GList');

  $s
}

#-------------------------------------------------------------------------------
method list-is-valid ( --> Bool ) {
  Gnome::N::deprecate(
    '.list-is-valid()', '.is-valid()', '0.15.5', '0.18.0'
  );

  self.is-valid
}

#-------------------------------------------------------------------------------
# TM:1:clear-list
method clear-list ( ) {
  Gnome::N::deprecate(
    '.clear-list()', '.clear-object()', '0.15.5', '0.18.0'
  );

  self.clear-object;
}

#-------------------------------------------------------------------------------
# no referencing for lists
method native-object-ref ( $n-native-object ) {
  $n-native-object
}

#-------------------------------------------------------------------------------
method native-object-unref ( $n-native-object ) {
  _g_list_free($n-native-object)
}

#`{{
#-------------------------------------------------------------------------------
# TM:0:g_list_alloc:
=begin pod
=head2 [g_] list_alloc

Allocates space for one B<Gnome::Glib::List> element. It is called by
C<g_list_append()>, C<g_list_prepend()>, C<g_list_insert()> and
C<g_list_insert_sorted()> and so is rarely used on its own.

Returns: a pointer to the newly-allocated B<Gnome::Glib::List> element

  method g_list_alloc ( --> N-GList  )


=end pod

sub g_list_alloc (  )
  returns N-GList
  is native(&glib-lib)
  { * }
}}

#`{{ not to be used directly
#-------------------------------------------------------------------------------
# TM:0:g_list_free:
=begin pod
=head2 [g_] list_free

Frees all of the memory used by a B<Gnome::Glib::List>.
The freed elements are returned to the slice allocator.

If list elements contain dynamically-allocated memory, you should
either use C<g_list_free_full()> or free them manually first.

  method g_list_free ( )


=end pod
}}

sub _g_list_free ( N-GList $list )
  is native(&glib-lib)
  is symbol('g_list_free')
  { * }

#`{{
#-------------------------------------------------------------------------------
# TM:0:g_list_free_1:
=begin pod
=head2 [[g_] list_] free_1

Frees one B<Gnome::Glib::List> element, but does not update links from the next and
previous elements in the list, so you should not call this function on an
element that is currently part of a list.

It is usually used after C<g_list_remove_link()>.

  method g_list_free_1 ( )


=end pod

sub g_list_free_1 ( N-GList $list )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:g_list_free_full:
=begin pod
=head2 [[g_] list_] free_full

Convenience method, which frees all the memory used by a B<Gnome::Glib::List>,
and calls I<free_func> on every element's data.

I<free_func> must not modify the list (eg, by removing the freed
element from it).

Since: 2.28

  method g_list_free_full ( GDestroyNotify $free_func )

=item GDestroyNotify $free_func; the function to be called to free each element's data

=end pod

sub g_list_free_full ( N-GList $list, GDestroyNotify $free_func )
  is native(&glib-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
# TM:0:g_list_append:
=begin pod
=head2 [g_] list_append

Adds a new element on to the end of the list.

Note that the return value is the new start of the list,
if I<list> was empty; make sure you store the new value.

C<g_list_append()> has to traverse the entire list to find the end,
which is inefficient when adding multiple elements. A common idiom
to avoid the inefficiency is to use C<g_list_prepend()> and reverse
the list with C<g_list_reverse()> when all elements have been added.

|[<!-- language="C" -->
// Notice that these are initialized to the empty list.
GList *string_list = NULL, *number_list = NULL;

// This is a list of strings.
string_list = g_list_append (string_list, "first");
string_list = g_list_append (string_list, "second");

// This is a list of integers.
number_list = g_list_append (number_list, GINT_TO_POINTER (27));
number_list = g_list_append (number_list, GINT_TO_POINTER (14));
]|

Returns: either I<list> or the new start of the B<Gnome::Glib::List> if I<list> was C<Any>

  method g_list_append ( Pointer $data --> N-GList  )

=item Pointer $data; the data for the new element

=end pod

sub g_list_append ( N-GList $list, Pointer $data )
  returns N-GList
  is native(&glib-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
# TM:0:g_list_prepend:
=begin pod
=head2 [g_] list_prepend

Prepends a new element on to the start of the list.

Note that the return value is the new start of the list,
which will have changed, so make sure you store the new value.

|[<!-- language="C" -->
// Notice that it is initialized to the empty list.
GList *list = NULL;

list = g_list_prepend (list, "last");
list = g_list_prepend (list, "first");
]|

Do not use this function to prepend a new element to a different
element than the start of the list. Use C<g_list_insert_before()> instead.

Returns: a pointer to the newly prepended element, which is the new
start of the B<Gnome::Glib::List>

  method g_list_prepend ( Pointer $data --> N-GList  )

=item Pointer $data; the data for the new element

=end pod

sub g_list_prepend ( N-GList $list, Pointer $data )
  returns N-GList
  is native(&glib-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
# TM:0:g_list_insert:
=begin pod
=head2 [g_] list_insert

Inserts a new element into the list at the given position.

Returns: the (possibly changed) start of the B<Gnome::Glib::List>

  method g_list_insert ( Pointer $data, Int $position --> N-GList  )

=item Pointer $data; the data for the new element
=item Int $position; the position to insert the element. If this is  negative, or is larger than the number of elements in the  list, the new element is added on to the end of the list.

=end pod

sub g_list_insert ( N-GList $list, Pointer $data, int32 $position )
  returns N-GList
  is native(&glib-lib)
  { * }
}}
#`{{
#-------------------------------------------------------------------------------
# TM:0:g_list_insert_sorted:
=begin pod
=head2 [[g_] list_] insert_sorted

Inserts a new element into the list, using the given comparison
function to determine its position.

If you are adding many new elements to a list, and the number of
new elements is much larger than the length of the list, use
C<g_list_prepend()> to add the new items and sort the list afterwards
with C<g_list_sort()>.

Returns: the (possibly changed) start of the B<Gnome::Glib::List>

  method g_list_insert_sorted ( Pointer $data, GCompareFunc $func --> N-GList  )

=item Pointer $data; the data for the new element
=item GCompareFunc $func; the function to compare elements in the list. It should  return a number > 0 if the first parameter comes after the  second parameter in the sort order.

=end pod

sub g_list_insert_sorted ( N-GList $list, Pointer $data, GCompareFunc $func )
  returns N-GList
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:g_list_insert_sorted_with_data:
=begin pod
=head2 [[g_] list_] insert_sorted_with_data

Inserts a new element into the list, using the given comparison
function to determine its position.

If you are adding many new elements to a list, and the number of
new elements is much larger than the length of the list, use
C<g_list_prepend()> to add the new items and sort the list afterwards
with C<g_list_sort()>.

Returns: the (possibly changed) start of the B<Gnome::Glib::List>

Since: 2.10

  method g_list_insert_sorted_with_data ( Pointer $data, GCompareDataFunc $func, Pointer $user_data --> N-GList  )

=item Pointer $data; the data for the new element
=item GCompareDataFunc $func; the function to compare elements in the list. It should return a number > 0 if the first parameter  comes after the second parameter in the sort order.
=item Pointer $user_data; user data to pass to comparison function

=end pod

sub g_list_insert_sorted_with_data ( N-GList $list, Pointer $data, GCompareDataFunc $func, Pointer $user_data )
  returns N-GList
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:g_list_insert_before:
=begin pod
=head2 [[g_] list_] insert_before

Inserts a new element into the list before the given position.

Returns: the (possibly changed) start of the B<Gnome::Glib::List>

  method g_list_insert_before ( N-GList $sibling, Pointer $data --> N-GList  )

=item N-GList $sibling; the list element before which the new element  is inserted or C<Any> to insert at the end of the list
=item Pointer $data; the data for the new element

=end pod

sub g_list_insert_before ( N-GList $list, N-GList $sibling, Pointer $data )
  returns N-GList
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:g_list_concat:
=begin pod
=head2 [g_] list_concat

Adds the second B<Gnome::Glib::List> onto the end of the first B<Gnome::Glib::List>.
Note that the elements of the second B<Gnome::Glib::List> are not copied.
They are used directly.

This function is for example used to move an element in the list.
The following example moves an element to the top of the list:
|[<!-- language="C" -->
list = g_list_remove_link (list, llink);
list = g_list_concat (llink, list);
]|

Returns: the start of the new B<Gnome::Glib::List>, which equals I<list1> if not C<Any>

  method g_list_concat ( N-GList $list2 --> N-GList  )

=item N-GList $list2; the B<Gnome::Glib::List> to add to the end of the first B<Gnome::Glib::List>, this must point  to the top of the list

=end pod

sub g_list_concat ( N-GList $list1, N-GList $list2 )
  returns N-GList
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:g_list_remove:
=begin pod
=head2 [g_] list_remove

Removes an element from a B<Gnome::Glib::List>.
If two elements contain the same data, only the first is removed.
If none of the elements contain the data, the B<Gnome::Glib::List> is unchanged.

Returns: the (possibly changed) start of the B<Gnome::Glib::List>

  method g_list_remove ( Pointer $data --> N-GList  )

=item Pointer $data; the data of the element to remove

=end pod

sub g_list_remove ( N-GList $list, Pointer $data )
  returns N-GList
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:g_list_remove_all:
=begin pod
=head2 [[g_] list_] remove_all

Removes all list nodes with data equal to I<data>.
Returns the new head of the list. Contrast with
C<g_list_remove()> which removes only the first node
matching the given data.

Returns: the (possibly changed) start of the B<Gnome::Glib::List>

  method g_list_remove_all ( Pointer $data --> N-GList  )

=item Pointer $data; data to remove

=end pod

sub g_list_remove_all ( N-GList $list, Pointer $data )
  returns N-GList
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:g_list_remove_link:
=begin pod
=head2 [[g_] list_] remove_link

Removes an element from a B<Gnome::Glib::List>, without freeing the element.
The removed element's prev and next links are set to C<Any>, so
that it becomes a self-contained list with one element.

This function is for example used to move an element in the list
(see the example for C<g_list_concat()>) or to remove an element in
the list before freeing its data:
|[<!-- language="C" -->
list = g_list_remove_link (list, llink);
free_some_data_that_may_access_the_list_again (llink->data);
g_list_free (llink);
]|

Returns: the (possibly changed) start of the B<Gnome::Glib::List>

  method g_list_remove_link ( N-GList $llink --> N-GList  )

=item N-GList $llink; an element in the B<Gnome::Glib::List>

=end pod

sub g_list_remove_link ( N-GList $list, N-GList $llink )
  returns N-GList
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:g_list_delete_link:
=begin pod
=head2 [[g_] list_] delete_link

Removes the node link_ from the list and frees it.
Compare this to C<g_list_remove_link()> which removes the node
without freeing it.

Returns: the (possibly changed) start of the B<Gnome::Glib::List>

  method g_list_delete_link ( N-GList $link_ --> N-GList  )

=item N-GList $link_; node to delete from I<list>

=end pod

sub g_list_delete_link ( N-GList $list, N-GList $link_ )
  returns N-GList
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:g_list_reverse:
=begin pod
=head2 [g_] list_reverse

Reverses a B<Gnome::Glib::List>.
It simply switches the next and prev pointers of each element.

Returns: the start of the reversed B<Gnome::Glib::List>

  method g_list_reverse ( --> N-GList  )


=end pod

sub g_list_reverse ( N-GList $list )
  returns N-GList
  is native(&glib-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:0:g_list_copy:
=begin pod
=head2 [g_] list_copy

Copies a B<N-GList>.

Note that this is a "shallow" copy. If the list elements consist of pointers to data, the pointers are copied but the actual data is not. See C<g_list_copy_deep()> if you need to copy the data as well.

Returns: the start of the new list that holds the same data as this list.

  method g_list_copy ( --> Gnome::Glib::List )

=end pod

sub g_list_copy ( N-GList $list --> Gnome::Glib::List ) {
  Gnome::Glib::List.new(:native-object(_g_list_copy($list)))
}

sub _g_list_copy ( N-GList $list )
  returns N-GList
  is symbol('g_list_copy')
  is native(&glib-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
# TM:0:g_list_copy_deep:
=begin pod
=head2 [[g_] list_] copy_deep

Makes a full (deep) copy of a B<Gnome::Glib::List>.

In contrast with C<g_list_copy()>, this function uses I<func> to make
a copy of each list element, in addition to copying the list
container itself.

I<func>, as a B<GCopyFunc>, takes two arguments, the data to be copied
and a I<user_data> pointer. On common processor architectures, it's safe to
pass C<Any> as I<user_data> if the copy function takes only one argument. You
may get compiler warnings from this though if compiling with GCC’s
`-Wcast-function-type` warning.

For instance, if I<list> holds a list of GObjects, you can do:
|[<!-- language="C" -->
another_list = g_list_copy_deep (list, (GCopyFunc) g_object_ref, NULL);
]|

And, to entirely free the new list, you could do:
|[<!-- language="C" -->
g_list_free_full (another_list, g_object_unref);
]|

Returns: the start of the new list that holds a full copy of I<list>,
use C<g_list_free_full()> to free it

Since: 2.34

  method g_list_copy_deep ( GCopyFunc $func, Pointer $user_data --> N-GList  )

=item GCopyFunc $func; a copy function used to copy every element in the list
=item Pointer $user_data; user data passed to the copy function I<func>, or C<Any>

=end pod

sub g_list_copy_deep ( N-GList $list, GCopyFunc $func, Pointer $user_data )
  returns N-GList
  is native(&glib-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:0:g_list_nth:
=begin pod
=head2 [g_] list_nth

Gets the element at the given position in a B<Gnome::Glib::List>.

This iterates over the list until it reaches the I<n>-th position. If you intend to iterate over every element, it is better to use a for-loop as described in the B<Gnome::Glib::List> introduction.

Returns: the element, or C<Any> if the position is off the end of the B<Gnome::Glib::List>

  method g_list_nth ( UInt $n --> N-GList  )

=item UInt $n; the position of the element, counting from 0

=end pod

sub g_list_nth ( N-GList $list, uint32 $n )
  returns N-GList
  is native(&glib-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
# TM:0:g_list_nth_prev:
=begin pod
=head2 [[g_] list_] nth_prev

Gets the element I<n> places before I<list>.

Returns: the element, or C<Any> if the position is
off the end of the B<Gnome::Glib::List>

  method g_list_nth_prev ( UInt $n --> N-GList  )

=item UInt $n; the position of the element, counting from 0

=end pod

sub g_list_nth_prev ( N-GList $list, uint32 $n )
  returns N-GList
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:g_list_find:
=begin pod
=head2 [g_] list_find

Finds the element in a B<Gnome::Glib::List> which contains the given data.

Returns: the found B<Gnome::Glib::List> element, or C<Any> if it is not found

  method g_list_find ( Pointer $data --> N-GList  )

=item Pointer $data; the element data to find

=end pod

sub g_list_find ( N-GList $list, Pointer $data )
  returns N-GList
  is native(&glib-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:4:g_list_find_custom:xt/List-Container-Children.t
=begin pod
=head2 [[g_] list_] find_custom

Finds an element in a B<Gnome::Glib::List>, using a supplied function to find the desired element. It iterates over the list, calling the given function which should return 0 when the desired element is found. The function takes two B<Pointer> arguments, the B<Gnome::Glib::List> element's data as the first argument and the given user data.

Returns: the found B<Gnome::Glib::List> element, or undefined if it is not found

  method g_list_find_custom (
    $func-object, Str $func-name, *%user-data
    --> N-GList
  )

=item Pointer $data; user data passed to the function
=item Callable $func; the function to call for each element. It should return 0 when the desired element is found. When the function returns an undefined value it is assumed that it didn't find a result (=1).

The function must be defined as follows;

  method search-handler ( Pointer $list-data, *%user-data --> Int )

An example where a search is done through a list of widgets returned from, for example, a grid. Such a search could be started after an 'ok' or 'apply' button is clicked on a configuration screen.

  class MySearchEngine {
    method search ( Pointer $list-data, :$widget-name, :$widget-text --> Int ) {

    my Gnome::Gtk3::Widget $w .= new(:native-object($list-data));
    my Str $wname = $w.widget-get-name;

    # stop when specified widget is found
    $wname eq $widget-name ?? 0 !! 1
  }

  # prepare grid
  my Gnome::Gtk3::Grid $g .= new;
  ... a label ...
  ... then an input field ...
  my Gnome::Gtk3::Entry $e .= new;
  $e.set-name('db-username');
  $g.grid-attach( $e, 1, 0, 1, 1);
  ... more fields to specify ...

  # search for an item (in a button click handler)
  my Gnome::Glib::List $list .= new(:native-object($g.get-children));
  if my N-GList $sloc = $list.g_list_find_custom(
    MySearchEngine.new, 'search', :widget-name('db-username')
  ) {
    ... get data from found widget ...
  }

This example might not be the best choice when all fields are searched through this way because most elements are passed multiple times after all tests. To prevent this, one could continue the search from where it returned a defined list. The other option is to use C<g_list_foreach()> defined below.

=end pod

sub g_list_find_custom (
  N-GList $list, $func-object, Str $func-name, *%user-data
  --> N-GList
) {
  my N-GList $result;
  if $func-object.^can($func-name) {
    $result = _g_list_find_custom(
      $list, OpaquePointer,
      sub ( Pointer $list-data, OpaquePointer --> int32 ) {
        # when returned value is returned, assume not found (=1) if undefined
        $func-object."$func-name"( $list-data, |%user-data) // 1
      }
    );
  }

  $result // N-GList
}

sub _g_list_find_custom (
  N-GList $list, OpaquePointer,
  Callable $func ( Pointer $a, Pointer $b --> int32)
  --> N-GList
) is native(&glib-lib)
  is symbol('g_list_find_custom')
  { * }

#`{{
#-------------------------------------------------------------------------------
# TM:0:g_list_position:
=begin pod
=head2 [g_] list_position

Gets the position of the given element
in the B<Gnome::Glib::List> (starting from 0).

Returns: the position of the element in the B<Gnome::Glib::List>,
or -1 if the element is not found

  method g_list_position ( N-GList $llink --> Int  )

=item N-GList $llink; an element in the B<Gnome::Glib::List>

=end pod

sub g_list_position ( N-GList $list, N-GList $llink )
  returns int32
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:g_list_index:
=begin pod
=head2 [g_] list_index

Gets the position of the element containing
the given data (starting from 0).

Returns: the index of the element containing the data,
or -1 if the data is not found

  method g_list_index ( Pointer $data --> Int  )

=item Pointer $data; the data to find

=end pod

sub g_list_index ( N-GList $list, Pointer $data )
  returns int32
  is native(&glib-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:4:g_list_last:xt/List-Container-Children.t
=begin pod
=head2 [g_] list_last

Gets the last element in a B<Gnome::Glib::List>, or undefined if the B<Gnome::Glib::List> has no elements.

  method g_list_last ( --> Gnome::Glib::List )

=end pod

sub g_list_last ( N-GList $list --> Gnome::Glib::List ) {
  my N-GList $no = _g_list_last($list);
  ?$no ?? Gnome::Glib::List.new(:native-object($no)) !! Gnome::Glib::List
}

sub _g_list_last ( N-GList $list --> N-GList )
  is native(&glib-lib)
  is symbol('g_list_last')
  { * }

#-------------------------------------------------------------------------------
#TM:4:g_list_first:xt/List-Container-Children.t
=begin pod
=head2 [g_] list_first

Gets the first element in a B<Gnome::Glib::List>, or undefined if the B<Gnome::Glib::List> has no elements

  method g_list_first ( --> Gnome::Glib::List )

=end pod

sub g_list_first ( N-GList $list --> Gnome::Glib::List ) {
  my N-GList $no = _g_list_first($list);
  ?$no ?? Gnome::Glib::List.new(:native-object($no)) !! Gnome::Glib::List
}

sub _g_list_first ( N-GList $list --> N-GList )
  is native(&glib-lib)
  is symbol('g_list_first')
  { * }

#-------------------------------------------------------------------------------
#TM:0:next:xt/List-Container-Children.t
=begin pod
=head2 next

Gets the next element in a B<Gnome::Glib::List>, or undefined if the B<Gnome::Glib::List> has no more elements.

  method next ( --> Gnome::Glib::List )

=end pod

method next ( --> Gnome::Glib::List ) {
  my N-GList $no = self.get-native-object.next;
  ?$no ?? Gnome::Glib::List.new(:native-object($no)) !! Gnome::Glib::List
}

#-------------------------------------------------------------------------------
#TM:4:previous:xt/List-Container-Children.t
=begin pod
=head2 previous

Gets the previous element in a B<Gnome::Glib::List>, or undefined if the B<Gnome::Glib::List> is at the beginning of the list.

  method previous ( --> Gnome::Glib::List )

=end pod

method previous ( --> Gnome::Glib::List ) {
  my N-GList $no = self.get-native-object.prev;
  ?$no ?? Gnome::Glib::List.new(:native-object($no)) !! Gnome::Glib::List
}

#-------------------------------------------------------------------------------
#TM:4:data:xt/List-Container-Children.t
=begin pod
=head2 data

Gets the data from the current B<Gnome::Glib::List> position.

  method data ( --> Gnome::Glib::List )

=end pod

method data ( --> Any ) {
  self.get-native-object.data
}

#-------------------------------------------------------------------------------
#TM:0:g_list_length:
=begin pod
=head2 [g_] list_length

Gets the number of elements in a B<Gnome::Glib::List>.

This function iterates over the whole list to count its elements.
=comment Use a B<GQueue> instead of a GList if you regularly need the number of items. To check whether the list is non-empty, it is faster to check the list against C<Any>.

Returns: the number of elements in the B<Gnome::Glib::List>

  method g_list_length ( --> UInt  )


=end pod

sub g_list_length ( N-GList $list )
  returns uint32
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:4:g_list_foreach:xt/List-Container-Children.t
=begin pod
=head2 [g_] list_foreach

Calls a function for each element of a B<Gnome::Glib::List>.

It is safe for I<$func> to remove the element from the list, but it must not modify any part of the list after that element.

  method g_list_foreach ( Callable $func, Pointer $user_data )

=item Callable $func; the function to call with each element's data
=item Pointer $user_data; user data to pass to the function

=end pod

method foreach ( $func-object, Str $func-name ) {
  Gnome::N::deprecate(
    '.foreach()', '.g_list_foreach', '0.15.5', '0.18.0'
  );

  if $func-object.^can($func-name) {

    Gnome::N::deprecate(
      ".$func-name\( \$list, \$data\)",
      ".$func-name\( \$list, \$list-entry, \$data\)",
      '0.15.5', '0.18.0'
    );

    _g_list_foreach(
      self.get-native-object,
      sub ( $d, $ud ) {
        $func-object."$func-name"( self, $d);
      },
      OpaquePointer
    )
  }
}

sub g_list_foreach ( N-GList $list, $func-object, Str $func-name ) {
  if $func-object.^can($func-name) {
    my $list-entry = 0;
    _g_list_foreach(
      $list,
      sub ( $d, $ud ) {
        $func-object."$func-name"(
          Gnome::Glib::List.new(:native-object($list)), $list-entry++, $d
        );
      },
      OpaquePointer
    )
  }
}

sub _g_list_foreach (
  N-GList $list,
  Callable $func ( Pointer $data, OpaquePointer $user-data),
  OpaquePointer $user_data
) is native(&glib-lib)
  is symbol('g_list_foreach')
  { * }

#`{{
#-------------------------------------------------------------------------------
# TM:0:g_list_sort:
=begin pod
=head2 [g_] list_sort

Sorts a B<Gnome::Glib::List> using the given comparison function. The algorithm
used is a stable sort.

Returns: the (possibly changed) start of the B<Gnome::Glib::List>

  method g_list_sort ( GCompareFunc $compare_func --> N-GList  )

=item GCompareFunc $compare_func; the comparison function used to sort the B<Gnome::Glib::List>. This function is passed the data from 2 elements of the B<Gnome::Glib::List>  and should return 0 if they are equal, a negative value if the  first element comes before the second, or a positive value if  the first element comes after the second.

=end pod

sub g_list_sort ( N-GList $list, GCompareFunc $compare_func )
  returns N-GList
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:g_list_sort_with_data:
=begin pod
=head2 [[g_] list_] sort_with_data

Like C<g_list_sort()>, but the comparison function accepts
a user data argument.

Returns: the (possibly changed) start of the B<Gnome::Glib::List>

  method g_list_sort_with_data ( GCompareDataFunc $compare_func, Pointer $user_data --> N-GList  )

=item GCompareDataFunc $compare_func; comparison function
=item Pointer $user_data; user data to pass to comparison function

=end pod

sub g_list_sort_with_data ( N-GList $list, GCompareDataFunc $compare_func, Pointer $user_data )
  returns N-GList
  is native(&glib-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:4:g_list_nth_data:Gnome::Gtk3::Button.t
=begin pod
=head2 [[g_] list_] nth_data

Gets the data of the element at the given position.

This iterates over the list until it reaches the I<n>-th position. If you intend to iterate over every element, it is better to use a for-loop as described in the B<Gnome::Glib::List> introduction.

Returns: the element's data, or C<Any> if the position is off the end of the B<Gnome::Glib::List>

  method g_list_nth_data ( UInt $n --> Pointer  )

=item UInt $n; the position of the element

=end pod

sub g_list_nth_data ( N-GList $list, uint32 $n )
  returns Pointer
  is native(&glib-lib)
  { * }

sub g_list_nth_data_str ( N-GList $list, int32 $n --> Str ) {
  Gnome::N::deprecate(
    '.g_list_nth_data_str()', '.g_list_nth_data()', '0.15.5', '0.18.0'
  );

  _g_list_nth_data_str( $list, $n)
}

sub _g_list_nth_data_str ( N-GList $list, int32 $n --> Str )
  is native(&gtk-lib)
  is symbol('g_list_nth_data')
  { * }

sub g_list_nth_data_gobject ( N-GList $list, int32 $n --> N-GObject ) {
  Gnome::N::deprecate(
    '.g_list_nth_data_gobject()', '.g_list_nth_data()', '0.15.5', '0.18.0'
  );

  _g_list_nth_data_gobject( $list, $n)
}

sub _g_list_nth_data_gobject ( N-GList $list, int32 $n --> N-GObject )
  is native(&gtk-lib)
  is symbol('g_list_nth_data')
  { * }
