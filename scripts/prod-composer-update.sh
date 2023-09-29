#!/bin/bash
# ----------------------------------------------------------------------
# [ prod-composer-update.sh ]
# 
# (프로덕션 환경에서) laravel composer 및 캐시 처리
#
# Copyright 2022 shoon
#
# ----------------------------------------------------------------------

# bash handling (bash가 아니면 bash로 실행)
if [ -z "$BASH_VERSION" ]; then exec bash "$0" "$@"; exit; fi
SCRIPT_PATH=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")") # 스크립트의 경로
PROJECT_ROOT_PATH=$(realpath "${SCRIPT_PATH}/../..") # Project Root 경로
PROJECT_WEB_PATH="${PROJECT_ROOT_PATH}/web" # Laravel 셋팅 경로

# Laravel Web 경로로 이동.
cd "${PROJECT_WEB_PATH}"

# composer 명령어
composer install --optimize-autoloader --no-dev

# config 설정 캐시 갱신
php artisan config:cache

# route 설정 캐시 갱신
php artisan route:cache
