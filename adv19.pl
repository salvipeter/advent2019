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
%run(N, M, 4, Mode, pause(X,N1,M1)) :- !, output(N, M, Mode, N1, M1), get(out-[X|_], M1).
run(N, M, Op, Mode, X) :-
    nth1(Op, [add, mul, input, output, jump_true, jump_false, less_than, equals, set_base], G),
    call(G, N, M, Mode, N1, M1),
    run(N1, M1, X).

patch(M, [], M) :- !.
patch(M, [X|Xs], M2) :-
    put(X, M, M1),
    patch(M1, Xs, M2).

% Map

beam(X-Y, B) :-
    program(P), memory(P, M),
    patch(M, [base-0,out-[],in-[X,Y]], M1),
    run(0, M1, halt([B])), !.

map(M) :- findall(X-Y, (between(0, 49, X),
                        between(0, 49, Y),
                        beam(X-Y, 1)),
                  M).

adv19(X) :- map(M), length(M, X).

check_pos(X-Y) :-
    X1 is X + 99, Y1 is Y + 99,
    beam(X-Y1, 1), beam(X1-Y, 1).

move(X-Y, X1-Y1) :- X1 is X - 1, Y1 is Y - 1, check_pos(X1-Y1), !.

move_left(X-Y, X1-Y) :- X1 is X - 1, check_pos(X1-Y), !.

move_up(X-Y, X-Y1) :- Y1 is Y - 1, check_pos(X-Y1), !.

try_moving(P, P2) :- move(P, P1), !, try_moving1(P1, P2).
try_moving(P, P2) :- move_up(P, P1), !, try_moving1(P1, P2).
try_moving(P, P2) :- move_left(P, P1), !, try_moving1(P1, P2).
try_moving(P, P).

try_moving1(P, P2) :- move(P, P1), !, try_moving1(P1, P2).
try_moving1(P, P2) :- move_up(P, P1), !, try_moving1(P1, P2).
try_moving1(P, P2) :- move_left(P, P1), !, try_moving1(P1, P2).
try_moving1(P, P1) :- try_moving(P, P1).

adv19b(P) :- try_moving(2000-3200, P). % start from a guess based on the shape
% This is not optimal yet, but after visualization it is easy to find the solution manually:
% ?- display(120).

% Visualization

display(N) :- display(N, 0-0).
display(N, 0-N) :- !.
display(N, N-Y) :- nl, Y1 is Y + 1, display(N, 0-Y1).
display(N, X-Y) :-
    X0 is X + 1060, Y0 is Y + 1710, % add a small margin
    beam(X0-Y0, B),
    ( B = 0, write('.')
    ; B = 1, write('#')
    ),
    X1 is X + 1,
    display(N, X1-Y), !.

% Data

program([109,424,203,1,21102,1,11,0,1106,0,282,21101,0,18,0,1106,0,259,1202,1,1,221,203,1,21101,0,31,0,1105,1,282,21102,38,1,0,1105,1,259,20102,1,23,2,21201,1,0,3,21102,1,1,1,21101,0,57,0,1105,1,303,2101,0,1,222,20102,1,221,3,21002,221,1,2,21101,0,259,1,21101,0,80,0,1106,0,225,21102,1,152,2,21101,91,0,0,1106,0,303,1201,1,0,223,21001,222,0,4,21101,0,259,3,21102,225,1,2,21101,0,225,1,21102,1,118,0,1105,1,225,20101,0,222,3,21102,61,1,2,21101,133,0,0,1106,0,303,21202,1,-1,1,22001,223,1,1,21102,148,1,0,1105,1,259,2101,0,1,223,21001,221,0,4,21001,222,0,3,21101,0,14,2,1001,132,-2,224,1002,224,2,224,1001,224,3,224,1002,132,-1,132,1,224,132,224,21001,224,1,1,21101,0,195,0,105,1,109,20207,1,223,2,20101,0,23,1,21102,-1,1,3,21102,214,1,0,1105,1,303,22101,1,1,1,204,1,99,0,0,0,0,109,5,2101,0,-4,249,21202,-3,1,1,21202,-2,1,2,21201,-1,0,3,21102,1,250,0,1106,0,225,22101,0,1,-4,109,-5,2106,0,0,109,3,22107,0,-2,-1,21202,-1,2,-1,21201,-1,-1,-1,22202,-1,-2,-2,109,-3,2105,1,0,109,3,21207,-2,0,-1,1206,-1,294,104,0,99,22102,1,-2,-2,109,-3,2105,1,0,109,5,22207,-3,-4,-1,1206,-1,346,22201,-4,-3,-4,21202,-3,-1,-1,22201,-4,-1,2,21202,2,-1,-1,22201,-4,-1,1,21202,-2,1,3,21101,343,0,0,1106,0,303,1105,1,415,22207,-2,-3,-1,1206,-1,387,22201,-3,-2,-3,21202,-2,-1,-1,22201,-3,-1,3,21202,3,-1,-1,22201,-3,-1,2,22101,0,-4,1,21101,0,384,0,1106,0,303,1105,1,415,21202,-4,-1,-4,22201,-4,-3,-4,22202,-3,-2,-2,22202,-2,-4,-4,22202,-3,-2,-3,21202,-4,-1,-2,22201,-3,-2,1,21201,1,0,-4,109,-5,2106,0,0]).
