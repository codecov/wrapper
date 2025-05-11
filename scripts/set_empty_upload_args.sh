#!/usr/bin/env bash

CODECOV_ARGS+=( $(k_arg BRANCH) $(v_arg BRANCH))
CODECOV_ARGS+=( $(write_bool_args CODECOV_FAIL_ON_ERROR) )
CODECOV_ARGS+=( $(write_bool_args CODECOV_FORCE) )
CODECOV_ARGS+=( $(k_arg GIT_SERVICE) $(v_arg GIT_SERVICE))
CODECOV_ARGS+=( $(k_arg PARENT_SHA) $(v_arg PARENT_SHA))
CODECOV_ARGS+=( $(k_arg PR) $(v_arg PR))
CODECOV_ARGS+=( $(k_arg SHA) $(v_arg SHA))
CODECOV_ARGS+=( $(k_arg SLUG) $(v_arg SLUG))
