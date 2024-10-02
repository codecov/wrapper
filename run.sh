#!/usr/bin/env bash

. ./version.sh
. ./set_defaults.sh
. ./download.sh
. ./validate.sh

. ./set_cli_args.sh
. ./set_create_commit_args.sh
. ./set_create_report_args.sh
. ./set_do_upload_args.sh
. ./upload.sh
