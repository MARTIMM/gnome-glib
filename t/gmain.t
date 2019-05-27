use v6;
use Test;

use Gnome::Glib::GMain;

#-------------------------------------------------------------------------------
subtest 'create gmain object', {
  my Gnome::Glib::GMain $e .= new;
  isa-ok $e, Gnome::Glib::GMain, 'object ok';
}

#-------------------------------------------------------------------------------
done-testing;
