use v6;
#use lib '../gnome-glib/lib';
use lib '../gnome-native/lib';
use lib '../gnome-gtk3/lib';
use NativeCall;
use Test;

use Gnome::Glib::Error;
use Gnome::Glib::OptionContext;
use Gnome::Gtk3::Main;

use Gnome::N::X;
#Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
my Gnome::Gtk3::Main $m .= new;
my Gnome::Glib::OptionContext $o;
#-------------------------------------------------------------------------------
subtest 'ISA test', {
  $o .= new(:pstring('- test tree model performance'));
  isa-ok $o, Gnome::Glib::OptionContext, '.new(:pstring)';
  ok $o.is-valid, '.is-valid()';
}

#-------------------------------------------------------------------------------
subtest 'Manipulations', {
  $o.context-set-summary('Program to test performance of a test tree');
  is $o.context-get-summary, 'Program to test performance of a test tree',
     '.set-summary() / .get-summary()';

  $o.context-set-description('x');
  is $o.context-get-description, 'x',
     '.context-set-description() / .context-get-description()';

  $o.context-set-help-enabled(1);
  ok $o.context-get-help-enabled,
     '.context-set-help-enabled() / .context-get-help-enabled()';

  $o.context-set-ignore-unknown-options(1);
  ok $o.context-get-ignore-unknown-options,
     '.context-set-ignore-unknown-options() / .context-get-ignore-unknown-options()';

  $o.context_set_strict_posix(1);
  ok $o.context_get_strict_posix,
     '.context_set_strict_posix() / .context_get_strict_posix()';

  # arg-data is ignored for the moment
  my CArray[N-GOptionEntry] $oes = $o.setup-option-entries(
    [ "repeats", 'r', 0, G_OPTION_ARG_INT, 2,
      "Average over N repetitions", "N"
    ],
    [ "max-size", 'm', 0, G_OPTION_ARG_INT, 8, "Test up to 2^M items", "M"],
    [ "verbose", 'v', 0, G_OPTION_ARG_NONE, 0, "Be verbose", ''],
    [ "beep", 'b', 0, G_OPTION_ARG_NONE, 0, "Beep when done", ''],
    [ "rand", 'x', 0, G_OPTION_ARG_NONE, 0, "Randomize the data", ''],
  );

  # add main entries and add group options from Gtk3::Main
  $o.context_add_main_entries( $oes, 'EN_us');

  my N-GOptionGroup $ogroup = $o.group_new(
    'sub-group', 'details of sub group', 'help help help'
  );
  my CArray[N-GOptionEntry] $ges = $o.setup-option-entries(
    [ "display", 'd', 0, G_OPTION_ARG_INT, 1, 'Set display', 'S'],
  );
  $o.group_add_entries( $ogroup, $ges);
  $o.context_add_group($m.gtk-get-option-group(1));

  my @args = 'testtreemodel', '--display=:1.0', '-r', '1',
             '-vb', '--', 'file1', 'file2';
  ( my Int $c, my $v, my Gnome::Glib::Error $e) = $o.context_parse(@args);

  nok $e.is-valid, 'no error from .context_parse()';
  is $c, 7, '.context_parse(), count == 7';
  is-deeply $v, [ 'testtreemodel', '-r', '1', '-vb', '--', 'file1', 'file2'],
    '.context_parse(), vals == <testtreemodel -r 1  -vb -- file1 file2>';

#`{{
  ( $v, $e) = $o.context-parse-strv(
    <testtreemodel --display=:0 -r 1  -vb -- file1 file2>
  );
  nok $e.is-valid, 'no error from .context_parse()';
  is-deeply $v, [ |<testtreemodel -r>, '1', |< -vb -- file1 file2>],
    '.context_parse_strv(), vals == <testtreemodel -r 1  -vb -- file1 file2>';
}}
#Gnome::N::debug(:on);

  ok $o.context-get-help-enabled, 'help enabled';
#`{{
  $o.context_set_strict_posix(0);
#  note $o.context-get-help( 1, N-GOptionGroup);
  my CArray[uint8] $nt = $o.context-get-help( 1, N-GOptionGroup);
#  my Str $help-text = '';
  my @b = ();
  my Int $i = 0;
  while $nt[$i] {
#    $help-text ~= $nt[$i++].chr;
    @b.push: ($nt[$i] < 0 ?? ($nt[$i] +& 0x7F) + 0x80 !! $nt[$i]);
    $i++;
  }
  note Buf.new(|@b).decode;
}}

  $o.clear-object;
  nok $o.is-valid, '.clear-object()';
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
