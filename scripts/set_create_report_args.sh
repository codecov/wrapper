#!/usr/bin/env bash

codecov_create_report_args=()

codecov_cr_args+=( $(k_arg CODE) $(v_arg CODE))
codecov_cr_args+=( $(write_truthy_args CODECOV_FAIL_ON_ERROR) )
codecov_cr_args+=( $(k_arg GIT_SERVICE) $(v_arg GIT_SERVICE))
codecov_cr_args+=( $(k_arg PR) $(v_arg PR))
codecov_cr_args+=( $(k_arg SHA) $(v_arg SHA))
codecov_cr_args+=( $(k_arg SLUG) $(v_arg SLUG))
