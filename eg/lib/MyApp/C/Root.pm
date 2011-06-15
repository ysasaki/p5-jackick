package MyApp::C::Root;

use strict;
use warnings;
use Koashi::Controller;

prefix '';

any '/' => sub {
    [ 200, [ 'Content-Type', 'text/plain' ], ['Hello, Koashi!'] ];
};

form '/upload' => [ TextField( name => 'title', required => 1 ) ];

post '/upload' => submitted_and_valid {
    my ( $form, $request, $route ) = @_;

    my $body = sprintf 'title => %s', $form->param('title');
    $request->response( 200, [ 'Content-Type', 'text/plain' ], [$body] );
};

post '/upload' => submitted {
    my ( $form, $request, $route ) = @_;
    my $body = 'title must be null';
    $request->response( 200, [ 'Content-Type', 'text/plain' ], [$body] );
};

# does not work yet
get '/upload' => default {
    my ( $request, $route ) = @_;
    my $body = <<HTML;
<!DOCTYPE HTML>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<title>upload</title>
</head>
<body>
	<form action="/upload" method="post">
		Title: <input name="title" type="text" />
		<input type="submit" value="Submit" />
	</form>
</body>
</html>
HTML

    $request->response( 200, [ 'Content-Type', 'text/html; charset=utf-8' ], [$body] );
};
1;
