#!/bin/sh
. /etc/functions.sh

include /lib/upgrade/

if (eval platform_check_image "$*")
then
	return 0;
else
	return 1;
fi

