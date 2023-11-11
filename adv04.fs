create digits 42 , 6 cells allot 42 ,
: d@ ( i -- d ) 1+ cells digits + @ ;
: d! ( d i -- ) 1+ cells digits + ! ; 
: digits ( n -- ) 6 0 do 10 /mod swap i d! loop drop ;
: same ( -- f ) \ Part 1
  5 0 do
    i d@ i 1+ d@ = if true unloop exit then
  loop false ;
: same' ( -- f ) \ Part 2
  5 0 do
    i d@ i 1+ d@ =
    i d@ i 2 + d@ <> and
    i d@ i 1- d@ <> and if
      true unloop exit 
    then
  loop false ;
: increasing ( n -- f )
  0 d@ 6 1 do
    i d@ swap over < if
      drop false unloop exit
    then
  loop drop true ;
: check ( -- f ) same increasing and ; \ use same' for Part 2
: count ( -- ) 0 579382 125730 do i digits check if 1+ then loop ;
