#!/bin/bash

# ##########################################
#

# bash handling (bash가 아니면 bash로 실행)
if [ -z "$BASH_VERSION" ]; then exec bash "$0" "$@"; exit; fi
SCRIPT_PATH=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")") # 현재 스크립트의 경로
LARAKIT_PATH=$(realpath "${SCRIPT_PATH}/../..") # LaraBaseKit 경로
PROJECT_PATH=$(realpath "${LARAKIT_PATH}/..") # Project Root 경로
SCRIPT_NAME=$(basename $BASH_SOURCE) # 스크립트 명칭

echo "[${SCRIPT_NAME}] start.."

# 파라미터가 없는 경우는 실행하지 않도록 함.
if [ "$#" -lt 1 ]; then
    echo "[${SCRIPT_NAME}] Parameters are required."
    exit 1
fi

# 프로젝트 경로로 이동
cd $PROJECT_PATH

# 메인 아카이브
git archive -o "archive.tar" HEAD

# 서브모듈 아카이브
git submodule foreach --recursive 'git archive --prefix=$sm_path/ -o $sha1.tar HEAD && tar --concatenate --file=../archive.tar $sha1.tar && rm $sha1.tar'

# 날짜를 포함한 파일명
# https://stackoverflow.com/questions/8190392/is-there-a-git-command-that-returns-the-current-project-name
PROJ_NAME=$(git config --local remote.origin.url|sed -n 's#.*/\([^.]*\)\.git#\1#p')
# echo $PROJ_NAME
mv -f archive.tar "../$PROJ_NAME.$(date +'%Y%m%d').tar"
