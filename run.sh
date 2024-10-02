#!/usr/bin/env bash

CODECOV_YML_PATH="codecov.yml"

. ./set_defaults.sh
. ./download.sh
. ./validate.sh

. ./set_cli_args.sh
. ./set_create_commit_args.sh
. ./upload.sh
