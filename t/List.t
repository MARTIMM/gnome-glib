use v6;
#use lib '../gnome-native/lib';
use NativeCall;
use Test;

use Gnome::Glib::List;
use Gnome::N::GlibToRakuTypes;

use Gnome::N::X;
#Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
my Gnome::Glib::List() $l;
#-------------------------------------------------------------------------------
subtest 'ISA test', {
  $l .= new;
  isa-ok $l, Gnome::Glib::List, '.new';
  ok $l.is-valid, '.is-valid()';
}

#-------------------------------------------------------------------------------
# set environment variable 'raku-test-all' if rest must be tested too.
unless %*ENV<raku_test_all>:exists {
  done-testing;
  exit;
}

#-------------------------------------------------------------------------------
class HC {
  has Str $!number-list;
  has Array $!user-side-data = [];

  method check-list ( Gnome::Glib::List $list, Str $compare-with, Str $test? ) {
    $!number-list = '';
    $list.foreach( self, 'list-entry');
    $!number-list ~~ s/\s+ $//;
    my Str $s = ( $test // 'test list' ) ~ ": $compare-with";
    is $!number-list, $compare-with, $s;
  }

  method check-data ( Gnome::Glib::List $list, Str $compare-with, Str $test? ) {
    # show data at this location
    my Int $i = self.unpack($list.data);
    is $i, $compare-with, ( $test // 'item' ) ~ ": $i";
  }

  method list-entry ( gpointer $item ) {
    # do something with the list item in list
    my CArray[gint] $sobj = nativecast( CArray[gint], $item);
    $!number-list ~= self.unpack($item) ~ ' ';
  }

  method compare ( gpointer $a, gpointer $b --> gint ) {
    my Int $ia = self.unpack($a);
    my Int $ib = self.unpack($b);
    my gint $cv;
    $cv = -1 if $ia < $ib;
    $cv = 0 if $ia == $ib;
    $cv = 1 if $ia > $ib;

    $cv
  }

  method find ( gpointer $item, Int :$nbr --> gint ) {
    my gint $cv = 1;
    my Int $i = self.unpack($item);
    $cv = 0 if my Bool $b = ($i ~~ $nbr);

    $cv
  }

  method pack ( Int $n --> gpointer ) {
    my $o = CArray[gint].new;
    $o[0] = $n;

    # collect data to prevent problems caused by Raku's garbage collection
    $!user-side-data.push: $o;
    nativecast( gpointer, $o)
  }

  method unpack ( gpointer $p --> Int ) {
    my $o = nativecast( CArray[gint], $p);
    $o[0]
  }

  method get-data ( Int $entry --> gpointer ) {
    nativecast( gpointer, $!user-side-data[$entry]);
  }
}

#-------------------------------------------------------------------------------
subtest 'Manipulations', {

  my HC $hc .= new;
  my gpointer $n-obj;

  subtest 'add/remove items', {
    #append
    is $l.length, 0, '.length(): list length = 0';
    for ^10 -> $i {
      $l .= append($hc.pack($i));
    }

    is $l.length, 10, '.length(): list length = 10';
    $hc.check-list( $l, '0 1 2 3 4 5 6 7 8 9', '.append()');
    is $l.index($hc.get-data(2)), 2, '.index(): ldata[2] at 2';

    # insert
    my Gnome::Glib::List $li = $l.insert( $hc.pack(100), 2);
    $hc.check-list( $l, '0 1 100 2 3 4 5 6 7 8 9', '.insert()');
    is $li.index($hc.get-data(2)), 3, '.index() ldata[2] at 3';

    # delete link
    $l .= delete-link($l.find($hc.get-data(5)));
    $hc.check-list( $l, '0 1 100 2 3 4 6 7 8 9', '.delete-link()');

    # insert before
    $l.insert-before( $l.find($hc.get-data(6)), $hc.pack(101));
    $hc.check-list( $l, '0 1 100 2 3 4 101 6 7 8 9', '.insert-before()');

    # prepend
    $l .= prepend($hc.pack(2143));
    $hc.check-list( $l, '2143 0 1 100 2 3 4 101 6 7 8 9', '.insert-before()');

    # remove
    $l .= remove($hc.get-data(6));
    $hc.check-list( $l, '2143 0 1 100 2 3 4 101 7 8 9', '.remove()');

    $l.insert-before( $l.find($hc.get-data(7)), $hc.get-data(6));
    $hc.check-list( $l, '2143 0 1 100 2 3 4 101 6 7 8 9', 'repair');

    # prepare for remove-all
    $n-obj = $hc.pack(11011);
    $l.insert-before( $l.find($hc.get-data(9)), $n-obj);
    $l.insert-before( $l.find($hc.get-data(2)), $n-obj);
    $hc.check-list( $l, '2143 0 1 100 11011 2 3 4 101 6 7 8 11011 9');

    $l.remove-all($n-obj);
    $hc.check-list( $l, '2143 0 1 100 2 3 4 101 6 7 8 9', '.remove-all()');

    # remove-link
    $l.insert-before( $l.find($hc.get-data(4)), $n-obj);
    $hc.check-list( $l, '2143 0 1 100 2 3 11011 4 101 6 7 8 9');
    my Gnome::Glib::List $l3 = $l.find($n-obj);
    $hc.check-data( $l3, '11011', '.find()');
    my Gnome::Glib::List $l2 = $l.remove-link($l3);
    $hc.check-list( $l, '2143 0 1 100 2 3 4 101 6 7 8 9', '.remove-link()');
    $hc.check-list( $l3, '11011', 'separated list');

    $l3 = $l.first.reverse;
    $hc.check-list( $l3, '9 8 7 6 101 4 3 2 100 1 0 2143', '.reverse()');
    $hc.check-list( $l, '2143', 'previous list points now to the end');
    $l = $l3.first.reverse;
    $hc.check-list( $l, '2143 0 1 100 2 3 4 101 6 7 8 9', 'repair');
  }

  subtest 'concat, copy, etc.', {
#Gnome::N::debug(:on);
    # make another list with 2 items and concatenate
    my Gnome::Glib::List $l2 .= new;
    for ^2 -> $i {
      $l2 .= append($hc.pack($i + 200));
    }

    # add $l to the end of $l2
    $l2 = $l2.concat($l.first);
    $hc.check-list( $l2, '200 201 2143 0 1 100 2 3 4 101 6 7 8 9', '.concat()');
    is $l2.index($hc.get-data(2)), 6, '.index(): ldata[2] at 6';

    my Gnome::Glib::List $l3 = $l2.copy;
    is $l3.length, 14, '.copy(): list length = ' ~ $l3.length;

    $l3 = $l2.last;
    $hc.check-data( $l3, '9', '.last()');
    $l3 .= next;
    is $l3.length, 0, '.next() element of last is empty; length = 0';

    $l3 = $l2.last;
    $l3 .= previous;
    $hc.check-data( $l3, '8', '.previous()');

    $l3 .= first;
    $hc.check-data( $l3, '200', '.first()');

    $l3 .= nth(2);
    $hc.check-data( $l3, '2143', '.nth()');
    $l3 .= nth(3);
    $hc.check-data( $l3, '100', '.nth() 3 places from 2nd');
    nok $l3.nth(2000).is-valid, '.nth() 2000th --> is not valid';

    # $l3 not modified!
    is $hc.unpack($l3.nth-data(4)), '101',
      '.nth-data() data 4 places further: 101';
    nok $l3.nth-data(2000).defined, '.nth-data() 2000th --> is not defined';

    $l3 .= nth-prev(4);
    $hc.check-data( $l3, '201', '.nth-prev() 4 places before last nth');
    nok $l3.nth-prev(2000).is-valid, '.nth-prev() 2000th --> is not valid';
    is $l3.position($l3.nth(2)), 2, '.position()';

    $l2.sort( $hc, 'compare');
    $hc.check-list( $l2, '200 201 2143',
      '.sort(); location comes somewhere else');
    $hc.check-list( $l2.first, '0 1 2 3 4 6 7 8 9 100 101 200 201 2143',
      '.sort() result');

#`{{
    # See if after a few rounds the data gets corrupted;
    # This is a garbage collect test. To prevent failure, user data must
    # be kept alive in the $hc.pack() method.
    for ^10 -> $i {
      #note $i;

      my @a = <0 1 2 3 4 6 7 8 9 100 101 200 201 2143>;
      $l2 = $l.first;

      # test for pod doc example
      while $l2.length {
        $hc.check-data( $l2, @a.shift);
        $l2 .= next;
      }
    }
}}

    # custom find
    $l .= first;
    $l2 = $l.find-custom( $hc, 'find', :nbr(100));
    is $l.position($l2), 9, '.find-custom(100): pos = 9';
    $l3 = $l2.find-custom( $hc, 'find', :nbr(201));
    is $l2.position($l3), 3, '.find-custom(201): pos = 3 relative to prev find';

    $l3 .= find-custom( $hc, 'find', :nbr(400));
    is $l2.position($l3), -1, '.find-custom(400): pos = -1 not found';
  }

  $l.clear-object;
  is $l.length, 0, '.clear-object()';
}

#-------------------------------------------------------------------------------
done-testing;
