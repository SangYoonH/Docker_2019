#!/bin/bash

LINENUM=`grep -n "server.*80" /etc/nginx/nginx.conf_tmp | awk -F[:] '{print $1}' | wc -l`

for i in $(seq 1 $LINENUM);
do
	LINE=`grep -n "server.*80" /etc/nginx/nginx.conf_tmp | awk -F[:] '{print $1}' | sed -n 1p`
	sed -i "${LINE}d" /etc/nginx/nginx.conf_tmp
done 
