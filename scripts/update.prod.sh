#!/bin/bash
# ----------------------------------------------------------------------
# 컴포저 갱신 및 설정 캐싱 등을 갱신하는 스크립트 (프로덕션 환경)
#
# Copyright 2023 shoon
#
# git을 새로 내려받아서 업데이트하고, composer 갱신하고, 라라벨 캐시를
# 갱신한다.
#
# 파라미터:
#   - 첫번째 파라미터 : 도커 컨테이너 ID. PHP가 실행 중인 도커 컨테이너 ID를 
#         넘겨받는다. composer 등을 이용하는데에 필요하다.
# ----------------------------------------------------------------------

# bash handling (bash가 아니면 bash로 실행)
if [ -z "$BASH_VERSION" ]; then exec bash "$0" "$@"; exit; fi
SCRIPT_PATH=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")") # 스크립트의 경로
LARAKIT_PATH=$(realpath "${SCRIPT_PATH}/..") # LaraBaseKit 경로
PROJECT_ROOT_PATH=$(realpath "${LARAKIT_PATH}/..") # Project Root 경로
PROJECT_WEB_PATH="${PROJECT_ROOT_PATH}/web" # Laravel 셋팅 경로

# 파라미터가 없는 경우는 실행하지 않도록 함. (잘못된 실행 방지)
if [ "$#" -lt 1 ]; then
    echo "Parameters are required."
	exit 1
fi

# 프로젝트 루트로 이동
cd $PROJECT_ROOT_PATH

# 'install-larave.sh' 실행
shell_str="cd ${LARAKIT_PATH} && ./scripts/install-laravel.sh prod"
sudo docker exec -it $1 bash -c "${shell_str}"

