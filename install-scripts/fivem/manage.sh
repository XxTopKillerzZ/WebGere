#!/bin/bash
# Fivem Easy Server Manager

#	Author: WebGere
#	Website: https://webgere.pt

# Color Codes
    DEFAULT="\033[0;39m"
    RED="\033[1;31m"
    GREEN="\033[1;32m"
    ORANGE="\033[1;33m"
	
# Messages customs
    MSG_180="The server is going to restart in 3 Minutes!"
    MSG_60="The server is going to restart in 1 Minute!"
    MSG_30="The server is going to restart in 30 Seconds!"
    
    MSG_off="The server is going shutdown in 10 seconds!"
	
# Path
    FIVEM_PATH=/home/fivem

# Screen
    SCREEN="fivem"

cd $FIVEM_PATH	
running(){
    if ! screen -list | grep -q "$SCREEN"
    then
        return 1
    else
        return 0
    fi
}	

case "$1" in
    # -----------------[ Start ]----------------- #
    start)
	if ( running )
	then
	    echo -e "$RED The [$SCREEN] server is already on !$DEFAULT"
	else
		echo -e "$RED Restarting mysql !$DEFAULT"
		sudo service mysql restart
		sleep 10
        	echo -e "$ORANGE The [$SCREEN] server is going to start.$DEFAULT"
		screen -dm -S $SCREEN
		sleep 2
		screen -x $SCREEN -X stuff "cd "$FIVEM_PATH"/server-data && bash "$FIVEM_PATH"/server/run.sh +exec server.cfg 
		"
		echo -e "$ORANGE Session restart.$DEFAULT"
		sleep 20
		screen -x $SCREEN -X stuff "restart sessionmanager
		"
		echo -e "$GREEN Session Ok ! $DEFAULT"
		sleep 5
		echo -e "$GREEN Server Ok ! $DEFAULT"
		time=$(date +"%m_%d_%Y")
		echo -n "$time -- Server Started" >> $FIVEM_PATH/manage_log.txt
	fi
    ;;
    # -----------------[ Stop ]------------------ #
    stop)
	if ( running )
	then
		echo -e "$GREEN The server will stop in 10 seconds. $DEFAULT"
        	screen -S $SCREEN -p 0 -X stuff "`printf "say $MSG_off\r"`"; sleep 10
		screen -S $SCREEN -X quit
        	echo -e "$RED The [$SCREEN] server has been stopped.$DEFAULT"
		sleep 5
    		echo -e "$GREEN Cleaning the cache. $DEFAULT"
		rm -R $FIVEM_PATH/server-data/cache/
		echo -n "$time -- Server Stopped" >> $FIVEM_PATH/manage_log.txt
	else
	    echo -e "The [$SCREEN] server is stopped."
	fi
    ;;
    # ----------------[ Restart ]---------------- #
	restart)
	if ( running )
	then
	    echo -e "$RED The [$SCREEN] server us already running ! $DEFAULT"
	else
	    echo -e "$GREEN The [$SCREEN] is stopped. $DEFAULT"
	fi
	  echo -e "$RED The server will restart... $DEFAULT"
		screen -S $SCREEN -p 0 -X stuff "`printf "say $MSG_180\r"`"; sleep 180
		screen -S $SCREEN -p 0 -X stuff "`printf "say $MSG_60\r"`"; sleep 60
		screen -S $SCREEN -p 0 -X stuff "`printf "say $MSG_30\r"`"; sleep 30
		screen -S $SCREEN -X quit
		echo -e "$GREEN Server Closed $DEFAULT"
		rm -R $FIVEM_PATH/server-data/cache/
		echo -e "$GREEN Cleaning the cache. $DEFAULT"
		sleep 2
		echo -e "$ORANGE Restart in progress ... $DEFAULT"
		echo -e "$RED Restarting mysql !$DEFAULT"
		sudo service mysql restart
		sleep 10
        	echo -e "$ORANGE [$SCREEN] is going to start.$DEFAULT"
		screen -dm -S $SCREEN
		sleep 2
		screen -x $SCREEN -X stuff "cd "$FIVEM_PATH"/server-data && bash "$FIVEM_PATH"/server/run.sh +exec server.cfg 
		"
		echo -e "$ORANGE Session Restart.$DEFAULT"
		sleep 20
		screen -x $SCREEN -X stuff "restart sessionmanager
		"
		echo -e "$GREEN [$SCREEN] is going to stop ! $DEFAULT"
		echo -n "$time -- Server Restarted" >> $FIVEM_PATH/manage_log.txt
	;;	
    # -----------------[ Status ]---------------- #
	status)
	if ( running )
	then
	    echo -e "$GREEN [$SCREEN] is running. $DEFAULT"
	else
	    echo -e "$RED [$SCREEN] is closed. $DEFAULT"
	fi
	;;
    # -----------------[ Screen ]---------------- #
    screen)
        echo -e "$GREEN Server Console [$SCREEN]. $DEFAULT"
        screen -R $SCREEN
    ;;
	*)
    echo -e "$ORANGE Options :$DEFAULT ./manage.sh {start|stop|status|screen|restart}"
    exit 1
    ;;
esac

exit 0
