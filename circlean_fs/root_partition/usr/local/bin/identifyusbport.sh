#!/bin/bash

DEBUG_FILE=/dev/shm/identifyusbport.txt
ACTION="connected"
DEVPATH="$1"
USBPORT="$2"

function FoundSource(){
		echo "upper left connected, source_key '${USBPORT}' ${ACTION}" >> ${DEBUG_FILE}
		echo source_key
}

echo -e "\nStart" >> ${DEBUG_FILE}
echo "Parameter 1: $1" >> ${DEBUG_FILE}
echo "Parameter 2: $2" >> ${DEBUG_FILE}
echo "Parameter 3: $3" >> ${DEBUG_FILE}

if (echo "$3" | grep -q "remove") ; then                         
	if (echo "$2" | grep -v -q "1-1.") ; then
		echo "ignore unknown remove $2" >> ${DEBUG_FILE}
		exit 0
	fi
	if (echo "$2" | grep -q ":") ; then
		echo "ignore remove subpath $2" >> ${DEBUG_FILE}
		exit 0
	fi
  ACTION="disconnected"
	DEVPATH="${2}/"
fi

MODEL=$(cat /proc/device-tree/model | tr -d '\000')
echo Device model: ${MODEL} >> ${DEBUG_FILE}
echo Devpath: ${DEVPATH} >> ${DEBUG_FILE}

if (echo "$MODEL" | grep -q "Raspberry Pi 3 Model B Plus") ; then 
	echo "found Raspberry Pi 3 B+ with special assignment" >> ${DEBUG_FILE}
	if (echo "${DEVPATH}" | grep -q "1-1.1.2/") ; then	
		FoundSource	
		exit 0
	fi
elif (echo "$MODEL" | grep -q "Raspberry Pi 4 Model B") ; then
        echo "found  Raspberry Pi 4 B with special assignment" >> ${DEBUG_FILE}
        if (echo "${DEVPATH}" | grep -q "1-1.3/") ; then                   
                FoundSource	
                exit 0
        fi
else
        echo "unsing default mapping" >> ${DEBUG_FILE}
        if (echo "${DEVPATH}" | egrep -q "1-1.1/|1-1.2/") ; then        
                FoundSource
                exit 0
        fi
fi
echo "dest_key $2 $ACTION" >> ${DEBUG_FILE}
echo dest_key

