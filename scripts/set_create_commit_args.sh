#!/usr/bin/env bash

set -x

codecov_cc_args=()

if [ "$CODECOV_FAIL_ON_ERROR" = "true" ];
then
  codecov_cc_args+=( " --fail-on-error" )
fi

if [ -n "$CODECOV_GIT_SERVICE" ];
then
  codecov_cc_args+=( " --git-service " "${CODECOV_GIT_SERVICE}" )
fi

if [ -n "$CODECOV_PARENT_SHA" ];
then
  codecov_cc_args+=( " --parent-sha " "${CODECOV_PARENT_SHA}" )
fi

if [ -n "$CODECOV_PULL_REQUEST" ];
then
  codecov_cc_args+=( " --pr " "${CODECOV_PULL_REQUEST}" )
fi

if [ -n "$CODECOV_SHA" ];
then
  codecov_cc_args+=( " --sha " "${CODECOV_SHA}" )
fi

if [ -n "$CODECOV_SLUG" ];
then
  codecov_cc_args+=( " --slug " "${CODECOV_SLUG}" )
fi
