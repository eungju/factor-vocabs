! Copyright (C) 2012 Eungju PARK.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.accessors alien.c-types alien.data alien.libraries alien.syntax byte-arrays classes.struct combinators kernel literals math system ;
IN: zmq.ffi

<< "zmq" {
  { [ os windows? ] [ "zmq.dll" stdcall ] }
  { [ os macosx? ] [ "libzmq.dylib" cdecl ] }
  { [ os unix? ] [ "libzmq.so" cdecl ] }
} cond add-library >>
LIBRARY: zmq

!
! 0MQ versioning support.
!

FUNCTION: void zmq_version ( int* major, int* minor, int* patch ) ;

!
! 0MQ errors.
!

<< CONSTANT: ZMQ_HAUSNUMERO 156384712 >>

! Native 0MQ error codes.
CONSTANT: EFSM $[ ZMQ_HAUSNUMERO 51 + ]
CONSTANT: ENOCOMPATPROTO $[ ZMQ_HAUSNUMERO 52 + ]
CONSTANT: ETERM $[ ZMQ_HAUSNUMERO 53 + ]
CONSTANT: EMTHREAD $[ ZMQ_HAUSNUMERO 54 + ]

FUNCTION: int zmq_errno ( ) ;
FUNCTION: c-string zmq_strerror ( int errnum ) ;

!
! 0MQ message definition.
!

CONSTANT: ZMQ_MAX_VSM_SIZE 30

CONSTANT: ZMQ_DELIMITER 31
CONSTANT: ZMQ_VSM 32

CONSTANT: ZMQ_MSG_MORE 1
CONSTANT: ZMQ_MSG_SHARED 128
CONSTANT: ZMQ_MSG_MASK 129

STRUCT: zmq_msg_t
  { content void* }
  { flags uchar }
  { vsm_size uchar }
  { vsm_data uchar[ZMQ_MAX_VSM_SIZE] } ;

CALLBACK: void zmq_free_fn ( void* data, void* hint ) ;

FUNCTION: int zmq_msg_init ( zmq_msg_t* msg ) ;
FUNCTION: int zmq_msg_init_size ( zmq_msg_t* msg, size_t size ) ;
FUNCTION: int zmq_msg_init_data ( zmq_msg_t* msg, void* data, size_t size, zmq_free_fn* ffn, void* hint ) ;
FUNCTION: int zmq_msg_close ( zmq_msg_t* msg ) ;
FUNCTION: int zmq_msg_move ( zmq_msg_t* dest, zmq_msg_t* src ) ;
FUNCTION: int zmq_msg_copy ( zmq_msg_t* dest, zmq_msg_t* src ) ;
FUNCTION: void* zmq_msg_data ( zmq_msg_t* msg ) ;
FUNCTION: size_t zmq_msg_size ( zmq_msg_t* msg ) ;

!
! 0MQ infrastructure (a.k.a. context) initialisation & termination.
!

FUNCTION: void* zmq_init ( int io_threads ) ;
FUNCTION: int zmq_term ( void* context ) ;

!
! 0MQ socket definition.
!

! Socket types.
CONSTANT: ZMQ_PAIR 0
CONSTANT: ZMQ_PUB 1
CONSTANT: ZMQ_SUB 2
CONSTANT: ZMQ_REQ 3
CONSTANT: ZMQ_REP 4
CONSTANT: ZMQ_DEALER 5
CONSTANT: ZMQ_ROUTER 6
CONSTANT: ZMQ_PULL 7
CONSTANT: ZMQ_PUSH 8
CONSTANT: ZMQ_XPUB 9
CONSTANT: ZMQ_XSUB 10

! Socket options.
CONSTANT: ZMQ_HWM 1
CONSTANT: ZMQ_SWAP 3
CONSTANT: ZMQ_AFFINITY 4
CONSTANT: ZMQ_IDENTITY 5
CONSTANT: ZMQ_SUBSCRIBE 6
CONSTANT: ZMQ_UNSUBSCRIBE 7
CONSTANT: ZMQ_RATE 8
CONSTANT: ZMQ_RECOVERY_IVL 9
CONSTANT: ZMQ_MCAST_LOOP 10
CONSTANT: ZMQ_SNDBUF 11
CONSTANT: ZMQ_RCVBUF 12
CONSTANT: ZMQ_RCVMORE 13
CONSTANT: ZMQ_FD 14
CONSTANT: ZMQ_EVENTS 15
CONSTANT: ZMQ_TYPE 16
CONSTANT: ZMQ_LINGER 17
CONSTANT: ZMQ_RECONNECT_IVL 18
CONSTANT: ZMQ_BACKLOG 19
CONSTANT: ZMQ_RECOVERY_IVL_MSEC 20
CONSTANT: ZMQ_RECONNECT_IVL_MAX 21
CONSTANT: ZMQ_RCVTIMEO 27
CONSTANT: ZMQ_SNDTIMEO 28

! Send/recv options.
CONSTANT: ZMQ_NOBLOCK 1
CONSTANT: ZMQ_SNDMORE 2

FUNCTION: void* zmq_socket ( void* context, int type ) ;
FUNCTION: int zmq_close ( void* s ) ;
FUNCTION: int zmq_setsockopt ( void* s, int option, void* optval, size_t optvallen ) ;
FUNCTION: int zmq_getsockopt ( void* s, int option, void* optval, size_t* optvallen ) ;
FUNCTION: int zmq_bind ( void* s, c-string addr ) ;
FUNCTION: int zmq_connect ( void* s, c-string addr ) ;
FUNCTION: int zmq_send ( void* s, zmq_msg_t* msg, int flags ) ;
FUNCTION: int zmq_recv ( void* s, zmq_msg_t* msg, int flags ) ;

!
! I/O multiplexing. 
!

CONSTANT: ZMQ_POLLIN 1
CONSTANT: ZMQ_POLLOUT 2
CONSTANT: ZMQ_POLLERR 4

STRUCT: zmq_pollitem_t
  { socket void* }
  { fd int }
  { events short }
  { revents short } ;

FUNCTION: int zmq_poll ( zmq_pollitem_t* items, int nitems, long timeout ) ;

!
! Built-in devices
!

CONSTANT: ZMQ_STREAMER 1
CONSTANT: ZMQ_FORWARDER 2
CONSTANT: ZMQ_QUEUE 3

FUNCTION: int zmq_device ( int device, void* insocket, void* outsocket ) ;
