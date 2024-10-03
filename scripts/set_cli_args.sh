#!/usr/bin/env bash

codecov_cli_args=()

if [ -n "$CODECOV_AUTO_LOAD_PARAMS_FROM" ];
then
  codecov_cli_args+=( " --auto-load-params-from " "${CODECOV_AUTO_LOAD_PARAMS_FROM}" )
fi

if [ -n "$CODECOV_ENTERPRISE_URL" ];
then
  codecov_cli_args+=( " --enterprise-url " "${CODECOV_ENTERPRISE_URL}" )
fi

unset CODECOV_YML_PATH
if [ -n "$CODECOV_YML_PATH" ];
then
  codecov_cli_args+=( " --codecov-yml-path " "${CODECOV_YML_PATH}" )
fi

