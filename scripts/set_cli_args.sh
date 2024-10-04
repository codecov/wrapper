#!/usr/bin/env bash

codecov_cli_args=()

codecov_cli_args+=( $(write_existing_args CODECOV_AUTO_LOAD_PARAMS_FROM) )
codecov_cli_args+=( $(write_existing_args CODECOV_ENTERPRISE_URL) )
codecov_cli_args+=( $(write_existing_args CODECOV_YML_PATH) )
