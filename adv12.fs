create moons -16 , 15 , -9 , -14 , 5 , 4 , 2 , 0 , 6 , -3 , 18 , 9 ,
create position 12 cells allot
create velocity 12 cells allot
: p@ ( i j -- pi_j ) swap 3 * + cells position + @ ;
: v+! ( x i j -- ) swap 3 * + cells velocity + +! ;

: init moons position 12 cells move velocity 12 cells 0 fill ;
: sumabs ( addr -- n ) dup @ abs swap cell+ dup @ abs swap cell+ @ abs + + ;
: energy ( -- n )
  0 4 0 do
    position i 3 * cells + sumabs
    velocity i 3 * cells + sumabs
    * +
  loop ;
: sign ( x -- s ) dup if 0> if 1 else -1 then then ;
: gravity ( i j -- )
  3 0 do
    2dup i p@ swap i p@ - sign  \ i j s(j-i)
    over over negate swap i v+! \ i j s(j-i)
    >r over r> swap i v+!
  loop 2drop ;
: motion ( -- )
  position velocity 12 0 do
    2dup @ swap +! cell+ swap cell+ swap 
  loop 2drop ;
: step
  0 1 0 2 0 3 1 2 1 3 2 3 \ all pairs
  6 0 do gravity loop motion ;
: part1 init 1000 0 do step loop energy . ;

: gcd ( n m -- g ) begin ?dup while tuck mod repeat ;
: lcm ( n m -- l ) 2dup * -rot gcd ?dup if / then ;
: cycle ( i -- f )
  true swap 4 0 do
    dup i 3 * + cells dup \ f i off off
    moons + @ over position + @ = swap \ f i f' off
    velocity + @ 0= and rot and swap 
  loop drop ;
: part2
  3 0 do 1 init begin
    step i cycle 0= while 1+
  repeat loop lcm lcm . ;
