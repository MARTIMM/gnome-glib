use v6;
use Test;

use Gnome::Glib::GList;

#-------------------------------------------------------------------------------
subtest 'create double linked list object', {

  throws-like(
    { my Gnome::Glib::GList $l .= new; },
    X::Parameter::InvalidConcreteness, 'no way to create empty lists',
    :message("Parameter '\$!glist' of routine 'BUILD' must be an object instance of type 'Gnome::Glib::GList::N-GList', not a type object of type 'Gnome::Glib::GList::N-GList'.  Did you forget a '.new'?"
    )
  );

  #isa-ok $l, Gnome::Glib::GList, 'object ok';
}

#-------------------------------------------------------------------------------
done-testing;
