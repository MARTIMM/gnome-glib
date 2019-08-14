use v6;
use NativeCall;
use Test;

use Gnome::Glib::SList;

#use Gnome::N::X;
#Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
my Gnome::Glib::SList $s .= new(:empty);
#-------------------------------------------------------------------------------
subtest 'ISA test', {
  isa-ok $s, Gnome::Glib::SList;
}

#-------------------------------------------------------------------------------
subtest 'Manipulations', {
  is $s.g-slist-length, 0, 'List has no elements';
}

#-------------------------------------------------------------------------------
done-testing;
