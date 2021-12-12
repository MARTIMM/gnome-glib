#TL:+:Gnome::Glib::SList

use v6;
#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Glib::SList

Linked lists that can be iterated in one direction

=head1 Description

The C<N-GSList> structure and its associated functions provide a standard singly-linked list data structure.

Each element in the list contains a piece of data, together with a pointer which links to the next element in the list. Using this pointer it is possible to move through the list in one direction only (unlike the double-linked lists, which allow movement in both directions).

=begin comment
The data contained in each element can be either integer values or simply pointers to any type of data.

List elements are allocated from the [slice allocator][glib-Memory-Slices], which is more efficient than allocating elements individually.
=end comment

Note that most of the C<N-GSList> functions expect to be passed a pointer to the first element in the list. The functions which insert elements set the new start of the list, which may have changed.

=begin comment
There is no function to create a C<N-GSList>. C<Any> is considered to be the empty list so you simply set a C<N-GSList> to C<Any>.

To add elements, use C<g_slist_append()>, C<g_slist_prepend()>, C<g_slist_insert()> and C<g_slist_insert_sorted()>.

To remove elements, use C<g_slist_remove()>.

To find elements in the list use C<g_slist_last()>, C<g_slist_next()>, C<g_slist_nth()>, C<g_slist_nth_data()>, C<g_slist_find()> and C<g_slist_find_custom()>.

To find the index of an element use C<g_slist_position()> and C<g_slist_index()>.

To call a function for each element in the list use C<g_slist_foreach()>.
=end comment

To free the entire list, use C<clear-gslist()>.

Many methods are not needed in simple Raku use. Most of the time you get a list from a method to process. For example, retrieving information from a widget path, See the example below.


=head2 Uml Diagram

![](plantuml/SList.svg)


=head1 Synopsis
=head2 Declaration

  unit class Gnome::Glib::SList;
  also is Gnome::N::TopLevelClassSupport;


=head2 Example

This example shows how to get and show some information from a widget path.

  # Build a gui; a button in a grid
  my Gnome::Gtk3::Window $w .= new;
  $w.set-name('top-level-window');

  my Gnome::Gtk3::Grid $g .= new();
  $w.add($g);

  my Gnome::Gtk3::Button $b1 .= new(:label<Start>);
  $g.grid-attach( $b1, 0, 0, 1, 1);

  # Get class names of the button in the widget path
  my Gnome::Gtk3::WidgetPath $wp .= new(:native-object($b1.get-path));
  my Gnome::Glib::SList $l .= new(:native-object($wp.iter-list-classes(2)));
  is $l.slist-length, 1, 'list contains one class';
  is $l.nth-data-str(0), 'text-button', "class is a 'text-button'";

=end pod
#-------------------------------------------------------------------------------
use NativeCall;

use Gnome::N::X;
use Gnome::N::N-GObject;
use Gnome::N::NativeLib;
use Gnome::N::TopLevelClassSupport;
use Gnome::N::GlibToRakuTypes;

#-------------------------------------------------------------------------------
# See /usr/include/glib-2.0/glib/gslist.h
# https://developer.gnome.org/glib/stable/glib-Singly-Linked-List.html
unit class Gnome::Glib::SList:auth<github:MARTIMM>;
also is Gnome::N::TopLevelClassSupport;

#-------------------------------------------------------------------------------
=begin pod
=head1 Types
=head2 class N-GSList

Structure to create a single linked list. This native object is stored here to prevent circular dependencies.
=end pod

#TT:1:N-GSList:
class N-GSList is repr('CStruct') is export {
  has Pointer $.data;
  has N-GSList $.next;
}

#-------------------------------------------------------------------------------
=begin pod
=head1 Methods
=head2 new
=head3 default, no options

Create a new plain object.

  multi method new ( )

=head3 :native-object

Create an object using a native object from elsewhere.

  multi method new ( N-GSList :$native-object! )

=end pod

#TM:4:new(:native-object):Gnome::N::TopLevelClassSupport
#TM:1:new():
submethod BUILD ( *%options ) {

  # prevent creating wrong widgets
  if self.^name eq 'Gnome::Glib::SList' or %options<GSList> {

    # skip if object is already set by parent
    if self.is-valid { }

    # process all named arguments
    elsif ? %options<empty> {
      Gnome::N::deprecate( '.new(:empty)', '.new()', '0.15.5', '0.18.0');
      self.set-native-object(N-GSList);
    }

    elsif ? %options<gslist> {
      my $no = %options<gslist>;
      $no .= get-native-object if $no ~~ Gnome::Glib::SList;
      self.set-native-object($no);

      Gnome::N::deprecate(
        '.new(:gslist)', '.new(:native-object)', '0.16.0', '0.18.0'
      );
    }

    else {
      self.set-native-object(N-GSList);
    }

    # only after creating the native-object, the gtype is known
    self._set-class-info('GSList');
  }
}

#-------------------------------------------------------------------------------
method _fallback ( $native-sub ) {

  my Callable $s;
  try { $s = &::("g_slist_$native-sub") };
  try { $s = &::("g_$native-sub"); } unless ?$s;
  try { $s = &::($native-sub); } if !$s and $native-sub ~~ m/^ 'g_' /;

  self._set-class-name-of-sub('GSList');

  $s
}

#-------------------------------------------------------------------------------
method clear-gslist ( ) {

  Gnome::N::deprecate(
    '.clear-gslist()', '.clear-object()', '0.16.1', '0.18.0'
  );
  self.clear-object;
}

#-------------------------------------------------------------------------------
method gslist-is-valid ( --> Bool ) {

  Gnome::N::deprecate(
    '.gslist-is-valid()', '.is-valid()', '0.16.1', '0.18.0'
  );

  self.is-valid;
}

#-------------------------------------------------------------------------------
# no referencing for lists
method native-object-ref ( $n-native-object ) {
  $n-native-object
}

#-------------------------------------------------------------------------------
method native-object-unref ( $n-native-object ) {
  # check for self.is-valid is not good enough. empty lists (undefined)
  # are still valid but should be cleared to prevent '***MEMORY-ERROR***:
  # qa-manager.pl6[28683]: GSlice: assertion failed: sinfo->n_allocated > 0'

  _g_slist_free($n-native-object) if g_slist_length($n-native-object);
}

#-------------------------------------------------------------------------------
#TM:0:g_slist_free
#`{{ No pod, user must use clear-gslist()
=begin pod
=head2 [g_] slist_free

Frees all of the memory used by a C<N-GSList>.
The freed elements are returned to the slice allocator.

If list elements contain dynamically-allocated memory,
you should either use C<g_slist_free_full()> or free them manually
first.

  method g_slist_free ( N-GSList $list )

=item N-GObject $list; a C<N-GSList>

=end pod
}}

sub _g_slist_free ( N-GSList $list )
  is native(&glib-lib)
  is symbol('g_slist_free')
  { * }


#-------------------------------------------------------------------------------
#TM:0:g_slist_reverse

=begin pod
=head2 [g_] slist_reverse

Reverses a C<N-GSList>.

Returns: the start of the reversed C<N-GSList>

  method g_slist_reverse ( N-GSList $list --> N-GSList  )

=item N-GSList $list; a C<N-GSList>

=end pod

sub g_slist_reverse ( N-GSList $list --> N-GSList )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_slist_copy

=begin pod
=head2 [g_] slist_copy

Copies a C<N-GSList>.

Note that this is a "shallow" copy. If the list elements consist of pointers to data, the pointers are copied but the actual data isn't. See C<g_slist_copy_deep()> if you need to copy the data as well.

Returns: a copy of I<list>

  method g_slist_copy ( N-GSList $list --> N-GSList  )

=item N-GSList $list; a C<N-GSList>

=end pod

sub g_slist_copy ( N-GSList $list --> N-GSList )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_slist_nth

=begin pod
=head2 [g_] slist_nth

Gets the element at the given position in a C<N-GSList>.

Returns: the element, or undefined if the position is off the end of the C<N-GSList>

  method g_slist_nth ( N-GSList $list, UInt $n --> N-GSList  )

=item N-GSList $list; a C<N-GSList>
=item UInt $n; the position of the element, counting from 0

=end pod

sub g_slist_nth ( N-GSList $list, guint $n --> N-GSList )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_slist_last

=begin pod
=head2 [g_] slist_last

Gets the last element in a C<N-GSList>.

This function iterates over the whole list.

Returns: the last element in the C<N-GSList>, or C<Any> if the C<N-GSList> has no elements

  method g_slist_last ( N-GSList $list --> N-GSList )

=item N-GSList $list; a C<N-GSList>

=end pod

sub g_slist_last ( N-GSList $list --> N-GSList )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:+:g_slist_length

=begin pod
=head2 [g_] slist_length

Gets the number of elements in a C<N-GSList>.

This function iterates over the whole list to count its elements. To check whether the list is non-empty, it is faster to check I<list> against an undefined native slist.

Returns: the number of elements in the C<N-GSList>

  method g_slist_length ( N-GSList $list --> UInt  )

=item N-GSList $list; a C<N-GSList>

=end pod

sub g_slist_length ( N-GSList $list --> guint )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_slist_nth_data

=begin pod
=head2 [[g_] slist_] nth_data

Gets the data of the element at the given position.

Returns: the element's data, or C<Any> if the position is off the end of the C<N-GSList>. Extra methods are added to return specific types of data.

  method g_slist_nth_data ( N-GSList $list, UInt $n --> Pointer )
  method g_slist_nth_data_str ( N-GSList $list, UInt $n --> Str )
  method g_slist_nth_data_gobject ( N-GSList $list, UInt $n --> N-GObject )

=item N-GSList $list; a C<N-GSList>
=item UInt $n; the position of the element

=end pod

sub g_slist_nth_data ( N-GSList $list, guint $n --> gpointer )
  is native(&glib-lib)
  { * }




# next subs are obsolete
sub g_slist_nth_data_str ( N-GSList $list, guint $n --> Str ) {
  Gnome::N::deprecate(
    '.g_slist_nth_data_str()', '.g_list_nth_data()', '0.15.5', '0.18.0'
  );

  _g_slist_nth_data_str( $list, $n)
}

sub _g_slist_nth_data_str ( N-GSList $list, guint $n --> Str )
  is native(&gtk-lib)
  is symbol('g_slist_nth_data')
  { * }

sub g_slist_nth_data_gobject ( N-GSList $list, guint $n --> N-GObject ) {
  Gnome::N::deprecate(
    '.g_slist_nth_data_gobject()', '.g_slist_nth_data()', '0.15.5', '0.18.0'
  );

  _g_slist_nth_data_gobject( $list, $n)
}

sub _g_slist_nth_data_gobject ( N-GSList $list, guint $n --> N-GObject )
  is native(&gtk-lib)
  is symbol('g_slist_nth_data')
  { * }






























=finish

#`{{
#-------------------------------------------------------------------------------
#TM:0:g_slist_find

=begin pod
=head2 [g_] slist_find

Finds the element in a C<N-GSList> which
contains the given data.

Returns: the found C<N-GSList> element,
or C<Any> if it is not found

  method g_slist_find ( N-GSList $list, Pointer $data --> N-GSList  )

=item N-GSList $list; a C<N-GSList>
=item Pointer $data; the element data to find

=end pod

sub g_slist_find ( N-GSList $list, Pointer $data --> N-GSList )
  is native(&glib-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
#TM:0:g_slist_find_custom

=begin pod
=head2 [[g_] slist_] find_custom

Finds an element in a C<N-GSList>, using a supplied function to
find the desired element. It iterates over the list, calling
the given function which should return 0 when the desired
element is found. The function takes two C<gconstpointer> arguments,
the C<N-GSList> element's data as the first argument and the
given user data.

Returns: the found C<N-GSList> element, or C<Any> if it is not found

  method g_slist_find_custom ( N-GSList $list, Pointer $data, GCompareFunc $func --> N-GSList  )

=item N-GSList $list; a C<N-GSList>
=item Pointer $data; user data passed to the function
=item GCompareFunc $func; the function to call for each element. It should return 0 when the desired element is found

=end pod

sub g_slist_find_custom ( N-GSList $list, Pointer $data, GCompareFunc $func --> N-GSList )
  is native(&glib-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
#TM:0:g_slist_position

=begin pod
=head2 [g_] slist_position

Gets the position of the given element
in the C<N-GSList> (starting from 0).

Returns: the position of the element in the C<N-GSList>,
or -1 if the element is not found

  method g_slist_position ( N-GSList $list, N-GSList $llink --> Int  )

=item N-GSList $list; a C<N-GSList>
=item N-GSList $llink; an element in the C<N-GSList>

=end pod

sub g_slist_position ( N-GSList $list, N-GSList $llink --> int32 )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_slist_index

=begin pod
=head2 [g_] slist_index

Gets the position of the element containing
the given data (starting from 0).

Returns: the index of the element containing the data,
or -1 if the data is not found

  method g_slist_index ( N-GSList $list, Pointer $data --> Int  )

=item N-GSList $list; a C<N-GSList>
=item Pointer $data; the data to find

=end pod

sub g_slist_index ( N-GSList $list, Pointer $data --> int32 )
  is native(&glib-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
#TM:0:g_slist_foreach

=begin pod
=head2 [g_] slist_foreach

Calls a function for each element of a C<N-GSList>.

It is safe for I<func> to remove the element from I<list>, but it must
not modify any part of the list after that element.

  method g_slist_foreach ( N-GSList $list, GFunc $func, Pointer $user_data )

=item N-GSList $list; a C<N-GSList>
=item GFunc $func; the function to call with each element's data
=item Pointer $user_data; user data to pass to the function

=end pod

sub g_slist_foreach ( N-GSList $list, GFunc $func, Pointer $user_data )
  is native(&glib-lib)
  { * }
}}
#`{{
#-------------------------------------------------------------------------------
#TM:0:g_slist_sort

=begin pod
=head2 [g_] slist_sort

Sorts a C<N-GSList> using the given comparison function. The algorithm
used is a stable sort.

Returns: the start of the sorted C<N-GSList>

  method g_slist_sort ( N-GSList $list, GCompareFunc $compare_func --> N-GSList  )

=item N-GSList $list; a C<N-GSList>
=item GCompareFunc $compare_func; the comparison function used to sort the C<N-GSList>. This function is passed the data from 2 elements of the C<N-GSList> and should return 0 if they are equal, a negative value if the first element comes before the second, or a positive value if the first element comes after the second.

=end pod

sub g_slist_sort ( N-GSList $list, GCompareFunc $compare_func --> N-GSList )
  is native(&glib-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
#TM:0:g_slist_sort_with_data

=begin pod
=head2 [[g_] slist_] sort_with_data

Like C<g_slist_sort()>, but the sort function accepts a user data argument.

Returns: new head of the list

  method g_slist_sort_with_data ( N-GSList $list, GCompareDataFunc $compare_func, Pointer $user_data --> N-GSList  )

=item N-GSList $list; a C<N-GSList>
=item GCompareDataFunc $compare_func; comparison function
=item Pointer $user_data; data to pass to comparison function

=end pod

sub g_slist_sort_with_data ( N-GSList $list, GCompareDataFunc $compare_func, Pointer $user_data --> N-GSList )
  is native(&glib-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
#TM:0:g_slist_alloc

=begin pod
=head2 [g_] slist_alloc

Allocates space for one C<N-GSList> element. It is called by the C<g_slist_append()>, C<g_slist_prepend()>, C<g_slist_insert()> and C<g_slist_insert_sorted()> functions and so is rarely used on its own.

Returns: a pointer to the newly-allocated C<N-GSList> element.

  method g_slist_alloc ( --> N-GSList  )

=item G_GNUC_WARN_UNUSED_RESUL $T;

=end pod

sub g_slist_alloc ( --> N-GSList )
  is native(&glib-lib)
  { * }
}}
#`{{
#-------------------------------------------------------------------------------
#TM:0:g_slist_free_1

=begin pod
=head2 [[g_] slist_] free_1

Frees one C<N-GSList> element. It is usually used after C<g_slist_remove_link()>.

  method g_slist_free_1 ( )

=end pod

sub g_slist_free_1 ( N-GSList $list )
  is native(&glib-lib)
  { * }
}}
#`{{
#-------------------------------------------------------------------------------
#TM:0:g_slist_free_full

=begin pod
=head2 [[g_] slist_] free_full

Convenience method, which frees all the memory used by a C<N-GSList>, and
calls the specified destroy function on every element's data.

I<free_func> must not modify the list (eg, by removing the freed
element from it).

Since: 2.28

  method g_slist_free_full ( N-GObject $list, GDestroyNotify $free_func )

=item N-GObject $list; a pointer to a C<N-GSList>
=item GDestroyNotify $free_func; the function to be called to free each element's data

=end pod

sub g_slist_free_full ( N-GObject $list, GDestroyNotify $free_func )
  is native(&glib-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
#TM:0:g_slist_append

=begin pod
=head2 [g_] slist_append

Adds a new element on to the end of the list.

The return value is the new start of the list, which may have changed, so make sure you store the new value.

Note that C<g_slist_append()> has to traverse the entire list to find the end, which is inefficient when adding multiple elements. A common idiom to avoid the inefficiency is to prepend the elements and reverse the list when all elements have been added.

|[<!-- language="C" -->
// Notice that these are initialized to the empty list.
GSList *list = NULL, *number_list = NULL;

// This is a list of strings.
list = g_slist_append ( list, "first");
list = g_slist_append ( list, "second");

// This is a list of integers.
number_list = g_slist_append (number_list, GINT_TO_POINTER (27));
number_list = g_slist_append (number_list, GINT_TO_POINTER (14));
]|

Returns: the new start of the C<N-GSList>

  method g_slist_append ( N-GSList $list, Pointer $data --> N-GSList  )

=item N-GSList $list; a C<N-GSList>
=item Pointer $data; the data for the new element

=end pod
method g_slist_append (Any $data) {
  $!gslist = _g_slist_append( $!gslist, nativecast( Pointer[void], $data));
}

sub _g_slist_append ( N-GSList $list, Pointer[void] $data --> N-GSList )
  is native(&glib-lib)
  is symbol('g_slist_append')
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
#TM:0:g_slist_prepend

=begin pod
=head2 [g_] slist_prepend

Adds a new element on to the start of the list.

The return value is the new start of the list, which
may have changed, so make sure you store the new value.

|[<!-- language="C" -->
// Notice that it is initialized to the empty list.
GSList *list = NULL;
list = g_slist_prepend (list, "last");
list = g_slist_prepend (list, "first");
]|

Returns: the new start of the C<N-GSList>

  method g_slist_prepend ( N-GSList $list, Pointer $data --> N-GSList  )

=item N-GSList $list; a C<N-GSList>
=item Pointer $data; the data for the new element

=end pod

sub g_slist_prepend ( N-GSList $list, Pointer $data --> N-GSList )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_slist_insert

=begin pod
=head2 [g_] slist_insert

Inserts a new element into the list at the given position.

Returns: the new start of the C<N-GSList>

  method g_slist_insert ( N-GSList $list, Pointer $data, Int $position --> N-GSList  )

=item N-GSList $list; a C<N-GSList>
=item Pointer $data; the data for the new element
=item Int $position; the position to insert the element. If this is negative, or is larger than the number of elements in the list, the new element is added on to the end of the list.

=end pod

sub g_slist_insert ( N-GSList $list, Pointer $data, int32 $position --> N-GSList )
  is native(&glib-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
#TM:0:g_slist_insert_sorted

=begin pod
=head2 [[g_] slist_] insert_sorted

Inserts a new element into the list, using the given
comparison function to determine its position.

Returns: the new start of the C<N-GSList>

  method g_slist_insert_sorted ( N-GSList $list, Pointer $data, GCompareFunc $func --> N-GSList  )

=item N-GSList $list; a C<N-GSList>
=item Pointer $data; the data for the new element
=item GCompareFunc $func; the function to compare elements in the list. It should return a number > 0 if the first parameter comes after the second parameter in the sort order.

=end pod

sub g_slist_insert_sorted ( N-GSList $list, Pointer $data, GCompareFunc $func --> N-GSList )
  is native(&glib-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
#TM:0:g_slist_insert_sorted_with_data

=begin pod
=head2 [[g_] slist_] insert_sorted_with_data

Inserts a new element into the list, using the given
comparison function to determine its position.

Returns: the new start of the C<N-GSList>

Since: 2.10

  method g_slist_insert_sorted_with_data ( N-GSList $list, Pointer $data, GCompareDataFunc $func, Pointer $user_data --> N-GSList  )

=item N-GSList $list; a C<N-GSList>
=item Pointer $data; the data for the new element
=item GCompareDataFunc $func; the function to compare elements in the list. It should return a number > 0 if the first parameter comes after the second parameter in the sort order.
=item Pointer $user_data; data to pass to comparison function

=end pod

sub g_slist_insert_sorted_with_data ( N-GSList $list, Pointer $data, GCompareDataFunc $func, Pointer $user_data --> N-GSList )
  is native(&glib-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
#TM:0:g_slist_insert_before

=begin pod
=head2 [[g_] slist_] insert_before

Inserts a node before I<sibling> containing I<data>.

Returns: the new head of the list.

  method g_slist_insert_before ( N-GSList $slist, N-GSList $sibling, Pointer $data --> N-GSList  )

=item N-GSList $slist; a C<N-GSList>
=item N-GSList $sibling; node to insert I<data> before
=item Pointer $data; data to put in the newly-inserted node

=end pod

sub g_slist_insert_before ( N-GSList $slist, N-GSList $sibling, Pointer $data --> N-GSList )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_slist_concat

=begin pod
=head2 [g_] slist_concat

Adds the second C<N-GSList> onto the end of the first C<N-GSList>.
Note that the elements of the second C<N-GSList> are not copied.
They are used directly.

Returns: the start of the new C<N-GSList>

  method g_slist_concat ( N-GSList $list1, N-GSList $list2 --> N-GSList  )

=item N-GSList $list1; a C<N-GSList>
=item N-GSList $list2; the C<N-GSList> to add to the end of the first C<N-GSList>

=end pod

sub g_slist_concat ( N-GSList $list1, N-GSList $list2 --> N-GSList )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_slist_remove

=begin pod
=head2 [g_] slist_remove

Removes an element from a C<N-GSList>.
If two elements contain the same data, only the first is removed.
If none of the elements contain the data, the C<N-GSList> is unchanged.

Returns: the new start of the C<N-GSList>

  method g_slist_remove ( N-GSList $list, Pointer $data --> N-GSList  )

=item N-GSList $list; a C<N-GSList>
=item Pointer $data; the data of the element to remove

=end pod

sub g_slist_remove ( N-GSList $list, Pointer $data --> N-GSList )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_slist_remove_all

=begin pod
=head2 [[g_] slist_] remove_all

Removes all list nodes with data equal to I<data>.
Returns the new head of the list. Contrast with
C<g_slist_remove()> which removes only the first node
matching the given data.

Returns: new head of I<list>

  method g_slist_remove_all ( N-GSList $list, Pointer $data --> N-GSList  )

=item N-GSList $list; a C<N-GSList>
=item Pointer $data; data to remove

=end pod

sub g_slist_remove_all ( N-GSList $list, Pointer $data --> N-GSList )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_slist_remove_link

=begin pod
=head2 [[g_] slist_] remove_link

Removes an element from a C<N-GSList>, without
freeing the element. The removed element's next
link is set to C<Any>, so that it becomes a
self-contained list with one element.

Removing arbitrary nodes from a singly-linked list
requires time that is proportional to the length of the list
(ie. O(n)). If you find yourself using C<g_slist_remove_link()>
frequently, you should consider a different data structure,
such as the doubly-linked C<N-GSList>.

Returns: the new start of the C<N-GSList>, without the element

  method g_slist_remove_link ( N-GSList $list, N-GSList $link_ --> N-GSList  )

=item N-GSList $list; a C<N-GSList>
=item N-GSList $link_; an element in the C<N-GSList>

=end pod

sub g_slist_remove_link ( N-GSList $list, N-GSList $link_ --> N-GSList )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_slist_delete_link

=begin pod
=head2 [[g_] slist_] delete_link

Removes the node link_ from the list and frees it.
Compare this to C<g_slist_remove_link()> which removes the node
without freeing it.

Removing arbitrary nodes from a singly-linked list requires time
that is proportional to the length of the list (ie. O(n)). If you
find yourself using C<g_slist_delete_link()> frequently, you should
consider a different data structure, such as the doubly-linked
C<GList>.

Returns: the new head of I<list>

  method g_slist_delete_link ( N-GSList $list, N-GSList $link_ --> N-GSList  )

=item N-GSList $list; a C<N-GSList>
=item N-GSList $link_; node to delete

=end pod

sub g_slist_delete_link ( N-GSList $list, N-GSList $link_ --> N-GSList )
  is native(&glib-lib)
  { * }
}}
#`{{
#-------------------------------------------------------------------------------
#TM:0:g_slist_copy_deep

=begin pod
=head2 [[g_] slist_] copy_deep

Makes a full (deep) copy of a C<N-GSList>.

In contrast with C<g_slist_copy()>, this function uses I<func> to make a copy of
each list element, in addition to copying the list container itself.

I<func>, as a C<GCopyFunc>, takes two arguments, the data to be copied
and a I<user_data> pointer. On common processor architectures, it's safe to
pass C<Any> as I<user_data> if the copy function takes only one argument. You
may get compiler warnings from this though if compiling with GCC’s
`-Wcast-function-type` warning.

For instance, if I<list> holds a list of GObjects, you can do:
|[<!-- language="C" -->
another_list = g_slist_copy_deep (list, (GCopyFunc) g_object_ref, NULL);
]|

And, to entirely free the new list, you could do:
|[<!-- language="C" -->
g_slist_free_full (another_list, g_object_unref);
]|

Returns: a full copy of I<list>, use C<g_slist_free_full()> to free it

Since: 2.34

  method g_slist_copy_deep ( N-GSList $list, GCopyFunc $func, Pointer $user_data --> N-GSList  )

=item N-GSList $list; a C<N-GSList>
=item GCopyFunc $func; a copy function used to copy every element in the list
=item Pointer $user_data; user data passed to the copy function I<func>, or C<NULL>

=end pod

sub g_slist_copy_deep ( N-GSList $list, GCopyFunc $func, Pointer $user_data --> N-GSList )
  is native(&glib-lib)
  { * }
}}






#-------------------------------------------------------------------------------
sub g_slist_length ( N-GSList $list --> uint32 )
  is native(&gtk-lib)
  { * }

sub g_slist_last ( N-GSList $list --> N-GSList )
  is native(&gtk-lib)
  { * }

sub g_slist_nth ( N-GSList $list, uint32 $n --> N-GSList )
  is native(&gtk-lib)
  { * }

#sub g_slist_nth_data ( N-GSList $list, uint32 $n --> Any )
#  is native(&gtk-lib)
#  { * }

sub g_slist_nth_data_str ( N-GSList $list, uint32 $n --> Str )
  is native(&gtk-lib)
  is symbol('g_slist_nth_data')
  { * }

sub g_slist_nth_data_gobject ( N-GSList $list, uint32 $n --> N-GObject )
  is native(&gtk-lib)
  is symbol('g_slist_nth_data')
  { * }

#TODO use a $!is-valid boolean
sub _g_slist_free ( N-GSList $list )
  is native(&gtk-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
method g_list_previous( N-GSList $list --> N-GSList ) {
  $!g-list.prev
}

#-------------------------------------------------------------------------------
method g_list_next( N-GSList $list --> N-GSList ) {
  $!g-list.next
}
}}
