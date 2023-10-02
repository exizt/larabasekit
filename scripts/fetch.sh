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
PROJECT_ROOT_PATH=$(realpath "${LARAKIT_PATH}/..") # Project Root 경로
PROJECT_WEB_PATH="${PROJECT_ROOT_PATH}/web" # Laravel 셋팅 경로

# 로컬에서는 실행되지 않게 해야하는데... 음...


# ### 프로젝트 git 갱신
# 프로젝트 루트 경로로 이동
cd $PROJECT_ROOT_PATH

# git 갱신 사항이 있는지 확인하고, 없으면 스크립트 종료.
git fetch origin main
git_behind_count=$(git rev-list HEAD..origin/main --count)
[[ "${git_behind_count}" == "0" ]] && exit 1

# git 갱신 (프로젝트 git)
git pull --recurse-submodules


# ### 서브 모듈 git 관련
cd $LARAKIT_PATH # 라라벨 베이스 키트 경로로 이동

# [aether - git] 태그를 삭제하고 다시 태그 받아옴
git tag -d $(git tag) && git fetch --all

# [aether - git] 체크아웃 없이 main 브랜치를 원격에 맞춰서 갱신
git fetch origin main:main


# ### 코드 관련
# 스크립트 파일 퍼미션 조정 (퍼미션이 초기화되므로 다시 조정)
cd $LARAKIT_PATH # 라라벨 베이스 키트 경로로 이동
git config core.fileMode false # git에서 퍼미션을 추적하지 않도록 설정.

# 적절하게 퍼미션 조정
cd "${SCRIPT_PATH}"
chmod o-x ./*.sh # others의 실행 권한 제거
chmod a-x ./install-laravel.sh # 실행 권한 제거 (쓸 일이 평소에는 없음)
chmod a-x ./dev/*.sh # 실행 권한 제거 (프로덕션에서는 사용되지 않음)

# 프로젝트 루트의 scripts
chmod o-x "${PROJECT_ROOT_PATH}/scripts/*.sh"

# 라라벨 설정 캐시 갱신
# 캐시 갱신은 여기서 처리하지 않음.