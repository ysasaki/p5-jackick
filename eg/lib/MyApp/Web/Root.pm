package MyApp::Web::Root;

use strict;
use warnings;
use JacKick::Web;

prefix '/';

any '' => sub {
    [ 200, [ 'Content-Type', 'text/plain' ], ['Hello, JacKick!'] ];
};

form 'upload' => [ TextField( name => 'title', required => 1 ) ];

post 'upload' => submitted_and_valid {
    my ( $form, $request, $route ) = @_;

    my $body = sprintf 'title => %s', $form->param('title');
    $request->response( 200, [ 'Content-Type', 'text/plain' ], [$body] );
};

post 'upload' => submitted {
    my ( $form, $request, $route ) = @_;
    my $body = 'title should not be null';
    $request->response( 200, [ 'Content-Type', 'text/plain' ], [$body] );
};

get 'upload' => default {
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

any 'version' => sub {
    [ 200, [ 'Content-Type', 'text/plain' ], ['$JacKick::VERSION => ' . $JacKick::VERSION] ];
};
1;
