! Copyright (C) 2012 Eungju PARK.
! See http://factorcode.org/license.txt for BSD license.
USING: byte-arrays calendar destructors formatting io kernel math math.parser strings threads zmq zmq.ffi ;
IN: zmq.examples.taskwork

: taskwork ( -- )
    1 <zmq-context> [
        ! Socket to receive messages on
        ZMQ_PULL <zmq-socket> [
            dup "tcp://localhost:5557" zmq-connect
            ! Socket to send messages to
            ZMQ_PUSH <zmq-socket> [
                dup "tcp://localhost:5558" zmq-connect
                ! Process tasks forever
                [ t ] [
                    over 0 zmq-recv-byte-array >string
                    ! Simple progress indicator for the viewer
                    dup "%s." printf flush
                    ! Do the work
                    string>number milliseconds sleep
                    ! Send results to sink
                    dup "" >byte-array 0 zmq-send-byte-array
                ] while
                drop
            ] with-disposal
            drop
        ] with-disposal
    ] with-zmq-context ;

MAIN: taskwork
