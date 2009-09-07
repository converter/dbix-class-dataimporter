package DBIx::Class::DataImporter;
use Moose;
use DBIx::Class::DataImporter::Types qw(
    ImportMapList
);

=head1 NAME

DBIx::Class::Importer

=head1 SYNOPSIS

 package My::Importer;
 use Moose;
 extends 'DBIx::Class::Importer';

 sub lookup_state_id {
    my $state = shift;
    my $id = ...;
    return $id;
 }

 sub find_or_new_zip_id {
     my $zip = shift;
     my $id = ...; # find existing email row or insert new email row, return id
     return $id;
 }

 sub find_or_new_email_id {
     my $email = shift;
     my $id = ...; # find existing email row or insert new email row, return id
     return $id;
 }

 # In your program

 use My::Importer;

 my $imp = My::Importer->new(
    src_schema => $oldschema, dest_schema => $newschema,
    import_maps => [
        {
            map => [
                'orders.code' => 'Order.code',
                'vendor.phone' => \&find_or_new_phone,
                'orders.phone' => \&find_or_new_phone,
            ]
        },
        {
            from_source => 'cust',
            to_source => 'Customer',
            map => [
                name => 'name',
                address1 => 'street1',
                city => 'city',
                state => \&lookup_state_id,
                zip => \&find_or_new_zip_id,
                email => \&find_or_new_email_id,
            ]
        },
    ]
 );

 $imp->import();

=head1 DESCRIPTION

Import data from schema 'src_schema' to schema 'dest_schema' using the maps
defined in the 'import_maps' array.

Use the 'lint' method to sanity check the import maps. Looks for possible
truncation, data loss, unreferenced columns, etc.

=head1 ATTRIBUTES

=cut

=head2 src_schema

The source DBIx::Class::Schema object.

=head2 dest_schema

The destination DBIx::Class::Schema object.

=head2 import_maps

A reference to an array of hash references with optional key-value pairs
'from_source' and 'to_source', specifying source and destination schema
source names, and the required 'map' key-value pair containing an array
with a list of source accessor and destination accessor or a reference
to a callback subroutine.

The callback subroutine will be passed the value from the source data
column.

=over

=item from_source

The schema source from which data are imported.

=item to_source

The schema source to which the imported data are stored.

=item map

A reference to an array of source accessor and target
specifiers. The target specifier may be either a target schema
accessor or a reference to a subroutine. The referent subroutine
will be passed the value of the source column.

=cut

has 'src_schema' => (
    is          => 'ro',
    isa         => 'DBIx::Class::Schema',
    required    => 1,
);

has 'dest_schema' => (
    is          => 'ro',
    isa         => 'DBIx::Class::Schema',
    required    => 1,
);

has 'import_maps' => (
    is          => 'ro',
    isa         => ImportMapList,
    required    => 1,
);

no Moose;
__PACKAGE__->meta->make_immutable();

1;
