#TL:1:Gnome::Glib::List:

use v6;
#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Glib::List

linked lists that can be iterated over in both directions

=head1 Description

The B<Gnome::Glib::List> structure and its associated functions provide a standard doubly-linked list data structure.

Each element in the list contains a piece of data, together with pointers which link to the previous and next elements in the list. Using these pointers it is possible to move through the list in both directions (unlike the singly-linked list, which only allows movement through the list in the forward direction).

The double linked list does not keep track of the number of items and does not keep track of both the start and end of the list. The data contained in each element can be either simple values like integer or real numbers or pointers to any type of data.

Note that most of the list functions expect to be passed a pointer to the first element in the list.

Raku does have plenty ways of its own two handle data for any kind of problem so a doubly linked list is not really needed. This class, however, is provided to handle returned information from other GTK+ methods. E.g. A Container can return child widgets in a List like this.
If you really, really want to use this module for your own data, please study the test program in C<t/List.t>. It is important for instance to gard your data against Raku's garbage collecting. Your data gets corrupted before you can say C<Oh! my program runs ok … (His Famous Last Words)>.

To create an empty list just call C<.new>.

To remove elements, use C<remove()>.

To navigate in a list, use C<first()>, C<last()>, C<next()>, C<previous()>, etc.

To find elements in the list use C<nth()>, C<nth_data()>, C<foreach()> and C<find_custom()>.

To find the index of an element use C<position()> and C<index()>.

To free the entire list, use C<clear-object()>.

When methods return lists, the list might be empty if e.g., things can not be found. You can test for its validity.

=head1 Synopsis
=head2 Declaration

  unit class Gnome::Glib::List;
  also is Gnome::N::TopLevelClassSupport;


=head2 Uml Diagram

![](plantuml/List.svg)


=head2 Example 1, a while loop to visit all widgets in a grid

  # Get the objects from the grid in a list
  my Gnome::Glib::List $list .= new(
    :native-object($grid.get-children)
  );

  while $list.is-valid {
    # Do something with data at $list.data
    my N-GObject $no = $list.data;
    my Gnome::Gtk3::Widget $w .= new(:native-object($no));

    # Names can be set but are like 'GtkLabel', GtkButton', etc. by default
    given $w.get-name {
      when 'GtkLabel' {
        my Gnome::Gtk3::Label $hl .= new(:native-object($no));
        …
      }
      …
    }

    $list .= next;
  }

  $list.clear-object;


=head2 Example 2, using foreach() to visit all items in the list

  use NativeCall;

  class ListManagement {
    method list-handler ( Pointer $item ) {
      # do something with the data $item
      my Gnome::Gtk3::Widget $w .= new(:native-object($item));
      given $w.get-name {
        when 'GtkLabel' {
          my Gnome::Gtk3::Label $lbl .= new(:native-object($item));
          …
        }
        …
      }
    }
  }

  # Get the objects from the grid in a list
  my Gnome::Glib::List $list .= new(
    :native-object($grid.get-children)
  );

  # work through all items in this list
  $list.foreach( ListManagement.new, 'list-handler');
  $list.clear-object;

=end pod
#-------------------------------------------------------------------------------
use NativeCall;

#use Gnome::N::X;
use Gnome::N::N-GObject;
use Gnome::N::NativeLib;
use Gnome::N::TopLevelClassSupport;
use Gnome::N::GlibToRakuTypes;

#-------------------------------------------------------------------------------
# See /usr/include/glib-2.0/glib/glist.h
# https://developer.gnome.org/glib/stable/glib-Doubly-Linked-Lists.html
unit class Gnome::Glib::List:auth<github:MARTIMM>:ver<0.2.0>;
also is Gnome::N::TopLevelClassSupport;

#-------------------------------------------------------------------------------
=begin pod
=head1 Types
=head2 class N-GList

Structure to create a doubly linked list.
=end pod

#TT:1:N-GList:
class N-GList is repr('CStruct') is export {
  has gpointer $.data;
  has N-GList $.next;
  has N-GList $.prev;
}

#-------------------------------------------------------------------------------
=begin pod
=head1 Methods
=head2 new

=head3 Default, no options

Create a new plain object.

  multi method new ( )

=head3 :native-object

Create a new list object using an other native list object.

  multi method new ( N-GList :$native-object! )

=end pod

#TM:1:new():
#TM:4:new(:native-object):Gnome::N::TopLevelClassSupport
submethod BUILD ( *%options ) {

  # prevent creating wrong widgets
  if self.^name eq 'Gnome::Glib::List' #`{{or %options<GList>}} {

    # skip if object is already set by parent
    if self.is-valid { }

    # check if common options are handled by some parent
    elsif %options<native-object>:exists { }

    # process all other options
    else {
      my $no;
      if ? %options<___x___> {
        #$no = %options<___x___>;
        #$no .= get-native-object-no-reffing unless $no ~~ N-GObject;
        #$no = _g_list_new___x___($no);
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
        $no = N-GList;
      }
      #}}

      self.set-native-object($no);
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
# no referencing for lists
method native-object-ref ( $n-native-object ) {
  $n-native-object
}

#-------------------------------------------------------------------------------
method native-object-unref ( $n-native-object ) {
  # check for self.is-valid is not good enough. empty lists (undefined)
  # are still valid but should be cleared to prevent errors like that for
  # SLists '***MEMORY-ERROR***: qa-manager.pl6[28683]: GSlice: assertion
  # failed: sinfo->n_allocated > 0'

  _g_list_free($n-native-object) if g_list_length($n-native-object);
}

#`{{ not to be used directly
#-------------------------------------------------------------------------------
#TM:1:_g_list_free:
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
# TM:0:alloc:
=begin pod
=head2 alloc

Allocates space for one B<Gnome::Glib::List> element. It is called by C<append()>, C<g-list-prepend()>, C<g-list-insert()> and C<g-list-insert-sorted()> and so is rarely used on its own.

Returns: a pointer to the newly-allocated B<Gnome::Glib::List> element

  method alloc ( --> N-GList )

=end pod

method alloc ( --> N-GList ) {

  g_list_alloc(
    self.get-native-object-no-reffing,
  )
}

sub g_list_alloc (
   --> N-GList
) is native(&glib-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:1:append:
=begin pod
=head2 append

Adds a new element on to the end of the list.

Note that the return value is the new start of the list, if I<list> was empty; make sure you store the new value.

C<append()> has to traverse the entire list to find the end, which is inefficient when adding multiple elements. A common idiom to avoid the inefficiency is to use C<prepend()> and reverse the list with C<reverse()> when all elements have been added.

=begin comment
|[<!-- language="C" --> // Notice that these are initialized to the empty list. GList *string-list = NULL, *number-list = NULL;

// This is a list of strings. string-list = g-list-append (string-list, "first"); string-list = g-list-append (string-list, "second");

// This is a list of integers. number-list = g-list-append (number-list, GINT-TO-POINTER (27)); number-list = g-list-append (number-list, GINT-TO-POINTER (14)); ]|
=end comment

Returns: either I<list> or the new start of the B<Gnome::Glib::List> if I<list> was C<undefined>

  method append ( Pointer $data --> Gnome::Glib::List )

=item Pointer $data; the data for the new element
=end pod

method append ( Pointer $data --> Gnome::Glib::List ) {
  Gnome::Glib::List.new(
    :native-object(g_list_append( self.get-native-object-no-reffing, $data))
  )
}

sub g_list_append (
  N-GList $list, gpointer $data --> N-GList
) is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:concat:
=begin pod
=head2 concat

Adds the provided B<Gnome::Glib::List> onto the end of this list. Note that the elements of the given B<Gnome::Glib::List> are not copied. They are used directly.

This function is for example used to move an element in the list.
=comment The following example moves an element to the top of the list:

=begin comment
  list = remove-link (list, llink);
  list = g-list-concat (llink, list);
=end comment

Returns: the start of the new B<Gnome::Glib::List>, which equals I<list1> if not C<undefined>

  method concat ( N-GList $list --> Gnome::Glib::List )

=item N-GList $list; the B<Gnome::Glib::List> to add to the end of this list B<Gnome::Glib::List>, this must point  to the top of the list
=end pod

method concat ( $list is copy --> Gnome::Glib::List ) {
  $list .= get-native-object-no-reffing unless $list ~~ N-GList;

  Gnome::Glib::List.new(
    :native-object(g_list_concat( self.get-native-object-no-reffing, $list))
  )
}

sub g_list_concat (
  N-GList $list1, N-GList $list2 --> N-GList
) is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:copy:
=begin pod
=head2 copy

Copies a B<Gnome::Glib::List>.

Note that this is a "shallow" copy. If the list elements consist of pointers to data, the pointers are copied but the actual data is not.
=comment See C<copy-deep()> if you need to copy the data as well.

Returns: the start of the new list that holds the same data as I<list>

  method copy ( --> Gnome::Glib::List )

=end pod

method copy ( --> Gnome::Glib::List ) {
  Gnome::Glib::List.new(
    :native-object(g_list_copy(self.get-native-object-no-reffing))
  )
}

sub g_list_copy (
  N-GList $list --> N-GList
) is native(&glib-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
# TM:0:copy-deep:
=begin pod
=head2 copy-deep

Makes a full (deep) copy of a B<Gnome::Glib::List>.

In contrast with C<copy()>, this function uses I<func> to make a copy of each list element, in addition to copying the list container itself.

I<func>, as a B<Gnome::Glib::CopyFunc>, takes two arguments, the data to be copied and a I<user-data> pointer. On common processor architectures, it's safe to pass C<undefined> as I<user-data> if the copy function takes only one argument. You may get compiler warnings from this though if compiling with GCC’s `-Wcast-function-type` warning.

For instance, if I<list> holds a list of GObjects, you can do: |[<!-- language="C" --> another-list = g-list-copy-deep (list, (GCopyFunc) g-object-ref, NULL); ]|

And, to entirely free the new list, you could do: |[<!-- language="C" --> g-list-free-full (another-list, g-object-unref); ]|

Returns: the start of the new list that holds a full copy of I<list>, use C<g-list-free-full()> to free it

  method copy-deep ( GCopyFunc $func, Pointer $user_data --> N-GList )

=item GCopyFunc $func; a copy function used to copy every element in the list
=item Pointer $user_data; user data passed to the copy function I<func>, or C<undefined>
=end pod

method copy-deep ( GCopyFunc $func, Pointer $user_data --> N-GList ) {

  g_list_copy_deep(
    self.get-native-object-no-reffing, $func, $user_data
  )
}

sub g_list_copy_deep (
  N-GList $list, GCopyFunc $func, gpointer $user_data --> N-GList
) is native(&glib-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:1:data:
=begin pod
=head2 data

Gets the data from the current B<Gnome::Glib::List> position.

  method data ( --> Pointer )

=end pod

method data ( --> Pointer ) {
  self.get-native-object-no-reffing.data
}

#-------------------------------------------------------------------------------
#TM:1:delete-link:
=begin pod
=head2 delete-link

Removes the node link- from the list and frees it. Compare this to C<remove-link()> which removes the node without freeing it.

Returns: the (possibly changed) start of the B<Gnome::Glib::List>

  method delete-link ( N-GList $link --> Gnome::Glib::List )

=item N-GList $link_; node to delete from I<list>
=end pod

method delete-link ( $link is copy --> Gnome::Glib::List ) {
  $link .= get-native-object-no-reffing unless $link ~~ N-GList;

  Gnome::Glib::List.new(
    :native-object(g_list_delete_link(self.get-native-object-no-reffing, $link))
  )
}

sub g_list_delete_link (
  N-GList $list, N-GList $link_ --> N-GList
) is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:find:
=begin pod
=head2 find

Finds the element in a B<Gnome::Glib::List> which contains the given data.

Returns: the found B<Gnome::Glib::List> element, or C<invalid> if it is not found

  method find ( Pointer $data --> Gnome::Glib::List )

=item Pointer $data; the element data to find
=end pod

method find ( Pointer $data --> Gnome::Glib::List ) {
  Gnome::Glib::List.new(
    :native-object(
      g_list_find( self.get-native-object-no-reffing, $data) // N-GList
    )
  )
}

sub g_list_find (
  N-GList $list, gpointer $data --> N-GList
) is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:find-custom:
=begin pod
=head2 find-custom

Finds an element in a B<Gnome::Glib::List>, using a supplied function to find the desired element. It iterates over the list, calling the given function which should return 0 when the desired element is found.

Returns: the found B<Gnome::Glib::List> element, or C<invalid> if it is not found.

  method find-custom (
    $handler-object, $method, *%user-data
    --> Gnome::Glib::List
  )

=item $handler-object; Object where method is defined.
=item $method; Name of method to call for each element in the list.
=item %user-data; optional data provided as named arguments

The method must be defined as follows;

  method search-handler ( Pointer $list-data, *%user-data --> int )

An example where a search is done through a list of widgets returned from, for example, a grid. Such a search could be started after an 'ok' or 'apply' button is clicked on a configuration screen.

  class MySearchEngine {
    method search ( Pointer $item, :$widget-name --> int ) {
      my Gnome::Gtk3::Widget $w .= new(:native-object($item));

      # stop when specified widget is found
      $w.widget-get-name eq $widget-name ?? 0 !! 1
    }
    …
  }

  # prepare grid
  my Gnome::Gtk3::Grid $g .= new;
  … a label …
  … then an input field …
  my Gnome::Gtk3::Entry $e .= new;
  $e.set-name('db-username');
  $g.attach( $e, 1, 0, 1, 1);
  … more fields to specify …

  # search for an item (in a button click handler)
  my Gnome::Glib::List $list .= new(:native-object($g.get-children));
  if my N-GList $sloc = $list.find-custom(
    MySearchEngine.new, 'search', :widget-name('db-username')
  ) {
    … do something with found widget …
  }

This example might not be the best choice when all fields are searched through this way because most elements are passed multiple times after all tests. To prevent this, one could continue the search from where it returned a defined list. The other option is to use C<foreach()>.

=end pod

method find-custom (
  $handler-object, $method, *%user-data --> Gnome::Glib::List
) {
  die X::Gnome.new(:message("Object and/or method '$method' not found"))
    unless $handler-object.^can($method);

  Gnome::Glib::List.new(
    :native-object(
      g_list_find_custom(
        self.get-native-object-no-reffing,
        gpointer,
        sub ( gpointer $item, gpointer $ud --> gint ) {
          $handler-object."$method"( $item, |%user-data)
        }
      ) // N-GList
    )
  )
}

sub g_list_find_custom (
  N-GList $list, gpointer $data,
  Callable $func ( gpointer $item, gpointer $ud --> gint )
  --> N-GList
) is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:first:
=begin pod
=head2 first

Gets the first element in a B<Gnome::Glib::List>.

Returns: the first element in the B<Gnome::Glib::List>, or C<invalid> if the B<Gnome::Glib::List> has no elements.

  method first ( --> Gnome::Glib::List )

=end pod

method first ( --> Gnome::Glib::List ) {
  Gnome::Glib::List.new(
    :native-object(g_list_first(self.get-native-object-no-reffing))
  )
}

sub g_list_first (
  N-GList $list --> N-GList
) is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:foreach:
=begin pod
=head2 foreach

Calls a function for each element of a B<Gnome::Glib::List>.

=comment It is safe for I<func> to remove the element from I<list>, but it must not modify any part of the list after that element.

  method foreach ( Any:D $handler-object, Str:D $method, *%user-data )

=item $handler-object; Object where method is defined.
=item $method; Name of method to call for each element in the list.
=item %user-data; optional data provided as named arguments

The method must be defined as follows;

  method foreach-handler ( Pointer $list-data, *%user-data )

=end pod

method foreach ( Any:D $handler-object, Str:D $method, *%user-data ) {

  die X::Gnome.new(:message("Object and/or method does not exist"))
    unless $handler-object.^can($method);

  g_list_foreach(
    self.get-native-object-no-reffing,
    -> gpointer $item, gpointer $d {
      $handler-object."$method"( $item, |%user-data)
    },
    gpointer
  );
}

sub g_list_foreach (
  N-GList $list, Callable $func ( gpointer, gpointer), gpointer $user_data
) is native(&glib-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
# TM:0:free1:
=begin pod
=head2 free1

Frees one B<Gnome::Glib::List> element, but does not update links from the next and previous elements in the list, so you should not call this function on an element that is currently part of a list.

It is usually used after C<remove-link()>.

  method free1 ( )

=end pod

method free1 ( ) {

  g_list_free_1(
    self.get-native-object-no-reffing,
  );
}

sub g_list_free_1 (
  N-GList $list
) is native(&glib-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
# TM:0:_g_list_free-full:
=begin pod
=head2 free-full

Convenience method, which frees all the memory used by a B<Gnome::Glib::List>, and calls I<free-func> on every element's data.

I<free-func> must not modify the list (eg, by removing the freed element from it).

  method free-full ( GDestroyNotify $free_func )

=item GDestroyNotify $free_func; the function to be called to free each element's data
=end pod

method free-full ( GDestroyNotify $free_func ) {

  g_list_free_full(
    self.get-native-object-no-reffing, $free_func
  );
}

sub _g_list_free_full (
  N-GList $list, GDestroyNotify $free_func
) is native(&glib-lib)
  is symbol('g_list_free_full')
  { * }
}}

#-------------------------------------------------------------------------------
#TM:1:index:
=begin pod
=head2 index

Gets the position of the element containing the given data (starting from 0).

Returns: the index of the element containing the data, or -1 if the data is not found

  method index ( Pointer $data --> Int )

=item Pointer $data; the data to find
=end pod

method index ( Pointer $data --> Int ) {

  g_list_index(
    self.get-native-object-no-reffing, $data
  )
}

sub g_list_index (
  N-GList $list, gpointer $data --> gint
) is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:insert:
=begin pod
=head2 insert

Inserts a new element into the list at the given position.

Returns: the (possibly changed) start of the B<Gnome::Glib::List>

  method insert ( Pointer $data, Int $position --> Gnome::Glib::List )

=item Pointer $data; the data for the new element
=item Int $position; the position to insert the element. If this is negative, or is larger than the number of elements in the list, the new element is added on to the end of the list.
=end pod

method insert ( Pointer $data, Int $position --> Gnome::Glib::List ) {

  Gnome::Glib::List.new(
    :native-object(
      g_list_insert( self.get-native-object-no-reffing, $data, $position)
    )
  )
}

sub g_list_insert (
  N-GList $list, gpointer $data, gint $position --> N-GList
) is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:insert-before:
=begin pod
=head2 insert-before

Inserts a new element into the list before the given position.

Returns: the (possibly changed) start of the B<Gnome::Glib::List>

  method insert-before ( N-GList $sibling, Pointer $data --> Gnome::Glib::List )

=item N-GList $sibling; the list element before which the new element is inserted or C<undefined> to insert at the end of the list
=item Pointer $data; the data for the new element
=end pod

method insert-before ( $sibling is copy, Pointer $data --> Gnome::Glib::List ) {
  $sibling .= get-native-object-no-reffing unless $sibling ~~ N-GList;

  Gnome::Glib::List.new(
    :native-object(
      g_list_insert_before( self.get-native-object-no-reffing, $sibling, $data)
    )
  )
}

sub g_list_insert_before (
  N-GList $list, N-GList $sibling, gpointer $data --> N-GList
) is native(&glib-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
# TM:0:insert-sorted:
=begin pod
=head2 insert-sorted

Inserts a new element into the list, using the given comparison function to determine its position.

If you are adding many new elements to a list, and the number of new elements is much larger than the length of the list, use C<prepend()> to add the new items and sort the list afterwards with C<sort()>.

Returns: the (possibly changed) start of the B<Gnome::Glib::List>

  method insert-sorted ( Pointer $data, GCompareFunc $func --> N-GList )

=item Pointer $data; the data for the new element
=item GCompareFunc $func; the function to compare elements in the list. It should  return a number > 0 if the first parameter comes after the  second parameter in the sort order.
=end pod

method insert-sorted ( Pointer $data, GCompareFunc $func --> N-GList ) {

  g_list_insert_sorted(
    self.get-native-object-no-reffing, $data, $func
  )
}

sub g_list_insert_sorted (
  N-GList $list, gpointer $data, GCompareFunc $func --> N-GList
) is native(&glib-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
# TM:0:insert-sorted-with-data:
=begin pod
=head2 insert-sorted-with-data

Inserts a new element into the list, using the given comparison function to determine its position.

If you are adding many new elements to a list, and the number of new elements is much larger than the length of the list, use C<prepend()> to add the new items and sort the list afterwards with C<g-list-sort()>.

Returns: the (possibly changed) start of the B<Gnome::Glib::List>

  method insert-sorted-with-data ( Pointer $data, GCompareDataFunc $func, Pointer $user_data --> N-GList )

=item Pointer $data; the data for the new element
=item GCompareDataFunc $func; the function to compare elements in the list. It should return a number > 0 if the first parameter  comes after the second parameter in the sort order.
=item Pointer $user_data; user data to pass to comparison function
=end pod

method insert-sorted-with-data ( Pointer $data, GCompareDataFunc $func, Pointer $user_data --> N-GList ) {

  g_list_insert_sorted_with_data(
    self.get-native-object-no-reffing, $data, $func, $user_data
  )
}

sub g_list_insert_sorted_with_data (
  N-GList $list, gpointer $data, GCompareDataFunc $func, gpointer $user_data --> N-GList
) is native(&glib-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:1:last:
=begin pod
=head2 last

Gets the last element in a B<Gnome::Glib::List>.

Returns: the last element in the B<Gnome::Glib::List>, or C<invalid> if the B<Gnome::Glib::List> has no elements

  method last ( --> Gnome::Glib::List )

=end pod

method last ( --> Gnome::Glib::List ) {
  Gnome::Glib::List.new(
    :native-object(g_list_last(self.get-native-object-no-reffing))
  )
}

sub g_list_last (
  N-GList $list --> N-GList
) is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:length:
=begin pod
=head2 length

Gets the number of elements in a B<Gnome::Glib::List>.

This function iterates over the whole list to count its elements.
=comment Use a B<Gnome::Glib::Queue> instead of a GList if you regularly need the number of items.
=comment To check whether the list is non-empty, it is faster to check I<list> against C<N-GList === undefined>.

Returns: the number of elements in the B<Gnome::Glib::List>

  method length ( --> UInt )

=end pod

method length ( --> UInt ) {
  g_list_length(self.get-native-object-no-reffing)
}

sub g_list_length (
  N-GList $list --> guint
) is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:next:
=begin pod
=head2 next

Gets the next element in a B<Gnome::Glib::List>, or undefined if the B<Gnome::Glib::List> has no more elements.

  method next ( --> Gnome::Glib::List )

=end pod

method next ( --> Gnome::Glib::List ) {
  Gnome::Glib::List.new(
    :native-object(self.get-native-object-no-reffing.next // N-GList)
  );
}

#-------------------------------------------------------------------------------
#TM:1:nth:
=begin pod
=head2 nth

Gets the element at the given position in a B<Gnome::Glib::List>.

This iterates over the list until it reaches the I<n>-th position. If you intend to iterate over every element, it is better to use a for-loop as described in the B<Gnome::Glib::List> introduction.

Returns: the element, or C<invalid> if the position is off the end of the B<Gnome::Glib::List>

  method nth ( UInt $n --> Gnome::Glib::List )

=item UInt $n; the position of the element, counting from 0
=end pod

method nth ( UInt $n --> Gnome::Glib::List ) {
  Gnome::Glib::List.new(
    :native-object(g_list_nth(self.get-native-object-no-reffing // N-GList, $n))
  )
}

sub g_list_nth (
  N-GList $list, guint $n --> N-GList
) is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:nth-data:
=begin pod
=head2 nth-data

Gets the data of the element at the given position.

This iterates over the list until it reaches the I<n>-th position. If you intend to iterate over every element, it is better to use a for-loop as described in the B<Gnome::Glib::List> introduction.

Returns: the element's data, or C<undefined> if the position is off the end of the B<Gnome::Glib::List>

  method nth-data ( UInt $n --> Pointer )

=item UInt $n; the position of the element
=end pod

method nth-data ( UInt $n --> Pointer ) {
  g_list_nth_data( self.get-native-object-no-reffing, $n)
}

sub g_list_nth_data (
  N-GList $list, guint $n --> gpointer
) is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:nth-prev:
=begin pod
=head2 nth-prev

Gets the element I<n> places before I<list>.

Returns: the element, or C<invalid> if the position is off the end of the B<Gnome::Glib::List>

  method nth-prev ( UInt $n --> Gnome::Glib::List )

=item UInt $n; the position of the element, counting from 0
=end pod

method nth-prev ( UInt $n --> Gnome::Glib::List ) {
  Gnome::Glib::List.new(
    :native-object(
      g_list_nth_prev( self.get-native-object-no-reffing, $n) // N-GList
    )
  )
}

sub g_list_nth_prev (
  N-GList $list, guint $n --> N-GList
) is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:position:
=begin pod
=head2 position

Gets the position of the given element in the B<Gnome::Glib::List> (starting from 0).

Returns: the position of the element in the B<Gnome::Glib::List>, or -1 if the element is not found

  method position ( N-GList $llink --> Int )

=item N-GList $llink; an element in the B<Gnome::Glib::List>
=end pod

method position ( $llink is copy --> Int ) {
  $llink .= get-native-object-no-reffing unless $llink ~~ N-GList;
  g_list_position( self.get-native-object-no-reffing, $llink)
}

sub g_list_position (
  N-GList $list, N-GList $llink --> gint
) is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:prepend:
=begin pod
=head2 prepend

Prepends a new element on to the start of the list.

Note that the return value is the new start of the list, which will have changed, so make sure you store the new value. Do not use this function to prepend a new element to a different element than the start of the list. (Note; probably the list before insertion point gets cut off and then there is a memory leak). Use C<g-list-insert-before()> instead.

Returns: a pointer to the newly prepended element, which is the new start of the B<Gnome::Glib::List>

  method prepend ( Pointer $data --> Gnome::Glib::List )

=item Pointer $data; the data for the new element

=head3 Example

my Gnome::Glib::List $list .= new;

$list .= prepend(CArray[Str].new("last"));
$list .= prepend(CArray[Str].new("first"));

=end pod

method prepend ( Pointer $data --> Gnome::Glib::List ) {
  Gnome::Glib::List.new(
    :native-object(g_list_prepend( self.get-native-object-no-reffing, $data))
  )
}

sub g_list_prepend (
  N-GList $list, gpointer $data --> N-GList
) is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:previous:
=begin pod
=head2 previous

Gets the previous element in a B<Gnome::Glib::List>, or C<invalif> if the B<Gnome::Glib::List> is at the beginning of the list.

  method previous ( --> Gnome::Glib::List )

=end pod

method previous ( --> Gnome::Glib::List ) {
  Gnome::Glib::List.new(
    :native-object(self.get-native-object-no-reffing.prev // N-GList)
  );
}

#-------------------------------------------------------------------------------
#TM:1:remove:
=begin pod
=head2 remove

Removes an element from a B<Gnome::Glib::List>. If two elements contain the same data, only the first is removed. If none of the elements contain the data, the B<Gnome::Glib::List> is unchanged.

Returns: the (possibly changed) start of the B<Gnome::Glib::List>

  method remove ( Pointer $data --> Gnome::Glib::List )

=item Pointer $data; the data of the element to remove
=end pod

method remove ( Pointer $data --> Gnome::Glib::List ) {
  Gnome::Glib::List.new(
    :native-object(
      g_list_remove( self.get-native-object-no-reffing, $data) // N-GList
    )
  )
}

sub g_list_remove (
  N-GList $list, gpointer $data --> N-GList
) is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:remove-all:
=begin pod
=head2 remove-all

Removes all list nodes with data equal to I<data>. Returns the new head of the list. Contrast with C<remove()> which removes only the first node matching the given data.

Returns: the (possibly changed) start of the B<Gnome::Glib::List>

  method remove-all ( Pointer $data --> Gnome::Glib::List )

=item Pointer $data; data to remove
=end pod

method remove-all ( Pointer $data --> Gnome::Glib::List ) {
  Gnome::Glib::List.new(
    :native-object(
      g_list_remove_all( self.get-native-object-no-reffing, $data) // N-GList
    )
  )
}

sub g_list_remove_all (
  N-GList $list, gpointer $data --> N-GList
) is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:remove-link:
=begin pod
=head2 remove-link

Removes an element from a B<Gnome::Glib::List>, without freeing the element. The removed element's prev and next links are set to C<invalid>, so that it becomes a self-contained list with one element.

This function is for example used to move an element in the list (see the example for C<concat()>) or to remove an element in the list before freeing its data.
=begin comment
  list = g-list-remove-link (list, llink);
  free-some-data-that-may-access-the-list-again (llink->data);
  g-list-free (llink);
=end comment

Returns: the (possibly changed) start of the B<Gnome::Glib::List>

  method remove-link ( N-GList $llink --> Gnome::Glib::List )

=item N-GList $llink; an element in the B<Gnome::Glib::List>
=end pod

method remove-link ( $llink is copy --> Gnome::Glib::List ) {
  $llink .= get-native-object-no-reffing unless $llink ~~ N-GList;

  Gnome::Glib::List.new(
    :native-object(
      g_list_remove_link( self.get-native-object-no-reffing, $llink) // N-GList
    )
  )
}

sub g_list_remove_link (
  N-GList $list, N-GList $llink --> N-GList
) is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:reverse:
=begin pod
=head2 reverse

Reverses a B<Gnome::Glib::List>. It simply switches the next and prev pointers of each element.

Returns: the start of the reversed B<Gnome::Glib::List>

  method reverse ( --> Gnome::Glib::List )

=end pod

method reverse ( --> Gnome::Glib::List ) {
  Gnome::Glib::List.new(
    :native-object(
      g_list_reverse(self.get-native-object-no-reffing) // N-GList
    )
  )
}

sub g_list_reverse (
  N-GList $list --> N-GList
) is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:sort:
=begin pod
=head2 sort

Sorts a B<Gnome::Glib::List> using the given comparison function. The algorithm used is a stable sort.

Returns: the (possibly changed) start of the B<Gnome::Glib::List>

  method sort (
    Any:D $user-object, Str:D $method
    --> Gnome::Glib::List
  )

=item $user-object is object wherein the compare method is defined.
=item $method is the the comparison function used to sort the B<Gnome::Glib::List>. This function is passed the data from 2 elements of the B<Gnome::Glib::List>  and should return 0 if they are equal, a negative value if the first element comes before the second, or a positive value if the first element comes after the second.

The method must be defined as follows;

  method compare-handler ( Pointer $a, Pointer $b --> int )

The method must return -1 when $a is less than $b, 0 when equal or 1 when $a is greater than $b.

=end pod

method sort (
  Any:D $user-object, Str:D $method, *%user-data
  --> Gnome::Glib::List
) {
  die X::Gnome.new(:message("User object and/or method $method not found"))
    unless $user-object.^can($method);

  Gnome::Glib::List.new(
    :native-object(
      g_list_sort(
        self.get-native-object-no-reffing,
        sub ( gpointer $a, gpointer $b --> gint ) {
          $user-object."$method"( $a, $b)
        }
      )
    )
  )
}

sub g_list_sort (
  N-GList $list, Callable $compare_func ( gpointer $a, gpointer $b --> gint )
  --> N-GList
) is native(&glib-lib)
  { * }


#`{{ No need because of use of *%user-data in g_list_sort()
#-------------------------------------------------------------------------------
# TM:0:sort-with-data:
=begin pod
=head2 sort-with-data

Like C<sort()>, but the comparison function accepts a user data argument.

Returns: the (possibly changed) start of the B<Gnome::Glib::List>

  method sort-with-data ( GCompareDataFunc $compare_func, Pointer $user_data --> N-GList )

=item GCompareDataFunc $compare_func; comparison function
=item Pointer $user_data; user data to pass to comparison function
=end pod

method sort-with-data ( GCompareDataFunc $compare_func, Pointer $user_data --> N-GList ) {

  g_list_sort_with_data(
    self.get-native-object-no-reffing, $compare_func, $user_data
  )
}

sub g_list_sort_with_data (
  N-GList $list, GCompareDataFunc $compare_func, gpointer $user_data --> N-GList
) is native(&glib-lib)
  { * }
}}
