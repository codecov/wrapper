#!/usr/bin/env bash

codecov_create_commit_args=()

if [ -n "$CODECOV_BRANCH" ];
then
  codecov_create_commit_args+=( " --branch " "${CODECOV_BRANCH}" )
fi

if [ "$CODECOV_FAIL_ON_ERROR" = "true" ];
then
  codecov_create_commit_args+=( " --fail-on-error" )
fi

if [ -n "$CODECOV_GIT_SERVICE" ];
then
  codecov_create_commit_args+=( " --git-service " "${CODECOV_GIT_SERVICE}" )
fi

if [ -n "$CODECOV_PARENT_SHA" ];
then
  codecov_create_commit_args+=( " --parent-sha " "${CODECOV_PARENT_SHA}" )
fi

if [ -n "$CODECOV_PULL_REQUEST" ];
then
  codecov_create_commit_args+=( " --pr " "${CODECOV_PULL_REQUEST}" )
fi

if [ -n "$CODECOV_SHA" ];
then
  codecov_create_commit_args+=( " --sha " "${CODECOV_SHA}" )
fi

if [ -n "$CODECOV_SLUG" ];
then
  codecov_create_commit_args+=( " --slug " "${CODECOV_SLUG}" )
fi
