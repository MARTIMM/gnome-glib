use v6;
use Test;

use Gnome::Glib::List;

#-------------------------------------------------------------------------------
subtest 'create double linked list object', {

  throws-like(
    { my Gnome::Glib::List $l .= new; },
    X::Parameter::InvalidConcreteness, 'no way to create empty lists',
    :message("Parameter '\$!glist' of routine 'BUILD' must be an object instance of type 'Gnome::Glib::List::N-GList', not a type object of type 'Gnome::Glib::List::N-GList'.  Did you forget a '.new'?"
    )
  );

  #isa-ok $l, Gnome::Glib::List, 'object ok';
}

#-------------------------------------------------------------------------------
done-testing;
