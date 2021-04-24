% -*- mode: prolog -*-

% Memory handling

memory([], _, []).
memory([P|Ps], N, [N-P|Ms]) :- N1 is N + 1, memory(Ps, N1, Ms).

get(N-V, [N-V1|_]) :- !, V = V1.
get(N-V, [N1-_|L]) :- N \= N1, !, get(N-V, L).

parameter(N, M, out, I, V) :-
    !, N1 is N + I,
    parameter(N1, M, 1, V).
parameter(N, M, Mode, I, V) :-
    N1 is N + I,
    ( nth1(I, Mode, PosImm) ; PosImm = 0 ),
    !, parameter(N1, M, PosImm, V).

parameter(N, M, 0, V) :- get(N-I, M), get(I-V, M). % positional
parameter(N, M, 1, V) :- get(N-V, M).              % immediate

% Instructions

add(N, M, Mode, N4, [V3-V|M]) :-
    N4 is N + 4,
    parameter(N, M, Mode, 1, V1),
    parameter(N, M, Mode, 2, V2),
    parameter(N, M, out, 3, V3),
    V is V1 + V2.

mul(N, M, Mode, N4, [V3-V|M]) :-
    N4 is N + 4,
    parameter(N, M, Mode, 1, V1),
    parameter(N, M, Mode, 2, V2),
    parameter(N, M, out, 3, V3),
    V is V1 * V2.

input(N, M, _, N2, [in-I,V1-V|M]) :-
    N2 is N + 2,
    parameter(N, M, out, 1, V1),
    get(in-[V|I], M).

output(N, M, Mode, N2, [out-V|M]) :-
    N2 is N + 2,
    parameter(N, M, Mode, 1, V).

jump_true(N, M, Mode, N3, M) :-
    parameter(N, M, Mode, 1, 0), !,
    N3 is N + 3.
jump_true(N, M, Mode, V2, M) :-
    parameter(N, M, Mode, 1, V1), V1 =\= 0,
    parameter(N, M, Mode, 2, V2).

jump_false(N, M, Mode, V2, M) :-
    parameter(N, M, Mode, 1, 0), !,
    parameter(N, M, Mode, 2, V2).
jump_false(N, M, Mode, N3, M) :-
    parameter(N, M, Mode, 1, V1), V1 =\= 0,
    N3 is N + 3.

less_than(N, M, Mode, N4, [V3-V|M]) :-
    N4 is N + 4,
    parameter(N, M, Mode, 1, V1),
    parameter(N, M, Mode, 2, V2),
    parameter(N, M, out, 3, V3),
    ( V1 < V2, V = 1 ; V = 0 ).

equals(N, M, Mode, N4, [V3-V|M]) :-
    N4 is N + 4,
    parameter(N, M, Mode, 1, V1),
    parameter(N, M, Mode, 2, V2),
    parameter(N, M, out, 3, V3),
    ( V1 =:= V2, V = 1 ; V = 0 ).

% Virtual machine

digits(N, [N]) :- N < 10, !.
digits(N, [D|L]) :- N >= 10, D is N mod 10, N1 is N // 10, digits(N1, L).

run(N, M, X) :-
    get(N-I, M),
    ( digits(I, [Op2,Op1|Mode]), Op is Op1 * 10 + Op2
    ; digits(I, [Op|Mode])
    ),
    run(N, M, Op, Mode, X).

run(_, M, 99, _, halt(X)) :- get(out-X, M).
run(N, M, 4, Mode, pause(X,N1,M1)) :- output(N, M, Mode, N1, M1), get(out-X, M1).
run(N, M, Op, Mode, X) :-
    nth1(Op, [add, mul, input, output, jump_true, jump_false, less_than, equals], G),
    call(G, N, M, Mode, N1, M1),
    run(N1, M1, X).

% Configurator

configure(C, I, O) :- program(P), memory(P, 0, M), run(0, [in-[C,I]|M], O), !.

configure([A,B,C,D,E], X) :-
    configure(A, 0, pause(RA,_,_)),
    configure(B, RA, pause(RB,_,_)),
    configure(C, RB, pause(RC,_,_)),
    configure(D, RC, pause(RD,_,_)),
    configure(E, RD, pause(X,_,_)).

thrust(X) :- permutation([0,1,2,3,4], C), configure(C, X).

adv07(X) :- findall(T, thrust(T), L), max_list(L, X).

continue([_], X, X). % only E is running
continue([N-M|L], I, X) :-
    run(N, [in-[I]|M], pause(R,N1,M1)), !,
    append(L, [N1-M1], L1),
    continue(L1, R, X).
continue([N-M|L], I, X) :-
    run(N, [in-[I]|M], halt(_)),
    continue(L, I, X).

feedback([A,B,C,D,E], X) :-
    configure(A, 0, pause(RA,NA,MA)),
    configure(B, RA, pause(RB,NB,MB)),
    configure(C, RB, pause(RC,NC,MC)),
    configure(D, RC, pause(RD,ND,MD)),
    configure(E, RD, pause(RE,NE,ME)),
    continue([NA-MA,NB-MB,NC-MC,ND-MD,NE-ME], RE, X).

feedback(X) :- permutation([5,6,7,8,9], C), feedback(C, X).

adv07b(X) :- findall(F, feedback(F), L), max_list(L, X).

% Data

program([3,8,1001,8,10,8,105,1,0,0,21,46,55,72,85,110,191,272,353,434,99999,3,9,1002,9,5,9,1001,9,2,9,102,3,9,9,101,2,9,9,102,4,9,9,4,9,99,3,9,102,5,9,9,4,9,99,3,9,1002,9,2,9,101,2,9,9,1002,9,2,9,4,9,99,3,9,1002,9,4,9,101,3,9,9,4,9,99,3,9,1002,9,3,9,101,5,9,9,1002,9,3,9,101,3,9,9,1002,9,5,9,4,9,99,3,9,1001,9,2,9,4,9,3,9,101,2,9,9,4,9,3,9,101,2,9,9,4,9,3,9,1001,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,1002,9,2,9,4,9,99,3,9,102,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,1001,9,1,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,101,1,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,101,2,9,9,4,9,99,3,9,1002,9,2,9,4,9,3,9,1001,9,2,9,4,9,3,9,101,2,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,1,9,4,9,3,9,1001,9,1,9,4,9,3,9,1001,9,2,9,4,9,3,9,1001,9,1,9,4,9,3,9,101,2,9,9,4,9,99,3,9,1001,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,101,2,9,9,4,9,3,9,1001,9,2,9,4,9,3,9,1001,9,2,9,4,9,3,9,1002,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,1,9,4,9,99,3,9,101,1,9,9,4,9,3,9,102,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,1001,9,2,9,4,9,3,9,1002,9,2,9,4,9,3,9,1002,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,1001,9,2,9,4,9,3,9,1001,9,2,9,4,9,99]).
