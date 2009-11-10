package OurFakeLWP;

use OurFakeResponse;
use Moose;

use base 'LWP::UserAgent';

has 'requests_redirectable' => ( is => 'ro', default => sub{ [] } );
has 'response_bodies' => ( is => 'ro' );

sub post{
    my $self = shift;
    return OurFakeResponse->new( content => shift @{$self->response_bodies} );
}

;1;
