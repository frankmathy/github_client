import 'package:flutter/material.dart';
import 'package:fluttericon/octicons_icons.dart';
import 'package:github/github.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class GitHubSummary extends StatefulWidget {
  const GitHubSummary({required this.gitHub, super.key});
  final GitHub gitHub;

  @override
  State<StatefulWidget> createState() => GitHubSummaryState();
}

class GitHubSummaryState extends State<GitHubSummary> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        NavigationRail(
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) {
            setState(() {
              selectedIndex = index;
            });
          },
          labelType: NavigationRailLabelType.selected,
          destinations: const [
            NavigationRailDestination(
                icon: Icon(Octicons.repo), label: Text('Repositories')),
            NavigationRailDestination(
                icon: Icon(Octicons.issue_opened),
                label: Text('Assigned Issues')),
            NavigationRailDestination(
                icon: Icon(Octicons.git_pull_request),
                label: Text('Pull Requests')),
          ],
        ),
        const VerticalDivider(
          thickness: 1,
          width: 1,
        ),
        Expanded(
            child: IndexedStack(
          index: selectedIndex,
          children: [
            RepositoriesList(gitHub: widget.gitHub),
            RepositoriesList(gitHub: widget.gitHub),
            RepositoriesList(gitHub: widget.gitHub),
          ],
        ))
      ],
    );
  }
}

class RepositoriesList extends StatefulWidget {
  const RepositoriesList({required this.gitHub, super.key});
  final GitHub gitHub;

  @override
  State<StatefulWidget> createState() => RepositoriesListState();
}

class RepositoriesListState extends State<RepositoriesList> {
  @override
  void initState() {
    super.initState();
    repositories = widget.gitHub.repositories.listRepositories().toList();
  }

  late Future<List<Repository>> repositories;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Repository>>(
      future: repositories,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var repositories = snapshot.data;
        return ListView.builder(
            primary: false,
            itemBuilder: (context, index) {
              var repository = repositories![index];
              return ListTile(
                title:
                    Text('${repository.owner?.login ?? ''}/${repository.name}'),
                subtitle: Text(repository.description),
                onTap: () => launchUrl(this, repository.htmlUrl),
              );
            });
      },
    );
  }
}

Future<void> launchUrl(State state, String url) async {
  if (await canLaunchUrlString(url)) {
    await launchUrlString(url);
  } else {
    if (state.mounted) {
      return showDialog(
          context: state.context,
          builder: (context) => AlertDialog(
                title: const Text('Navigation error'),
                content: Text('Could not launch $url'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Close'),
                  )
                ],
              ));
    }
  }
}
