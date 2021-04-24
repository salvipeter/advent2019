% -*- mode: prolog -*-

password(X) :-
    between(125730, 579381, X),
    digits(X, Ds),
    once(nextto(D, D, Ds)),
    sort(0, >=, Ds, Ds).

digits(N, [N]) :- N < 10, !.
digits(N, [D|Ds]) :- N >= 10, D is N mod 10, N1 is N // 10, digits(N1, Ds).

adv04(X) :- findall(P, password(P), L), length(L, X).

password2(X) :-
    between(125730, 579381, X),
    digits(X, Ds),
    clumped(Ds, C), memberchk(_-2, C),
    sort(0, >=, Ds, Ds).

adv04b(X) :- findall(P, password2(P), L), length(L, X).

% - clumped is now part of SWI Prolog

clumped(Items, Counts) :-
    clump(Items, Counts).

clump([], []).
clump([H|T0], [H-C|T]) :-
    ccount(T0, H, T1, 1, C),
    clump(T1, T).

ccount([H|T0], E, T, C0, C) :-
    E == H,
    !,
    C1 is C0+1,
    ccount(T0, E, T, C1, C).
ccount(List, _, List, C, C).
