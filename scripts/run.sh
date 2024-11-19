#!/usr/bin/env bash

if [ -n "$CC_USE_PYTHON" ]; then
  echo "CC_USE_PYTHON is set, skipping download and validation steps."
else
  . ./download.sh
  . ./validate.sh
fi

. ./version.sh
. ./set_defaults.sh

. ./set_cli_args.sh
. ./set_create_commit_args.sh
. ./set_create_report_args.sh
. ./set_do_upload_args.sh
. ./upload.sh
