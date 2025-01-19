#!/usr/bin/env bash

codecov_run_args=()

codecov_run_args+=( $(k_arg SHA) $(v_arg SHA))
codecov_run_args+=( $(write_truthy_args CODECOV_FAIL_ON_ERROR) )
codecov_run_args+=( $(k_arg GIT_SERVICE) $(v_arg GIT_SERVICE))
codecov_run_args+=( $(k_arg SLUG) $(v_arg SLUG))
