use v6;
use Test;

use Gnome::Glib::GSList;

#-------------------------------------------------------------------------------
subtest 'create single linked list object', {

  throws-like(
    { my Gnome::Glib::GSList $l .= new; },
    X::Parameter::InvalidConcreteness, 'no way to create empty lists',
    :message("Parameter '\$!gslist' of routine 'BUILD' must be an object instance of type 'Gnome::Glib::GSList::N-GSList', not a type object of type 'Gnome::Glib::GSList::N-GSList'.  Did you forget a '.new'?"
    )
  );

  #isa-ok $l, Gnome::Glib::GList, 'object ok';
}

#-------------------------------------------------------------------------------
done-testing;
