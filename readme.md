# 개요
라라벨Laravel 프레임워크 지원 도구
- 라라벨 프레임워크를 생성하는 데에 도움이 되거나 공통적인 스크립트 등을 모아놓은 프로젝트.
- 라라벨 프레임워크를 구성할 때 서브모듈로 끼워넣어서, 사용에 도움이 되게 한다.


## 동작 환경
- `PHP`: 
- 데이터베이스
    - `MySQL`
    - `MariaDB`
- PHP 익스텐션
    
- 필요 패키지
    
<br><br>


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


## `SQLSTATE[HY000] [1045] Access denied`
`SQLSTATE[HY000] [1045] Access denied for user 'forge'@'127.0.0.1' (using password: NO)`


원인
  - 데이터베이스 설정이 안 되어있거나 인식이 안 되는 상황

해결 방법
  - `.env`의 데이터베이스 설정을 확인하기.
  - 프로덕션의 환경에서는 설정을 확인한 뒤, `php artisan config:cache`


## `net::ERR_HTTP_RESPONSE_CODE_FAILURE (500 오류)`
net::ERR_HTTP_RESPONSE_CODE_FAILURE (500 오류)


원인
  - views 캐싱이 안 되서 발생할 수 있다.
  - `storage` 폴더 내에 views를 캐싱한 파일이 생성되어야 하는데, 생성이 되지 못하고 있음.


해결 방법
  - `storage` 폴더의 권한을 점검.
    - 우분투 계열: `chgrp -R www-data storage`
    - CentOS 계열: `chgrp -R apache storage`
