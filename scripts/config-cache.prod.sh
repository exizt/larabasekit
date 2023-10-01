#!/bin/bash
# ----------------------------------------------------------------------
# 라라벨 config, route 설정 캐시 갱신 스크립트 (프로덕션 환경)
# 
# copyright 2023 shoon
# 
# 라라벨 artisan으로 config, route의 설정 캐시를 생성하거나 갱신한다.
# 도커 컨테이너 내부에 composer가 셋팅되어있으므로, 컨테이너 내부에서 실행
# 해야 한다.
#
# 스크립트명 : prod-laravel-config-cache.sh
# ----------------------------------------------------------------------

# bash handling (bash가 아니면 bash로 실행)
if [ -z "$BASH_VERSION" ]; then exec bash "$0" "$@"; exit; fi
SCRIPT_PATH=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")") # 스크립트의 경로
PROJECT_ROOT_PATH=$(realpath "${SCRIPT_PATH}/../..") # Project Root 경로
PROJECT_WEB_PATH="${PROJECT_ROOT_PATH}/web" # Laravel 셋팅 경로

# 프로젝트 루트로 이동
cd $PROJECT_WEB_PATH

# config 설정 캐시 갱신
php artisan config:cache

# route 설정 캐시 갱신
php artisan route:cache

