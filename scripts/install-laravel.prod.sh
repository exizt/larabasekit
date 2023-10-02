#!/bin/bash
# ----------------------------------------------------------------------
# 라라벨 설치 및 셋팅하는 스크립트 (프로덕션 환경)
#
# Copyright 2022-2023 shoon
#
# 라라벨 폴더 및 파일 퍼미션 지정하고, composer 생성하고, 라라벨 캐시를
# 생성한다.
#
# 스크립트명: install-laravel.prod.sh
#   - 예전 명칭: prod-install.sh
# 파라미터:
#   - 첫번째 파라미터 : 도커 컨테이너 ID. PHP가 실행 중인 도커 컨테이너 ID를 
#         넘겨받는다. composer 등을 이용하는데에 필요하다.
# ----------------------------------------------------------------------

# bash handling (bash가 아니면 bash로 실행)
if [ -z "$BASH_VERSION" ]; then exec bash "$0" "$@"; exit; fi
SCRIPT_PATH=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")") # 스크립트의 경로
PROJECT_ROOT_PATH=$(realpath "${SCRIPT_PATH}/../..") # Project Root 경로
PROJECT_WEB_PATH="${PROJECT_ROOT_PATH}/web" # Laravel 셋팅 경로

# 파라미터가 없는 경우는 실행하지 않도록 함. (잘못된 실행 방지)
if [ "$#" -lt 1 ]; then
    echo "Parameters are required."
	exit 1
fi

# Laravel Web 경로로 이동.
cd "${PROJECT_WEB_PATH}"

# 라라벨 폴더 및 파일 퍼미션 지정
# bash "${SCRIPT_PATH}/apply-permission.sh"
# 쓰기 권한이 필요한 폴더의 그룹 소유권을 www-data로 변경.
sudo chgrp -R www-data bootstrap/cache
sudo chgrp -R www-data storage

# 컴포저 업데이트 및 라라벨 캐시 갱신
# sudo docker exec -it $1 "${SCRIPT_PATH}/prod-composer-update.sh"
# bash ./prod-composer-update.sh
sudo docker exec -it $1 bash -c "cd ${PROJECT_WEB_PATH} && php artisan config:cache && php artisan route:cache"

# 스토리지 심볼릭 링크 생성
# 생성되는 심볼릭 링크에 대한 설정은 '/web/config/filesystems.php'의 가장 하단에 있음.
sudo docker exec -it $1 bash -c "cd ${PROJECT_WEB_PATH} && php artisan storage:link"