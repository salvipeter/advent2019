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
run(N, M, Op, Mode, X) :-
    nth1(Op, [add, mul, input, output, jump_true, jump_false, less_than, equals, set_base], G),
    call(G, N, M, Mode, N1, M1),
    run(N1, M1, X).

patch(M, [], M) :- !.
patch(M, [X|Xs], M2) :-
    put(X, M, M1),
    patch(M1, Xs, M2).
