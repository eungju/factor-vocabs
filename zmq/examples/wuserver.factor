! Copyright (C) 2012 Eungju PARK.
! See http://factorcode.org/license.txt for BSD license.
USING: byte-arrays calendar destructors formatting io kernel math namespaces random strings threads zmq zmq.ffi ;
IN: zmq.examples.wuserver

: wuserver ( -- )
    1 <zmq-context> [
        ZMQ_PUB <zmq-socket> [
            dup "tcp://*:5556" zmq-bind
            dup "ipc://weather.ipc" zmq-bind
            random-generator get now timestamp>unix-time seed-random [
                [ t ] [
                    dup
                    100000 random
                    215 random 80 -
                    50 random 10 +
                    "%05d %d %d" sprintf
                    >byte-array 0 zmq-send-byte-array
                ] while
            ] with-random drop
        ] with-disposal
    ] with-zmq-context ;

MAIN: wuserver
