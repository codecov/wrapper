#!/usr/bin/env bash

codecov_cc_args=()

codecov_cc_args+=( $(write_truthy_args CODECOV_FAIL_ON_ERROR) )
codecov_cc_args+=( $(k_arg GIT_SERVICE) $(v_arg GIT_SERVICE))
codecov_cc_args+=( $(k_arg PARENT_SHA) $(v_arg PARENT_SHA))
codecov_cc_args+=( $(k_arg PR) $(v_arg PR))
codecov_cc_args+=( $(k_arg SHA) $(v_arg SHA))
codecov_cc_args+=( $(k_arg SLUG) $(v_arg SLUG))
