package Devel::REPL::Plugin::Nopaste;

use Moose::Role;
use MooseX::AttributeHelpers;
use namespace::clean -except => [ 'meta' ];

with 'Devel::REPL::Plugin::Turtles';

has complete_session => (
    metaclass => 'String',
    is        => 'rw',
    isa       => 'Str',
    default   => '',
    provides  => {
        append => 'add_to_session',
    },
);

before eval => sub {
    my $self = shift;
    my $line = shift;

    # prepend each line with #
    $line =~ s/^/# /mg;

    $self->add_to_session($line . "\n");
};

around eval => sub {
    my $orig = shift;
    my $self = shift;
    my $line = shift;

    my @ret = $orig->($self, $line, @_);

    $self->add_to_session(join("\n", @ret) . "\n\n");

    return @ret;
};

sub command_nopaste {
    my $self = shift;

    require App::Nopaste;
    return App::Nopaste->nopaste(
        text => $self->complete_session,
        desc => "Devel::REPL session",
        lang => "perl",
    );
}

1;
