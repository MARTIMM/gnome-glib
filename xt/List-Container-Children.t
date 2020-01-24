use v6;
use NativeCall;
use Test;

#use Gnome::N::N-GObject;
use Gnome::Glib::List;
use Gnome::GObject::Value;
use Gnome::GObject::Value;
use Gnome::Gtk3::Grid;
use Gnome::Gtk3::Widget;
use Gnome::Gtk3::Label;
use Gnome::Gtk3::Entry;

use Gnome::N::X;
#Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
# preparations
my Gnome::Gtk3::Grid $g .= new;
my Gnome::Gtk3::Label $l .= new(:text('Username'));
my Gnome::Gtk3::Entry $e .= new;
$e.set-text('new text in entry');
#  is $e.get-text, 'new text in entry', '.set-text() / .get-text()';

$g.grid-attach( $l, 0, 0, 1, 1);
$g.grid-attach( $e, 1, 0, 1, 1);

class H {
  method h ( Gnome::Glib::List $hlist, Int $hi, Pointer $hd ) {

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

      when 'GtkEntry' {
        my Gnome::Gtk3::Entry $he .= new(:native-object($hd));
        my Str $t = $he.get-text;
        is $t, 'new text in entry', 'Text from entry found';
      }
    }
  }
}

#-------------------------------------------------------------------------------
# get list
my Gnome::Glib::List $list .= new(:glist($g.get-children));
is $list.length, 2, 'two elements in grid';
$list.list-foreach( H.new, 'h');

# direct, now we know that 0 is a GtkEntry
my $o = $list.nth-data(0);
my Gnome::Gtk3::Entry $he .= new(:native-object($o));
my Str $t = $he.get-text;
is $t, 'new text in entry', '.nth-data()';

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
