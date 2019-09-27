#!/bin/bash
# Fivem Easy Server Manager

#	Author: WebGere
#	Website: https://webgere.pt

# Color Codes
    NORMAL="\033[0;39m"
    ROUGE="\033[1;31m"
    VERT="\033[1;32m"
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
	    echo -e "$ROUGE The [$SCREEN] server is already on !$NORMAL"
	else
		echo -e "$ROUGE Restarting mysql !$NORMAL"
		sudo service mysql restart
		sleep 10
        	echo -e "$ORANGE The [$SCREEN] server is going to start.$NORMAL"
		screen -dm -S $SCREEN
		sleep 2
		screen -x $SCREEN -X stuff "cd "$FIVEM_PATH"/server-data && bash "$FIVEM_PATH"/server/run.sh +exec server.cfg 
		"
		echo -e "$ORANGE Session restart.$NORMAL"
		sleep 20
		screen -x $SCREEN -X stuff "restart sessionmanager
		"
		echo -e "$VERT Session Ok ! $NORMAL"
		sleep 5
		echo -e "$VERT Server Ok ! $NORMAL"
		time=$(date +"%m_%d_%Y")
		echo -n "$time -- Server Started" >> $FIVEM_PATH/manage_log.txt
	fi
    ;;
    # -----------------[ Stop ]------------------ #
    stop)
	if ( running )
	then
		echo -e "$VERT The server will stop in 10 seconds. $NORMAL"
        	screen -S $SCREEN -p 0 -X stuff "`printf "say $MSG_off\r"`"; sleep 10
		screen -S $SCREEN -X quit
        	echo -e "$ROUGE The [$SCREEN] server has been stopped.$NORMAL"
		sleep 5
    		echo -e "$VERT Cleaning the cache. $NORMAL"
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
	    echo -e "$ROUGE The [$SCREEN] server us already running ! $NORMAL"
	else
	    echo -e "$VERT The [$SCREEN] is stopped. $NORMAL"
	fi
	  echo -e "$ROUGE The server will restart... $NORMAL"
		screen -S $SCREEN -p 0 -X stuff "`printf "say $MSG_180\r"`"; sleep 180
		screen -S $SCREEN -p 0 -X stuff "`printf "say $MSG_60\r"`"; sleep 60
		screen -S $SCREEN -p 0 -X stuff "`printf "say $MSG_30\r"`"; sleep 30
		screen -S $SCREEN -X quit
		echo -e "$VERT Server Closed $NORMAL"
		rm -R $FIVEM_PATH/server-data/cache/
		echo -e "$VERT Cleaning the cache. $NORMAL"
		sleep 2
		echo -e "$ORANGE Restart in progress ... $NORMAL"
		echo -e "$ROUGE Restarting mysql !$NORMAL"
		sudo service mysql restart
		sleep 10
        	echo -e "$ORANGE [$SCREEN] is going to start.$NORMAL"
		screen -dm -S $SCREEN
		sleep 2
		screen -x $SCREEN -X stuff "cd "$FIVEM_PATH"/server-data && bash "$FIVEM_PATH"/server/run.sh +exec server.cfg 
		"
		echo -e "$ORANGE Session Restart.$NORMAL"
		sleep 20
		screen -x $SCREEN -X stuff "restart sessionmanager
		"
		echo -e "$VERT [$SCREEN] is going to stop ! $NORMAL"
		echo -n "$time -- Server Restarted" >> $FIVEM_PATH/manage_log.txt
	;;	
    # -----------------[ Status ]---------------- #
	status)
	if ( running )
	then
	    echo -e "$VERT [$SCREEN] is running. $NORMAL"
	else
	    echo -e "$ROUGE [$SCREEN]is closed. $NORMAL"
	fi
	;;
    # -----------------[ Screen ]---------------- #
    screen)
        echo -e "$VERT Server Console [$SCREEN]. $NORMAL"
        screen -R $SCREEN
    ;;
	*)
    echo -e "$ORANGE Options :$NORMAL ./manage.sh {start|stop|status|screen|restart}"
    exit 1
    ;;
esac

exit 0
