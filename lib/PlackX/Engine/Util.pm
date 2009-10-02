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
