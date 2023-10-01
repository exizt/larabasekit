#!/bin/bash
# ----------------------------------------------------------------------
# git 내려받기 및 소스 코드 갱신 스크립트 (프로덕션 환경)
#
# Copyright 2023 shoon
#
# submodule을 포함하여 git을 내려받고(pulling), 스크립트 파일 등에 대한
# 퍼미션 설정을 하는 스크립트.
#
# 스크립트명 : fetch.sh
# ----------------------------------------------------------------------

# bash handling (bash가 아니면 bash로 실행)
if [ -z "$BASH_VERSION" ]; then exec bash "$0" "$@"; exit; fi
SCRIPT_PATH=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")") # 스크립트의 경로
LARAKIT_PATH=$(realpath "${SCRIPT_PATH}/..") # LaraBaseKit 경로
PROJECT_ROOT_PATH=$(realpath "${SCRIPT_PATH}/../..") # Project Root 경로
PROJECT_WEB_PATH="${PROJECT_ROOT_PATH}/web" # Laravel 셋팅 경로

# 파라미터가 없는 경우는 실행하지 않도록 함. (잘못된 실행 방지)
if [ "$#" -lt 1 ]; then
    echo "Parameters are required."
	exit 1
fi


# ### 프로젝트 git 갱신
# 프로젝트 루트 경로로 이동
cd $PROJECT_ROOT_PATH

# git 갱신 사항이 있는지 확인하고, 없으면 스크립트 종료.
git fetch origin master
git_behind_count=$(git rev-list HEAD..origin/master --count)
[[ "${git_behind_count}" == "0" ]] && exit 1

# git 갱신 (프로젝트 git)
git pull --recurse-submodules


# ### 서브 모듈 git 관련
# 라라벨 베이스 키트 경로로 이동
cd $LARAKIT_PATH

# [aether - git] 태그를 삭제하고 다시 태그 받아옴
git tag -d $(git tag) && git fetch --all

# [aether - git] 체크아웃 없이 main 브랜치를 원격에 맞춰서 갱신
git fetch origin main:main


# ### 코드 관련
# 라라벨 폴더 및 파일 퍼미션 지정
bash "${SCRIPT_PATH}/apply-permission.sh"

# 스크립트 파일 퍼미션 조정 (퍼미션이 초기화되므로 다시 조정)
# prod-install.sh 은 권한주지 않아도 되므로 권한을 제외
cd "${SCRIPT_PATH}"
chmod o-x ./*.sh # others의 실행 권한 제거
chmod a-x ./prod-install.sh # 실행 권한 제거 (쓸 일이 평소에는 없음)

# 라라벨 설정 캐시 갱신
# sudo docker exec -it $1 "${SCRIPT_PATH}/laravel-config-cache.sh"