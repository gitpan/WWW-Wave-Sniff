=head1 NAME

WWW::Wave::Sniff - Sniff info from your Google Wave Inbox

=head1 SYNOPSYS

use WWW::Wave::Sniff;

my $ws = WWW::Wave::Sniff->new( username => 'bof@gmail.com',
                                password => '1234' );

print 'You have : '. $ws->unread_count . ' unread waves.';


=head1 DESCRIPTION

Crude wave inbox sniffer. Logs in to your google wave account grabs the JSON data and uses it to check your unread wave count.

=head1 RELIABILITY WARNING

This library relies on google's wacky minified JSON format not changing, so it could actually break at any time!


=head1 CONSTRUCTOR

=head2 REQUIRED PARAMETERS

=head3 username

Your google wave username.

=head3 password

Your google wave password.

=head2 OPTIONAL PARAMETERS

=head3 user_agent

An LWP::UserAgent to use instead of making our own.

=head1 METHODS

=cut
package WWW::Wave::Sniff;

use Moose;

use LWP::UserAgent;
use Readonly;
use JSON;

our $VERSION = '0.1';

# properties:
has 'username' => (
    is => 'ro',
    required => 1,
    isa => 'Str',
);
has 'password' => (
    is => 'ro',
    required => 1,
    isa => 'Str',
);
has 'user_agent' => (
    is => 'ro',
    isa => 'LWP::UserAgent',
    lazy => 1,
    builder => '_ua'
);
sub _ua{ LWP::UserAgent->new; }

# URLs
Readonly my $PROTO => 'https';
Readonly my $WAVE_INBOX_URI => "$PROTO://wave.google.com/wave";
Readonly my $WAVE_LOGIN_URI => "$PROTO://www.google.com/accounts/ClientLogin";

sub get_wave_info{
    my $self = shift;
    my $ua = $self->user_agent;

    # log in to google:
    my $l_rsp = $ua->post( $WAVE_LOGIN_URI, { Email => $self->username,
                                              Passwd => $self->password,
                                              accountType	=> 'GOOGLE',
                                              service => 'wave',
                                              source		=> __PACKAGE__,
                                          } );
    # fail?
    $l_rsp->is_success
          or die 'Could not login to google: '. $l_rsp->status_line;



    # grab the auth token from the response:
    my $at = _get_auth_token( $l_rsp->content );

    # fail?
    $at or die 'Could not find an authorization token in'
              .' google\'s reponse to a login attempt.';


    push @{ $ua->requests_redirectable }, 'POST';
    # get wave inbox!
    my $ib_rsp = $ua->post( $WAVE_INBOX_URI,
                            {
                                nouacheck => 1,
                                auth => $at });

    # fail?
    $ib_rsp->is_success or die 'Could not get wave inbox: '
                               . $ib_rsp->status_line;

    # pull the JSON string out of the response:
    my $json_string = _grab_json( $ib_rsp->content );

    $json_string or die 'could not find json in response';

    my $wave_ib_data = from_json( $json_string );

    #fail?
    $wave_ib_data or die 'Could not parse JSON response';

    # This is where I give thanks to the firefox extension!


    my $in = $wave_ib_data->{p}->{1};

    $in or die 'Could not find the inbox data in JSON response. Format changed?';

    my $unread = 0;
    foreach my $wave (  @{ $in } ){
        if( $wave->{7} && $wave->{7} =~ /^\d+$/ ){
            $unread++;
        }
    }

    return { unread => $unread };
}

=head2 unread_count

Probes your wave account and extracts the number of unread waves.

Should hopefully die with a useful message on errors.

=cut
sub unread_count{
    my $self = shift;

    if( my $wi = $self->get_wave_info ){
        return $wi->{unread};
    }

    return;
}

#
# Little utility task funtions:
#

sub _get_auth_token{
    my $response_body = shift;
    my ($at) = ( $response_body =~ /Auth=(.+)$/oi );
    return $at;
}
sub _grab_json{
    my $response_body = shift;

    # todo: a less crude method of extraction?
    my $recognisable_fragment = '\{"r":"\^d1"';
    my ($json) = ( $response_body =~ /json\s*=\s*($recognisable_fragment.+?});/ois );
    return $json;
}

no Moose;
;1;

=head1 THANKS TO..

The code of "thatsmith"'s wave notifier plugin for Firefox which helped me
navigate google's JSON data.


=head1 AUTHOR

Joe Higton

=head1 COPYRIGHT

Copyright 2009 Joe Higton

This program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself. 

=cut
