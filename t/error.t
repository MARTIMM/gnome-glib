use v6;
use Test;

use Gnome::Glib::Error;

#-------------------------------------------------------------------------------
subtest 'create error object', {
  my Gnome::Glib::Error $e .= new;
  isa-ok $e, Gnome::Glib::Error, 'object ok';
}


#-------------------------------------------------------------------------------
done-testing;
