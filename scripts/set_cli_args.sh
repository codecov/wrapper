#!/usr/bin/env bash

codecov_cli_args=()

codecov_cli_args+=( $(k_arg AUTO_LOAD_PARAMS_FROM) $(v_arg AUTO_LOAD_PARAMS_FROM))
codecov_cli_args+=( $(k_arg ENTERPRISE_URL) $(v_arg ENTERPRISE_URL))
codecov_cli_args+=( $(k_arg YML_PATH) $(v_arg YML_PATH))
codecov_cli_args+=( $(write_truthy_args CODECOV_VERBOSE) )
