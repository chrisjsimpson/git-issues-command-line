#!/bin/bash

set -x

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
  echo Listing issues from $GITHOST
  if [ "$GITHOST" = "github" ]; then
    curl --silent -u $GITHUB_USERNAME:$GITHUB_ACCESS_TOKEN https://api.github.com/repos/$GITHUB_REPO_OWNER/$GITHUB_REPO_NAME/issues | jq -r '.[] | (.number|tostring) + ":" + .title'
  fi
}

function getListCommand {
  # Work out what they want to list
  #(issues/pull requests? etc)
  echo You want to list $2 from $GITHOST
  if [ "$2" = "issues" ]; then
    listIssues $@
  fi
}

function getCommand {
  # Work out what git command they want to run
  # If it's an error from git don't try ang continue
  # otherwise, check if it's a command we've added
  # (e.g. like git list issues)
  exitCode=$?
  echo The exit code was $exitCode
  if [ $exitCode -gt 2 ]; then
    exit $? # Was probably a error from git, dont continue
  fi
  echo "working out what you want to do $1"
  
  if [ "$1" = "list" ]; then
    echo You want to list something
    getListCommand $@
  fi
}

function mygit {
  echo This is not really git
  echo $0
  echo ${FUNCNAME}
  workoutGitHost # First work out which git host
  git $@ || getCommand $@
}

mygit $@

