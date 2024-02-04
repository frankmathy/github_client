# github_client

Simple Github client with OAuth2.

## Getting Started

This is based on a Google codelab:

- [Lab: Write a Flutter desktop application](https://codelabs.developers.google.com/codelabs/flutter-github-client)
- To run it, you need to add a lib/src/github_oauth_credentials.dart file with the following contents:

```
const githubClientId = '<clientId>';
const githubClientSecret = '<secret>';

// OAuth scopes for repository and user information
const githubScopes = ['repo', 'read:org'];
```
