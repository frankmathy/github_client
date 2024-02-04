import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:url_launcher/url_launcher.dart';

final authorisationEndpoint =
    Uri.parse('https://github.com/login/oauth/authorize');
final tokenEndpoint = Uri.parse('https://github.com/login/oauth/access_token');

class GithubLoginWidget extends StatefulWidget {
  const GithubLoginWidget({
    required this.builder,
    required this.githubClientId,
    required this.githubClientSecret,
    required this.githubScopes,
    super.key,
  });
  final AuthenticatedBuilder builder;
  final String githubClientId;
  final String githubClientSecret;
  final List<String> githubScopes;

  @override
  State<GithubLoginWidget> createState() => GithubLoginState();
}

typedef AuthenticatedBuilder = Widget Function(
    BuildContext context, oauth2.Client client);

class GithubLoginState extends State<GithubLoginWidget> {
  HttpServer? _redirectServer;
  oauth2.Client? _client;

  @override
  Widget build(BuildContext context) {
    final client = _client;
    if (client != null) {
      return widget.builder(context, client);
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Github Login'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              await _redirectServer?.close();
              _redirectServer = await HttpServer.bind('localhost', 0);
              var authenticatedHttpClient = await getOAuth2Client(
                  Uri.parse('http://localhost:${_redirectServer!.port}/auth'));
              setState(() {
                _client = authenticatedHttpClient;
              });
            },
            child: const Text('Login to Github'),
          ),
        ));
  }

  Future<oauth2.Client> getOAuth2Client(Uri redirectUrl) async {
    if (widget.githubClientId.isEmpty || widget.githubClientSecret.isEmpty) {
      throw const GithubLoginException(
          'githubClientId and githubClientSecret must be not empty. '
          'See `lib/github_oauth_credentials.dart` for more detail.');
    }
    var grant = oauth2.AuthorizationCodeGrant(
        widget.githubClientId, authorisationEndpoint, tokenEndpoint,
        secret: widget.githubClientSecret,
        httpClient: JsonAcceptingHttpClient());
    var authorisationUrl =
        grant.getAuthorizationUrl(redirectUrl, scopes: widget.githubScopes);
    await redirect(authorisationUrl);
    var responseQueryParameters = await listen();
    var client =
        await grant.handleAuthorizationResponse(responseQueryParameters);
    return client;
  }

  Future<void> redirect(Uri authorisationUrl) async {
    if (await canLaunchUrl(authorisationUrl)) {
      await launchUrl(authorisationUrl);
    } else {
      throw GithubLoginException('Could not launch $authorisationUrl');
    }
  }

  Future<Map<String, String>> listen() async {
    var request = await _redirectServer!.first;
    var params = request.uri.queryParameters;
    request.response.statusCode = 200;
    request.response.headers.set('content-type', 'text/plain');
    request.response.writeln('Authenticated! You can close this tab.');
    await request.response.close();
    await _redirectServer!.close();
    return params;
  }
}

class JsonAcceptingHttpClient extends http.BaseClient {
  final httpClient = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Accept'] = 'application/json';
    return httpClient.send(request);
  }
}

class GithubLoginException implements Exception {
  const GithubLoginException(this.message);
  final String message;
  @override
  String toString() => message;
}
