#!/usr/bin/env bash

CODECOV_ARGS+=( $(k_arg SHA) $(v_arg SHA))
CODECOV_ARGS+=( $(write_bool_args CODECOV_FAIL_ON_ERROR) )
CODECOV_ARGS+=( $(k_arg GIT_SERVICE) $(v_arg GIT_SERVICE))
CODECOV_ARGS+=( $(k_arg SLUG) $(v_arg SLUG))
