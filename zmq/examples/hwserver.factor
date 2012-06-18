! Copyright (C) 2012 Eungju PARK.
! See http://factorcode.org/license.txt for BSD license.
USING: byte-arrays calendar destructors formatting io kernel strings threads zmq zmq.ffi ;
IN: zmq.examples.hwserver

: hwserver ( -- )
    1 <zmq-context> [
        ZMQ_REP <zmq-socket> [
            dup "tcp://*:5555" zmq-bind
            [ t ] [
                dup
                [ 0 zmq-recv-byte-array >string "Received %s\n" printf flush ]
                [ drop 1 seconds sleep ]
                [ "World" >byte-array 0 zmq-send-byte-array ]
                tri
            ] while drop
        ] with-disposal
    ] with-zmq-context ;

MAIN: hwserver
