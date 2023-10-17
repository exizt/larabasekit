#!/bin/bash
# ----------------------------------------------------------------------
# 로컬 web 컨테이너 명령어 실행 스크립트
# 
# Copyright 2023 shoon
#
# 로컬에서 작업을 좀 더 쉽게하기 위해 만든 스크립트.
# 사용법:
#    1. 프로젝트 루트에서 심볼릭 링크를 만든다.
#       'ln -s ./larabasekit/scripts/dev/cmd-web.sh local.sh'
#    2. 사용 예시
#        ./local.sh composer --version
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
sudo docker-compose --env-file=.env.local --project-directory=. exec web bash -c "$*"
# sudo docker-compose --env-file=.env.local --project-directory=. exec web bash -c "$1"