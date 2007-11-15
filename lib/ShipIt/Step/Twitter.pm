package ShipIt::Step::Twitter;

use strict;
use warnings;
use Net::Twitter;
use YAML 'LoadFile';


our $VERSION = '0.01';


use base qw(ShipIt::Step);


sub init {
    my ($self, $conf) = @_;
    my $config_file = $conf->value('twitter.config');
    defined $config_file || die "twitter.config not defined in config\n";

    $config_file =~ s/~/$ENV{HOME}/;

    -e $config_file || die "twitter.config: $config_file does not exist\n";
    -r $config_file || die "twitter.config: $config_file is not readable\n";

    $self->{config} = LoadFile($config_file);

    defined $self->{config}{username} or
        die "$config_file: no username defined\n";
    defined $self->{config}{password} or
        die "$config_file: no password defined\n";

    my $message = $conf->value('twitter.message');
    defined $message || die "twitter.message not defined in config\n";
    $self->{message} = $message;
}


sub run {
    my ($self, $state) = @_;

    my $version = $state->version;
    (my $message = $self->{message}) =~ s/%v/$version/ge;

    # warn(), don't die(), if we couldn't send the message, because this
    # step will presumably come after uploading to CPAN, so we don't want
    # to skip the rest of the shipit process just because of that.

    if ($state->dry_run) {
        warn "*** DRY RUN, not twittering!\n";
        warn "message: $message\n";
        return;
    }

    my $twitter = Net::Twitter->new(
        username => $self->{config}{username},
        password => $self->{config}{password},
    );

    $twitter->update($message) or warn "couldn't send message to twitter\n";
}


1;


__END__



=head1 NAME

ShipIt::Step::Twitter - ShipIt step to announce to upload on Twitter

=head1 SYNOPSIS

None.

=head1 DESCRIPTION

This L<ShipIt> step announces the upload to Twitter.

To use it, just list it in your C<.shipit> file. You might want to use it
after the C<UploadCPAN> step, as it is not a good idea to announce the
upload before it has gone through - something might go wrong with the upload.

If this step fails - maybe Twitter is down - a warning is issued, but the
shipit process doesn't die. This is because you might have uploaded the
distribution to CPAN already, and it would be a shame for the whole process to
die just because you're not able to twitter.

=head1 CONFIGURATION

In the C<.shipit> file:

    twitter.config = /path/to/config/file
    twitter.message = shipped Foo-Bar %v

You have to define two configuration values for this step.

C<twitter.config> is the location of the file that contains the Twitter
username and password in YAML style. I keep mine in C<~/.twitterrc>. The first
tilde is expanded to the user's home directory. An example file could look
like this:

    username: foobar
    password: flurble

C<twitter.message> is the message to send to Twitter. You can use the
placeholder C<%v>, which will be expanded to the version of the distribution
you're shipping.

=head1 TAGS

If you talk about this module in blogs, on del.icio.us or anywhere else,
please use the C<shipitsteptwitter> tag.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to
C<<bug-shipit-step-twitter@rt.cpan.org>>, or through the web interface at
L<http://rt.cpan.org>.

=head1 INSTALLATION

See perlmodinstall for information and options on installing Perl modules.

=head1 AVAILABILITY

The latest version of this module is available from the Comprehensive Perl
Archive Network (CPAN). Visit <http://www.perl.com/CPAN/> to find a CPAN
site near you. Or see <http://www.perl.com/CPAN/authors/id/M/MA/MARCEL/>.

=head1 AUTHOR

Marcel GrE<uuml>nauer, C<< <marcel@cpan.org> >>

=head1 COPYRIGHT AND LICENSE

Copyright 2007 by Marcel GrE<uuml>nauer

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.


=cut

