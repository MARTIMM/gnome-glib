use v6;
use NativeCall;
use Test;

use Gnome::Glib::List;

#use Gnome::N::X;
#Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
my Gnome::Glib::List $l;
#-------------------------------------------------------------------------------
subtest 'ISA test', {
  $l .= new(:empty);
  isa-ok $l, Gnome::Glib::List, '.new(:empty)';
  ok $l.list-is-valid, '.list-is-valid()';
}

#-------------------------------------------------------------------------------
subtest 'Manipulations', {
  is $l.g_list_length, 0, '.g_list_length()';

  $l.clear-list;
  nok $l.list-is-valid, '.clear-list()';
}

#`{{
#-------------------------------------------------------------------------------
subtest 'Inherit ...', {
}

#-------------------------------------------------------------------------------
subtest 'Interface ...', {
}

#-------------------------------------------------------------------------------
subtest 'Properties ...', {
}

#-------------------------------------------------------------------------------
subtest 'Themes ...', {
}

#-------------------------------------------------------------------------------
subtest 'Signals ...', {
}
}}

#-------------------------------------------------------------------------------
done-testing;