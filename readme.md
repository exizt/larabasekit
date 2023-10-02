# 개요
라라벨Laravel 프레임워크 지원 도구
- 라라벨 프레임워크를 생성하는 데에 도움이 되거나 공통적인 스크립트 등을 모아놓은 프로젝트.
- 라라벨 프레임워크를 구성할 때 서브모듈로 끼워넣어서, 사용에 도움이 되게 한다.

<br>

동작 환경
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

# 셋팅하기
## 로컬 환경
### 프로젝트 생성 또는 내려받기
#### 프로젝트 생성하기
1. 프로젝트를 위한 폴더를 생성하고 터미널을 실행한다.
2. git 생성 및 서브 모듈을 추가한다.
```shell
git init

git submodule add -b main git@github.com:exizt/larabasekit.git larabasekit
```
3. 라라벨 프로젝트를 생성한다.
```shell
# web 디렉토리에 라라벨 프로젝트 생성 등의 작업을 진행.
composer create-project --prefer-dist laravel/laravel 프로젝트명
mv 프로젝트명 web
```
4. `larabasekit/prj_tpl`의 파일들을 프로젝틀 루트로 복사한다.


#### 원격 저장소에서 내려받기
서브모듈을 포함하여 내려받는다.
```shell
git clone --recurse-submodules -j8 (저장소경로) (폴더명)
```

### 프로젝트 셋팅하기
1. 라라벨 설정
    - `web/.env.local.example`을 복사해서 `web/.env` 생성 후 설정.
2. 도커 설정
    - `larabasekit/docker/.env.local.example`을 복사해서 프로젝트 루트에 `.env.local`로 생성 후 설정.
3. 도커 컨테이너 생성 및 실행
    ```shell
    sudo docker-compose --env-file=.env.local --project-directory=. up --build --force-recreate -d
    ```


### 셋팅 직후
작업의 편의를 위해 다음의 심볼릭 링크를 생성한다.
```shell
ln -s ./larabasekit/scripts/dev/cmd-web.sh local.sh
```
* 로컬에서 명령어를 수행하기 쉽게 해주는 스크립트. 웹 컨테이너로 명령어를 전달한다.


사용법 예시
```shell
./local.sh "ls -al"
./local.sh "composer --version"
```


### 기타
> 기타 팁 등.

#### 도커 컨테이너가 이미 있을 경우 시작하기
```shell
sudo docker-compose --env-file=.env.local --project-directory=. start
```


#### 도커 삭제 + 볼륨 삭제
DB 볼륨을 삭제할 필요가 있을 시에는 다음 명령어를 실행한다.
```shell
sudo docker-compose --env-file=.env.local --project-directory=. down -v
```

## 프로덕션, Staging 환경 (공통 컨테이너)
웹용 도커 컨테이너를 하나로 이용하고 있을 때에 대한 내용입니다. (개별로 컨테이너를 구성했다면 로컬 개발환경과 차이가 없음)

### 셋팅
> 아무것도 없는 상태에서 프로젝트를 내려받고 셋팅하는 과정.

1. 깃 클론하기
    ```shell
    git clone --recurse-submodules -j8 (저장소경로) (폴더명)
    ```
2. 라라벨 설정
    - `web/.env.prod.example`을 복사해서 `web/.env` 생성 후 값 입력.
    - 데이터베이스 연결 정보 등을 기입.
3. 라라벨 설치 및 셋업
    ```shell
    sudo docker exec -it php_laravel_web_1 bash -c "cd $(pwd) && ./larabasekit/scripts/install-laravel.sh prod"

    sudo ./larabasekit/scripts/prod-install.sh php_laravel_web_1
    ```
    - 패키지 설치 및 업로드 폴더 권한, 스토리지 심볼릭 링크 생성 등
4. 필요시 `APP_KEY` 갱신
    ```shell
    # 예시
    sudo docker exec -it php_laravel_web_1 bash -c "cd $(pwd) && cd web && php artisan key:generate && php artisan config:cache && php artisan route:cache"
    ```
5. `storage`에 파일 업로드를 사용중일 경우, 업로드된 파일 복사.
    `web/storage/app`에 있는 파일을 FTP로 업로드
6. 데이터베이스 import (아래 참조)
7. 웹 접속


# 업데이트
## 프로덕션 환경
```shell
./scripts/fetch.sh
```


# 사용법
## 데이터베이스
### 데이터베이스 백업
(1) 바로 접근이 가능할 경우.
- 구문: `mysqldump --routines -uroot -p (디비명) > (생성될_파일_경로)`
- 예시:
```shell
mariadb-dump --routines -uroot -p db > db_dump.local.$(date +%Y%m%d).sql
```

<br>

(2) 로컬 환경 + 도커 컨테이너
> `docker-compose`로 접근하여 따로 입력하는 것 없이 백업을 진행하는 방식
```shell
sudo docker-compose --env-file=.env.local --project-directory=. exec db sh -c 'exec mariadb-dump --routines -uroot -p"${MARIADB_ROOT_PASSWORD}" ${MARIADB_DATABASE}' > ./scripts/db_dump.local.$(date +%Y%m%d).sql
```
<br>

> `docker` 컨테이너로 접근하는 방식
```shell
sudo docker exec (컨테이너명) sh -c 'exec mariadb-dump --routines -uroot -p"${MARIADB_ROOT_PASSWORD}" ${MARIADB_DATABASE}' > ./scripts/db_dump.local.$(date +%Y%m%d).sql
```

설명
* 비밀번호 입력없이 하는 방법이다.

<br>

(3) 프로덕션 환경 + 디비 전용 도커 컨테이너
```shell
sudo docker exec -it (컨테이너명) mariadb-dump --routines -u root -p (디비명) > chosim_dump.$(date +%Y%m%d).sql
```
* 중간에 DB 루트 암호를 적어줘야 함.

<br>

(4) 정석적인 방법 + 도커 컨테이너
```shell
# 구문
sudo docker exec -it (컨테이너명) /bin/bash
mariadb-dump --routines --triggers -uroot -p (디비명) > (백업될 파일경로)

# (로컬) 예시
sudo docker exec -it container_name /bin/bash
mariadb-dump --routines --triggers -uroot -p db_name > /app/scripts/chosim_dump.$(date +%Y%m%d).sql
```


### 데이터베이스 올리기
(1) 바로 접근이 가능할 경우.
- 구문: `mysql -uroot -p (디비명) < (백업_파일경로)`
- 예시:
```shell
mysql -uroot -p db_name < dump.sql
```

<br>

(2) 로컬 환경 + 도커 컨테이너
> `docker-compose`로 접근하는 방식
```shell
sudo docker-compose --env-file=.env.local --project-directory=. exec db sh -c 'exec mariadb -uroot -p"${MARIADB_ROOT_PASSWORD}" ${MARIADB_DATABASE}' < (백업_파일경로)
```

> `docker` 컨테이너로 접근하는 방식
```shell
docker exec -i (컨테이너명) sh -c 'exec mariadb -uroot -p"${MARIADB_ROOT_PASSWORD}" ${MARIADB_DATABASE}' < (백업_파일경로)
```

<br>

(3) 프로덕션 환경 + 디비 전용 도커 컨테이너
```shell
sudo docker exec -it (컨테이너명) mariadb -uroot -p (디비명) < (백업_파일경로)
```

<br>

(4) 정석적인 방법 + 도커 컨테이너
```shell
sudo docker exec -it (컨테이너명) /bin/bash
mariadb -uroot -p (디비명) < (백업_파일경로)
```

## 이 프로젝트
### 스크립트 목록
- `fetch.sh`
    - (프로덕션 전용)
    - 소스 코드의 갱신을 위한 스크립트. `git pull`등을 수행함.
- `install-laravel.sh`
    - 라라벨의 셋팅을 위한 스크립트. `composer install`(패키지 설치)등을 수행함.
- `update.prod.sh`
    - 프로덕션에서 업데이트를 위한 스크립트.
    - `install-laravel.sh prod`와 동일.
- `caching-config.prod.sh`
    - 프로덕션에서 라라벨 설정을 캐싱하는 스크립트.



## Docker
### 도커 컨테이너 시작
- 구문: `sudo docker start (컨테이너명1) (컨테이너명2)`


(로컬 환경) `docker-compose`를 이용한 방식.
```shell
sudo docker-compose --env-file=.env.local --project-directory=. start
```

(프로덕션 환경)
```shell
sudo docker start (컨테이너명)
```

### 도커 컨테이너 접속
- 구문: `sudo docker exec -it (컨테이너명) /bin/bash`

(로컬 환경) `docker-compose`를 이용한 방식.
```shell
# web 컨테이너 접속
sudo docker-compose --env-file=.env.local --project-directory=. exec web /bin/bash

# db 컨테이너 접속
sudo docker-compose --env-file=.env.local --project-directory=. exec db /bin/bash
```

(프로덕션 환경)
```shell
sudo docker exec -it (컨테이너명) /bin/bash
```

## Composer
(로컬 환경)
```shell
sudo docker-compose --env-file=.env.local --project-directory=. exec web composer (명령어)
```

(프로덕션 환경에서)
```shell
sudo docker exec -it (컨테이너명) bash -c "cd $(pwd) && composer (명령어)"
```

### composer update
(로컬 환경)
```shell
sudo docker-compose --env-file=.env.local --project-directory=. exec web composer update

sudo docker exec -it chosim_webapp_1 composer update
```


(프로덕션 환경에서)
```shell
sudo docker exec -it php_laravel_web_1 bash -c "cd $(pwd) && composer update"
```

## Artisan
(로컬 환경에서)
```shell
# 구문
sudo docker-compose --env-file=.env.local --project-directory=. exec web php artisan (명령어)

# 예시 (스토리지 심볼릭 링크 생성)
sudo docker-compose --env-file=.env.local --project-directory=. exec web php artisan storage:link

# 심볼릭 local.sh를 이용.
./local.sh php artisan storage:link
```


### 프로덕션 환경
(프로덕션 환경에서)
```shell
# 구문
sudo docker exec -it (컨테이너명) bash -c "cd $(pwd) && php artisan (명령어)"

# 예시
sudo docker exec -it php_laravel_web_1 bash -c "cd $(pwd) && php artisan key:generate"
```

### migration 모델 생성
(로컬 환경에서) migration 및 모델 생성
```shell
# migration 파일 생성 1
./local.sh php artisan make:model --migration SoftwareProductTheme

# migration 파일 생성 2
./local.sh php artisan make:model --migration SoftwareProductFile

# migration 데이터베이스 반영
./local.sh php artisan migrate
```
그런데 권한이 root 에다가 퍼미션은 644로 생성되는데... 이거 대안 찾아야 할 듯.


### controller 생성
(로컬 환경에서) 컨트롤러 생성
```shell
./local.sh php artisan make:controller PhotoController --resource
./local.sh php artisan make:controller Admin/PhotoController --resource
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
