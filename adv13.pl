% -*- mode: prolog -*-

% Memory handling

memory(P, M) :- build_list(P, 0, L), list_to_assoc(L, M).

build_list([], _, []).
build_list([P|Ps], N, [N-P|Ms]) :- N1 is N + 1, build_list(Ps, N1, Ms).

get(N-V, M) :- get_assoc(N, M, V1), !, V = V1.
get(_-0, _).

put(N-V, M, M1) :- put_assoc(N, M, V, M1).

% Addressing modes

parameter(N, M, in, 0, V) :- get(N-I, M), get(I-V, M). % positional
parameter(N, M, in, 1, V) :- get(N-V, M).              % immediate
parameter(N, M, in, 2, V) :-                           % relative
    get(base-B, M), get(N-I, M),
    I1 is B + I, get(I1-V, M).

parameter(N, M, out, 0, V) :- get(N-V, M).             % positional
parameter(N, M, out, 2, V) :-                          % relative
    get(base-B, M), get(N-I, M), V is B + I.

parameters(N, _, [], _, [], N1) :- N1 is N + 1.
parameters(N, M, [IO|L], Mode, [V|Vs], Next) :-
    N1 is N + 1,
    ( [P|Ps] = Mode ; [P|Ps] = [0] ), !,
    parameter(N1, M, IO, P, V),
    parameters(N1, M, L, Ps, Vs, Next).

% Instructions

add(N, M, Mode, N1, M1) :-
    parameters(N, M, [in,in,out], Mode, [V1,V2,V3], N1),
    V is V1 + V2, put(V3-V, M, M1).

mul(N, M, Mode, N1, M1) :-
    parameters(N, M, [in,in,out], Mode, [V1,V2,V3], N1),
    V is V1 * V2, put(V3-V, M, M1).

input(N, M, Mode, N1, M2) :-
    parameters(N, M, [out], Mode, [V1], N1),
    get(in-[V|I], M), !,
    put(V1-V, M, M1),
    put(in-I, M1, M2).
input(_, _, _, _, _) :-
    write('not enough input'), nl, fail.

output(N, M, Mode, N1, M1) :-
    parameters(N, M, [in], Mode, [V1], N1),
    get(out-O, M),
    put(out-[V1|O], M, M1).

jump_true(N, M, Mode, Next, M) :-
    parameters(N, M, [in,in], Mode, [V1,V2], N1),
    ( V1 = 0, Next = N1 ; Next = V2 ), !.

jump_false(N, M, Mode, Next, M) :-
    parameters(N, M, [in,in], Mode, [V1,V2], N1),
    ( V1 = 0, Next = V2 ; Next = N1 ), !.

less_than(N, M, Mode, N1, M1) :-
    parameters(N, M, [in,in,out], Mode, [V1,V2,V3], N1),
    ( V1 < V2, V = 1 ; V = 0 ), !,
    put(V3-V, M, M1).

equals(N, M, Mode, N1, M1) :-
    parameters(N, M, [in,in,out], Mode, [V1,V2,V3], N1),
    ( V1 =:= V2, V = 1 ; V = 0 ), !,
    put(V3-V, M, M1).

set_base(N, M, Mode, N1, M1) :-
    parameters(N, M, [in], Mode, [V1], N1),
    get(base-B, M), V is B + V1,
    put(base-V, M, M1).

% Virtual machine

digits(N, [N]) :- N < 10, !.
digits(N, [D|L]) :- N >= 10, D is N mod 10, N1 is N // 10, digits(N1, L).

run(N, M, pause(N,M)) :-
    get(out-O, M), length(O, L), L mod 3 =:= 0, O = [4|_], !. % ball info
run(N, M, X) :-
    get(N-I, M),
    ( digits(I, [Op2,Op1|Mode]), Op is Op1 * 10 + Op2
    ; digits(I, [Op|Mode])
    ), !,
    run(N, M, Op, Mode, X).

run(_, M, 99, _, halt(X)) :- !, get(out-O, M), reverse(O, X).
run(N, M, Op, Mode, X) :-
    nth1(Op, [add, mul, input, output, jump_true, jump_false, less_than, equals, set_base], G),
    call(G, N, M, Mode, N1, M1),
    run(N1, M1, X).

patch(M, [], M) :- !.
patch(M, [X|Xs], M2) :-
    put(X, M, M1),
    patch(M1, Xs, M2).

% Game

tile_type(0, empty).
tile_type(1, wall).
tile_type(2, block).
tile_type(3, paddle).
tile_type(4, ball).

parse_tiles(L, M) :- parse_tiles(L, [], M).
parse_tiles([], M, M).
parse_tiles([-1,0,S|L], M, M1) :-
    parse_tiles(L, [score(S)|M], M1).
parse_tiles([X,Y,I|L], M, M1) :-
    X >= 0, tile_type(I, T),
    parse_tiles(L, [tile(X-Y,T)|M], M1).

count_blocks([], 0).
count_blocks([tile(_,block)|M], N1) :- !, count_blocks(M, N), N1 is N + 1.
count_blocks([_|M], N) :- count_blocks(M, N).

adv13(X) :-
    program(P), memory(P, M),
    patch(M, [base-0,out-[]], M1),
    run(0, M1, halt(L)),
    parse_tiles(L, T),
    display(T),
    count_blocks(T, X), !.

joystick(X-_, X-_, 0) :- !.
joystick(Bx-_, Px-_, -1) :- Bx < Px, !.
joystick(Bx-_, Px-_, 1) :- Bx > Px, !.

update_tiles([], T, T).
update_tiles([tile(X-Y,T)|Ts], Xs, Zs) :-
    ( select(tile(X-Y,_), Xs, Ys) ; Ys = Xs ),
    update_tiles(Ts, [tile(X-Y,T)|Ys], Zs).
update_tiles([score(S)|Ts], Xs, Zs) :-
    ( select(score(_), Xs, Ys) ; Ys = Xs ),
    update_tiles(Ts, [score(S)|Ys], Zs).

play(N, M, T, X) :-
    run(N, M, pause(N1,M1)), !,
    get(out-O, M1), reverse(O, O1), parse_tiles(O1, T0),
    update_tiles(T0, T, T1),
    member(tile(B,ball), T1), member(tile(P,paddle), T1),
    joystick(B, P, J),
    patch(M1, [out-[],in-[J]], M2),
    play(N1, M2, T1, X).
play(N, M, T, X) :-
    run(N, M, halt(O)),
    parse_tiles(O, T0),
    update_tiles(T0, T, T1),
    display(T1),
    member(score(X), T1).

adv13b(X) :-
    program(P), memory(P, M),
    patch(M, [base-0,in-[0],out-[],0-2], M1),
    run(0, M1, pause(N,M2)), % the machine pauses for input when writing ball position
    get(out-O, M2), reverse(O, O1), parse_tiles(O1, T),
    patch(M2, [out-[]], M3),
    play(N, M3, T, X), !.

% Display

paint(empty, ' ').
paint(wall, 'O').
paint(block, 'X').
paint(paddle, '=').
paint(ball, '*').

write_row(37, _, _) :- nl.
write_row(X, Y, L) :-
    X < 37, X1 is X + 1,
    member(tile(X-Y,T), L),
    paint(T, C), write(C),
    write_row(X1, Y, L).

write_rows(23, _).
write_rows(Y, L) :-
    Y < 23, Y1 is Y + 1,
    write_row(0, Y, L), write_rows(Y1, L).

display(L) :- write_rows(0, L).

% Data

program([1,380,379,385,1008,2341,437598,381,1005,381,12,99,109,2342,1101,0,0,383,1102,0,1,382,21001,382,0,1,21002,383,1,2,21102,37,1,0,1105,1,578,4,382,4,383,204,1,1001,382,1,382,1007,382,37,381,1005,381,22,1001,383,1,383,1007,383,23,381,1005,381,18,1006,385,69,99,104,-1,104,0,4,386,3,384,1007,384,0,381,1005,381,94,107,0,384,381,1005,381,108,1105,1,161,107,1,392,381,1006,381,161,1101,-1,0,384,1105,1,119,1007,392,35,381,1006,381,161,1101,1,0,384,20102,1,392,1,21101,0,21,2,21101,0,0,3,21102,138,1,0,1105,1,549,1,392,384,392,21001,392,0,1,21102,21,1,2,21101,3,0,3,21102,1,161,0,1105,1,549,1101,0,0,384,20001,388,390,1,21001,389,0,2,21101,180,0,0,1106,0,578,1206,1,213,1208,1,2,381,1006,381,205,20001,388,390,1,21001,389,0,2,21102,1,205,0,1106,0,393,1002,390,-1,390,1101,0,1,384,20102,1,388,1,20001,389,391,2,21101,0,228,0,1106,0,578,1206,1,261,1208,1,2,381,1006,381,253,21001,388,0,1,20001,389,391,2,21102,253,1,0,1106,0,393,1002,391,-1,391,1101,1,0,384,1005,384,161,20001,388,390,1,20001,389,391,2,21102,279,1,0,1106,0,578,1206,1,316,1208,1,2,381,1006,381,304,20001,388,390,1,20001,389,391,2,21101,304,0,0,1106,0,393,1002,390,-1,390,1002,391,-1,391,1102,1,1,384,1005,384,161,20102,1,388,1,21001,389,0,2,21102,1,0,3,21102,338,1,0,1105,1,549,1,388,390,388,1,389,391,389,21002,388,1,1,21001,389,0,2,21101,4,0,3,21101,0,365,0,1106,0,549,1007,389,22,381,1005,381,75,104,-1,104,0,104,0,99,0,1,0,0,0,0,0,0,344,16,18,1,1,18,109,3,22101,0,-2,1,21202,-1,1,2,21101,0,0,3,21101,0,414,0,1106,0,549,22101,0,-2,1,22101,0,-1,2,21101,0,429,0,1105,1,601,2101,0,1,435,1,386,0,386,104,-1,104,0,4,386,1001,387,-1,387,1005,387,451,99,109,-3,2106,0,0,109,8,22202,-7,-6,-3,22201,-3,-5,-3,21202,-4,64,-2,2207,-3,-2,381,1005,381,492,21202,-2,-1,-1,22201,-3,-1,-3,2207,-3,-2,381,1006,381,481,21202,-4,8,-2,2207,-3,-2,381,1005,381,518,21202,-2,-1,-1,22201,-3,-1,-3,2207,-3,-2,381,1006,381,507,2207,-3,-4,381,1005,381,540,21202,-4,-1,-1,22201,-3,-1,-3,2207,-3,-4,381,1006,381,529,21201,-3,0,-7,109,-8,2105,1,0,109,4,1202,-2,37,566,201,-3,566,566,101,639,566,566,2101,0,-1,0,204,-3,204,-2,204,-1,109,-4,2106,0,0,109,3,1202,-1,37,593,201,-2,593,593,101,639,593,593,21002,0,1,-2,109,-3,2105,1,0,109,3,22102,23,-2,1,22201,1,-1,1,21102,431,1,2,21101,653,0,3,21102,851,1,4,21102,630,1,0,1106,0,456,21201,1,1490,-2,109,-3,2105,1,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,2,2,2,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2,2,2,2,0,2,0,2,2,2,2,2,0,2,0,1,1,0,2,0,2,2,0,2,2,0,0,2,2,0,2,2,2,2,0,2,2,2,2,0,2,0,2,2,0,2,0,2,2,2,2,0,1,1,0,0,2,2,2,2,2,2,0,2,2,0,2,2,2,2,2,2,2,2,0,2,2,2,0,2,2,2,2,2,2,0,0,2,0,1,1,0,0,2,2,2,2,0,2,2,2,0,2,2,0,2,2,2,2,2,2,2,2,0,2,2,0,2,0,2,2,0,2,2,2,0,1,1,0,2,2,2,0,2,0,2,0,2,2,2,0,0,0,2,0,2,2,2,2,2,2,0,2,0,2,0,2,2,2,2,2,2,0,1,1,0,2,2,2,2,2,2,0,2,0,2,0,0,0,2,0,2,2,2,2,0,2,2,0,2,2,0,2,2,0,0,2,2,0,0,1,1,0,2,0,0,2,2,0,2,2,2,0,0,0,0,2,2,2,2,2,2,0,0,0,2,0,2,2,2,2,2,0,0,0,0,0,1,1,0,2,0,0,2,2,0,0,2,2,2,2,2,2,2,2,0,2,0,2,2,0,2,2,2,0,2,0,2,2,0,2,2,2,0,1,1,0,0,2,2,2,2,2,0,2,2,0,0,0,0,2,2,2,2,0,2,2,0,2,2,0,2,0,0,2,2,2,2,2,2,0,1,1,0,2,0,2,0,2,2,0,2,0,0,2,2,2,0,0,2,2,0,2,0,2,2,2,0,2,2,2,2,0,2,2,0,0,0,1,1,0,2,2,2,2,2,0,2,2,2,2,2,2,2,2,2,0,2,2,2,2,0,2,0,2,2,2,0,0,2,2,2,2,0,0,1,1,0,2,0,2,2,0,0,0,0,2,2,2,2,0,2,2,0,0,2,0,2,0,2,0,2,0,2,0,0,2,0,2,2,2,0,1,1,0,2,0,2,2,2,2,0,2,2,0,2,2,2,0,2,0,2,0,2,0,2,2,2,2,0,2,2,2,0,2,2,0,0,0,1,1,0,2,2,2,0,2,2,0,0,2,2,2,2,2,2,0,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,0,1,1,0,2,2,2,0,2,2,2,2,0,0,2,2,2,0,2,0,2,2,0,0,2,2,2,0,2,2,0,2,2,2,2,2,2,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,68,85,54,62,55,66,45,25,17,78,41,1,66,35,5,38,72,17,31,57,18,19,35,53,33,17,10,15,46,71,34,46,84,46,71,81,9,64,73,66,65,89,6,86,23,81,19,13,59,12,2,83,74,11,82,9,80,27,22,85,92,3,91,79,47,85,68,45,39,50,80,14,7,34,68,98,67,63,10,15,40,85,3,87,14,91,76,37,45,78,77,8,64,62,83,74,48,54,61,76,5,89,27,96,78,60,86,45,97,11,21,62,49,52,24,74,23,19,82,28,6,14,1,14,45,37,13,9,61,74,67,18,62,13,6,24,27,67,60,80,68,25,53,80,31,67,41,8,93,23,93,95,6,47,4,25,33,45,56,37,12,62,75,85,42,83,16,40,78,38,87,1,96,18,73,96,91,29,44,58,47,71,90,28,74,12,97,15,32,86,9,81,54,92,94,95,36,34,67,48,71,57,60,39,50,31,7,58,5,43,63,98,55,56,87,83,70,92,63,51,72,11,73,26,94,81,62,38,15,92,4,38,91,32,12,34,26,46,46,54,51,16,36,98,65,68,79,65,3,34,6,24,70,49,27,78,41,50,38,46,23,27,53,11,45,5,24,94,56,56,40,85,13,52,36,86,31,92,16,72,66,77,12,5,2,7,56,7,88,67,49,31,73,10,19,83,87,96,47,86,35,91,38,85,24,6,32,78,20,28,88,8,5,97,9,17,32,91,52,74,92,13,92,1,35,62,68,17,44,4,51,93,61,60,65,46,52,91,7,85,78,28,68,31,16,7,70,10,64,56,73,57,49,19,1,54,62,50,68,98,76,48,39,62,19,50,34,46,41,36,54,47,5,37,86,6,22,22,21,32,98,54,29,41,86,78,52,78,53,28,39,24,65,40,3,25,85,19,81,1,82,56,40,33,87,48,77,3,67,27,89,22,87,30,14,82,72,90,86,49,57,79,27,41,34,35,90,90,51,80,77,75,45,52,93,17,8,12,17,45,94,92,86,7,15,42,70,14,91,4,88,86,94,5,96,74,2,48,80,14,43,78,96,53,65,46,8,52,64,79,39,3,44,42,31,96,41,40,75,7,83,84,70,86,97,31,56,1,60,78,58,20,15,35,18,48,54,15,66,11,87,20,65,4,10,28,10,1,52,2,88,64,31,47,57,29,92,8,91,82,73,7,17,2,92,10,11,31,19,44,71,6,9,17,97,11,50,5,61,74,18,21,73,32,81,64,81,37,23,97,15,34,85,18,64,46,74,39,14,65,47,10,26,31,77,35,55,30,59,78,86,35,85,80,51,9,11,1,46,81,37,55,3,59,28,2,89,68,32,82,73,7,64,63,25,34,96,37,67,53,1,98,74,20,14,41,29,3,25,9,8,5,96,60,53,4,14,40,94,72,25,95,9,56,12,3,46,75,39,64,75,59,23,13,69,90,40,12,69,5,94,86,23,73,23,22,45,46,20,66,97,68,56,25,55,14,39,78,23,84,58,34,36,4,10,72,95,83,22,81,5,23,32,72,33,58,52,87,28,12,93,1,2,97,76,43,78,98,73,76,23,13,79,51,65,27,9,21,44,4,11,88,93,82,93,91,93,3,53,55,95,64,59,26,3,95,61,25,87,72,80,35,70,79,82,38,3,86,90,85,78,25,3,42,18,63,96,60,49,65,68,2,57,27,70,37,97,90,5,4,31,17,8,27,39,77,67,45,44,59,60,66,84,75,60,18,61,71,64,92,97,43,25,94,7,50,67,78,43,93,66,25,27,5,93,2,4,85,21,9,84,67,6,81,93,16,38,90,84,29,41,38,95,75,5,41,28,16,7,8,33,13,64,60,18,93,58,74,45,49,4,33,24,43,76,38,3,32,36,3,32,3,64,96,85,19,80,56,96,65,83,12,27,64,91,14,65,52,8,49,48,437598]).
