
use lib qw< t >;
use Test::More tests => 1;

use WWW::Wave::Sniff;
use OurFakeLWP;

my $resp;

open( R, 't/two.html' );
$resp = join '', <R>;
close(R);

my $ua = OurFakeLWP->new( response_bodies =>  [ 'Auth=boo', $resp ]  );

my $ws = WWW::Wave::Sniff->new( username => 'foo', password => 'foo',
                                user_agent => $ua );

is( $ws->unread_count, 2, 'Wave sniff gets valid response to the two data' );
