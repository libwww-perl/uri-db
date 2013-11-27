package URI::db::unify;
use base 'URI::db';
our $VERSION = '0.10';

sub default_port  { 27117 }
sub is_file_based { 1 }
sub dbi_driver    { 'Unify' }

sub _dbi_param_map { }

sub dbi_dsn {
    my $self = shift;
    return join ':' => 'dbi', $self->dbi_driver,
           join ';' => $self->dbname, ($self->_dsn_params || ());
}

1;
