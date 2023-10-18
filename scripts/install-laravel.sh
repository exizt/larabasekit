#!/bin/bash
# ----------------------------------------------------------------------
# 라라벨 설치 및 셋팅하는 스크립트
#
# Copyright 2022-2023 shoon
#
# composer 패키지를 받고, 라라벨 업로드 폴더의 권한을 조정하고,
# 라라벨 설정 캐싱을 생성한다.
#
# 스크립트명: install-laravel.sh
# 
# 파라미터:
#   - 첫번째 파라미터 : 환경 설정에 대한 값. 로컬인지 프로덕션인지.
#       - 입력값: local | prod | staging
# ----------------------------------------------------------------------

# bash handling (bash가 아니면 bash로 실행)
if [ -z "$BASH_VERSION" ]; then exec bash "$0" "$@"; exit; fi
SCRIPT_PATH=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")") # 스크립트의 경로
PROJECT_ROOT_PATH=$(realpath "${SCRIPT_PATH}/../..") # Project Root 경로
PROJECT_WEB_PATH="${PROJECT_ROOT_PATH}/web" # Laravel 셋팅 경로

# 첫 문구
echo "[larabasekit.inst] laravel installation"

# 파라미터가 없는 경우는 실행하지 않도록 함. (잘못된 실행 방지)
if [ "$#" -lt 1 ]; then
    echo "Parameters are required."
    exit 1
fi

# Laravel Web 경로로 이동.
cd "${PROJECT_WEB_PATH}"

# 1. composer 패키지 셋팅
# 라라벨 및 연관성 패키지들의 설치 또는 업데이트
# 'composer install'은 'composer.lock'을 참조하여 'vendor'폴더 이하의 패키지를 셋팅 및 설치한다.
if [ "$1" == "prod" ] || [ "$1" == "staging" ]; then
    # 프로덕션용 옵션으로 설치. '--no-dev'옵션으로 디버그 툴 등은 설치하지 않는다.
    composer install --optimize-autoloader --no-dev
    echo "[larabasekit.inst] composer packages have been successfully installed."
elif [ "$1" == "local" ]; then
    composer install
    echo "[larabasekit.inst] composer packages have been successfully installed."
else
    # 잘못된 접근으로 종료함.
    exit 1
fi

# 2. 라라벨 업로드 폴더 및 파일 퍼미션 지정
# 쓰기 권한이 필요한 폴더의 그룹 소유권을 www-data로 변경.
chgrp -R www-data bootstrap/cache
chgrp -R www-data storage

# 3. config, route 설정 캐시 갱신 [프로덕션 환경]
if [ "$1" == "prod" ] || [ "$1" == "staging" ]; then
    php artisan config:cache && php artisan route:cache
    echo "[larabasekit.inst] configuration caching has been completed."
fi

# 4. 스토리지 심볼릭 링크 생성
# 생성되는 심볼릭 링크에 대한 설정은 '/web/config/filesystems.php'의 가장 하단에 있음.
php artisan storage:link
echo "[larabasekit.inst] storage symbolic link has been created."

# 완료
echo "[larabasekit.inst] successfully completed."