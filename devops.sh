#!/bin/sh

DOCKER_APP_NAME=spring-boot
BLUECOMPOSE=docker-compose.blue.yml
GREENCOMPOSE=docker-compose.green.yml

usage()
{
	echo ""
	echo "# Usage : "
	echo " sh $0 [start | stop | restart | deploy | scaleout n]"
	echo " -h   Help"
	echo "ex) ./devops.sh start"
	exit
}
nginxconf_init(){
	NGINX_CONID=`docker container ps | grep nginx | grep 80 | cut -d ' ' -f 1`
	docker exec -it $NGINX_CONID ./etc/nginx/delete.sh
}
switch_nginx_reload()
{
	
	NGINX_CONID=`docker container ps | grep nginx | grep 80 | cut -d ' ' -f 1`
	CON_NUM=`docker container ps | grep apptest | grep Up | wc -l`
	EXIST_UP_BLUE=`docker container ps | grep 8080 | grep Up`
	EXIST_UP_GREEN=`docker container ps | grep 8180 | grep Up`

        nginxconf_init;
	for i in $(seq 1 $CON_NUM);
	do
		CON_NAME=`docker container ps | grep apptest | grep Up | rev | cut -d ' ' -f 1 | rev | sed -n ${i}p`		
		LINEWRITE=`docker exec -it $NGINX_CONID grep -n "upstream backend" /etc/nginx/nginx.conf_tmp | awk -F[":"] '{print $1}'`
		TARGETLINE=`expr $LINEWRITE + 1`
	
		if [ -z "$EXIST_UP_BLUE" ]; then
		docker exec -it $NGINX_CONID sed -i "${TARGETLINE}i\                server ${CON_NAME}:8180;" /etc/nginx/nginx.conf_tmp
		else
		docker exec -it $NGINX_CONID sed -i "${TARGETLINE}i\                server ${CON_NAME}:8080;" /etc/nginx/nginx.conf_tmp
	        fi	
		
	done

	
	docker exec -it $NGINX_CONID mv /etc/nginx/nginx.conf_tmp /etc/nginx/nginx.conf_tmp_new 2>&1
	docker exec -it $NGINX_CONID mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf_tmp 2>&1
	docker exec -it $NGINX_CONID mv /etc/nginx/nginx.conf_tmp_new /etc/nginx/nginx.conf 2>&1
	docker exec -it $NGINX_CONID service nginx  reload 2>&1
}
start()
{
	EXIST_UP_BLUE=`docker container ps | grep 8080 | grep Up`
	EXIST_UP_GREEN=`docker container ps | grep 8180 | grep Up`

 	if [[ -z "$EXIST_UP_BLUE" ]] && [[ -z "$EXIST_UP_GREEN" ]]; then	
	docker-compose -f docker-compose.yml up -d --build 2>&1

	else 
	echo "System is already running"
        exit 1	
	fi

	docker container ps

}
stop()
{
        EXIST_UP_BLUE=`docker container ps | grep 8080 | grep Up`
        EXIST_UP_GREEN=`docker container ps | grep 8180 | grep Up`	
	NGINX_CONID=`docker container ps | grep nginx | grep 80 | cut -d ' ' -f 1`

	if [[ -z "$EXIST_UP_BLUE" ]] && [[ -z "$EXIST_UP_GREEN" ]] && [[ -z "$NGINX_CONID" ]]; then
	echo "Any container are not booted"
	exit 1

#	elif [ -z "$EXIST_UP_BLUE" ]; then
#	GREEN_CONID=`docker container ps | grep 8180 | cut -d ' ' -f 1 | sed -n 1p`
#	GREEN_CONID_2=`docker container ps  | grep 8180 | cut -d ' ' -f 1 | sed -n 2p`
#	NGINX_CONID=`docker container ps | grep nginx | grep 80 | cut -d ' ' -f 1`
#
#	docker container stop $GREEN_CONID $GREEN_CONID_2 $NGINX_CONID 2>&1
#
	else
#	BLUE_CONID=`docker container ps | grep 8080 | cut -d ' ' -f 1 | sed -n 1p`
#	BLUE_CONID_2=`docker container ps | grep 8080 | cut -d ' ' -f 1 | sed -n 2p`	
#	NGINX_CONID=`docker container ps | grep nginx | grep 80 | cut -d ' ' -f 1`

#	docker container stop $BLUE_CONID $BLUE_CONID_2 $NGINX_CONID 2>&1
	docker-compose stop
	fi

	docker container ps
}
restart()
{
	
	
	stop;
	docker-compose start

	docker container ps

}


deploy()
{
	
	echo "> Check which one is in alive "

	EXIST_UP_BLUE=`docker container ps | grep 8080 | grep Up`
	EXIST_UP_GREEN=`docker container ps | grep 8180 | grep Up`
	
	if [[ -z "$EXIST_UP_BLUE" ]] && [[ -z "$EXIST_UP_GREEN" ]]; then
		echo "This is the first deployment"
        	echo "Blue container group will be raised up"
		docker-compose -f docker-compose.yml up -d --build 2>&1
		echo "Blue container is sucessfully raised up"
 		 	
	elif [ -z "$EXIST_UP_BLUE" ]; then
		echo "Green one(port 8180) is in alive"
		echo "Deployment will be done at BLUE(Port 8080) wihtout system down"
		docker-compose -f $BLUECOMPOSE up -d --build 2>&1
		sleep 20
		echo "Deployment is sucessfully done at BLUE(Port 8080)"
		switch_nginx_reload; 

#		GREEN_CONID=`docker container ps | grep 8180 | cut -d ' ' -f 1 | sed -n 1p`
#		GREEN_CONID_2=`docker container ps | grep 8180 | cut -d ' ' -f 1 | sed -n 2p`
	        GREEN_NUM=`docker container ps | grep Up | grep 8180 | wc -l`
		for i in $(seq 1 $GREEN_NUM);
		do
	
			GREEN_CONID=`docker container ps | grep 8180 | cut -d ' ' -f 1 | sed -n 1p`	
			docker container stop $GREEN_CONID 2>&1
		done

#		docker container stop $GREEN_CONID $GREEN_CONID_2 2>&1
		echo "Green ones are gone"		
	else
                echo "Blue one(port 8080) is in alive"
                echo "Deployment will be done at GREEN(Port 8180) wihtout system down"
                docker-compose -f $GREENCOMPOSE up -d --build 2>&1
                sleep 20 
                switch_nginx_reload; 
       	        echo "Deployment is sucessfully done at GREEN(Port 8180)"

       #         BLUE_CONID=`docker container ps  | grep 8080 | cut -d ' ' -f 1 | sed -n 1p`
       #         BLUE_CONID_2=`docker container ps  | grep 8080 | cut -d ' ' -f 1 | sed -n 2p`
                BLUE_NUM=`docker container ps | grep Up | grep 8080 | wc -l`
                for i in $(seq 1 $BLUE_NUM);
                do
                        BLUE_CONID=`docker container ps | grep 8080 | cut -d ' ' -f 1 | sed -n 1p`
                        docker container stop $BLUE_CONID 2>&1

                done

#		docker container stop $BLUE_CONID $BLUE_CONID_2 2>&1
                echo "Blue container is gone"          
	
	fi
	


#	EXIST_UP_BLUE=`docker-compose -p $DOCKER_APP_NAME-blue -f $BLUECOMPOSE ps | grep Up`
#
#	if [ -z "$EXIST_UP_BLUE" ]; then
#		echo "New Deployment is started at Blue -> Blue goes up & Green goes down"
#		docker-compose -p $DOCKER_APP_NAME-blue -f $BLUECOMPOSE up -d --build 
#
#		sleep 10
#		docker-compose -p $DOCKER_APP_NAME-green -f $GREENCOMPOSE down
#	else
#		echo "New Deployment is started at Green -> Green goes up & Blue goes down"
#		docker-compose -p $DOCKER_APP_NAME-green -f $GREENCOMPOSE up -d --build 
#
#		sleep 10
#		docker-compose -p $DOCKER_APP_NAME-blue -f $BLUECOMPOSE down 
#	fi

	docker container ps


}
scaleout(){
	EXIST_UP_BLUE=`docker container ps | grep 8080 | grep Up`
	EXIST_UP_GREEN=`docker container ps | grep 8180 | grep Up`


	if [[ -z "$EXIST_UP_BLUE" ]] && [[ -z "$EXIST_UP_GREEN" ]]; then
		echo "Start first"
	elif [ -z "$EXIST_UP_BLUE" ]; then	
		docker-compose -f $GREENCOMPOSE up --scale apptest01_green=$2 --scale apptest_green=$2 -d  2>&1
	else
		docker-compose -f $BLUECOMPOSE up --scale apptest01_blue=$2 --scale apptest_blue=$2 -d  2>&1	
	fi
	sleep 20
	switch_nginx_reload;

	docker container ps

	
}


main_proc()
{
	case $@ in
		start) start;;
		stop) stop;;
		restart) restart;;
		deploy) deploy;;
		scaleout) scaleout;;
		\?) exit;
	esac
}
if [ $# -eq 0 ]; then
	echo "Please specify command"
elif [ $1 != "start" -a  $1 != "stop" -a $1 != "restart" -a $1 != "deploy" -a $1 != "scaleout" ]; then
	  	usage;
elif [[ $1 == "scaleout" ]] && [[ -n "$2" ]]; then
		scaleout $@
else
	main_proc $1;	
fi

while getopts :h options
do
	case $options in
		h) usage;;
		\?) exit;
	esac
done

