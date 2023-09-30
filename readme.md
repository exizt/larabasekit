# 개요
라라벨Laravel 프레임워크 지원 도구
- 라라벨 프레임워크를 생성하는 데에 도움이 되거나 공통적인 스크립트 등을 모아놓은 프로젝트.
- 라라벨 프레임워크를 구성할 때 서브모듈로 끼워넣어서, 사용에 도움이 되게 한다.


## 동작 환경
- `PHP`: 8.0 이상
- 데이터베이스
    - `MySQL`
    - `MariaDB`
- PHP 익스텐션
    - `extension=openssl` : 뭐였는지 기억 안 나지만 필요함
    - `extension=pdo_mysql` : DB 연결을 위해 필요
    - `extension=mbstring` : 뭐였는지 기억 안 남
- 필요 패키지
    
<br><br>

# 로컬 환경
## 프로젝트 생성 또는 내려받기
### 프로젝트 생성하기
1. 프로젝트를 위한 폴더를 생성하고 터미널을 실행한다.
2. git 생성 및 서브 모듈을 추가한다.
    ```shell
    git init

    git submodule add -b main git@github.com:exizt/larabasekit.git larabasekit
    ```
### 원격 저장소에서 내려받기
서브모듈을 포함하여 내려받는다.
```shell
git clone --recurse-submodules -j8 (저장소경로) (폴더명)
```

## 프로젝트 셋팅하기
1. 라라벨 설정
    - `web/.env.local.example`을 복사해서 `web/.env` 생성 후 설정.
2. 도커 설정
    - `larabasekit/docker/.env.local.example`을 복사해서 프로젝트 루트에 `.env.local`로 생성 후 설정.
3. 도커 컨테이너 생성 및 실행
    ```shell
    sudo docker-compose --env-file=.env.local --project-directory=. up --build --force-recreate -d
    ```

# 팁
## 도커
DB 볼륨을 삭제할 필요가 있을 시에는 다음 명령어를 실행한다.
```shell
sudo docker-compose --env-file=.env.local down -v
```

# 문제 해결
## `storage`에서 소유권, 퍼미션 문제 발생시

storage에서 소유권, 퍼미션이 꼬였을 때
```shell
cd storage

# 파일과 디렉토리에 대해서 퍼미션을 기본값으로 변경
sudo find . -type f -exec chmod 664 {} \;
sudo find . -type d -exec chmod 775 {} \;

# 그룹 소유자를 `www-data`로 지정
sudo chgrp -R www-data *
```


## SQLSTATE[HY000] [1045] Access denied
`SQLSTATE[HY000] [1045] Access denied for user 'forge'@'127.0.0.1' (using password: NO)`


원인
  - 데이터베이스 설정이 안 되어있거나 인식이 안 되는 상황

해결 방법
  - `.env`의 데이터베이스 설정을 확인하기.
  - 프로덕션의 환경에서는 설정을 확인한 뒤, `php artisan config:cache`


## net::ERR_HTTP_RESPONSE_CODE_FAILURE (500 오류)
net::ERR_HTTP_RESPONSE_CODE_FAILURE (500 오류)


원인
  - views 캐싱이 안 되서 발생할 수 있다.
  - `storage` 폴더 내에 views를 캐싱한 파일이 생성되어야 하는데, 생성이 되지 못하고 있음.


해결 방법
  - `storage` 폴더의 권한을 점검.
    - 우분투 계열: `chgrp -R www-data storage`
    - CentOS 계열: `chgrp -R apache storage`
