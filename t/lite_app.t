use Mojolicious::Lite;
use Test::More;
use Test::Mojo;

plugin 'Subprocess';

get '/' => sub {
  my $c = shift;
  $c->subprocess(sub {
    die $$ if $c->param('die') and $c->param('die') == 1;
    return $$;
  }, sub {
    my ($c, $pid) = @_;
    die $$ if $c->param('die') and $c->param('die') == 2;
    $c->render(json => {child => $pid, parent => $$});
  });
};

my $t = Test::Mojo->new;

$t->get_ok('/')->status_is(200);
my $j = $t->tx->res->json;
cmp_ok $j->{child}, '!=', $j->{parent}, 'first sub run in subprocess';
cmp_ok $j->{parent}, '==', $$, 'second sub run in parent process';

$t->get_ok('/?die=1')->status_is(500);
$t->get_ok('/?die=2')->status_is(500);

done_testing;
