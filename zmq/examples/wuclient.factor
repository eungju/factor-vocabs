! Copyright (C) 2012 Eungju PARK.
! See http://factorcode.org/license.txt for BSD license.
USING: byte-arrays command-line destructors formatting io kernel math math.parser namespaces sequences splitting strings zmq zmq.ffi ;
IN: zmq.examples.wuclient

: wuclient ( -- )
    1 <zmq-context> [
        "Collecting updates from weather server…" print
        ZMQ_SUB <zmq-socket> [
            dup "tcp://localhost:5556" zmq-connect
            command-line get dup empty? [ drop "10001 " ] [ first ] if
            2dup >byte-array ZMQ_SUBSCRIBE swap zmq-setsockopt
            0 100 dup [
                [ pick 0 zmq-recv-byte-array
                  >string " " split [ string>number ] map second +
                ] times
            ] dip
            / "Average temperature for zipcode '%s' was %dF\n" printf
            drop
        ] with-disposal
    ] with-zmq-context ;
    
MAIN: wuclient

