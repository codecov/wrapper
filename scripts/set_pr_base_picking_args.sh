#!/usr/bin/env bash

codecov_args=()

codecov_args+=( $(k_arg BASE_SHA) $(v_arg BASE_SHA))
codecov_args+=( $(k_arg PR) $(v_arg PR))
codecov_args+=( $(k_arg SLUG) $(v_arg SLUG))
codecov_args+=( $(k_arg SERVICE) $(v_arg SERVICE))
