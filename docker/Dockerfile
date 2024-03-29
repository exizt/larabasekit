# 'Laravel'을 위한 `PHP, Apache(httpd)` 도커 파일
FROM php:8.2-apache-bullseye

WORKDIR /app

# 도커 entrypoint.sh에서 dforground 옵션으로 동작시킬 것이기 때문에 서비스에서는 종료.
RUN service apache2 stop

# 아파치에서 사용될 환경변수 (유저, 그룹 소유권 등)을 지정
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2

# ##### 1. composer 설치 및 설정 #####

# 필요한 것들 설치
# - git, unzip : composer 에서 필요
# RUN  apt-get update && apt-get install -y \
#    git \
#    unzip \
#    && apt-get autoremove -y \
#    && rm -rf /var/lib/apt/lists/*
# 
# composer 설치
# RUN curl -sS https://getcomposer.org/installer | php
# RUN mv composer.phar /usr/local/bin/composer

# 단순화된 방식. 멀티 스테이지 빌드 방식.
COPY --from=composer /usr/bin/composer /usr/bin/composer

# composer 설정 및 실행
ENV COMPOSER_ALLOW_SUPERUSER 1 


# ##### 2. php 및 아파치 확장 기능 설치 등 #####
# php extension 설치
RUN docker-php-ext-install bcmath pdo_mysql

# 아파치 모듈 허용 설정
#   - rewrite : 기본적으로 사용. url을 rewrite하는 모듈.
#   - headers : 기본적으로 사용.
RUN a2enmod rewrite headers

# apache의 servername 값 지정. (Could not reliably determine.. 오류를 없애기 위함. 크게 중요하지는 않음..)
RUN echo "ServerName localhost" | tee /etc/apache2/conf-available/servername.conf
RUN a2enconf servername

# 포트
EXPOSE 80


## 4. php.ini 설정

# php.ini 를 복사 설정
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"
# RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# 업로드 제한을 늘림
RUN sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 10M/g" "$PHP_INI_DIR/php.ini"
# 필요시 POST 제한도 늘림
RUN sed -i "s/post_max_size = 8M/post_max_size = 10M/g" "$PHP_INI_DIR/php.ini"


## 5. 그 외

# entrypoint.sh 복사
# COPY docker-entrypoint.sh .

# WORKDIR 지정
WORKDIR /app/web

# 위에서 변경한 ENV 설정을 envvars 에 적용시키기 위함으로 생각됨. 
# bash 에서는 source /etc/apache2/envvars 이고, 여기서는 . 으로 하면 동일하게 작동된다고 함.
# RUN . /etc/apache2/envvars

# CMD ["apache2","-D","FOREGROUND"]
