package OurFakeResponse;

use Moose;

has 'is_success' => ( default => 1, is => 'rw' );
has 'content' => ( default => 1, is => 'rw' );

;1;
