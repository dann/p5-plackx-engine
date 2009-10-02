package PlackX::Engine::Util;
use strict;

sub load_class {
    my ( $class, $prefix ) = @_;

    if ( $class !~ s/^\+// && $prefix ) {
        $class = "$prefix\::$class";
    }

    my $file = $class;
    $file =~ s!::!/!g;
    require "$file.pm";    ## no critic

    return $class;
}

1;

__END__

=encoding utf-8

=head1 NAME

PlackX::Engine::Util - utility

=head1 SYNOPSIS

  use PlackX::Engine::Util;

=head1 DESCRIPTION

PlackX::Engine::Util is the utility class for PlackX::Engine.

=head1 AUTHOR

Takatoshi Kitano E<lt>kitano.tk@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
