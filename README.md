# About
Omeka를 구동하는 PHP 웹서버, DB, ELK 스택을 연동시키는 docker-compose 구성 파일입니다.

별다른 설정 없이 Omeka + ELK 스택을 실행시킬 수 있습니다.


# 사용 방법

## 커맨드 라인

```bash
# 현재 디렉토리(docker-playground) 기준 커맨드

# 도커 컨테이너를 생성/실행하는 명령어
$ sudo docker-compose up -d

# 도커 컨테이너를 삭제한다
$ sudo docker-compose down

# 도커 컨테이너 정지
$ sudo docker stop maria php-dev elasticsearch kibana logstash

# 정지된 도커 컨테이너 재시작
$ sudo docker start maria php-dev elasticsearch kibana logstash

# 실행 중인 도커 컨테이너 확인
$ sudo docker ps

# 도커 컨테이너 전체 리스트 확인
$ sudo docker ps -a

# 생성되어 있는 도커 이미지 확인
$ sudo docker images

# 생성되어 있는 도커 이미지를 삭제한다
$ sudo docker rm docker-playground_db docker-playground_php-dev

# omeka 파일을 html 디렉토리에 복사한다
$ sudo sh ./omeka.sh

# sudo가 너무 귀찮으면
$ su

# html에 파일 추가한 다음에 권한(소유자) 수정
$ sudo sh ./file-permission.sh

```

## docker manager 스크립트 실행
```bash
$ sudo ./manager.sh
```

# 도커 구성

## docker-compose.yml
현재 **docker-playground**에서 사용중인 이미지는 **db**와 **php-dev**, **ELK** 스택을 포함한 다섯가지입니다.

**db** 이미지는 mariadb 이미지를 베이스로 하여 생성되었고 **php-dev**는 php 이미지를 기반으로 생성되었습니다.

이 두가지 이미지에 대한 설정은 *docker-compose.yml*에 작성되어 있습니다.

**사용 방법** 문단에 따라서 도커 실행 명령어(docker-compose)를 입력하면 *docker-compose.yml* 설정에 따라 이미지로부터 컨테이너를 생성하고 실행합니다. 만약 컨테이너가 이미 생성되어 있다면 기존 컨테이너를 다시 실행합니다.

그냥 `docker` 명령어와 다른 점은 *docker-compose.yml*에 여러 이미지를 한꺼번에 설정하고 실행할 수 있다는 점입니다.



### db

mariaDB를 실행하는 이미지입니다. **php-dev**에서 생성된 컨테이너와 연동되어 동작하며, Omeka 관련 데이터를 저장합니다.

컨테이너가 꺼져도 데이터베이스는 유지되지만 컨테이너가 삭제되는 경우 데이터베이스도 같이 삭제됩니다.

### php-dev

php/apache가 같이 포함된 php 이미지를 사용합니다. 본래는 omeka 소스코드가 DocumentRoot에 포함된 이미지를 생성하려고 했으나, DocumentRoot를 호스트에 접근할 수 있도록 하는 순간 omeka 소스코드가 삭제되는 문제가 있어 omeka 소스코드를 직접 복사 붙여넣기 하는 방식으로 전환하였습니다.

### elasticsearch

검색 기능을 제공하는 Elasticsearch의 이미지를 사용합니다. Omeka 플러그인을 통해 DB와 연동할 수 있으며 Omeka에 업로드된 자료의 색인과 검색이 가능해집니다. 최신 버전은 7.x 버전이지만 Omeka 플러그인이 지원하는 Elasticsearch의 가장 최근 버전이 6.x 이며, Kibana, Logstash도 동일한 메이저 버전을 사용하는 것이 호환성에서 유리하기 때문에 ELK 스택은 전부 6.x 버전으로 통일됩니다.

### kibana

데이터의 시각화 기능과 GUI를 제공하는 Kibana의 이미지를 사용합니다.

### logstash 

데이터 전처리 및 배치 처리를 수행하는 Logstash의 이미지를 사용합니다.



## 디렉토리 구조
**docker-playground** 디렉토리에는 mariadb, php-dev, php, html, omeka 총 다섯개의 디렉토리가 있습니다.

* mariadb
  db 이미지에 대한 Dockerfile이 들어있습니다. 이 디렉토리를 *docker-compose.yml*이 참조하여 db 컨테이너를 생성합니다.

* php-dev
php-dev 이미지에 대한 Dockerfile이 들어있습니다. 이 디렉토리를 *docker-compose.yml*이 참조하여 php-dev 컨테이너를 생성합니다.

* html
php-dev 컨테이너 생성 시 자동으로 생성되는 DocumentRoot 디렉토리입니다. 처음 컨테이너 생성 시 빈 디렉토리로 생성되며, 여기에 omeka 파일을 복사해 넣으면 아파치에서 실행됩니다.

* data_volume
  maria 컨테이너 생성 시 자동으로 생성되는 디렉토리입니다. 컨테이너 내부의 데이터베이스 파일이 호스트에 저장됩니다.

* elasticsearch
  엘라스틱 서치 Dockerfile과 설정 파일을 포함한 디렉토리입니다.

* kibana
  Kibana Dockerfile과 설정 파일을 포함한 디렉토리입니다.

* logstash
  Logstash Dockerfile과 설정파일을 포함한 디렉토리입니다.

* extensions
  ELK 스택 관련 확장 프로그램의 Dockerfile과 설정 파일을 포함한 디렉토리입니다.

*  omeka
  Omeka 2.7.1 버전 소스코드가 들어 있는 디렉토리입니다.
  db.ini 파일이 수정되어 있어서 DB username, password를 매번 수정하지 않아도 됩니다.
  파일 업로드 용량 제한을 80MB까지 조정해놓았습니다.

  *omeka.sh* 스크립트를 실행하면 자동으로 html 폴더에 복사됩니다.

다음은 *docker-playground* 디렉토리에 들어있는 파일입니다.

* docker-compose.yml
  db, php-dev, elasticsearch, kibana, logstash 이미지에 대한 설정이 포함되어 있습니다.
* .env
  *docker-compose.yml* 파일에서 참조할 수 있는 설정 파일입니다. 현재는 DB관련 설정만 들어 있습니다.
* manager.sh
  `./manager.sh` 명령어로 실행할 수 있습니다. 실행중인 Docker 컨테이너 확인, 정지, 삭제, 초기화 등의 기능을 합니다.
  반드시 superuser 권한으로 실행되어야 합니다.
