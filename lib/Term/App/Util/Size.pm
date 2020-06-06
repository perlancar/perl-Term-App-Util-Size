package Term::App::Util::Size;

# AUTHORITY
# DATE
# DIST
# VERSION

use strict;
use warnings;

our %SPEC;

$SPEC{':package'} = {
    v => 1.1,
    summary => 'Determine the sane terminal size (width, height)',
};

my $termw_cache;
my $termh_cache;
sub _termattr_size {
    my $self = shift;

    if (defined $termw_cache) {
        return ($termw_cache, $termh_cache);
    }

    ($termw_cache, $termh_cache) = (0, 0);
    if (eval { require Term::Size; 1 }) {
        ($termw_cache, $termh_cache) = Term::Size::chars(*STDOUT{IO});
    }
    ($termw_cache, $termh_cache);
}

$SPEC{term_width} = {
    v => 1.1,
    args => {},
    description => <<'_',

Try to determine the sane terminal width. First will observe the COLUMNS
environment variable, and use it if defined. Otherwise will try to use
<pm:Term::Size> to determine the terminal size and use the result if succeed.
Otherwise will use the default value of 80 (79 on Windows).

_
};
sub term_width {
    my $res = [200, "OK", undef, {}];

    if ($ENV{COLUMNS}) {
        $res->[2] = $ENV{COLUMNS};
        $res->[3]{'func.debug_info'}{term_width_from} = 'COLUMNS env';
        goto RETURN_RES;
    }
    my ($termw, undef) = _termattr_size();
    if ($termw) {
        $res->[2] = $termw;
        $res->[3]{'func.debug_info'}{term_width_from} = 'term_size';
        goto RETURN_RES;
    } else {
        # sane default, on windows printing to rightmost column causes cursor to
        # move to the next line.
        $res->[2] = $^O =~ /Win/ ? 79 : 80;
        $res->[3]{'func.debug_info'}{term_width_from} = 'default';
        goto RETURN_RES;
    }

  RETURN_RES:
    $res;
}

$SPEC{term_height} = {
    v => 1.1,
    args => {},
    description => <<'_',

Try to determine the sane terminal height. First will observe the LINES
environment variable, and use it if defined. Otherwise will try to use
<pm:Term::Size> to determine the terminal size and use the result if succeed.
Otherwise will use the default value of 25.

_
};
sub term_height {
    my $res = [200, "OK", undef, {}];

    if ($ENV{LINES}) {
        $res->[2] = $ENV{LINES};
        $res->[3]{'func.debug_info'}{term_height_from} = 'LINES env';
        goto RETURN_RES;
    }
    my (undef, $termh) = _termattr_size();
    if ($termh) {
        $res->[2] = $termh;
        $res->[3]{'func.debug_info'}{term_height_from} = 'term_size';
        goto RETURN_RES;
    } else {
        $res->[2] = 25; # sane default
        $res->[3]{'func.debug_info'}{term_height_from} = 'default';
        goto RETURN_RES;
    }

  RETURN_RES:
    $res;
}

1;
# ABSTRACT:

=head1 DESCRIPTION


=head1 ENVIRONMENT

=head2 COLUMNS

=head2 LINES


=head1 SEE ALSO

Other C<Term::App::Util::*> modules.

L<Term::Size>
