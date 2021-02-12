use v6;
use NativeCall;

#-------------------------------------------------------------------------------
# Native object placed here because it is used by several modules. When placed
# in one of those module it can create circular dependencies
#
=begin pod
=head2 class N-GMainLoop

N-GMainLoop is an opaque data structure. This native object is stored here to prevent circular dependencies and some other reasons.

=end pod

#TT:1:N-GMainLoop:
class N-GMainLoop
  is repr('CPointer')
  is export
  { }
