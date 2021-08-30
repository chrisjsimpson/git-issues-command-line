# git issues cli

A `git` cli wrapper to add `git list issues` and more for
any git hosting provider (github/gitlab/bitbucket etc).

- Listing issues/pull requests with `git list issues`

# Installation

```
curl -L https://raw.githubusercontent.com/chrisjsimpson/git-issues-command-line/main/git.sh > $HOME/.local/bin/giti
```

```
alias git=$HOME/.local/bin/giti
chmod +x $HOME/.local/bin/giti
```

# Usage

```
git list issues
```

# Uninstall
```
rm $HOME/.local/bin/giti
unalias git
```

## Authentication

If working with a private repo:

### GitHub

```
export GITHUB_USERNAME=<yourusername>
```

export GITHUB_ACCESS_TOKEN=<[access token]("https://docs.github.com/en/github/authenticating-to-github/keeping-your-account-and-data-secure/creating-a-personal-access-token")>
