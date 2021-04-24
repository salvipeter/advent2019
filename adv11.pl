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
    get(in-[V|I], M),
    put(V1-V, M, M1),
    put(in-I, M1, M2).

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
run(N, M, 4, Mode, pause(X,N1,M1)) :- !, output(N, M, Mode, N1, M1), get(out-X, M1).
run(N, M, Op, Mode, X) :-
    nth1(Op, [add, mul, input, output, jump_true, jump_false, less_than, equals, set_base], G),
    call(G, N, M, Mode, N1, M1),
    run(N1, M1, X).

% Robot

camera(M, P, 1) :- get_assoc(P, M, white), !.
camera(_, _, 0).

paint(M, P, 0, M1) :- !, ( put_assoc(P, M, black, M1) ; M1 = M ).
paint(M, P, 1, M1) :- put_assoc(P, M, white, M1).

turn(up, 0, left).
turn(left, 0, down).
turn(down, 0, right).
turn(right, 0, up).
turn(up, 1, right).
turn(right, 1, down).
turn(down, 1, left).
turn(left, 1, up).

move(X-Y, up, X-Y1) :- Y1 is Y - 1.
move(X-Y, right, X1-Y) :- X1 is X + 1.
move(X-Y, down, X-Y1) :- Y1 is Y + 1.
move(X-Y, left, X1-Y) :- X1 is X - 1.

one_step(robot(RN,RM), P, D, M, robot(RN2,RM2), P1, D1, M1) :-
    camera(M, P, C),
    put(in-[C], RM, RM0),
    run(RN, RM0, R), !, R = pause([O1|_],RN1,RM1),
    run(RN1, RM1, pause([O2|_],RN2,RM2)),
    paint(M, P, O1, M1),
    turn(D, O2, D1),
    move(P, D1, P1), !.

run_robot(R, P, D, M, X) :-
    one_step(R, P, D, M, R1, P1, D1, M1), !,
    run_robot(R1, P1, D1, M1, X).
run_robot(_, _, _, M, M).

adv11(X) :-
    program(P), memory(P, M), empty_assoc(L),
    run_robot(robot(0,M), 0-0, up, L, L1),
    assoc_to_keys(L1, X1), length(X1, X).

adv11b :-
    program(P), memory(P, M), empty_assoc(L0),
    put_assoc(0-0, L0, white, L),
    run_robot(robot(0,M), 0-0, up, L, L1),
    display(L1), !.

% Display

write_row(40, _, _) :- nl.
write_row(X, Y, L) :-
    X < 40, X1 is X + 1,
    ( get_assoc(X-Y, L, white), write('O')
    ; write('.')
    ), write_row(X1, Y, L).

write_rows(6, _).
write_rows(Y, L) :-
    Y < 6, Y1 is Y + 1,
    write_row(1, Y, L), write_rows(Y1, L).

display(L) :- write_rows(0, L).

% Test program

/*
program([109,26,        % set base to the position before the inputs
         109,1,         % set base to the next input
         3,100,         % put current input at [100]
         208,0,100,100, % check that the input is correct
         1006,100,48,   % jump to error if not
         204,7,204,14,  % write output
         1208,17,99,100,% are we at the end?
         106,100,2,     % jump to the start if not
         106,0,50,      % jump to the end
         0,0,0,0,1,0,0, % inputs
         1,0,1,1,0,1,1, % output colors
         0,0,0,0,1,0,0, % output directions
         104,-1,        % show error
         99]).          % halt
*/

% Data

program([3,8,1005,8,330,1106,0,11,0,0,0,104,1,104,0,3,8,102,-1,8,10,1001,10,1,10,4,10,108,0,8,10,4,10,1001,8,0,28,1,1103,17,10,1006,0,99,1006,0,91,1,102,7,10,3,8,1002,8,-1,10,101,1,10,10,4,10,108,1,8,10,4,10,1002,8,1,64,3,8,102,-1,8,10,1001,10,1,10,4,10,108,0,8,10,4,10,102,1,8,86,2,4,0,10,1006,0,62,2,1106,13,10,3,8,1002,8,-1,10,1001,10,1,10,4,10,1008,8,0,10,4,10,101,0,8,120,1,1109,1,10,1,105,5,10,3,8,102,-1,8,10,1001,10,1,10,4,10,108,1,8,10,4,10,1002,8,1,149,1,108,7,10,1006,0,40,1,6,0,10,2,8,9,10,3,8,102,-1,8,10,1001,10,1,10,4,10,1008,8,1,10,4,10,1002,8,1,187,1,1105,10,10,3,8,102,-1,8,10,1001,10,1,10,4,10,1008,8,1,10,4,10,1002,8,1,213,1006,0,65,1006,0,89,1,1003,14,10,3,8,102,-1,8,10,1001,10,1,10,4,10,108,0,8,10,4,10,102,1,8,244,2,1106,14,10,1006,0,13,3,8,102,-1,8,10,1001,10,1,10,4,10,108,0,8,10,4,10,1001,8,0,273,3,8,1002,8,-1,10,1001,10,1,10,4,10,108,1,8,10,4,10,1001,8,0,295,1,104,4,10,2,108,20,10,1006,0,94,1006,0,9,101,1,9,9,1007,9,998,10,1005,10,15,99,109,652,104,0,104,1,21102,937268450196,1,1,21102,1,347,0,1106,0,451,21101,387512636308,0,1,21102,358,1,0,1105,1,451,3,10,104,0,104,1,3,10,104,0,104,0,3,10,104,0,104,1,3,10,104,0,104,1,3,10,104,0,104,0,3,10,104,0,104,1,21101,0,97751428099,1,21102,1,405,0,1105,1,451,21102,1,179355806811,1,21101,416,0,0,1106,0,451,3,10,104,0,104,0,3,10,104,0,104,0,21102,1,868389643008,1,21102,439,1,0,1105,1,451,21102,1,709475853160,1,21102,450,1,0,1105,1,451,99,109,2,22102,1,-1,1,21101,0,40,2,21101,482,0,3,21102,1,472,0,1105,1,515,109,-2,2106,0,0,0,1,0,0,1,109,2,3,10,204,-1,1001,477,478,493,4,0,1001,477,1,477,108,4,477,10,1006,10,509,1101,0,0,477,109,-2,2105,1,0,0,109,4,2101,0,-1,514,1207,-3,0,10,1006,10,532,21101,0,0,-3,21202,-3,1,1,22101,0,-2,2,21101,1,0,3,21101,0,551,0,1105,1,556,109,-4,2106,0,0,109,5,1207,-3,1,10,1006,10,579,2207,-4,-2,10,1006,10,579,22102,1,-4,-4,1105,1,647,21201,-4,0,1,21201,-3,-1,2,21202,-2,2,3,21101,0,598,0,1106,0,556,22101,0,1,-4,21102,1,1,-1,2207,-4,-2,10,1006,10,617,21101,0,0,-1,22202,-2,-1,-2,2107,0,-3,10,1006,10,639,22102,1,-1,1,21102,1,639,0,105,1,514,21202,-2,-1,-2,22201,-4,-2,-4,109,-5,2105,1,0]).
