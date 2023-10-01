#!/bin/bash
# ----------------------------------------------------------------------
# [ prod-update.sh ]
# 
# (프로덕션 환경에서) 소스 업데이트하는 스크립트
#
# Copyright 2022 shoon
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
PROJECT_ROOT_PATH=$(realpath "${SCRIPT_PATH}/../..") # Project Root 경로
PROJECT_WEB_PATH="${PROJECT_ROOT_PATH}/web" # Laravel 셋팅 경로

# 파라미터가 없는 경우는 실행하지 않도록 함. (잘못된 실행 방지)
if [ "$#" -lt 1 ]; then
    echo "Parameters are required."
	exit 1
fi

# 프로젝트 루트로 이동
cd $PROJECT_ROOT_PATH

# 라라벨 폴더 및 파일 퍼미션 지정
# bash "${SCRIPT_PATH}/apply-permission.sh"
# 쓰기 권한이 필요한 폴더의 그룹 소유권을 www-data로 변경.
cd "${PROJECT_WEB_PATH}" # Laravel Web 경로로 이동.
sudo chgrp -R www-data bootstrap/cache
sudo chgrp -R www-data storage

# 컴포저 업데이트 및 라라벨 캐시 갱신
# sudo docker exec -it $1 "${SCRIPT_PATH}/prod-composer-update.sh"
# 라라벨 및 연관성 패키지들의 설치 또는 업데이트
shell_str="cd ${PROJECT_WEB_PATH} && composer install --optimize-autoloader --no-dev"
sudo docker exec -it $1 bash -c "${shell_str}"

# 라라벨 config, route 설정 캐싱
shell_str="cd ${PROJECT_WEB_PATH} && php artisan config:cache && php artisan route:cache"
sudo docker exec -it $1 bash -c "${shell_str}"