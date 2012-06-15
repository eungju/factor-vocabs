! Copyright (C) 2012 Eungju PARK.
! See http://factorcode.org/license.txt for BSD license.
USING: byte-arrays destructors formatting io kernel sequences strings zmq zmq.ffi ;
IN: zmq.examples.hwclient

: hwclient ( -- )
    1 <zmq-context> [
        "Connecting to hello world server…" print
        ZMQ_REQ <zmq-socket> [
            dup "tcp://localhost:5555" zmq-connect
            10 iota [
                [ "Hello" dup rot "Sending %s %d...\n" printf
                  dupd >byte-array 0 zmq-send-byte-array ]
                [ [ dup 0 zmq-recv-byte-array >string ] dip
                  "Received %s %d\n" printf flush ]
                bi
            ] each
        ] with-disposal drop
    ] with-zmq-context ;
    
MAIN: hwclient

