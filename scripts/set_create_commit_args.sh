#!/usr/bin/env bash

codecov_cc_args=()

codecov_cc_args+=( $(write_truthy_args CODECOV_FAIL_ON_ERROR) )
codecov_cc_args+=( $(write_existing_args CODECOV_GIT_SERVICE) )
codecov_cc_args+=( $(write_existing_args CODECOV_PARENT_SHA) )
codecov_cc_args+=( $(write_existing_args CODECOV_PR) )
codecov_cc_args+=( $(write_existing_args CODECOV_SHA) )
codecov_cc_args+=( $(write_existing_args CODECOV_SLUG) )
