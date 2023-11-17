40 constant size 
: load ( addr n -- )
  s" adv10.txt" r/o open-file abort" cannot open file"
  >r r@ read-file abort" cannot read file" drop r> close-file drop ;
create map size dup 1+ * dup allot map swap load
: m@ ( x y -- f ) size 1+ * + map + c@ [char] # = ;

: gcd ( n m -- d ) begin ?dup while tuck mod repeat abs ;
: div ( x y d -- x/d y/d ) rot over / -rot / ;
: add ( x y x' y' -- x+x' y+y' ) >r rot + r> rot + ;
: sub ( x y x' y' -- x-x' y-y' ) 2swap >r rot - r> rot - ;
: differ ( x y x' y' -- f ) rot <> -rot <> or ;
: visible ( x y x' y' -- f )
  2>r 2dup 2r> 2swap sub 2dup gcd >r r@ div r> \ x y dx dy d
  1- 0 ?do \ x y dx dy
    2>r 2r@ add 2dup m@ if 
      2drop 2r> 2drop false unloop exit 
    then 2r>
  loop 2drop 2drop true ;
: asteroids ( x y -- n )
  0 size 0 do size 0 do
    i j m@ if 
      -rot 2dup i j differ if
        2dup i j visible if rot 1+ else rot then
      else rot then
    then
  loop loop nip nip ;
: part1
  0 size 0 do size 0 do
    i j m@ if
      i j asteroids 2dup < if nip else drop then
    then
  loop loop . ;

\ We know the best position (31 20), and also know that one rotation is enough,
\ since there are > 200 visible asteroids.
\ We also assume that two "adjacent" asteroids have an angle < 90 degrees.
\ Also, there _is_ an asteroid upwards from (31 20).
: pos 31 20 ;
: scale 1000 * ;
: findfirst ( -- x y ) pos begin 1- 2dup m@ invert while repeat ;
: s>f s>d d>f ; : f>s f>d d>s ;
: normsqr ( x y - n ) dup * swap dup * + ;
: normalize ( x y - x' y' )
  2dup normsqr s>f fsqrt fdup
  scale s>f fswap f/ scale s>f frot f/ f>s f>s ;
: unitvec ( x y -- dx dy ) pos sub normalize ;
: 2unitvec ( x y x' y' -- dx dy dx' dy' ) unitvec 2>r unitvec 2r> ;
: cos ( x y x' y' -- c ) 2unitvec rot * -rot * + ;
: sin ( x y x' y' -- s ) 2unitvec >r * swap r> * swap - ;
: findnext ( x y -- x' y' )
  2dup size 0 do size 0 do \ x' y' x y
    i j m@ pos i j differ and if               \ there is a different asteroid
    pos i j visible else false then if         \ and it is visible from `pos`
    2>r 2r@ 2over sin 2r@ rot 2r> i j sin      \ x' y' x y s1 s2
    2over i j cos 0< over 0<= or if 2drop else \ cos2 >= 0 and sin2 > 0
    over 0= -rot > or if                       \ sin1 = 0 or sin2 < sin1
      2swap 2drop i j 2swap 
    then then then
  loop loop 2drop ;
: part2 findfirst 199 0 do findnext loop swap 100 * + . ;
