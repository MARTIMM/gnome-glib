use v6;
use NativeCall;

#use Gnome::N::N-GObject:api<1>;
use Gnome::Glib::List:api<1>;
use Gnome::N::GlibToRakuTypes:api<1>;

my Gnome::Glib::List $l .= new;
my N-GList $n-l;

my $sobj = CArray[gint].new;
$sobj[0] = 100;
$l .= append(nativecast( gpointer, $sobj));

$sobj = CArray[gint].new;
$sobj[0] = 200;
$n-l = $l.append(nativecast( gpointer, $sobj));
