% -*- mode: prolog -*-

memory([], _, []).
memory([P|Ps], N, [N-P|Ms]) :- N1 is N + 1, memory(Ps, N1, Ms).

get(X, [X|_]) :- !.
get(X, [Y|Ys]) :- X \= Y, !, get(X, Ys).

add(N, M, [I3-V|M]) :-
    N1 is N + 1, N2 is N + 2, N3 is N + 3,
    get(N1-I1, M), get(N2-I2, M), get(N3-I3, M),
    get(I1-V1, M), get(I2-V2, M),
    V is V1 + V2.

mul(N, M, [I3-V|M]) :-
    N1 is N + 1, N2 is N + 2, N3 is N + 3,
    get(N1-I1, M), get(N2-I2, M), get(N3-I3, M),
    get(I1-V1, M), get(I2-V2, M),
    V is V1 * V2.

run(N, M, X) :- get(N-99, M), get(0-X, M).
run(N, M, X) :-
    ( get(N-1, M), add(N, M, M1)
    ; get(N-2, M), mul(N, M, M1)
    ),
    N1 is N + 4, run(N1, M1, X).

adv02(X) :- program(P), memory(P, 0, M), run(0, M, X).

adv02b(X) :-
    program(P), memory(P, 0, M),
    between(0, 99, Noun), between(0, 99, Verb),
    run(0, [1-Noun,2-Verb|M], 19690720),
    X is 100 * Noun + Verb.

% Data

program([1,12,2,3,1,1,2,3,1,3,4,3,1,5,0,3,2,13,1,19,1,9,19,23,2,23,13,27,1,27,9,31,2,31,6,35,1,5,35,39,1,10,39,43,2,43,6,47,1,10,47,51,2,6,51,55,1,5,55,59,1,59,9,63,1,13,63,67,2,6,67,71,1,5,71,75,2,6,75,79,2,79,6,83,1,13,83,87,1,9,87,91,1,9,91,95,1,5,95,99,1,5,99,103,2,13,103,107,1,6,107,111,1,9,111,115,2,6,115,119,1,13,119,123,1,123,6,127,1,127,5,131,2,10,131,135,2,135,10,139,1,13,139,143,1,10,143,147,1,2,147,151,1,6,151,0,99,2,14,0,0]).

%?- adv02(X).
