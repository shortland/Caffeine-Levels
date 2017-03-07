#!/usr/bin/perl

use strict;
use warnings;

use Mojolicious::Lite;
use File::Slurp;
use Math::Round;

our $headers = qq{
<!DOCTYPE html>
<html>
	<head>
		<title>Coffee</title>
	</head>
	<body>
};

our $endheaders = qq{
	</body>
</html>
};

get '/' => sub {
    my $self = shift;
    #400e^((ln(1/2)/6)*(24))
    #my $timesince = current unix time - unix time taken;
    my $timesince = 24;
    my $dosage = 400;
    #my $res = $dosage * exp(((log(.5)/21600) * $timesince));

    my $amountInSystem = 0;
    my @doses = split(/\|/, read_file("data.txt"));
    for (my $i = 0; $i < scalar(@doses); $i++) {
    	my @diffDatas = split(/\,/, $doses[$i]);
    	my $timesince = time - $diffDatas[1];
    	$amountInSystem += ($diffDatas[0] * exp(((log(.5)/21600) * $timesince)));
    }
    $amountInSystem = nearest(.001, $amountInSystem);
	$self->render( text => qq{
		$headers

		<h3>New amount you did:</h3> 
		
		<form method="POST">
			<input name="amt">
			<input type="submit" value="post">
		</form>

		<br/><br/>

		<hr>

		<br/>

		<h3>Current amount in your system: $amountInSystem</h3>

		$endheaders
	});
};
 
post '/' => sub {
    my $self = shift;

    my $amt = $self->param('amt');
    my $time = time;
	$self->render( text => qq{
		$headers
		<h3>Saved amount you did: ${amt}mg at timestamp ($time)</h3> 
		$endheaders
	});

	append_file("data.txt", "$amt,$time|")
};
 
app->secrets(['lego1998']);
app->start;

__DATA__
@@ not_found.html.ep
<!DOCTYPE html>
<html>
  <head><title>Page not found</title></head>
  <body>Page not found <%= $status %></body>
</html>