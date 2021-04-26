% -*- mode: prolog -*-

digit(L, I, X) :- digit(L, I, 1, 0, X).

digit([], _, _, A, X) :- last_digit(A, X).
digit([D|L], I, K, A, X) :-
    multiplier(I, K, M),
    A1 is A + D * M,
    K1 is K + 1,
    !, digit(L, I, K1, A1, X).

last_digit(N, D) :- N < 0, D is -N mod 10.
last_digit(N, D) :- N >= 0, D is N mod 10.

% Multiplier of Kth digit when computing the new Ith digit
% (K and I start from 1)
multiplier(I, K, M) :-
    T is (K // I) mod 4,
    ( T = 0, M = 0
    ; T = 1, M = 1
    ; T = 2, M = 0
    ; T = 3, M = -1
    ), !.

next_phase(L, L1) :- length(L, N), next_phase(N, L, 0, L1).

next_phase(N, _, N, []).
next_phase(N, L, I, [D|Ds]) :-
    I < N, I1 is I + 1,
    digit(L, I1, D),
    next_phase(N, L, I1, Ds).

iterations(0, L, L).
iterations(N, L, X) :-
    N > 0, N1 is N - 1,
    next_phase(L, L1),
    iterations(N1, L1, X).

prefix(N, L, X) :- prefix(N, L, 0, X).
prefix(0, _, A, A).
prefix(N, [D|L], A, X) :-
    N > 0, N1 is N - 1,
    A1 is A * 10 + D,
    prefix(N1, L, A1, X).

adv16(X) :- signal(S), iterations(100, S, S1), prefix(8, S1, X), !.

% Trick: the starting index in the problem (and in all the examples)
% is near the end of the series, so we only need to sum the digits
% from the starting index to the end.

% A very compact (but somehow not very efficient) Haskell implementation:
%
% adv16b = take 8 $ iterate next xs !! 100
%     where next = scanr1 (\x y -> (x + y) `mod` 10)
%           xs   = [signal !! (n `mod` 650) | n <- [5979633..6500000-1]]
%
% signal = [5,9,7,9,...
%
% Anyway, this would be much faster with destructive updates, see adv16.scm.

get(I, N) :-
    signal(D),
    I1 is I mod 650, % data length
    nth0(I1, D, N).

generate_list(E, E, []) :- !.
generate_list(I, E, [X|L]) :-
    I < E, I1 is I + 1,
    get(I, X),
    generate_list(I1, E, L).

next([X], [X]) :- !.
next([X|Xs], [X1,Y|Ys]) :-
    next(Xs, [Y|Ys]),
    X1 is (X + Y) mod 10.

iterate(0, L, L) :- !.
iterate(N, L, L2) :-
    N > 0, N1 is N - 1,
    next(L, L1),
    iterate(N1, L1, L2).

take(0, _, []) :- !.
take(N, [X|Xs], [X|Ys]) :-
    N > 0, N1 is N - 1,
    take(N1, Xs, Ys).

from_digits(D, N) :- from_digits(D, 0, N).
from_digits([], A, A).
from_digits([X|Xs], A, N) :-
    A1 is A * 10 + X,
    from_digits(Xs, A1, N).

adv16b(X) :-
    generate_list(5979633, 6500000, L),
    iterate(100, L, L1),
    take(8, L1, D),
    from_digits(D, X).

% Data

signal([5,9,7,9,6,3,3,2,4,3,0,2,8,0,5,2,8,2,1,1,0,6,0,6,5,7,5,7,7,0,3,9,7,4,4,0,5,6,6,0,9,6,3,6,5,0,5,1,1,1,3,1,3,3,3,6,0,9,4,8,6,5,9,0,0,6,3,5,3,4,3,6,8,2,2,9,6,7,0,2,0,9,4,0,1,8,4,3,2,7,6,5,6,1,3,0,1,9,3,7,1,2,3,4,4,8,3,8,1,8,4,1,5,9,3,4,9,1,4,5,7,5,7,1,7,1,3,4,6,1,7,7,8,3,5,1,5,2,3,7,3,0,0,9,1,9,2,0,1,9,8,9,7,0,6,4,5,1,5,2,4,0,6,9,0,4,4,9,2,1,3,8,4,7,3,8,9,3,0,1,7,2,0,2,6,2,3,4,8,7,2,5,2,5,2,5,4,6,8,9,6,0,9,7,8,7,7,5,2,4,0,1,3,4,2,6,8,7,0,9,8,9,1,8,8,0,4,2,1,0,4,9,4,3,9,1,1,6,1,5,3,1,0,0,8,3,4,1,3,2,9,0,1,6,6,2,6,9,2,2,9,9,0,9,3,8,8,5,4,6,8,1,5,7,5,3,1,7,5,5,9,8,2,1,0,6,7,9,3,3,0,5,8,6,3,0,6,8,8,3,6,5,0,6,7,7,9,0,8,1,2,3,4,1,4,7,5,1,6,8,2,0,0,2,1,5,4,9,4,9,6,3,6,9,0,5,9,3,8,7,3,2,5,0,8,8,4,8,0,7,8,4,0,6,1,1,4,8,7,2,8,8,5,6,0,2,9,1,7,4,8,4,1,4,1,6,0,5,5,1,5,0,8,9,7,9,3,7,4,3,3,5,2,6,7,1,0,6,4,1,4,6,0,2,5,2,6,2,4,9,4,0,1,2,8,1,0,6,6,5,0,1,6,7,7,2,1,2,0,0,2,9,8,0,6,1,6,7,1,1,0,5,8,8,0,3,8,4,5,3,3,6,0,6,7,1,2,3,2,9,8,9,8,3,2,5,8,0,1,0,0,7,9,1,7,8,1,1,1,6,7,8,6,7,8,7,9,6,5,8,6,1,7,6,7,0,5,1,3,0,9,3,8,1,3,9,3,3,7,6,0,3,5,3,8,6,8,3,8,0,3,1,5,4,8,2,4,5,0,2,7,6,1,2,2,8,1,8,4,2,0,9,4,7,3,3,4,4,6,0,7,0,5,5,9,2,6,1,2,0,8,2,9,7,5,1,5,3,2,8,8,7,8,1,0,4,8,7,1,6,4,4,8,2,3,0,7,5,6,4,7,1,2,6,9,2,2,0,8,1,5,7,1,1,8,9,2,3,5,0,2,0,1,0,0,2,8,2,5,0,8,8,6,2,9,0,8,7,3,9,9,5,5,7,7,1,0,2,1,7,8,5,2,6,9,4,2,1,5,2]).
