#!/usr/bin/env bash

codecov_create_report_args=()

if [ -n "$CODECOV_CODE" ];
then
  codecov_cr_args+=( " --code " "${CODECOV_CODE}" )
fi

if [ "$CODECOV_FAIL_ON_ERROR" = "true" ];
then
  codecov_cr_args+=( " --fail-on-error" )
fi

if [ -n "$CODECOV_GIT_SERVICE" ];
then
  codecov_cr_args+=( " --git-service " "${CODECOV_GIT_SERVICE}" )
fi

if [ -n "$CODECOV_PULL_REQUEST" ];
then
  codecov_cr_args+=( " --pr " "${CODECOV_PULL_REQUEST}" )
fi

if [ -n "$CODECOV_SHA" ];
then
  codecov_cr_args+=( " --sha " "${CODECOV_SHA}" )
fi

if [ -n "$CODECOV_SLUG" ];
then
  codecov_cr_args+=( " --slug " "${CODECOV_SLUG}" )
fi
