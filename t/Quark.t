use v6;
use NativeCall;
use Test;

use Gnome::Glib::Quark;

#use Gnome::N::X;
#Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
my Gnome::Glib::Quark $quark;
#-------------------------------------------------------------------------------
subtest 'ISA test', {
  my Gnome::Glib::Quark $quark .= new;
  isa-ok $quark, Gnome::Glib::Quark;
}

#-------------------------------------------------------------------------------
subtest 'Manipulations', {
  # in a clean simple program GQuarks can be followed from 0
  my Int $q = $quark.try-string('my string');
  is $q, 0, '.try-string()';

  is $quark.from-string('my string'), 1, '.from-string()';

  is $quark.from-string('my 2nd string'), 2, '.from-string()';
  is $quark.to-string(2), 'my 2nd string', '.to-string()';

  is $quark.to-string(42), Str, '.to-string()';
}

#-------------------------------------------------------------------------------
done-testing;
