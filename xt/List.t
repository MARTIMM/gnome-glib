use v6;
#use lib '../gnome-native/lib';
use NativeCall;
use Test;

#use Gnome::N::N-GObject;
#use Gnome::N::N-GList;
use Gnome::N::GlibToRakuTypes;
use Gnome::N::X;
#Gnome::N::debug(:on);

use Gnome::Glib::List;
use Gnome::GObject::Value;
use Gnome::Gtk3::Grid;
use Gnome::Gtk3::Widget;
use Gnome::Gtk3::Label;
use Gnome::Gtk3::Entry;


#-------------------------------------------------------------------------------
class H {
  # g_list_foreach test method
  method h ( gpointer $hd ) {

    my Gnome::Gtk3::Widget $w .= new(:native-object($hd));
    my Str $widget-name = $w.widget-get-name;

    # Test names of widget, by default its GTK class name. Proper names should
    # be given on input fields when reading out config setting grids.
    given $widget-name {
      when 'GtkLabel' {
        my Gnome::Gtk3::Label $hl .= new(:native-object($hd));
        my Str $t = $hl.get-text;
        is $t, 'Username', 'Text from label found';
      }

      # Entry has a name
      when 'db-username' {
        my Gnome::Gtk3::Entry $he .= new(:native-object($hd));
        my Str $t = $he.get-text;
        is $t, 'new text in entry', 'Text from entry found';
      }
    }
  }

  # g_list_find_custom test method
  method s ( gpointer $list-data, :$widget-name, :$widget-text --> Int ) {

    my Gnome::Gtk3::Widget $w .= new(:native-object($list-data));
    my Str $wname = $w.widget-get-name;

#note "W: $wname, $widget-name, $widget-text";
#return 1;
    my Int $return-value = 1;
    if $wname eq $widget-name {
      my Gnome::Gtk3::Entry $hl .= new(:native-object($list-data));
      my Str $t = $hl.get-text;
      is $t, 'new text in entry', 'Text from label found';

      # if text is requested data from user
      $return-value = !( $t eq $widget-text );
    }

    $return-value
  }
}

#-------------------------------------------------------------------------------
# preparations
my Gnome::Gtk3::Grid $g .= new;
my Gnome::Gtk3::Label $l .= new(:text('Username'));
my Gnome::Gtk3::Entry $e .= new;
$e.set-text('new text in entry');
$e.widget-set-name('db-username');

$g.grid-attach( $l, 0, 0, 1, 1);
$g.grid-attach( $e, 1, 0, 1, 1);

#-------------------------------------------------------------------------------
# get list
my Gnome::Glib::List $list .= new(:native-object($g.get-children));
is $list.length, 2, 'two elements in grid';
$list.foreach( H.new, 'h');

# direct, now we know that 0 is a GtkEntry
my $o = $list.nth-data(0);
my Gnome::Gtk3::Entry $he .= new(:native-object($o));
my Str $t = $he.get-text;
is $t, 'new text in entry', '.nth-data()';

#-------------------------------------------------------------------------------
# search for an item
my Gnome::Glib::List $sloc = $list.find-custom(
  H.new, 's', :widget-name('db-username'), :widget-text('new text in entry')
);
ok ?$sloc, '.find-custom()';

# make the search to fail
$sloc = $list.find-custom(
  H.new, 's', :widget-name('db-username'), :widget-text('Othername')
);
is $sloc.length, 0, '.find-custom(), search failed';

#-------------------------------------------------------------------------------
#Gnome::N::debug(:on);
my @x = ();
my Gnome::Glib::List $ll = $list.first;
is $ll.length, 2, 'two elements in grid';
my Int $pos = 0;
while $ll.is-valid {
  is $list.position($ll), $pos, ".position\() $pos";
  is $list.index($ll.data), $pos, ".index\() $pos";
  my Gnome::Glib::List $xl = $list.find($ll.data);
  is $list.position($xl), $pos, '.find()';

  $pos++;

  my Gnome::Gtk3::Widget $w .= new(:native-object($ll.data));
  @x.push: $w.get-name;
  $ll .= next;
}
#Gnome::N::debug(:off);

$ll = $list.last;
is $list.list-position($list.nth(1)), 1, '.nth()';
is $list.list-position($ll.nth-prev(1)), 0, '.nth-prev()';
while $ll.is-valid {
  my Gnome::Gtk3::Widget $w .= new(:native-object($ll.data));
#  note $w.widget-get-name;
  is @x.pop, $w.get-name,
     '.first() / .next() / .last() / .previous()';
  $ll .= previous;
}

$ll.clear-object;

#-------------------------------------------------------------------------------
done-testing;
=finish




loop ( my Int $i = 0; $i < $list.length; $i++ ) {
  my Gnome::GObject::Object

method foreach ( $func-object, Str $func-name ) {
  if $func-object.^can($func-name) {
    _g_list_foreach(
      self.get-native-object,
      sub ( $d, $ud ) {
        $func-object."$func-name"( self, $d);
      },
      OpaquePointer
    )
  }
}
