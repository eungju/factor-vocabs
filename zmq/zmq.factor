! Copyright (C) 2012 Eungju PARK.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data arrays byte-arrays classes.struct combinators continuations destructors io kernel math namespaces sequences zmq.ffi ;
IN: zmq

ERROR: zmq-error n string ;

: throw-zmq-error ( -- )
    zmq_errno dup zmq_strerror zmq-error ; inline

: check-zmq-error ( retval -- )
    0 = [ throw-zmq-error ] unless ; inline


: zmq-version ( -- major minor patch )
    { int int int } [ zmq_version ] with-out-parameters ;


TUPLE: zmq-msg underlying ;

: <zmq-msg> ( -- msg )
    zmq_msg_t <struct> dup zmq_msg_init check-zmq-error
    zmq-msg boa ;

: <byte-array-zmq-msg> ( byte-array -- msg )
    zmq_msg_t <struct> dup rot dup length f f zmq_msg_init_data check-zmq-error
    zmq-msg boa ;
    
M: zmq-msg dispose
    underlying>> zmq_msg_close check-zmq-error ;
    
: zmq-msg-data ( msg -- data )
    underlying>> zmq_msg_data ;

: zmq-msg-size ( msg -- size )
    underlying>> zmq_msg_size ;


TUPLE: zmq-context underlying ;

: <zmq-context> ( n -- context )
    zmq_init dup [ throw-zmq-error ] unless
    zmq-context boa ;

M: zmq-context dispose
    underlying>> zmq_term check-zmq-error ;

: with-zmq-context* ( context quot -- )
    zmq-context swap with-variable ; inline

: with-zmq-context ( context quot -- )
    [ with-zmq-context* ] curry with-disposal ; inline


TUPLE: zmq-socket underlying ;

: <zmq-socket> ( type -- socket )
    zmq-context get underlying>> swap zmq_socket dup [ throw-zmq-error ] unless
    zmq-socket boa ;

M: zmq-socket dispose
    underlying>> zmq_close check-zmq-error ;

: zmq-setsockopt ( socket name value -- )
    [ underlying>> ] 2dip
    over {
        { ZMQ_SUBSCRIBE [ dup length ] }
        { ZMQ_UNSUBSCRIBE [ dup length ] }
        { ZMQ_RCVTIMEO [ 4 ] }
        { ZMQ_SNDTIMEO [ 4 ] }
    } case
    zmq_setsockopt check-zmq-error ;

: zmq-bind ( socket addr -- )
    [ underlying>> ] dip zmq_bind check-zmq-error ;

: zmq-connect ( socket addr -- )
    [ underlying>> ] dip zmq_connect check-zmq-error ;

: zmq-send ( socket msg flags -- )
    [ [ underlying>> ] bi@ ] dip zmq_send check-zmq-error ;

: zmq-recv ( socket msg flags -- )
    [ [ underlying>> ] bi@ ] dip zmq_recv check-zmq-error ;

: zmq-send-byte-array ( socket byte-array flags -- )
  swap <byte-array-zmq-msg> [ swap zmq-send ] with-disposal ;

: zmq-recv-byte-array ( socket flags -- byte-array )
  <zmq-msg> [ dup -rot [ zmq-recv ] dip
              [ zmq-msg-data ] [ zmq-msg-size ] bi memory>byte-array
  ] with-disposal ;

! : zmq-poll ( items nitems timeout -- n )
!     zmq_poll dup < 0 [ throw-zmq-error ] when ;

! : zmq-device ( device frontend backend -- )
!    zmq_device check-zmq-error ;
