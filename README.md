# github_client

Simple Github client with OAuth2.

## Getting Started

This is based on a Google codelab:

- [Lab: Write a Flutter desktop application](https://codelabs.developers.google.com/codelabs/flutter-github-client)
- To run it, you need to add a lib/src/github_oauth_credentials.dart file with the following contents:

```
const githubClientId = '59e01d211613fb1fe9b8';
const githubClientSecret = '39cb74e974018aafe1167459055154bb8f95acfb';

// OAuth scopes for repository and user information
const githubScopes = ['repo', 'read:org'];
```
