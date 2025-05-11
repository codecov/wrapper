#!/usr/bin/env bash

CODECOV_ARGS+=( $(k_arg BASE_SHA) $(v_arg BASE_SHA))
CODECOV_ARGS+=( $(k_arg PR) $(v_arg PR))
CODECOV_ARGS+=( $(k_arg SLUG) $(v_arg SLUG))
CODECOV_ARGS+=( $(k_arg SERVICE) $(v_arg SERVICE))
