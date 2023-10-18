@echo off
@chcp 65001 1> NUL 2> NUL

rem 스크립트 경로
set SCRIPT_PATH=%~DP0

rem 스크립트 경로로 이동
pushd "%SCRIPT_PATH%"

rem git bash로 스크립트 호출
sh archive.sh 1

pause