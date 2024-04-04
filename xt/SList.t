use v6;
#use lib '../gnome-native/lib';
use NativeCall;
use Test;

use Gnome::N::N-GObject:api<1>;
use Gnome::N::GlibToRakuTypes:api<1>;
#use Gnome::N::X:api<1>;
#Gnome::N::debug(:on);

use Gnome::Glib::SList:api<1>;

use Gnome::GObject::Value:api<1>;
use Gnome::GObject::Type:api<1>;

use Gnome::Gtk3::Button:api<1>;
use Gnome::Gtk3::Enums:api<1>;
use Gnome::Gtk3::Grid:api<1>;
use Gnome::Gtk3::Widget:api<1>;
use Gnome::Gtk3::WidgetPath:api<1>;
use Gnome::Gtk3::Window:api<1>;

#-------------------------------------------------------------------------------
my Gnome::Gtk3::WidgetPath $wp .= new;

my Gnome::Gtk3::Window $w .= new;
$w.set-title('Top');

my Gnome::Gtk3::Grid $g .= new;
$g.gtk-widget-set-name('top-grid');
$w.add($g);

my Gnome::Gtk3::Button $b1 .= new(:label<Start>);
$b1.gtk-widget-set-name('start-button');
$g.gtk-grid-attach( $b1, 0, 0, 1, 1);

my Gnome::Gtk3::Button $b2 .= new(:label<Stop>);
$g.gtk-grid-attach( $b2, 0, 1, 1, 1);

$wp .= new(:native-object($b2.get-path));
diag 'widget path: ' ~ $wp.to-string;

#-------------------------------------------------------------------------------
subtest 'Manipulations', {

#Gnome::N::debug(:on);
  my Gnome::Glib::SList $l .= new(:native-object($wp.iter-list-classes(2)));
  is $l.g-slist-length, 1, 'list contains one class';
  is nativecast( Str, $l.nth-data(0)), 'text-button', "class is a 'text-button'";
}

#-------------------------------------------------------------------------------
done-testing;













=finish
use Gnome::Gtk3::Grid:api<1>;
use Gnome::Gtk3::Widget:api<1>;
use Gnome::Gtk3::Label:api<1>;
use Gnome::Gtk3::Entry:api<1>;

#-------------------------------------------------------------------------------
# preparations
my Gnome::Gtk3::Grid $g .= new;
my Gnome::Gtk3::Label $l .= new(:text('Username'));
my Gnome::Gtk3::Entry $e .= new;
$e.set-text('new text in entry');
$e.widget-set-name('db-username');

$g.grid-attach( $l, 0, 0, 1, 1);
$g.grid-attach( $e, 1, 0, 1, 1);

class H {
  # g_list_foreach test method
  method h (
    Gnome::Glib::SList $hlist, Int $hi, gpointer $hd
  ) {

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
# get list
my Gnome::Glib::SList $list .= new(:native-object($g.get-children));
is $list.length, 2, 'two elements in grid';
$list.list-foreach( H.new, 'h');

# direct, now we know that 0 is a GtkEntry
my $o = $list.nth-data(0);
my Gnome::Gtk3::Entry $he .= new(:native-object($o));
my Str $t = $he.get-text;
is $t, 'new text in entry', '.nth-data()';

#-------------------------------------------------------------------------------
# search for an item
my N-GList $sloc = $list.find-custom(
  H.new, 's', :widget-name('db-username'), :widget-text('new text in entry')
);
ok ?$sloc, '.find-custom()';

# make the search to fail
$sloc = $list.find-custom(
  H.new, 's', :widget-name('db-username'), :widget-text('Othername')
);
ok !$sloc, '.find-custom(), search failed';

#-------------------------------------------------------------------------------
#Gnome::N::debug(:on);
my @x = ();
my Gnome::Glib::SList $ll = $list.list-first;
is $ll.length, 2, 'two elements in grid';
my Int $pos = 0;
while ?$ll {
  is $list.list-position($ll), $pos, ".list-position\() $pos";
  is $list.list-index($ll.data), $pos, ".list-index\() $pos";
  my Gnome::Glib::SList $xl = $list.list-find($ll.data);
  is $list.list-position($xl), $pos, '.list-find()';

  $pos++;

  my Gnome::Gtk3::Widget $w .= new(:native-object($ll.data));
  @x.push: $w.widget-get-name;
  $ll .= next;
}
#Gnome::N::debug(:off);

$ll = $list.g-list-last;
is $list.list-position($list.nth(1)), 1, '.nth()';
is $list.list-position($ll.nth-prev(1)), 0, '.nth-prev()';
while ?$ll {
  my Gnome::Gtk3::Widget $w .= new(:native-object($ll.data));
#  note $w.widget-get-name;
  is @x.pop, $w.widget-get-name,
     '.g-list-first() / .next() / .g-list-last() / .previous()';
  $ll .= previous;
}

#-------------------------------------------------------------------------------
done-testing;
=finish




loop ( my Int $i = 0; $i < $list.length; $i++ ) {
  my Gnome::GObject::Object

method foreach ( $func-object, Str $func-name ) {
  if $func-object.^can($func-name) {
    _g_list_foreach(
      self._get-native-object,
      sub ( $d, $ud ) {
        $func-object."$func-name"( self, $d);
      },
      OpaquePointer
    )
  }
}
