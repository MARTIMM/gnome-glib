use v6;
use Test;

use Gnome::Glib::Main;

#-------------------------------------------------------------------------------
subtest 'create gmain object', {
  my Gnome::Glib::Main $e .= new;
  isa-ok $e, Gnome::Glib::Main, 'object ok';
}

#-------------------------------------------------------------------------------
done-testing;
