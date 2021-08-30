#!/bin/bash

function workoutGitHost {
  # Work out which git host this repository is using
  # e.g. is it github, gitlab, bare, bitbucket etc
  git remote -v show | grep 'github.com'
  if [ $? -eq 0 ]; then
    GITHOST="github"
    GitHubWorkoutRepoOwner
    GitHubWorkoutRepoName
  fi

  git remote -v show | grep 'gitlab.com'
  if [ $? -eq 0 ]; then
    GITHOST="gitlab"
  fi
}

function GitHubWorkoutRepoOwner {
  GITHUB_REPO_OWNER=`git config --get remote.origin.url | cut -d ':' -f 2 | cut -d '/' -f 1 | tail -n 1`
}

function GitHubWorkoutRepoName {
  GITHUB_REPO_NAME=`git config --get remote.origin.url | cut -d '/' -f 2 | cut -d '.' -f 1 | tail -n 1`
}

function listIssues {
  if [ "$GITHOST" = "github" ]; then
    curl -s -u $GITHUB_USERNAME:$GITHUB_ACCESS_TOKEN https://api.github.com/repos/$GITHUB_REPO_OWNER/$GITHUB_REPO_NAME/issues | jq -r '.[] | (.number|tostring) + ":" + .title'

  fi
}

function getListCommand {
  # Work out what they want to list
  #(issues/pull requests? etc)
  if [ "$2" = "issues" ]; then
    listIssues $@
  fi
}

function readIssue {
  if [ "$GITHOST" = "github" ]; then
    curl --silent -u $GITHUB_USERNAME:$GITHUB_ACCESS_TOKEN https://api.github.com/repos/$GITHUB_REPO_OWNER/$GITHUB_REPO_NAME/issues/$3 | jq -r '.body'
  fi
}

function getReadCommand {
  # Work out what they want to read
  #(issues/pull requests? etc)
  if [ "$2" = "issue" ]; then
    readIssue $@
  fi
}

function createIssue {
  echo Enter issue title:
  read issueTitle
  echo Enter issue description:
  read issueDescription

  if [ "$GITHOST" = "github" ]; then
    curl -X POST --silent \
      -u $GITHUB_USERNAME:$GITHUB_ACCESS_TOKEN \
      https://api.github.com/repos/$GITHUB_REPO_OWNER/$GITHUB_REPO_NAME/issues \
      -d '{"title":"'"$issueTitle"'"}'| \
      jq -r '(.number|tostring) + ":" + .title'
  fi

}

function getCreateCommand {
  # Work out what they want to create
  # e.g new issue
  if [ "$2" = "issue" ]; then
    createIssue $@
  fi
}

function closeIssue {
  if [ "$GITHOST" = "github" ]; then
    curl -X PATCH --silent \
      -u $GITHUB_USERNAME:$GITHUB_ACCESS_TOKEN \
      https://api.github.com/repos/$GITHUB_REPO_OWNER/$GITHUB_REPO_NAME/issues/$3 \
      -d '{"state":"closed"}'
  fi

}

function getCloseCommand {
  # Work out what they want to close
  # e.g close issue
  if [ "$2" = "issue" ]; then
    closeIssue $@
  fi
}


function getCommand {
  # Work out what git command they want to run
  # If it's an error from git don't try ang continue
  # otherwise, check if it's a command we've added
  # (e.g. like git list issues)
  exitCode=$?
  if [ $exitCode -gt 2 ]; then
    exit $? # Was probably a error from git, dont continue
  fi
  
  if [ "$1" = "list" ]; then
    getListCommand $@
  fi

  if [ "$1" = "read" ]; then
    getReadCommand $@
  fi

  if [ "$1" = "new" ] || [ "$1" = "create" ]; then
    getCreateCommand $@
  fi

  if [ "$1" = "close" ]; then
    getCloseCommand $@
  fi
}

function mygit {
  workoutGitHost # First work out which git host
  git $@ || getCommand $@
}

mygit $@

