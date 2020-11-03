#! /bin/bash

# root 권한 확인
if [ $(id -u) -ne 0 ]; then exec sudo bash "$0" "$@"; exit; fi

# 쉘스크립트 위치로 이동
cd "$(dirname "$0")" 

# 1~7 숫자를 입력받아서 그대로 반환하는 함수
# 문자열 e를 입력받으면 바로 프로그램을 종료하고 1~4 / "e" 가 아니면 255를 반환한다
input()
{
    running=`docker ps -aq -f "status=running" | wc -l`
    paused=`docker ps -aq -f "status=exited" | wc -l`
    echo -e "실행 중인 컨테이너 :   $running 개"
    echo -e "정지된 컨테이너    :   $paused 개\n"
    
    echo -e "1) docker 컨테이너 재생성 & 실행"
    echo -e "2) docker 컨테이너 삭제"
    echo -e "3) 실행 중인 docker 컨테이너 확인"
    echo -e "4) 전체 docker 컨테이너 리스트 확인"
    echo -e "5) 모든 docker 컨테이너 정지"
    echo -e "6) 정지된 docker 컨테이너 재시작"
    echo -e "7) (html 디렉토리) 소유자 권한 수정\n"

    echo -n "숫자를 입력하세요 (프로그램 종료는 exit) "
    read num

    if [ $num == 1 -o $num == 2 -o $num == 3 -o $num == 4 -o $num == 5 -o $num == 6 -o $num == 7 ]; then return $num; fi

    if [ $num == "exit" ]; then exit 0; fi

    return 255
}

# 도커 컨테이너 / 네트워크 / 마운트된 볼륨을 전부 삭제하고 다시 생성한다.
compose_recreate()
{
    echo -n "[주의] 이 명령어는 omeka 디렉토리와 데이터베이스를 전부 삭제합니다. 계속 진행하려면 y를 입력하세요 (y/n) "
    read confirm

    if [ $confirm == "y" ]; then
        compose_cleanup

        echo -e "`docker-compose up -d`"

        echo -e "`cp -rv ./omeka/* ./html`"
        echo -e "`cp -rv ./omeka/.htaccess ./html/.htaccess`"
        change_owner
    fi
}

# 도커 컨테이너 / 네트워크 / 마운트된 볼륨을 전부 삭제한다.
compose_down()
{
    echo -n "[주의] 이 명령어는 omeka 디렉토리와 데이터베이스를 전부 초기화 합니다. 계속 진행하려면 y를 입력하세요 (y/n) "
    read confirm

    if [ $confirm == "y" ]; then
        compose_cleanup
    fi
}

# docker-down을 실행하고 html, data_volume 디렉토리를 삭제한다
compose_cleanup()
{
    count=0
    if [[ $(docker ps -aq -f "name=php-dev" | wc -l) = "1" ]]; then ((count+=1)); fi
    if [[ $(docker ps -aq -f "name=maria" | wc -l) = "1" ]]; then ((count+=1)); fi
    if [[ $(docker ps -aq -f "name=elasticsearch" | wc -l) = "1" ]]; then ((count+=1)); fi
    if [[ $(docker ps -aq -f "name=kibana" | wc -l) = "1" ]]; then ((count+=1)); fi
    if [[ $(docker ps -aq -f "name=logstash" | wc -l) = "1" ]]; then ((count+=1)); fi

    if [ ${count} -gt 0 ]; then
        echo -e "`docker-compose down`"
        echo -e "`rm -rfv html data_volume`"
    fi
}

# 실행중인 컨테이너 확인 
docker_ps()
{
    echo -e "`docker ps`"
}

# 전체 컨테이너 확인
docker_ps_all() {
    echo -e "`docker ps -a`"
}

# 모든 컨테이너 시작
compose_start()
{
    echo -e "컨테이너를 시작합니다.\n"
    echo -e "`docker start maria php-dev elasticsearch kibana logstash`"
}

# 컨테이너 정지
compose_stop()
{
    echo -e "컨테이너를 정지합니다.\n"
    echo -e "`docker stop maria php-dev elasticsearch kibana logstash`"
}

# 소유자 재설정
change_owner()
{
    echo -e "`chown -Rv www-data:www-data ./html/* ./html/.htaccess`"
}

# 실제 실행되는 코드부
clear
while [ true ]
do
    input
    num=$?

    clear
    case $num in
        1) compose_recreate ;;
        2) compose_down ;;
        3) docker_ps ;;
        4) docker_ps_all ;;
        5) compose_stop ;;
        6) compose_start ;;
        7) change_owner ;;
        *) echo "다시 입력해주세요." ;;
    esac
    echo ""
done

exit 0