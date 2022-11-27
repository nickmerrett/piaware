#!/bin/bash
#
# Refer to https://hub.docker.com/r/inodes/rtlsdr-dump1090-piaware/
if [[ -x ./dump1090 ]]
then
    ./dump1090 --net --gain -10 --ppm 1 --oversample --fix --lat ${LAT} --lon ${LONG} --max-range 400 \
               --net-ri-port 30001 --net-ro-port 30002 --net-bi-port 30004 --net-bo-port 30005 --net-sbs-port 30003 \
               --net-fatsv-port 10001 --net-heartbeat 60 --net-ro-size 500 --net-ro-interval 1 --net-buffer 2 \
               --stats-every 3600 --write-json /run/dump1090-mutability --write-json-every 1 --json-location-accuracy 2 --quiet &

elif [[ -x /usr/bin/dump1090-fa ]]
then
    /usr/bin/dump1090-fa --net --gain -10 --ppm 1 --lat ${LAT} --lon ${LONG} --max-range 400 \
               --net-ro-interval 1 --net-buffer 2 --net-heartbeat 60 --net-ro-size 1000  --net-http-port 0 \
               --net-ri-port 0 --net-ro-port 30002 --net-sbs-port 30003 --net-bi-port 30004,30104 \
               --net-bo-port 30005 --fix --device-index ${DEVICE} \
               --json-location-accuracy 2 --stats-every 600 --write-json /run/dump1090-fa --write-json-every 1 --quiet &

    ln -s /etc/lighttpd/conf-available/88-dump1090-fa-statcache.conf /etc/lighttpd/conf-enabled/
    ln -s /etc/lighttpd/conf-available/89-dump1090-fa.conf /etc/lighttpd/conf-enabled/
else
    echo "ERROR: Cannot execute dump1090"
    exit 126
fi

if [[ -x /usr/bin/piaware ]]
then
    if [[ ! -z $FLIGHTAWARE_USER ]] && [[ ! -z $FLIGHTAWARE_PASS ]]
    then
        echo "Adding user $FLIGHTAWARE_USER and password $FLIGHTAWARE_PASS to Flightaware configuration"
        /usr/bin/piaware-config flightaware-user "${FLIGHTAWARE_USER:?}"
        /usr/bin/piaware-config flightaware-password "${FLIGHTAWARE_PASS:?}"
    fi

    if [ -n "${FEEDER_ID}" ]; then
        /usr/bin/piaware-config feeder-id "${FEEDER_ID}"
    fi
    
    ln -s /etc/lighttpd/conf-available/50-piaware.conf /etc/lighttpd/conf-enabled/

    service lighttpd stop
    service lighttpd start
    service lighttpd status

    /usr/bin/piaware -v
    /usr/bin/piaware -showtraffic -plainlog -p /run/piaware/piaware.pid -statusfile /run/piaware/status.json 
fi

