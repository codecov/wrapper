#!/usr/bin/env bash

codecov_run_args=()

codecov_run_args+=( $(k_arg BASE_SHA) $(v_arg BASE_SHA))
codecov_run_args+=( $(k_arg PR) $(v_arg PR))
codecov_run_args+=( $(k_arg SLUG) $(v_arg SLUG))
codecov_run_args+=( $(k_arg SERVICE) $(v_arg SERVICE))
