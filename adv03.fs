: R, rot + dup , swap dup , ;
: L, rot swap - dup , swap dup , ;
: U, + over , dup , ;
: D, - over , dup , ;
: start 0 , 0 , 0 , 0 0 ;
: end here over - cell / 2/ swap ! 2drop ;

create wire1 start
  1009 R, 263 U, 517 L, 449 U, 805 L, 78 D, 798 L, 883 D, 777 L, 562 D, 652 R,
  348 D, 999 R, 767 D, 959 L, 493 U, 59 R, 994 D, 225 L, 226 D, 634 R, 200 D,
  953 R, 343 U, 388 L, 158 U, 943 R, 544 U, 809 L, 785 D, 618 R, 499 U, 476 L,
  600 U, 452 L, 693 D, 696 L, 764 U, 927 L, 346 D, 863 L, 458 D, 789 L, 268 U,
  586 R, 884 U, 658 L, 371 D, 910 L, 178 U, 524 R, 169 U, 973 R, 326 D, 483 R,
  233 U, 26 R, 807 U, 246 L, 711 D, 641 L, 75 D, 756 R, 365 U, 203 R, 377 D,
  624 R, 430 U, 422 L, 367 U, 547 R, 294 U, 916 L, 757 D, 509 R, 332 D, 106 R,
  401 D, 181 L, 5 U, 443 L, 197 U, 406 R, 829 D, 878 R, 35 U, 958 L, 31 U, 28 L,
  362 D, 188 R, 582 D, 358 R, 750 U, 939 R, 491 D, 929 R, 513 D, 541 L, 418 U,
  861 R, 639 D, 917 L, 582 U, 211 R, 725 U, 711 R, 718 D, 673 L, 921 U, 157 L,
  83 U, 199 L, 501 U, 66 L, 993 D, 599 L, 947 D, 26 L, 237 U, 981 L, 833 U,
  121 L, 25 U, 641 R, 372 D, 757 L, 645 D, 287 R, 390 U, 274 R, 964 U, 288 R,
  209 D, 109 R, 364 D, 983 R, 715 U, 315 L, 758 U, 36 R, 500 D, 626 R, 893 U,
  840 L, 716 U, 606 L, 831 U, 969 L, 643 D, 300 L, 838 D, 31 R, 751 D, 632 L,
  702 D, 468 R, 7 D, 169 L, 149 U, 893 R, 33 D, 816 R, 558 D, 152 R, 489 U,
  237 L, 415 U, 434 R, 472 D, 198 L, 874 D, 351 L, 148 U, 761 R, 809 U, 21 R,
  25 D, 586 R, 338 D, 568 L, 20 U, 157 L, 221 U, 26 L, 424 U, 261 R, 227 D,
  551 L, 754 D, 90 L, 110 U, 791 L, 433 U, 840 R, 323 U, 240 R, 124 U, 723 L,
  418 D, 938 R, 173 D, 160 L, 293 U, 773 R, 204 U, 192 R, 958 U, 472 L, 703 D,
  556 R, 168 D, 263 L, 574 U, 845 L, 932 D, 165 R, 348 D, 811 R, 834 D, 960 R,
  877 U, 935 R, 141 D, 696 R, 748 U, 316 L, 236 U, 796 L, 566 D, 524 R, 449 U,
  378 R, 480 U, 79 L, 227 U, 867 R, 185 D, 474 R, 757 D, 366 R, 153 U, 882 R,
  252 U, 861 R, 900 U, 28 R, 381 U, 845 L, 642 U, 849 L, 352 U, 134 R, 294 D,
  788 R, 406 D, 693 L, 697 D, 433 L, 872 D, 78 R, 364 D, 240 R, 995 U, 48 R,
  681 D, 727 R, 825 D, 583 L, 44 U, 743 R, 929 D, 616 L, 262 D, 997 R, 15 D,
  575 R, 341 U, 595 R, 889 U, 254 R, 76 U, 962 R, 944 D, 724 R, 261 D, 608 R,
  753 U, 389 L, 324 D, 569 L, 308 U, 488 L, 358 D, 695 L, 863 D, 712 L, 978 D,
  149 R, 177 D, 92 R,
wire1 end
create wire2 start
  1003 L, 960 D, 10 L, 57 D, 294 R, 538 U, 867 R, 426 D, 524 L, 441 D, 775 R,
  308 U, 577 R, 785 D, 495 R, 847 U, 643 R, 895 D, 448 R, 685 U, 253 L, 312 U,
  312 L, 753 U, 89 L, 276 U, 799 R, 923 D, 33 L, 595 U, 400 R, 111 U, 664 L,
  542 D, 171 R, 709 U, 809 L, 713 D, 483 L, 918 U, 14 L, 854 U, 150 L, 69 D,
  158 L, 500 D, 91 L, 800 D, 431 R, 851 D, 798 L, 515 U, 107 L, 413 U, 94 L,
  390 U, 17 L, 221 U, 999 L, 546 D, 191 L, 472 U, 568 L, 114 U, 913 L, 743 D,
  713 L, 215 D, 569 L, 674 D, 869 L, 549 U, 789 L, 259 U, 330 L, 76 D, 243 R,
  592 D, 646 L, 880 U, 363 L, 542 U, 464 L, 955 D, 107 L, 473 U, 818 R, 786 D,
  852 R, 968 U, 526 R, 78 D, 275 L, 891 U, 480 R, 991 U, 981 L, 391 D, 83 R,
  691 U, 689 R, 230 D, 217 L, 458 D, 10 R, 736 U, 317 L, 145 D, 902 R, 428 D,
  344 R, 334 U, 131 R, 739 D, 438 R, 376 D, 652 L, 304 U, 332 L, 452 D, 241 R,
  783 D, 82 R, 317 D, 796 R, 323 U, 287 R, 487 D, 302 L, 110 D, 233 R, 631 U,
  584 R, 973 U, 878 L, 834 D, 930 L, 472 U, 120 R, 78 U, 806 R, 21 D, 521 L,
  988 U, 251 R, 817 D, 44 R, 789 D, 204 R, 669 D, 616 R, 96 D, 624 R, 891 D,
  532 L, 154 U, 438 R, 469 U, 785 R, 431 D, 945 R, 649 U, 670 R, 11 D, 840 R,
  521 D, 235 L, 69 D, 551 L, 266 D, 454 L, 807 U, 885 L, 590 U, 647 L, 763 U,
  449 R, 194 U, 68 R, 809 U, 884 L, 962 U, 476 L, 648 D, 139 L, 96 U, 300 L,
  351 U, 456 L, 202 D, 168 R, 698 D, 161 R, 834 U, 273 L, 47 U, 8 L, 157 D,
  893 L, 200 D, 454 L, 723 U, 886 R, 92 U, 474 R, 262 U, 190 L, 110 U, 407 L,
  723 D, 786 R, 786 D, 572 L, 915 D, 904 L, 744 U, 820 L, 663 D, 205 R, 878 U,
  186 R, 247 U, 616 L, 386 D, 582 R, 688 U, 349 L, 399 D, 702 R, 132 U, 276 L,
  866 U, 851 R, 633 D, 468 R, 263 D, 678 R, 96 D, 50 L, 946 U, 349 R, 482 D,
  487 R, 525 U, 464 R, 977 U, 499 L, 187 D, 546 R, 708 U, 627 L, 470 D, 673 R,
  886 D, 375 L, 616 U, 503 L, 38 U, 775 L, 8 D, 982 L, 556 D, 159 R, 680 U,
  124 L, 777 U, 640 L, 607 D, 248 R, 671 D, 65 L, 290 D, 445 R, 778 U, 650 L,
  679 U, 846 L, 1 D, 769 L, 659 U, 734 R, 962 D, 588 R, 178 U, 888 R, 753 D,
  223 R, 318 U, 695 L, 586 D, 430 R, 61 D, 105 R, 801 U, 953 R, 721 U, 856 L,
  769 U, 937 R, 335 D, 895 R,
wire2 end

: pos ( p -- x y ) dup @ swap cell+ @ ;
: x ( p -- x ) @ ;
: y ( p -- y ) cell+ @ ;
: wnext ( w -- w' ) 2 cells + ;
: minx ( w -- x ) dup x swap wnext x min ;
: maxx ( w -- x ) dup x swap wnext x max ;
: miny ( w -- y ) dup y swap wnext y min ;
: maxy ( w -- y ) dup y swap wnext y max ;
: commonxy ( w1 w2 -- x y )
  dup x over wnext x = \ is w2 vertical?
  if x swap y else y swap x swap then ;
: intersect ( w1 w2 -- x y T | F )
  2dup minx swap maxx < >r
  2dup maxx swap minx > r> and >r
  2dup miny swap maxy < r> and >r
  2dup maxy swap miny > r> and
  if commonxy true else 2drop false then ;
: intersections ( -- )
  wire1 dup @ swap cell+ swap 1 ?do
    wire2 dup @ swap cell+ swap 1 ?do
      2dup intersect if swap , , then
    wnext loop drop
  wnext loop drop ;
create all intersections
here all - cell / 2/ constant size
: int ( n -- p ) 2 * cells all + ;

: manhattan ( p -- d ) dup @ abs swap cell+ @ abs + ;
: minimize ( xt -- d )
  all over execute size 1 ?do
    over i int swap execute min
  loop nip ;
: part1 ['] manhattan minimize . ;

: length ( p1 p2 -- d ) pos rot pos >r rot - abs r> rot - abs + ;
: wlength ( w -- d ) dup wnext length ;
: between ( p w -- f )
  2dup wnext length -rot swap \ |p-w+1| w p
  over length rot + swap wlength = ;
: (distance) ( p w -- d )
  cell+ 0 -rot begin
    2dup between invert while
    dup wlength >r rot r> + -rot wnext
  repeat length + ;
: distance ( p -- d ) dup wire1 (distance) swap wire2 (distance) + ;
: part2 ['] distance minimize . ;
