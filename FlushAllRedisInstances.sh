#!/bin/bash
#title           :FlushAllRedisInstances
#description     :This script will flush all Redis instances
#author		 :Eugenio Marzo
#date            :25/05/2015
#version         :1.0
#usage		 :bash FlushAllRedisInstances.sh -h=foo.org  -p=6380,6381

REDIS_CLI="/opt/apw/bin/redis-cli"

function flushall_redis {
 echo "executing ssh $1@$2 \"echo 'GET dog:name' |  $REDIS_CLI  -p $3\""
 ret_val=`ssh $1@$2 "echo 'FLUSHALL' | $REDIS_CLI  -p $3"`
 if [ $ret_val == "OK" ];
 then
  echo "Flushall for port $3 OK.."
 else
  echo "Error on Fliushall port $3"
  exit 2
 fi

}




for i in "$@"
do
case $i in
    -h=*|--host=*)
    REDIS_SERVER="${i#*=}"
    shift # past argument=value
    ;;
    -u=*|--user=*)
    SSH_USER="${i#*=}"
    shift # past argument=value
    ;;
    -p=*|--ports=*)
    PORTS="${i#*=}"
    shift # past argument=value
    ;;
    
    *)
        echo  "ERROR: $i is an unknown option.."
        exit 2
    ;;
esac
done

[ -z $PORTS ] && echo "Please insert PORTS numbers of redice instances.. Es :  -p=6380,6381" && exit 2
[ -z $REDIS_SERVER ] && echo "Please insert redis server hostname or ip.. Es :  -h=127.0.0.1 "  && exit 2
[ -z $SSH_USER ] && echo "Please insert ssh user.. Es: -u=root" && exit 2

echo 
echo "#############################"
echo "# Redis Server: $REDIS_SERVER"
echo "# SSH user: $SSH_USER"
echo "# Ports: `echo $PORTS | sed 's/,/\ /g'`"
echo "#############################"
echo

for i in $(echo  $PORTS | tr "," "\n") 
do 
 echo "Flushing instance on port $i.." ; 
 flushall_redis $SSH_USER $REDIS_SERVER $i
 sleep 1
done

exit 0








