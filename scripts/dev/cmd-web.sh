#!/bin/bash
# ----------------------------------------------------------------------
#
# Copyright 2023 shoon
#
# ----------------------------------------------------------------------

# bash handling (bash가 아니면 bash로 실행)
if [ -z "$BASH_VERSION" ]; then exec bash "$0" "$@"; exit; fi
SCRIPT_PATH=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")") # 현재 스크립트의 경로
LARAKIT_PATH=$(realpath "${SCRIPT_PATH}/../..") # LaraBaseKit 경로
PROJECT_ROOT_PATH=$(realpath "${LARAKIT_PATH}/..") # Project Root 경로
PROJECT_WEB_PATH="${PROJECT_ROOT_PATH}/web" # Laravel 셋팅 경로

# 파라미터가 없는 경우는 실행하지 않도록 함. (잘못된 실행 방지)
if [ "$#" -lt 1 ]; then
    echo "Parameters are required."
	exit 1
fi

# 프로젝트 루트로 이동
cd $PROJECT_ROOT_PATH

# 명령어 실행
sudo docker-compose --env-file=.env.local --project-directory=. exec web bash -c "$1"