#!/usr/bin/perl

use strict;
use warnings;

use Mojolicious::Lite;
use File::Slurp;
use Math::Round;
use JSON;

my @supTypes = @{decode_json(read_file("types/types.json"))->{types}};

my $headers = qq{
<!DOCTYPE html>
<html>
	<head>
		<title>Lifestyle</title>
        <meta name="viewport" content="user-scalable=no, initial-scale=1, maximum-scale=1, minimum-scale=1, width=device-width, height=device-height, target-densitydpi=device-dpi" />
		<script type="text/javascript" src="../js/jquery.js"></script>
	</head>
	<body>
};

my $endheaders = qq{
	</body>
</html>
};

get '/' => sub {
    my $self = shift;
    my $formData = "";

    foreach my $supType (@supTypes) {
        $formData .= "
        <b>$supType:</b>
        <form>
            <input id=\"${supType}_amt\">
            <button type='button' id='${supType}'>save</button>
        </form>\n
        <p>Current: <span id='${supType}_current'>0.0</span>mg</p>
        <hr>
        ";
    }

	$self->render( text => qq{
		$headers
		<script type="text/javascript" src="../js/script.js"></script>
        <script type="text/javascript">
        // path to script.js gets messed up if we don't add lagging fslash
        var c = (window.location.pathname).substr(-1);
        if (c.valueOf() != "/".valueOf()) {
            window.location.href = window.location.pathname + "/";
        }
        </script>

        <!-- begin form datas -->
		$formData
        <!-- end form datas -->

        <b>New Type:</b><br/>(need to manually remove them, so please don't mess up)
        <form>
            Name: <input id="new_name" placeholder="Only Letters/Numbers!"><br/>
            HalfLife: <input id="new_hl" placeholder="In Seconds!"><br/>
            <button type='button' id='newNameSave'>create</button>
        </form>\n
        <hr>\n\n

		$endheaders
	});
};
 
post '/did' => sub {
    my $self = shift;

    my $amt = $self->param('amt');
    $amt = 0 if($self->param('amt') eq "" || !defined($self->param('amt')));

    my $type = $self->param('type');
    $type = "caffeine", $amt = 0 if($self->param('type') eq "" || !defined($self->param('type')));

    my $time = time;
    $self->render( text => qq{
        $headers
        <h3>Saved amount of ${type} you did: ${amt}mg at timestamp ($time)</h3>\n
        $endheaders
    });

    if ($amt =~ /(\d+)/ ) {
        my $currentDid = decode_json(read_file("types/${type}/amt.json"));
        my $newIndex = scalar @{$currentDid->{data}};
        $currentDid->{data}[$newIndex]{time} = $time;
        $currentDid->{data}[$newIndex]{amount} = $amt;
        $currentDid = encode_json($currentDid);
        write_file("types/${type}/amt.json", $currentDid);
    }
};

get '/howmuch' => sub {
    my $self = shift;

    my $type = $self->param('type');
    $type = "Caffeine" if($self->param('type') eq "" || !defined($self->param('type')));

    if ($type =~ /^all$/) {
        my $totals = "{";
        foreach my $newType (@supTypes) {
            my $amountInSystem = 0;
            my $doseData = decode_json(read_file("types/${newType}/amt.json"));
            my $halflife = decode_json(read_file("types/${newType}/info.json"))->{halflife};
            for (my $i = 0; $i < scalar(@{$doseData->{data}}); $i++) {
                my $timesince = time - $doseData->{data}[$i]{time};
                $amountInSystem += ($doseData->{data}[$i]{amount} * exp(((log(.5)/$halflife) * $timesince)));
            }
            $amountInSystem = nearest(.001, $amountInSystem);
            $totals .= "\"$newType\":$amountInSystem,";
        }
        $self->render(text => qq{$totals"dummy":0\}});
    }
    else {
        $self->render(text => qq{error});
    }
};

post '/makenew' => sub {
    my $self = shift;

    my $name = $self->param('name');
    my $hl = $self->param('hl');

    # write it to the types .json
    my $typeData = decode_json(read_file("types/types.json"));
    $typeData->{types}[scalar(@{$typeData->{types}})] = $name;
    write_file("types/types.json", encode_json($typeData));

    # now create a directory for it, with the halflife
    mkdir "types/" . $name unless -d "types/" . $name;
    chmod(0777, "types/" . $name) or die "Couldn't chmod: $!";
    write_file("types/" . $name . "/info.json", "{\"halflife\":\"" . $hl . "\"}");
    write_file("types/" . $name . "/amt.json", "{\"data\" : [{\"amount\" : 0, \"time\" : ".time()."}]}");

    $self->render(text => qq{success});
};
 
app->secrets(['password']);
app->start;

__DATA__
@@ not_found.html.ep
<!DOCTYPE html>
<html>
  <head><title>Page not found</title></head>
  <body>Page not found <%= $status %></body>
</html>