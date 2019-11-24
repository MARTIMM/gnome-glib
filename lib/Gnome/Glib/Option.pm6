#TL:1:Gnome::Glib::Option:

#TODO split option_group from option_context

use v6;
#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Glib::Option

parses commandline options

=head1 Description

The GOption commandline parser is intended to be a simpler replacement for the popt library. It supports short and long commandline options, as shown in the following example:

`testtreemodel -r 1 --max-size 20 --rand --display=:1.0 -vb -- file1 file2`

The example demonstrates a number of features of the GOption commandline parser:

=item Options can be single letters, prefixed by a single dash.

=item Multiple short options can be grouped behind a single dash.

=item Long options are prefixed by two consecutive dashes.

=item Options can have an extra argument, which can be a number, a string or a filename. For long options, the extra argument can be appended with an equals sign after the option name, which is useful if the extra argument starts with a dash, which would otherwise cause it to be interpreted as another option.

=item Non-option arguments are returned to the application as rest arguments.

=item An argument consisting solely of two dashes turns off further parsing, any remaining arguments (even those starting with a dash) are returned to the application as rest arguments.

Another important feature of GOption is that it can automatically generate nicely formatted help output. Unless it is explicitly turned off with C<g_option_context_set_help_enabled()>, GOption will recognize the `--help`, `-?`, `--help-all` and `--help-groupname` options (where `groupname` is the name of a B<N-GOptionGroup>) and write a text similar to the one shown in the following example to stdout.


  Usage:
    testtreemodel [OPTION...] - test tree model performance

  Help Options:
    -h, --help               Show help options
    --help-all               Show all help options
    --help-gtk               Show GTK+ Options

  Application Options:
    -r, --repeats=N          Average over N repetitions
    -m, --max-size=M         Test up to 2^M items
    --display=DISPLAY        X display to use
    -v, --verbose            Be verbose
    -b, --beep               Beep when done
    --rand                   Randomize the data

GOption groups options in B<N-GOptionGroups>, which makes it easy to incorporate options from multiple sources. The intended use for this is to let applications collect option groups from the libraries it uses, add them to their B<N-GOptionContext>, and parse all options by a single call to C<g_option_context_parse()>. See C<gtk_get_option_group()> for an example.

If an option is declared to be of type string or filename, GOption takes care of converting it to the right encoding; strings are returned in UTF-8, filenames are returned in the GLib filename encoding. Note that this only works if C<setlocale()> has been called before C<g_option_context_parse()>.

=begin comment
Here is a complete example of setting up GOption to parse the example commandline above and produce the example help output.
|[<!-- language="C" -->
static gint repeats = 2;
static gint max_size = 8;
static gboolean verbose = FALSE;
static gboolean beep = FALSE;
static gboolean randomize = FALSE;

static GOptionEntry entries[] =
{
  { "repeats", 'r', 0, G_OPTION_ARG_INT, &repeats, "Average over N repetitions", "N" },
  { "max-size", 'm', 0, G_OPTION_ARG_INT, &max_size, "Test up to 2^M items", "M" },
  { "verbose", 'v', 0, G_OPTION_ARG_NONE, &verbose, "Be verbose", NULL },
  { "beep", 'b', 0, G_OPTION_ARG_NONE, &beep, "Beep when done", NULL },
  { "rand", 0, 0, G_OPTION_ARG_NONE, &randomize, "Randomize the data", NULL },
  { NULL }
};

int
main (int argc, char *argv[])
{
  GError *error = NULL;
  N-GOptionContext *context;

  context = g_option_context_new ("- test tree model performance");
  g_option_context_add_main_entries (context, entries, GETTEXT_PACKAGE);
  g_option_context_add_group (context, gtk_get_option_group (TRUE));
  if (!g_option_context_parse (context, &argc, &argv, &error))
    {
      g_print ("option parsing failed: C<s>\n", error->message);
      exit (1);
    }

  ...

}
]|
=end comment

On UNIX systems, the argv that is passed to C<main()> has no particular encoding, even to the extent that different parts of it may have different encodings.  In general, normal arguments and flags will be in the current locale and filenames should be considered to be opaque byte strings.  Proper use of C<G_OPTION_ARG_FILENAME> vs C<G_OPTION_ARG_STRING> is therefore important.

Note that on Windows, filenames do have an encoding, but using B<N-GOptionContext> with the argv as passed to C<main()> will result in a program that can only accept commandline arguments with characters from the system codepage.  This can cause problems when attempting to deal with filenames containing Unicode characters that fall outside of the codepage.

A solution to this is to use C<g_win32_get_command_line()> and C<g_option_context_parse_strv()> which will properly handle full Unicode filenames.  If you are using B<Gnome::Gio::Application>, this is done automatically for you.

=begin comment
The following example shows how you can use B<N-GOptionContext> directly in order to correctly deal with Unicode filenames on Windows:

|[<!-- language="C" -->
int
main (int argc, char **argv)
{
  GError *error = NULL;
  N-GOptionContext *context;
  gchar **args;

B<ifdef> G_OS_WIN32
  args = C<g_win32_get_command_line()>;
B<else>
  args = g_strdupv (argv);
B<endif>

  // set up context

  if (!g_option_context_parse_strv (context, &args, &error))
    {
      // error happened
    }

  ...

  g_strfreev (args);

  ...
}
]|
=end comment


=head1 Synopsis
=head2 Declaration

  unit class Gnome::Glib::Option;

=comment head2 Example

=end pod

#-------------------------------------------------------------------------------
use NativeCall;

use Gnome::N::X;
use Gnome::N::NativeLib;
use Gnome::N::N-GObject;
use Gnome::Glib::Error;

#-------------------------------------------------------------------------------
# /usr/include/gtk-3.0/gtk/INCLUDE
# https://developer.gnome.org/WWW
unit class Gnome::Glib::Option:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------
=begin pod
=head1 Types
=end pod

#-------------------------------------------------------------------------------
#subset N-GDestroyNotify of Callable;
#subset N-GOptionParseFunc of Callable;
#subset N-GOptionArgFunc of Callable;
#subset N-GTranslateFunc of Callable;
#subset N-GOptionErrorFunc of Callable;

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GOptionFlags

Flags which modify individual options.


=item G_OPTION_FLAG_NONE: No flags. Since: 2.42.
=item G_OPTION_FLAG_HIDDEN: The option doesn't appear in `--help` output.
=item G_OPTION_FLAG_IN_MAIN: The option appears in the main section of the `--help` output, even if it is defined in a group.
=item G_OPTION_FLAG_REVERSE: For options of the C<G_OPTION_ARG_NONE> kind, this flag indicates that the sense of the option is reversed.
=item G_OPTION_FLAG_NO_ARG: For options of the C<G_OPTION_ARG_CALLBACK> kind, this flag indicates that the callback does not take any argument (like a C<G_OPTION_ARG_NONE> option). Since 2.8
=item G_OPTION_FLAG_FILENAME: For options of the C<G_OPTION_ARG_CALLBACK> kind, this flag indicates that the argument should be passed to the callback in the GLib filename encoding rather than UTF-8. Since 2.8
=item G_OPTION_FLAG_OPTIONAL_ARG: For options of the C<G_OPTION_ARG_CALLBACK>  kind, this flag indicates that the argument supply is optional. If no argument is given then data of C<N-GOptionParseFunc> will be set to NULL. Since 2.8
=item G_OPTION_FLAG_NOALIAS: This flag turns off the automatic conflict resolution which prefixes long option names with `groupname-` if  there is a conflict. This option should only be used in situations where aliasing is necessary to model some legacy commandline interface. It is not safe to use this option, unless all option groups are under your direct control. Since 2.8.

=end pod

#TE:1:GOptionFlags:
enum GOptionFlags is export (
  'G_OPTION_FLAG_NONE'            => 0,
  'G_OPTION_FLAG_HIDDEN'		      => 1 +< 0,
  'G_OPTION_FLAG_IN_MAIN'		      => 1 +< 1,
  'G_OPTION_FLAG_REVERSE'		      => 1 +< 2,
  'G_OPTION_FLAG_NO_ARG'		      => 1 +< 3,
  'G_OPTION_FLAG_FILENAME'	      => 1 +< 4,
  'G_OPTION_FLAG_OPTIONAL_ARG'    => 1 +< 5,
  'G_OPTION_FLAG_NOALIAS'	        => 1 +< 6
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GOptionArg

The B<GOptionArg> enum values determine which type of extra argument the
options expect to find. If an option expects an extra argument, it can
be specified in several ways; with a short option: `-x arg`, with a long
option: `--name arg` or combined in a single argument: `--name=arg`.


=item G_OPTION_ARG_NONE: No extra argument. This is useful for simple flags.
=item G_OPTION_ARG_STRING: The option takes a string argument.
=item G_OPTION_ARG_INT: The option takes an integer argument.
=item G_OPTION_ARG_CALLBACK: The option provides a callback (of type B<N-GOptionArgFunc>) to parse the extra argument.
=item G_OPTION_ARG_FILENAME: The option takes a filename as argument.
=item G_OPTION_ARG_STRING_ARRAY: The option takes a string argument, multiple uses of the option are collected into an array of strings.
=item G_OPTION_ARG_FILENAME_ARRAY: The option takes a filename as argument,  multiple uses of the option are collected into an array of strings.
=item G_OPTION_ARG_DOUBLE: The option takes a double argument. The argument can be formatted either for the user's locale or for the "C" locale. Since 2.12
=item G_OPTION_ARG_INT64: The option takes a 64-bit integer. Like C<G_OPTION_ARG_INT> but for larger numbers. The number can be in decimal base, or in hexadecimal (when prefixed with `0x`, for example, `0xffffffff`). Since 2.12


=end pod

#TE:1:GOptionArg:
enum GOptionArg is export (
  'G_OPTION_ARG_NONE',
  'G_OPTION_ARG_STRING',
  'G_OPTION_ARG_INT',
  'G_OPTION_ARG_CALLBACK',
  'G_OPTION_ARG_FILENAME',
  'G_OPTION_ARG_STRING_ARRAY',
  'G_OPTION_ARG_FILENAME_ARRAY',
  'G_OPTION_ARG_DOUBLE',
  'G_OPTION_ARG_INT64'
);

#-------------------------------------------------------------------------------
=begin pod
=head2 enum GOptionError

Error codes returned by option parsing.


=item G_OPTION_ERROR_UNKNOWN_OPTION: An option was not known to the parser. This error will only be reported, if the parser hasn't been instructed to ignore unknown options, see C<g_option_context_set_ignore_unknown_options()>.
=item G_OPTION_ERROR_BAD_VALUE: A value couldn't be parsed.
=item G_OPTION_ERROR_FAILED: A B<N-GOptionArgFunc> callback failed.


=end pod

#TE:0:GOptionError:
enum GOptionError is export (
  'G_OPTION_ERROR_UNKNOWN_OPTION',
  'G_OPTION_ERROR_BAD_VALUE',
  'G_OPTION_ERROR_FAILED'
);

#-------------------------------------------------------------------------------
=begin pod
=head2 class N-GOptionEntry

A N-GOptionEntry struct defines a single option. To have an effect, they
must be added to a B<N-GOptionGroup> with C<g_option_context_add_main_entries()>
or C<g_option_group_add_entries()>.


=item Str $.long_name: The long name of an option can be used to specify it in a commandline as `--long_name`. Every option must have a long name. To resolve conflicts if multiple option groups contain the same long name, it is also possible to specify the option as  `--groupname-long_name`.
=item Int $.short_name: If an option has a short name, it can be specified `-short_name` in a commandline. I<short_name> must be  a printable ASCII character different from '-', or zero if the option has no short name.
=item Int $.flags: Flags from B<GOptionFlags>
=item GOptionArg $.arg: The type of the option, as a B<GOptionArg>
=item Pointer $.arg_data: If the I<arg> type is C<G_OPTION_ARG_CALLBACK>, then I<arg_data> must point to a B<N-GOptionArgFunc> callback function, which will be called to handle the extra argument. Otherwise, I<arg_data> is a pointer to a location to store the value, the required type of the location depends on the I<arg> type:
=item2 C<G_OPTION_ARG_NONE>: C<Int> ( 0 or 1 (= C type boolean) )
=item2 C<G_OPTION_ARG_STRING>: C<Str>
=item2 C<G_OPTION_ARG_INT>: C<Int>
=item2 C<G_OPTION_ARG_FILENAME>: C<Str>
=item2 C<G_OPTION_ARG_STRING_ARRAY>: C<CArray[Str]>
=item2 C<G_OPTION_ARG_FILENAME_ARRAY>: C<CArray[Str]>
=item2 C<G_OPTION_ARG_DOUBLE>: C<Num>
If I<arg> type is C<G_OPTION_ARG_STRING> or C<G_OPTION_ARG_FILENAME>, the location will contain a newly allocated string if the option was given. That string needs to be freed by the callee using C<g_free()>. Likewise if I<arg> type is C<G_OPTION_ARG_STRING_ARRAY> or C<G_OPTION_ARG_FILENAME_ARRAY>, the data should be freed using C<g_strfreev()>.
=item Str $.description: the description for the option in `--help` output. The I<description> is translated using the I<translate_func> of the group, see C<g_option_group_set_translation_domain()>.
=item Str $.arg_description: The placeholder to use for the extra argument parsed by the option in `--help` output. The I<arg_description> is translated using the I<translate_func> of the group, see C<g_option_group_set_translation_domain()>.

=end pod
#class ArgData is repr('CPointer') { }

#TT:1:N-GOptionEntry:
class N-GOptionEntry is export is repr('CStruct') {
  has str $.long-name;
  has uint8 $.short-name;
  has int32 $.flags;
  has int32 $.arg;
  has Pointer $.arg-data;
  has str $.description;
  has str $.arg-description;

  submethod BUILD (
    :$!long-name, :$!short-name, :$!flags, :$!arg,
    :$!description, :$!arg-description
  ) { }

  submethod TWEAK ( :$arg-data ) {
    $!arg-data := nativecast( Pointer, $arg-data);
  }
}

#-------------------------------------------------------------------------------
class N-GOptionGroup
  is repr('CPointer')
  is export
  { }

#-------------------------------------------------------------------------------
class N-GOptionContext
  is repr('CPointer')
  is export
  { }

#-------------------------------------------------------------------------------
has N-GOptionContext $!g-option-context;

has Bool $.option-context-is-valid = False;

#-------------------------------------------------------------------------------
=begin pod
=head1 Methods
=head2 new

Create a new option context object. The string is a parameter string. See also C<g_option_context_new()>.

  multi method new ( Str :pstring! )

Create an object using a native option context object from elsewhere.

  multi method new ( N-GOptionContext :$context! )

=end pod

#TM:1:new(:pstring):
#TM:1:new(:context):

submethod BUILD ( *%options ) {

  # prevent creating wrong widgets
  return unless self.^name eq 'Gnome::Glib::Option';

  # process all named arguments
  if ? %options<pstring> {
    $!g-option-context = g_option_context_new(%options<pstring>);
    $!option-context-is-valid = $!g-option-context.defined;
  }

  elsif ? %options<context> {
    $!g-option-context = %options<context>;
    $!option-context-is-valid = $!g-option-context.defined;
  }

  elsif %options.keys.elems {
    die X::Gnome.new(
      :message('Unsupported options for ' ~ self.^name ~
               ': ' ~ %options.keys.join(', ')
              )
    );
  }
}

#-------------------------------------------------------------------------------
method CALL-ME ( N-GOptionContext $g-option-context? --> N-GOptionContext ) {

  if $g-option-context.defined {
    _g_option_context_free($!g-option-context) if $!g-option-context.defined;
    $!g-option-context = $g-option-context;
    $!option-context-is-valid = True;
  }

  $!g-option-context
}

#-------------------------------------------------------------------------------
# no pod. user does not have to know about it.
#TODO destroy when overwritten?
method native-object (
  N-GOptionContext:D $g-option-context --> N-GOptionContext
) {

  if $g-option-context.defined {
    _g_option_context_free($!g-option-context) if $!g-option-context.defined;
    $!g-option-context = $g-option-context;
    $!option-context-is-valid = True;
  }

  $!g-option-context
}

#-------------------------------------------------------------------------------
# no pod. user does not have to know about it.
method get-native-gobject ( --> N-GOptionContext ) {
  $!g-option-context
}

#-------------------------------------------------------------------------------
# no pod. user does not have to know about it.
method FALLBACK ( $native-sub is copy, |c ) {

  note "\nSearch for $native-sub in Options" if $Gnome::N::x-debug;

  CATCH { test-catch-exception( $_, $native-sub); }

  # convert all dashes to underscores if there are any.
  $native-sub ~~ s:g/ '-' /_/ if $native-sub.index('-').defined;

  my Callable $s;
  try { $s = &::("g_option_$native-sub"); };
  try { $s = &::("g_$native-sub"); } unless ?$s;
  try { $s = &::($native-sub); } if !$s and $native-sub ~~ m/^ 'g_' /;

  #$s = callsame unless ?$s;

  # User convenience substitutions to get a native object instead of
  # a GtkSomeThing or other *SomeThing object.
  my Array $params = [];
  for c.list -> $p {
    note "Substitution of parameter \[{$++}]: ", $p.^name if $Gnome::N::x-debug;

    #TODO maybe another class later
    if $p.^name ~~ m/ '::N-GOptionGroup' / {

      $params.push($p);
    }

    elsif $p.^name ~~
          m/^ 'Gnome::' [ Gtk || Gdk || Glib || Gio || GObject ] \d? '::' / {

      $params.push($p());
    }

    else {
      $params.push($p);
    }
  }

  test-call( $s, $!g-option-context, |$params)
}

#-------------------------------------------------------------------------------
#TM:1:option-context-is-valid
# doc of $!option-context-is-valid defined above
=begin pod
=head2 option-context-is-valid

Returns True if native option context object is valid, otherwise C<False>.

  method option-context-is-valid ( --> Bool )

=end pod

#-------------------------------------------------------------------------------
method setup-option-entries ( **@entries --> CArray[N-GOptionEntry] ) {
#note "As: ", @entries;

  my CArray[N-GOptionEntry] $oes .= new;
  my $entry-count = 0;
  for @entries -> $entry {
#note "A: ", $entry.join(', ');
    # get option arg type
    my GOptionArg $arg = $entry[3];
    my $arg-data;

    # test the type of argument to store the 4th item in arg-data
    given $arg {
      when any( G_OPTION_ARG_NONE, G_OPTION_ARG_INT) {
        $arg-data = CArray[int32].new($entry[4]);
      }

      when any( G_OPTION_ARG_STRING, G_OPTION_ARG_FILENAME) {
        $arg-data = CArray[Str].new($entry[4]);
      }

      when any( G_OPTION_ARG_STRING_ARRAY, G_OPTION_ARG_FILENAME_ARRAY) {
        $arg-data = CArray[CArray[Str]].new([$entry[4]]);
      }

      when G_OPTION_ARG_DOUBLE {
        $arg-data = CArray[num64].new($entry[4]);
      }
    }

    # create a new option entry
    $oes[$entry-count++] = N-GOptionEntry.new(
      :long-name($entry[0]),
      :short-name($entry[1].ord),
      :flags($entry[2]),
      :$arg,
      :$arg-data,
      :description($entry[5]),
      :arg-description($entry[6]),
    );
  }

  # and finish the last one
  $oes[$entry-count] = N-GOptionEntry;

  $oes
}

#-------------------------------------------------------------------------------
#TM:1:clear-option-context
=begin pod
=head2

Clear the error and return data to memory to pool. The option context object is not valid after this call and option-context-is-valid() will return C<False>.

  method clear-option-context ()

=end pod

method clear-option-context ( ) {

  _g_option_context_free($!g-option-context) if $!g-option-context.defined;
  $!option-context-is-valid = False;
  $!g-option-context = N-GOptionContext;
}

sub _g_option_context_free ( N-GOptionContext $context )
  is native(&glib-lib)
  is symbol('g_option_context_free')
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_option_error_quark:
=begin pod
=head2 [g_option_] error_quark

  method g_option_error_quark ( --> int32  )

=end pod

sub g_option_error_quark (  )
  returns int32
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:2:g_option_context_new:new(:pstring)
=begin pod
=head2 [g_option_] context_new

Creates a new option context.

The I<parameter_string> can serve multiple purposes. It can be used to add descriptions for "rest" arguments, which are not parsed by the B<N-GOptionContext>, typically something like "FILES" or "FILE1 FILE2...". If you are using B<G_OPTION_REMAINING> for collecting "rest" arguments, GLib handles this automatically by using the I<arg_description> of the corresponding B<N-GOptionEntry> in the usage summary.

Another usage is to give a short summary of the program functionality, like " - frob the strings", which will be displayed in the same line as the usage. For a longer description of the program functionality that should be displayed as a paragraph below the usage line, use C<g_option_context_set_summary()>.

Note that the I<parameter_string> is translated using the function set with C<g_option_context_set_translate_func()>, so it should normally be passed untranslated.

Returns: a newly created B<N-GOptionContext>, which must be freed with C<g_option_context_free()> after use.

Since: 2.6

  method g_option_context_new ( Str $parameter_string --> N-GOptionContext  )

=item Str $parameter_string; (nullable): a string which is displayed in the first line of `--help` output, after the usage summary `programname [OPTION...]`

=end pod

sub g_option_context_new ( Str $parameter_string )
  returns N-GOptionContext
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:g_option_context_set_summary:
=begin pod
=head2 [g_option_] context_set_summary

Adds a string to be displayed in `--help` output before the list of options. This is typically a summary of the program functionality.

Note that the summary is translated (see C<g_option_context_set_translate_func()> and C<g_option_context_set_translation_domain()>).

Since: 2.12

  method g_option_context_set_summary ( Str $summary )

=item Str $summary; a string to be shown in `--help` output before the list of options, or C<Any>.

=end pod

sub g_option_context_set_summary ( N-GOptionContext $context, Str $summary )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:g_option_context_get_summary:
=begin pod
=head2 [g_option_] context_get_summary

Returns the summary. See C<g_option_context_set_summary()>.

Returns: the summary

Since: 2.12

  method g_option_context_get_summary ( --> Str  )

=end pod

sub g_option_context_get_summary ( N-GOptionContext $context )
  returns Str
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:g_option_context_set_description:
=begin pod
=head2 [g_option_] context_set_description

Adds a string to be displayed in `--help` output after the list
of options. This text often includes a bug reporting address.

Note that the summary is translated (see
C<g_option_context_set_translate_func()>).

Since: 2.12

  method g_option_context_set_description ( Str $description )

=item Str $description; (nullable): a string to be shown in `--help` output after the list of options, or C<Any>

=end pod

sub g_option_context_set_description ( N-GOptionContext $context, Str $description )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:g_option_context_get_description:
=begin pod
=head2 [g_option_] context_get_description

Returns the description. See C<g_option_context_set_description()>.

Returns: the description

Since: 2.12

  method g_option_context_get_description ( --> Str  )

=end pod

sub g_option_context_get_description ( N-GOptionContext $context )
  returns Str
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:g_option_context_set_help_enabled:
=begin pod
=head2 [g_option_] context_set_help_enabled

Enables or disables automatic generation of `--help` output.
By default, C<g_option_context_parse()> recognizes `--help`, `-h`,
`-?`, `--help-all` and `--help-groupname` and creates suitable
output to stdout.

Since: 2.6

  method g_option_context_set_help_enabled ( Int $help_enabled )

=item Int $help_enabled; C<1> to enable `--help`, C<0> to disable it

=end pod

sub g_option_context_set_help_enabled ( N-GOptionContext $context, int32 $help_enabled )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:g_option_context_get_help_enabled:
=begin pod
=head2 [g_option_] context_get_help_enabled

Returns whether automatic `--help` generation
is turned on for I<context>. See C<g_option_context_set_help_enabled()>.

Returns: C<1> if automatic help generation is turned on.

Since: 2.6

  method g_option_context_get_help_enabled ( --> Int )

=end pod

sub g_option_context_get_help_enabled ( N-GOptionContext $context )
  returns int32
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:g_option_context_set_ignore_unknown_options:
=begin pod
=head2 [g_option_] context_set_ignore_unknown_options

Sets whether to ignore unknown options or not. If an argument is
ignored, it is left in the I<argv> array after parsing. By default,
C<g_option_context_parse()> treats unknown options as error.

This setting does not affect non-option arguments (i.e. arguments
which don't start with a dash). But note that GOption cannot reliably
determine whether a non-option belongs to a preceding unknown option.

Since: 2.6

  method g_option_context_set_ignore_unknown_options ( Int $ignore_unknown )

=item Int $ignore_unknown; C<1> to ignore unknown options, C<0> to produce an error when unknown options are met

=end pod

sub g_option_context_set_ignore_unknown_options ( N-GOptionContext $context, int32 $ignore_unknown )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:g_option_context_get_ignore_unknown_options:
=begin pod
=head2 [g_option_] context_get_ignore_unknown_options

Returns whether unknown options are ignored or not. See
C<g_option_context_set_ignore_unknown_options()>.

Returns: C<1> if unknown options are ignored.

Since: 2.6

  method g_option_context_get_ignore_unknown_options ( N-GOptionContext $context --> Int  )

=item N-GOptionContext $context; a B<N-GOptionContext>

=end pod

sub g_option_context_get_ignore_unknown_options ( N-GOptionContext $context )
  returns int32
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:g_option_context_set_strict_posix:
=begin pod
=head2 [g_option_] context_set_strict_posix

Sets strict POSIX mode.

By default, this mode is disabled.

In strict POSIX mode, the first non-argument parameter encountered
(eg: filename) terminates argument processing.  Remaining arguments
are treated as non-options and are not attempted to be parsed.

If strict POSIX mode is disabled then parsing is done in the GNU way
where option arguments can be freely mixed with non-options.

As an example, consider "ls foo -l".  With GNU style parsing, this
will list "foo" in long mode.  In strict POSIX style, this will list
the files named "foo" and "-l".

It may be useful to force strict POSIX mode when creating "verb
style" command line tools.  For example, the "gsettings" command line
tool supports the global option "--schemadir" as well as many
subcommands ("get", "set", etc.) which each have their own set of
arguments.  Using strict POSIX mode will allow parsing the global
options up to the verb name while leaving the remaining options to be
parsed by the relevant subcommand (which can be determined by
examining the verb name, which should be present in argv[1] after
parsing).

Since: 2.44

  method g_option_context_set_strict_posix ( Int $strict_posix )

=item Int $strict_posix; the new value

=end pod

sub g_option_context_set_strict_posix ( N-GOptionContext $context, int32 $strict_posix )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:g_option_context_get_strict_posix:
=begin pod
=head2 [g_option_] context_get_strict_posix

Returns whether strict POSIX code is enabled.

See C<g_option_context_set_strict_posix()> for more information.

Returns: C<1> if strict POSIX is enabled, C<0> otherwise.

Since: 2.44

  method g_option_context_get_strict_posix ( --> Int  )

=end pod

sub g_option_context_get_strict_posix ( N-GOptionContext $context )
  returns int32
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:g_option_context_add_main_entries:
=begin pod
=head2 [g_option_] context_add_main_entries

A convenience function which creates a main group if it doesn't exist, adds the I<entries> to it and sets the translation domain.

Since: 2.6

  method g_option_context_add_main_entries (
    CArray[N-GOptionEntry] $entries, Str $translation_domain
  )

=item CArray[N-GOptionEntry] $entries; a C<Any>-terminated array of B<N-GOptionEntrys>
=item Str $translation_domain; (nullable): a translation domain to use for translating the `--help` output for the options in I<entries> with C<gettext()>, or C<Any>

=end pod

sub g_option_context_add_main_entries ( N-GOptionContext $context, CArray[N-GOptionEntry] $entries, Str $translation_domain )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:g_option_context_parse:
=begin pod
=head2 [g_option_] context_parse

Parses the command line arguments, recognizing options which have been added to I<context>. A side-effect of calling this function is that C<g_set_prgname()> will be called.

If the parsing is successful, any parsed arguments are removed from the array and I<argc> and I<argv> are updated accordingly. A '--' option is stripped from I<argv> unless there are unparsed options before and after it, or some of the options after it start with '-'. In case of an error, I<argc> and I<argv> are left unmodified.

If automatic `--help` support is enabled (see C<g_option_context_set_help_enabled()>), and the I<argv> array contains one of the recognized help options, this function will produce help output to stdout and call `exit (0)`.

Note that function depends on the [current locale][setlocale] for automatic character set conversion of string and filename arguments.

Returns: C<1> if the parsing was successful, C<0> if an error occurred

Since: 2.6

  method g_option_context_parse ( Int $argc, @argv --> List )

=item Int $argc; (inout) (optional): a pointer to the number of command line arguments
=item Array $argv; (inout) (array length=argc) (optional): a pointer to the array of command line arguments

The method returns a list of;
=item Int, the modified argument count
=item Array, the modified argument values
=item a Gnome::Glib::Error if any. Check .error-is-valid() of this object.

=end pod

sub g_option_context_parse (
  N-GOptionContext $context, Int $argc is copy, @argv is copy
  --> List
) {
#note "AC 0: ", $argc;
#note "AV 0: ", @argv;

  my Gnome::Glib::Error $error;
  my CArray[N-GError] $e .= new(N-GError);

  my CArray[int32] $ac .= new;
  $ac[0] = $argc;

  my CArray[Str] $avi .= new;
  loop ( my Int $i = 0; $i < @argv.elems; $i++ ) {
    $avi[$i] = @argv[$i];
  }
  my CArray[CArray[Str]] $av .= new;
  $av[0] = $avi;

  my Int $s = _g_option_context_parse( $context, $ac, $av, $e);
note "S: $s";

  if $s {
    $error = Gnome::Glib::Error.new(:gerror(N-GError));
    @argv = ();
    $argc = $ac[0];
    loop ( my Int $i = 0; $i < $argc; $i++ ) {
      @argv[$i] = $av[0][$i];
    }
#note "AC 2: ", $argc;
#note "AV 2: ", @argv;
  }

  else {
note "E: ", $e, ', ', $e[0].perl;
    $error = Gnome::Glib::Error.new(:gerror($e[0]))
  }

  ( $argc, [@argv], $error)
}

sub _g_option_context_parse (
  N-GOptionContext $context, CArray[int32] $argc, CArray[CArray[Str]] $argv,
  CArray[N-GError] $error
) returns int32
  is native(&glib-lib)
  is symbol('g_option_context_parse')
  { * }

#`{{
#-------------------------------------------------------------------------------
# TM:0:g_option_context_parse_strv:
=begin pod
=head2 [g_option_] context_parse_strv

Parses the command line arguments.

This function is similar to C<g_option_context_parse()> except that it respects the normal memory rules when dealing with a strv instead of assuming that the passed-in array is the argv of the main function.

In particular, strings that are removed from the arguments list will be freed using C<g_free()>.

On Windows, the strings are expected to be in UTF-8.  This is in contrast to C<g_option_context_parse()> which expects them to be in the system codepage, which is how they are passed as I<argv> to C<main()>. See C<g_win32_get_command_line()> for a solution.

This function is useful if you are trying to use B<N-GOptionContext> with B<Gnome::Gio::Application>.

Since: 2.40

  method g_option_context_parse_strv ( @arguments --> List )

=item CArray[Str] @arguments; a pointer to the command line arguments (which must be in UTF-8 on Windows)

Returns a List with;
=item A possibly modified arguments list
=item Gnome::Glib::Error object to check if parsing fails. Check with C<.error-is-valid()> on the returned object.

=end pod

sub g_option_context_parse_strv (
  N-GOptionContext $context, @arguments is copy
  --> List
) {
  my Gnome::Glib::Error $error;
  my CArray[N-GError] $e .= new(N-GError);

  my CArray[Str] $argv .= new;
  loop ( my $i = 0; $i < +@arguments; $i++ ) {
    $argv[$i] = @arguments[$i];
  }
  my CArray[CArray[Str]] $argv-p .= new;
  $argv-p[0] = $argv;
  my Int $s = _g_option_context_parse_strv( $context, $argv-p, $e);
note "S $s";
  if $s {
    $error .= new(N-GError);
note "Ex: ", $error.perl;
    @arguments = ();
    loop ( my $i = 0; $i < $argv-p[0].elems; $i++ ) {
      @arguments[$i] = $argv-p[0][$i];
    }
  }

  else {
    $error .= new(:gerror($e[0]));
note "E+: ", $error.perl;
  }

  ( [@arguments], $error)
}


sub _g_option_context_parse_strv (
  N-GOptionContext $context, CArray[CArray[Str]] $arguments,
  CArray[N-GError] $error
) returns int32
  is native(&glib-lib)
  is symbol('g_option_context_parse_strv')
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
#TM:0:g_option_context_set_translate_func:
=begin pod
=head2 [g_option_] context_set_translate_func

Sets the function which is used to translate the contexts
user-visible strings, for `--help` output. If I<func> is C<Any>,
strings are not translated.

Note that option groups have their own translation functions,
this function only affects the I<parameter_string> (see C<g_option_context_new()>),
the summary (see C<g_option_context_set_summary()>) and the description
(see C<g_option_context_set_description()>).

If you are using C<gettext()>, you only need to set the translation
domain, see C<g_option_context_set_translation_domain()>.

Since: 2.12

  method g_option_context_set_translate_func ( N-GOptionContext $context, N-GTranslateFunc $func, Pointer $data, N-GDestroyNotify $destroy_notify )

=item N-GOptionContext $context; a B<N-GOptionContext>
=item N-GTranslateFunc $func; (nullable): the B<N-GTranslateFunc>, or C<Any>
=item Pointer $data; (nullable): user data to pass to I<func>, or C<Any>
=item N-GDestroyNotify $destroy_notify; (nullable): a function which gets called to free I<data>, or C<Any>

=end pod

sub g_option_context_set_translate_func ( N-GOptionContext $context, N-GTranslateFunc $func, Pointer $data, N-GDestroyNotify $destroy_notify )
  is native(&glib-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
#TM:0:g_option_context_set_translation_domain:
=begin pod
=head2 [g_option_] context_set_translation_domain

A convenience function to use C<gettext()> for translating user-visible strings.

Since: 2.12

  method g_option_context_set_translation_domain ( Str $domain )

=item Str $domain; the domain to use

=end pod

sub g_option_context_set_translation_domain ( N-GOptionContext $context, Str $domain )
  is native(&glib-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:1:g_option_context_add_group:
=begin pod
=head2 [g_option_] context_add_group

Adds a B<N-GOptionGroup> to the I<context>, so that parsing with I<context>
will recognize the options in the group. Note that this will take
ownership of the I<group> and thus the I<group> should not be freed.

Since: 2.6

  method g_option_context_add_group ( N-GOptionGroup $group )

=item N-GOptionGroup $group; the group to add

=end pod

sub g_option_context_add_group ( N-GOptionContext $context, N-GOptionGroup $group )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_option_context_set_main_group:
=begin pod
=head2 [g_option_] context_set_main_group

Sets a B<N-GOptionGroup> as main group of the I<context>. This has the same effect as calling C<g_option_context_add_group()>, the only difference is that the options in the main group are treated differently when generating `--help` output.

Since: 2.6

  method g_option_context_set_main_group ( N-GOptionGroup $group )

=item N-GOptionGroup $group; (transfer full): the group to set as main group

=end pod

sub g_option_context_set_main_group ( N-GOptionContext $context, N-GOptionGroup $group )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_option_context_get_main_group:
=begin pod
=head2 [g_option_] context_get_main_group

Returns: the main group of I<context>, or C<Any> if I<context> doesn't have a main group. Note that group belongs to I<context> and should not be modified or freed.

Since: 2.6

  method g_option_context_get_main_group ( --> N-GOptionGroup  )

=end pod

sub g_option_context_get_main_group ( N-GOptionContext $context )
  returns N-GOptionGroup
  is native(&glib-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
#TM:0:g_option_context_get_help:
=begin pod
=head2 [g_option_] context_get_help

Returns a formatted, translated help text for the given context. To obtain the text produced by I<--help>, call C<g_option_context_get_help( 1, 0)>. To obtain the text produced by I<--help-all>, call C<g_option_context_get_help( 0, 0)>. To obtain the help text for an option group, call C<g_option_context_get_help( 0, $n-group)>.

Returns: A newly allocated string containing the help text

Since: 2.14

  method g_option_context_get_help (
    Int $main_help, N-GOptionGroup $group?
    --> Str
  )

=item Int $main_help; if C<1>, only include the main group
=item N-GOptionGroup $group; the B<N-GOptionGroup> to create help for. This is an optional argument.

=end pod

sub g_option_context_get_help (
  N-GOptionContext $context, Int $main_help, N-GOptionGroup $group?
  --> Str
) {
  my N-GOptionGroup $g = $group;
  my CArray[uint8] $v = _g_option_context_get_help( $context, $main_help, $g);
  my Int $null-loc = 0;
  loop {
    last if $v[$null-loc] == 0;
    $null-loc++;
  }
note "NC: $null-loc, ", ($v[0..($null-loc - 1)]).chrs;
#  my Buf $b .= new($v[0..($null-loc - 1)]);
#  note $b.decode;
  ''
}

sub _g_option_context_get_help (
  N-GOptionContext $context, int32 $main_help, N-GOptionGroup $group
) returns CArray[uint8]
  is native(&glib-lib)
  is symbol('g_option_context_get_help')
  { * }
}}

#-------------------------------------------------------------------------------
#TM:1:g_option_group_new:
=begin pod
=head2 [g_option_] group_new

Creates a new B<N-GOptionGroup>.

Returns: a newly created option group. It should be added to a B<N-GOptionContext> or freed with C<g_option_group_unref()>.

Since: 2.6

  method g_option_group_new (
    Str $name, Str $description, Str $help_description,
    --> N-GOptionGroup
  )

=item Str $name; the name for the option group, this is used to provide help for the options in this group with '--help-I<name>'
=item Str $description; a description for this group to be shown in `--help`. This string is translated using the translation domain or translation function of the group
=item Str $help_description; a description for the '--help-I<name>' option. This string is translated using the translation domain or translation function of the group
#`[[
    Pointer $user_data?, N-GDestroyNotify $destroy?
=item Pointer $user_data; user data that will be passed to the pre- and post-parse hooks, the error hook and to callbacks of C<G_OPTION_ARG_CALLBACK> options, is optional
=item Callable $destroy; a function that will be called to free I<user_data>, is optional
]]
=end pod

sub g_option_group_new (
  Str $name, Str $description, Str $help_description,
#  Pointer $user_data?, Callable $destroy?
  --> N-GOptionGroup
) {
#  my Pointer $ud = $user_data // OpaquePointer;
  my N-GOptionGroup $go = _g_option_group_new(
    $name, $description, $help_description, OpaquePointer,
    -> $d {
#      $destroy($d) if $destroy.defined;
    }
  );

  $go
}

sub _g_option_group_new (
  Str $name, Str $description, Str $help_description,
  Pointer $user_data, Callable $destroy-handler ( OpaquePointer )
) returns N-GOptionGroup
  is native(&glib-lib)
  is symbol('g_option_group_new')
  { * }

#`[[
#-------------------------------------------------------------------------------
#TM:0:g_option_group_set_parse_hooks:
=begin pod
=head2 [g_option_] group_set_parse_hooks

Associates two functions with I<group> which will be called
from C<g_option_context_parse()> before the first option is parsed
and after the last option has been parsed, respectively.

Note that the user data to be passed to I<pre_parse_func> and
I<post_parse_func> can be specified when constructing the group
with C<g_option_group_new()>.

Since: 2.6

  method g_option_group_set_parse_hooks ( N-GOptionGroup $group, N-GOptionParseFunc $pre_parse_func, N-GOptionParseFunc $post_parse_func )

=item N-GOptionGroup $group; a B<N-GOptionGroup>
=item N-GOptionParseFunc $pre_parse_func; (nullable): a function to call before parsing, or C<Any>
=item N-GOptionParseFunc $post_parse_func; (nullable): a function to call after parsing, or C<Any>

=end pod

sub g_option_group_set_parse_hooks ( N-GOptionGroup $group, N-GOptionParseFunc $pre_parse_func, N-GOptionParseFunc $post_parse_func )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_option_group_set_error_hook:
=begin pod
=head2 [g_option_] group_set_error_hook

Associates a function with I<group> which will be called
from C<g_option_context_parse()> when an error occurs.

Note that the user data to be passed to I<error_func> can be
specified when constructing the group with C<g_option_group_new()>.

Since: 2.6

  method g_option_group_set_error_hook ( N-GOptionGroup $group, N-GOptionErrorFunc $error_func )

=item N-GOptionGroup $group; a B<N-GOptionGroup>
=item N-GOptionErrorFunc $error_func; a function to call when an error occurs

=end pod

sub g_option_group_set_error_hook ( N-GOptionGroup $group, N-GOptionErrorFunc $error_func )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_option_group_ref:
=begin pod
=head2 [g_option_] group_ref

Increments the reference count of I<group> by one.

Returns: a B<N-GOptionGroup>

Since: 2.44

  method g_option_group_ref ( N-GOptionGroup $group --> N-GOptionGroup  )

=item N-GOptionGroup $group; a B<N-GOptionGroup>

=end pod

sub g_option_group_ref ( N-GOptionGroup $group )
  returns N-GOptionGroup
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_option_group_unref:
=begin pod
=head2 [g_option_] group_unref

Decrements the reference count of I<group> by one.
If the reference count drops to 0, the I<group> will be freed.
and all memory allocated by the I<group> is released.

Since: 2.44

  method g_option_group_unref ( N-GOptionGroup $group )

=item N-GOptionGroup $group; a B<N-GOptionGroup>

=end pod

sub g_option_group_unref ( N-GOptionGroup $group )
  is native(&glib-lib)
  { * }
]]

#-------------------------------------------------------------------------------
#TM:0:g_option_group_add_entries:
=begin pod
=head2 [g_option_] group_add_entries

Adds the options specified in I<entries> to I<group>.

Since: 2.6

  method g_option_group_add_entries ( N-GOptionGroup $group, N-GOptionEntry $entries )

=item N-GOptionGroup $group; a B<N-GOptionGroup>
=item N-GOptionEntry $entries; a C<Any>-terminated array of B<N-GOptionEntry>

=end pod

sub g_option_group_add_entries (
  N-GOptionContext $context, N-GOptionGroup $group,
  CArray[N-GOptionEntry] $entries
) {
  _g_option_group_add_entries( $group, $entries);
}

sub _g_option_group_add_entries (
  N-GOptionGroup $group, CArray[N-GOptionEntry] $entries
) is native(&glib-lib)
  is symbol('g_option_group_add_entries')
  { * }

#`[[
#-------------------------------------------------------------------------------
#TM:0:g_option_group_set_translate_func:
=begin pod
=head2 [g_option_] group_set_translate_func

Sets the function which is used to translate user-visible strings,
for `--help` output. Different groups can use different
B<N-GTranslateFuncs>. If I<func> is C<Any>, strings are not translated.

If you are using C<gettext()>, you only need to set the translation
domain, see C<g_option_group_set_translation_domain()>.

Since: 2.6

  method g_option_group_set_translate_func ( N-GOptionGroup $group, N-GTranslateFunc $func, Pointer $data, N-GDestroyNotify $destroy_notify )

=item N-GOptionGroup $group; a B<N-GOptionGroup>
=item N-GTranslateFunc $func; (nullable): the B<N-GTranslateFunc>, or C<Any>
=item Pointer $data; (nullable): user data to pass to I<func>, or C<Any>
=item N-GDestroyNotify $destroy_notify; (nullable): a function which gets called to free I<data>, or C<Any>

=end pod

sub g_option_group_set_translate_func ( N-GOptionGroup $group, N-GTranslateFunc $func, Pointer $data, N-GDestroyNotify $destroy_notify )
  is native(&glib-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:g_option_group_set_translation_domain:
=begin pod
=head2 [g_option_] group_set_translation_domain

A convenience function to use C<gettext()> for translating
user-visible strings.

Since: 2.6

  method g_option_group_set_translation_domain ( N-GOptionGroup $group, Str $domain )

=item N-GOptionGroup $group; a B<N-GOptionGroup>
=item Str $domain; the domain to use

=end pod

sub g_option_group_set_translation_domain ( N-GOptionGroup $group, Str $domain )
  is native(&glib-lib)
  { * }
]]
