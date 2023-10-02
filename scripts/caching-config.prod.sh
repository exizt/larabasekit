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
# 스크립트명 : caching-config.prod.sh
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

# 프로젝트 루트로 이동
cd $PROJECT_WEB_PATH

# config 설정 캐시 갱신
# php artisan config:cache

# route 설정 캐시 갱신
# php artisan route:cache

# config, route 설정 캐시 갱신
shell_str="cd ${PROJECT_WEB_PATH} && php artisan config:cache && php artisan route:cache"
sudo docker exec -it $1 bash -c "${shell_str}"
