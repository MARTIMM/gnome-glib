
use v6;
use NativeCall;
use Test;

use Gnome::N::GlibToRakuTypes;

use Gnome::Glib::MainLoop;
use Gnome::Glib::MainContext;

#use Gnome::N::X;
#Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
my Gnome::Glib::MainLoop $ml;
my Gnome::Glib::MainContext $mc;
#-------------------------------------------------------------------------------
subtest 'ISA test', {
  $mc .= new;
  isa-ok $mc, Gnome::Glib::MainContext, '.new()';
  $mc.clear-object;

  $mc .= new(:default);
  isa-ok $mc, Gnome::Glib::MainContext, '.new(:default)';
  $mc.clear-object;

  $mc .= new(:thread-default);
  isa-ok $mc, Gnome::Glib::MainContext, '.new(:thread-default)';
  $mc.clear-object;
}

#-------------------------------------------------------------------------------
# test rest in MainLoop.t
#-------------------------------------------------------------------------------
done-testing;
