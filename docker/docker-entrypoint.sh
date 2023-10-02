#!/bin/bash

# /app 경로가 없으면 이상이 있는 것이므로 그냥 종료.
# 보통 잘못 실행한 경우임.
if ! [ -d /app ]; then
	echo "not found /app"
	exit 1
fi
echo "[entrypoint.sh] start"

cd /app/web

# 필요한 패키지 및 초반 셋팅
if [ -f composer.json ]; then
    if [ -d vendor ]; then
        echo "[entrypoint.sh] vendor already exists, it does not install packages."
        # vendor 가 있으므로 composer install 을 하지 않고 진행
    else
        echo "[entrypoint.sh] vendor not eixsts, composer installs packages."
        if [ -d "/app/web/bootstrap/cache" ]; then
            # 여기에 해당하는 게 있으면 삭제를 먼저 하지 않으면 
            # php artisan package:discover --ansi handling the post-autoload-dump event returned with error code 1
            # 오류를 만날 수 있다.
            rm -f /app/web/bootstrap/cache/packages.php
            rm -f /app/web/bootstrap/cache/services.php
        fi
        # vendor 폴더 생성. composer.lock 을 참조하여 생성됨.
        # composer install
        bash /app/larabasekit/scripts/install-laravel.sh local

        # 처음 구동일 것이라고 가정하고. 여기서 서버 네임 지정하는 부분 추가.
        # echo "ServerName localhost" >> /etc/apache2/apache2.conf
    fi
else
    echo "[entrypoint.sh] composer.json does not exist."
fi



# db 서버를 기다리기
# echo "wait db server"
# dockerize -wait tcp://db:3306 -timeout 20s

# php artisan migrate
# php artisan db:seed --class=UserTableSeeder

# 서버 실행
echo "[entrypoint.sh] The Apache server has started successfully."
# 환경변수 APACHE_RUN_USER 등의 적용.
source /etc/apache2/envvars
# Apache 실행
exec apache2 -DFOREGROUND