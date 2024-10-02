#!/usr/bin/env bash

. ./scripts/version.sh
. ./scripts/set_defaults.sh
. ./scripts/download.sh
. ./scripts/validate.sh

. ./scripts/set_cli_args.sh
. ./scripts/set_create_commit_args.sh
. ./scripts/set_create_report_args.sh
. ./scripts/set_do_upload_args.sh
. ./scripts/upload.sh
