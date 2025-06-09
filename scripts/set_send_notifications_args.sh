#!/bin/sh

add_arg "$(k_arg SHA)"
add_arg "$(v_arg SHA)"
add_arg "$(write_bool_args CODECOV_FAIL_ON_ERROR)"
add_arg "$(k_arg GIT_SERVICE)"
add_arg "$(v_arg GIT_SERVICE)"
add_arg "$(k_arg SLUG)"
add_arg "$(v_arg SLUG)"
