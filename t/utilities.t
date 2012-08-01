#!perl

use strict;
use warnings;

use lib 't/lib';
use Test::More;
use Test::Exception;
use Test::Deep;

use DBIx::Class::Helpers::Util ':all';

my ($ns, $class) = get_namespace_parts('Project::Schema::Result::Child');
is $ns, 'Project::Schema::Result',
   'namespace part of get_namespace_parts works';
is $class, 'Child', 'result part of get_namespace_parts works';

($ns, $class) = get_namespace_parts('Project::Schema::Result::HouseHold::Child');
is $ns, 'Project::Schema::Result',
   'namespace part of get_namespace_parts works';
is $class, 'HouseHold::Child', 'result part of get_namespace_parts works';

subtest is_load_namespaces => sub {
   ok is_load_namespaces('P::Result::Foo'),
      'is_load_namespaces works when correct';
   ok !is_load_namespaces('P::Foo'),
      'is_load_namespaces works when incorrect';
   ok is_load_namespaces('P::Result::Foo::Bar'),
         'is_load_namespaces works with two levels namespace';
};

subtest is_not_load_namespaces => sub {
   ok is_not_load_namespaces('P::Foo'),
      'is_not_load_namespaces works correct';
   ok !is_not_load_namespaces('P::Result::Foo'),
      'is_not_load_namespaces works when incorrect';
};

subtest assert_similar_namespaces => sub {
   lives_ok { assert_similar_namespaces('P::Foo', 'L::Bar') }
      'assert_similar_namespaces works when both non-namespace';
   lives_ok { assert_similar_namespaces('P::Result::Foo', 'L::Result::Bar') }
      'assert_similar_namespaces works when both namespace';
   dies_ok { assert_similar_namespaces('P::Foo', 'L::Result::Bar') }
      'assert_similar_namespaces works when right is namespace';
   dies_ok { assert_similar_namespaces('P::Result::Foo', 'L::Bar') }
      'assert_similar_namespaces works when left is namespace';
   lives_ok { assert_similar_namespaces('P::Result::Foo::Bar',  'L::Result::Foo::Bar')}
      'assert_similar_namespaces works with two levels of right namespace';
};

subtest order_by_vistor => sub {
   my $complex_order_by = [
      { -desc => [qw( foo bar )] },
      'baz',
      { -asc => 'biff' }
   ];

   cmp_deeply(
      order_by_visitor($complex_order_by, sub{@_}),
      $complex_order_by,
      'roundtrip'
   );

   cmp_deeply(
      order_by_visitor('frew', sub{'bar'}),
      'bar',
      'simplest ever'
   );

   cmp_deeply(
      order_by_visitor({ -asc => 'foo' }, sub{'bar'}),
      { -asc => 'bar' },
      'simple hash'
   );

   cmp_deeply(
      order_by_visitor([{ -asc => 'foo' }, 'bar'], sub{
         if ($_[0] eq 'foo') {
            return 'foot'
         } else {
            return $_[0]
         }
      }),
      [{ -asc => 'foot' }, 'bar'],
      'typical'
   );

};

done_testing;
