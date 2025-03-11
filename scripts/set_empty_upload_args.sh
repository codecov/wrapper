#!/usr/bin/env bash

codecov_args+=( $(k_arg BRANCH) $(v_arg BRANCH))
codecov_args+=( $(write_bool_args CODECOV_FAIL_ON_ERROR) )
codecov_args+=( $(write_bool_args CODECOV_FORCE) )
codecov_args+=( $(k_arg GIT_SERVICE) $(v_arg GIT_SERVICE))
codecov_args+=( $(k_arg PARENT_SHA) $(v_arg PARENT_SHA))
codecov_args+=( $(k_arg PR) $(v_arg PR))
codecov_args+=( $(k_arg SHA) $(v_arg SHA))
codecov_args+=( $(k_arg SLUG) $(v_arg SLUG))
