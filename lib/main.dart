import 'package:flutter/material.dart';
import 'package:github_client/src/github_oauth_credentials.dart';
import 'src/github_login.dart';
import 'package:github/github.dart';
import 'package:window_to_front/window_to_front.dart';
import 'src/github_summary.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GitHub Client',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'GitHub Client'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return GithubLoginWidget(
        builder: (context, httpClient) {
          WindowToFront.activate();
          return FutureBuilder<CurrentUser>(
            future: viewerDetail(httpClient.credentials.accessToken),
            builder: (context, snapshot) {
              return Scaffold(
                  appBar: AppBar(
                    title: Text(title),
                    elevation: 2,
                  ),
                  body: GitHubSummary(
                      gitHub: getGitHub(httpClient.credentials.accessToken)));
            },
          );
        },
        githubClientId: githubClientId,
        githubClientSecret: githubClientSecret,
        githubScopes: githubScopes);
  }
}

Future<CurrentUser> viewerDetail(String accessToken) async {
  final gitHub = GitHub(auth: Authentication.withToken(accessToken));
  return gitHub.users.getCurrentUser();
}

GitHub getGitHub(String accessToken) {
  return GitHub(auth: Authentication.withToken(accessToken));
}
