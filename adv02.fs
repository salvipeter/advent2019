create program
  1 , 0 , 0 , 3 , 1 , 1 , 2 , 3 , 1 , 3 , 4 , 3 , 1 , 5 , 0 , 3 , 2 , 13 , 1 ,
  19 , 1 , 9 , 19 , 23 , 2 , 23 , 13 , 27 , 1 , 27 , 9 , 31 , 2 , 31 , 6 , 35 ,
  1 , 5 , 35 , 39 , 1 , 10 , 39 , 43 , 2 , 43 , 6 , 47 , 1 , 10 , 47 , 51 , 2 ,
  6 , 51 , 55 , 1 , 5 , 55 , 59 , 1 , 59 , 9 , 63 , 1 , 13 , 63 , 67 , 2 , 6 ,
  67 , 71 , 1 , 5 , 71 , 75 , 2 , 6 , 75 , 79 , 2 , 79 , 6 , 83 , 1 , 13 , 83 ,
  87 , 1 , 9 , 87 , 91 , 1 , 9 , 91 , 95 , 1 , 5 , 95 , 99 , 1 , 5 , 99 , 103 ,
  2 , 13 , 103 , 107 , 1 , 6 , 107 , 111 , 1 , 9 , 111 , 115 , 2 , 6 , 115 ,
  119 , 1 , 13 , 119 , 123 , 1 , 123 , 6 , 127 , 1 , 127 , 5 , 131 , 2 , 10 ,
  131 , 135 , 2 , 135 , 10 , 139 , 1 , 13 , 139 , 143 , 1 , 10 , 143 , 147 , 1 ,
  2 , 147 , 151 , 1 , 6 , 151 , 0 , 99 , 2 , 14 , 0 , 0 ,
here program - cell / constant length

create memory 1000 cells allot
: mem@ cells memory + @ ;
: mem! cells memory + ! ;
: init ( n -- ) program memory length cells move 100 /mod 1 mem! 2 mem! ;
: arg ( ip -- [ip] ip+1 ) dup mem@ swap 1+ ;
: [arg] ( ip -- [[ip]] ip+1 ) dup mem@ mem@ swap 1+ ;
: add ( ip -- ip' ) 1+ [arg] [arg] arg >r -rot + swap mem! r> ;
: mul ( ip -- ip' ) 1+ [arg] [arg] arg >r -rot * swap mem! r> ;
: run ( -- n )
  0 begin
    dup mem@
    dup 99 <> while
    dup 1 = if drop add else
    dup 2 = if drop mul else
    abort" Invalid opcode" then then
  repeat 2drop memory @ ;
: part1 1202 init run . ;
: part2 0 begin dup init run 19690720 <> while 1+ repeat . ;
