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

run(N, M, X) :-
    get(N-I, M),
    ( digits(I, [Op2,Op1|Mode]), Op is Op1 * 10 + Op2
    ; digits(I, [Op|Mode])
    ), !,
    run(N, M, Op, Mode, X).

run(_, M, 99, _, halt(X)) :- !, get(out-O, M), reverse(O, X).
run(N, M, 4, Mode, pause(X,N1,M1)) :- !, output(N, M, Mode, N1, M1), get(out-[X|_], M1).
run(N, M, Op, Mode, X) :-
    nth1(Op, [add, mul, input, output, jump_true, jump_false, less_than, equals, set_base], G),
    call(G, N, M, Mode, N1, M1),
    run(N1, M1, X).

patch(M, [], M) :- !.
patch(M, [X|Xs], M2) :-
    put(X, M, M1),
    patch(M1, Xs, M2).

% Droid

move(X-Y, 1, X-Y1) :- Y1 is Y - 1.
move(X-Y, 2, X-Y1) :- Y1 is Y + 1.
move(X-Y, 3, X1-Y) :- X1 is X - 1.
move(X-Y, 4, X1-Y) :- X1 is X + 1.

update_map(P, M, 0, [m(P,wall)|M]).
update_map(P, M, 1, [m(P,empty)|M]).
update_map(P, M, 2, [m(P,oxygen)|M]).

turn_left(1, 3).
turn_left(2, 4).
turn_left(3, 2).
turn_left(4, 1).

turn_right(1, 4).
turn_right(2, 3).
turn_right(3, 1).
turn_right(4, 2).

next_dir(lefthanded, _, _, D, 0, D1) :-
    turn_right(D, D1), !.
next_dir(lefthanded, M, P, D, _, D1) :-
    turn_left(D, D1),
    move(P, D1, P1),
    \+ member(m(P1,wall), M), !.
next_dir(righthanded, _, _, D, 0, D1) :-
    turn_left(D, D1), !.
next_dir(righthanded, M, P, D, _, D1) :-
    turn_right(D, D1),
    move(P, D1, P1),
    \+ member(m(P1,wall), M), !.
next_dir(_, _, _, D, _, D).

control_droid(_, _, _, _, _, Map, Map2) :-
    length(Map, L), L > 2000, % stop after many iterations
    Map2 = Map.
control_droid(N, M, P, LastDir, Handedness, Map, Map2) :-
    run(N, M, pause(R,N1,M1)),
    move(P, LastDir, P1),
    update_map(P1, Map, R, Map1),
    next_dir(Handedness, Map1, P1, LastDir, R, NextDir),
    patch(M1, [in-[NextDir]], M2),
    ( R = 0, control_droid(N1, M2, P, NextDir, Handedness, Map1, Map2)
    ; R > 0, control_droid(N1, M2, P1, NextDir, Handedness, Map1, Map2)
    ).

generate_map(Map) :-
    program(P), memory(P, M),
    patch(M, [base-0,in-[1],out-[]], M1),
    control_droid(0, M1, 0-0, 1, lefthanded, [m(0-0,empty)], MapL),
    control_droid(0, M1, 0-0, 1, righthanded, [m(0-0,empty)], MapR),
    append(MapL, MapR, Map).

% Shortest path / flood fill

floodfill_adjacent(Map, [], Map, []).
floodfill_adjacent(Map, [P|Ps], Map1, L1) :-
    member(m(P,T), Map),
    ( T = oxygen ; T = wall ), !,
    floodfill_adjacent(Map, Ps, Map1, L1).
floodfill_adjacent(Map, [P|Ps], Map1, [P|L1]) :-
    floodfill_adjacent([m(P,oxygen)|Map], Ps, Map1, L1).

floodfill_list(Map, [], Map, []).
floodfill_list(Map, [P|L], Map2, L3) :-
    findall(P1, move(P,_,P1), Ps),
    floodfill_adjacent(Map, Ps, Map1, L1),
    floodfill_list(Map1, L, Map2, L2),
    append(L1, L2, L3).

floodfill(I, Map, P0, L, Map, I) :- member(P0, L).
floodfill(I, Map, P0, L, Map2, N) :-
    floodfill_list(Map, L, Map1, L1),
    I1 is I + 1,
    floodfill(I1, Map1, P0, L1, Map2, N).

turns_to_fill(Map, P0, Map1, N) :-
    member(m(P,oxygen), Map),
    floodfill(0, Map, P0, [P], Map1, N).

adv15(X) :-
    generate_map(Map), display(Map), !,
    turns_to_fill(Map, 0-0, _, X).

adv15b(X) :-
    generate_map(Map),
    turns_to_fill(Map, 4-10, Map1, X), % last cell to fill up with oxygen
    display(Map1).

% Display

paint(empty, '.').
paint(wall, '#').
paint(oxygen, 'O').

write_row(20, _, _) :- nl.
write_row(X, Y, L) :-
    X < 20, X1 is X + 1,
    ( X-Y = 0-0, C = 'D'
    ; member(m(X-Y,T), L), paint(T, C)
    ; C = ' '
    ), write(C),
    write_row(X1, Y, L).

write_rows(20, _).
write_rows(Y, L) :-
    Y < 20, Y1 is Y + 1,
    write_row(-21, Y, L), write_rows(Y1, L).

display(L) :- write_rows(-21, L).

% Data

program([3,1033,1008,1033,1,1032,1005,1032,31,1008,1033,2,1032,1005,1032,58,1008,1033,3,1032,1005,1032,81,1008,1033,4,1032,1005,1032,104,99,101,0,1034,1039,101,0,1036,1041,1001,1035,-1,1040,1008,1038,0,1043,102,-1,1043,1032,1,1037,1032,1042,1106,0,124,1002,1034,1,1039,1001,1036,0,1041,1001,1035,1,1040,1008,1038,0,1043,1,1037,1038,1042,1105,1,124,1001,1034,-1,1039,1008,1036,0,1041,1002,1035,1,1040,1001,1038,0,1043,101,0,1037,1042,1105,1,124,1001,1034,1,1039,1008,1036,0,1041,101,0,1035,1040,102,1,1038,1043,1001,1037,0,1042,1006,1039,217,1006,1040,217,1008,1039,40,1032,1005,1032,217,1008,1040,40,1032,1005,1032,217,1008,1039,1,1032,1006,1032,165,1008,1040,7,1032,1006,1032,165,1101,2,0,1044,1105,1,224,2,1041,1043,1032,1006,1032,179,1102,1,1,1044,1106,0,224,1,1041,1043,1032,1006,1032,217,1,1042,1043,1032,1001,1032,-1,1032,1002,1032,39,1032,1,1032,1039,1032,101,-1,1032,1032,101,252,1032,211,1007,0,45,1044,1106,0,224,1102,1,0,1044,1105,1,224,1006,1044,247,101,0,1039,1034,1001,1040,0,1035,102,1,1041,1036,1002,1043,1,1038,1001,1042,0,1037,4,1044,1105,1,0,20,12,24,92,28,41,2,48,89,3,20,28,54,25,52,5,1,6,33,88,74,9,9,37,88,28,76,41,47,37,36,57,47,29,66,5,85,31,41,36,91,73,35,57,47,84,35,24,73,58,46,6,12,33,71,36,91,84,10,11,63,23,54,49,36,43,17,37,67,92,8,90,27,35,73,21,43,93,43,23,73,13,21,92,17,93,9,82,29,43,75,91,64,28,78,83,6,5,87,81,44,44,25,64,36,90,89,39,50,1,99,8,46,61,82,44,30,92,83,27,9,58,96,4,48,22,98,22,14,58,11,36,98,14,71,29,63,95,23,70,74,20,97,35,96,18,29,68,20,69,39,56,2,37,82,15,34,29,88,86,11,13,75,1,73,48,59,71,44,42,83,89,17,53,82,1,70,35,79,28,82,62,2,62,8,79,11,20,27,50,6,77,47,27,4,24,64,37,22,84,27,49,40,13,98,25,28,98,94,18,10,40,95,6,27,11,54,43,30,53,5,72,73,92,44,30,61,9,97,84,18,30,65,17,34,75,86,47,1,32,14,70,32,27,84,65,63,37,57,90,25,64,7,54,76,29,94,33,53,29,58,21,3,81,88,50,16,53,24,28,96,64,12,36,67,13,33,67,78,43,90,20,46,31,44,87,30,35,85,94,22,86,12,63,92,6,43,24,47,26,64,77,39,21,76,9,63,79,17,34,61,4,1,19,63,89,30,85,19,95,58,91,16,97,35,50,81,3,59,37,96,17,79,12,46,81,9,64,47,10,48,25,64,2,62,69,23,32,71,77,41,28,65,98,7,39,76,31,61,41,18,56,39,80,95,24,41,38,97,29,32,65,42,97,10,91,68,5,27,55,35,94,4,10,69,22,40,2,81,5,88,1,99,3,99,75,7,87,60,39,26,53,14,20,80,94,2,49,19,79,41,46,42,9,82,13,51,76,19,75,18,28,89,56,21,92,86,17,58,17,30,50,19,34,47,71,1,93,21,36,90,77,40,20,80,63,17,7,52,79,10,53,64,24,40,4,64,24,39,77,55,31,29,91,77,46,36,15,44,96,22,19,98,76,2,20,9,99,76,2,87,84,31,47,3,16,95,84,4,32,13,56,34,79,93,18,89,92,12,92,80,33,78,42,76,33,14,42,64,81,5,54,15,92,97,56,29,5,63,21,6,76,58,65,28,29,58,18,73,49,25,95,59,40,59,5,15,72,36,62,43,77,1,20,48,31,90,22,63,21,79,31,75,24,21,64,84,16,65,91,38,35,29,57,72,61,73,5,35,94,36,16,66,17,88,56,6,41,75,6,25,87,27,68,42,23,66,19,21,76,2,33,92,21,76,44,30,79,42,46,63,59,41,94,20,66,3,71,60,54,82,2,17,98,38,90,95,3,15,65,53,39,92,6,20,62,53,33,12,52,92,39,60,72,41,86,16,40,25,63,14,21,32,24,10,68,97,38,33,40,97,93,43,40,1,94,84,27,23,71,9,68,32,19,15,25,71,57,10,52,25,92,12,72,90,42,97,79,4,73,83,25,80,26,68,35,8,91,47,43,15,57,76,68,37,29,92,92,24,52,53,37,26,94,23,49,18,20,63,38,5,15,77,66,39,89,14,20,19,80,15,63,81,3,60,74,13,33,85,71,94,7,18,95,75,34,73,23,28,99,35,77,60,71,37,74,43,50,46,55,28,97,16,90,21,60,89,88,52,48,39,72,3,46,43,77,17,79,20,71,41,67,26,99,13,54,90,64,20,75,0,0,21,21,1,10,1,0,0,0,0,0,0]).
