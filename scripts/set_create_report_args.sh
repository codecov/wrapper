#!/usr/bin/env bash

codecov_create_report_args=()

codecov_cr_args+=( $(write_existing_args CODECOV_CODE) )
codecov_cr_args+=( $(write_truthy_args CODECOV_FAIL_ON_ERROR) )
codecov_cr_args+=( $(write_existing_args CODECOV_GIT_SERVICE) )
codecov_cr_args+=( $(write_existing_args CODECOV_PR) )
codecov_cr_args+=( $(write_existing_args CODECOV_SHA) )
codecov_cr_args+=( $(write_existing_args CODECOV_SLUG) )
