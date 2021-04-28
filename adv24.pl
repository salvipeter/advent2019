% -*- mode: prolog -*-

% Cellular automata B12/S1

get(X-Y, V) :- map(L), nth1(Y, L, R), string_code(X, R, C), char_code(V, C).

init(L) :- findall(X-Y, (between(1, 5, X), between(1, 5, Y), get(X-Y, '#')), L).

biodiversity([], 0).
biodiversity([X-Y|P], N) :-
    biodiversity(P, N0),
    N is N0 + 1 << (5 * (Y - 1) + X - 1).

next(L, L1) :- findall(X-Y, (between(1, 5, X), between(1, 5, Y), buggy(X-Y, L)), L1).

buggy(X-Y, L) :- member(X-Y, L), !, adjacent(X-Y, L, 1).
buggy(X-Y, L) :- adjacent(X-Y, L, N), ( N = 1 ; N = 2 ).

adjacent(_, [], 0).
adjacent(X-Y, [X-Y1|P], N) :-
    abs(Y - Y1) =:= 1, !,
    adjacent(X-Y, P, N0),
    N is N0 + 1.
adjacent(X-Y, [X1-Y|P], N) :-
    abs(X - X1) =:= 1, !,
    adjacent(X-Y, P, N0),
    N is N0 + 1.
adjacent(X-Y, [_|P], N) :-
    adjacent(X-Y, P, N).

iterate(L, Bs, X) :-
    biodiversity(L, B),
    ( member(B, Bs), X = B
    ; next(L, L1),
      iterate(L1, [B|Bs], X)
    ).

adv24(X) :-
    init(L),
    iterate(L, [], X), !.

% Add recursivity by supplying a depth to each position
% (bugs are sorted for faster intersesction computation)

init1(L) :-
    findall(p(X,Y,0), (between(1, 5, X), between(1, 5, Y), get(X-Y, '#')), L0),
    sort(L0, L).

next1(L, L1) :- next1(L, L, [], L1).
next1(_, [], A, L) :- sort(A, L).
next1(L, [P|Ps], A, L1) :- new_bugs(L, P, A, A1), next1(L, Ps, A1, L1).

new_bugs(L, P, A, A1) :-
    adjacent_cells(P, Cs),
    add_adjacent(Cs, L, A, A0),
    adjacent_bugs(P, L, N),
    ( N = 1, A1 = [P|A0]
    ; N \= 1, A1 = A0
    ).

add_adjacent([], _, A, A).
add_adjacent([P|Ps], L, A, A1) :-
    member(P, L), !,
    add_adjacent(Ps, L, A, A1).
add_adjacent([P|Ps], L, A, A1) :-
    add_adjacent(Ps, L, A, A0),
    adjacent_bugs(P, L, N),
    ( ( N = 1 ; N = 2 ), !, A1 = [P|A0]
    ; A1 = A0
    ).

adjacent_bugs(P, L, N) :-
    adjacent_cells(P, C),
    sort(C, C1),
    ord_intersection(C1, L, I),
    length(I, N).

iterate1(0, L, L).
iterate1(N, L, L1) :-
    write(N), nl,
    N > 0, N1 is N - 1,
    next1(L, L0), !,
    iterate1(N1, L0, L1).

% slow (~ 3 mins.)
adv24b(X) :-
    init1(L),
    iterate1(200, L, L1),
    length(L1, X), !.

% Recursive adjacency table - not very inventive, but simple :)

adjacent_cells(p(1,1,D), [p(2,1,D),p(1,2,D),p(2,3,D1),p(3,2,D1)]) :- D1 is D - 1.
adjacent_cells(p(2,1,D), [p(3,1,D),p(2,2,D),p(1,1,D),p(3,2,D1)]) :- D1 is D - 1.
adjacent_cells(p(3,1,D), [p(4,1,D),p(3,2,D),p(2,1,D),p(3,2,D1)]) :- D1 is D - 1.
adjacent_cells(p(4,1,D), [p(5,1,D),p(4,2,D),p(3,1,D),p(3,2,D1)]) :- D1 is D - 1.
adjacent_cells(p(5,1,D), [p(4,3,D1),p(5,2,D),p(4,1,D),p(3,2,D1)]) :- D1 is D - 1.
adjacent_cells(p(1,2,D), [p(2,2,D),p(1,3,D),p(2,3,D1),p(1,1,D)]) :- D1 is D - 1.
adjacent_cells(p(2,2,D), [p(3,2,D),p(2,3,D),p(1,2,D),p(2,1,D)]).
adjacent_cells(p(3,2,D), [p(4,2,D),p(1,1,D1),p(2,1,D1),p(3,1,D1),
                         p(4,1,D1),p(5,1,D1),p(2,2,D),p(3,1,D)]) :- D1 is D + 1.
adjacent_cells(p(4,2,D), [p(5,2,D),p(4,3,D),p(3,2,D),p(4,1,D)]).
adjacent_cells(p(5,2,D), [p(4,3,D1),p(5,3,D),p(4,2,D),p(5,1,D)]) :- D1 is D - 1.
adjacent_cells(p(1,3,D), [p(2,3,D),p(1,4,D),p(2,3,D1),p(1,2,D)]) :- D1 is D - 1.
adjacent_cells(p(2,3,D), [p(1,1,D1),p(1,2,D1),p(1,3,D1),p(1,4,D1),
                         p(1,5,D1),p(2,4,D),p(1,3,D),p(2,2,D)]) :- D1 is D + 1.
% p(3,3,D) is the next recursive level
adjacent_cells(p(4,3,D), [p(5,3,D),p(4,4,D),p(5,1,D1),p(5,2,D1),
                         p(5,3,D1),p(5,4,D1),p(5,5,D1),p(4,2,D)]) :- D1 is D + 1.
adjacent_cells(p(5,3,D), [p(4,3,D1),p(5,4,D),p(4,3,D),p(5,2,D)]) :- D1 is D - 1.
adjacent_cells(p(1,4,D), [p(2,4,D),p(1,5,D),p(2,3,D1),p(1,3,D)]) :- D1 is D - 1.
adjacent_cells(p(2,4,D), [p(3,4,D),p(2,5,D),p(1,4,D),p(2,3,D)]).
adjacent_cells(p(3,4,D), [p(4,4,D),p(3,5,D),p(2,4,D),p(1,5,D1),
                         p(2,5,D1),p(3,5,D1),p(4,5,D1),p(5,5,D1)]) :- D1 is D + 1.
adjacent_cells(p(4,4,D), [p(5,4,D),p(4,5,D),p(3,4,D),p(4,3,D)]).
adjacent_cells(p(5,4,D), [p(4,3,D1),p(5,5,D),p(4,4,D),p(5,3,D)]) :- D1 is D - 1.
adjacent_cells(p(1,5,D), [p(2,5,D),p(3,4,D1),p(2,3,D1),p(1,4,D)]) :- D1 is D - 1.
adjacent_cells(p(2,5,D), [p(3,5,D),p(3,4,D1),p(1,5,D),p(2,4,D)]) :- D1 is D - 1.
adjacent_cells(p(3,5,D), [p(4,5,D),p(3,4,D1),p(2,5,D),p(3,4,D)]) :- D1 is D - 1.
adjacent_cells(p(4,5,D), [p(5,5,D),p(3,4,D1),p(3,5,D),p(4,4,D)]) :- D1 is D - 1.
adjacent_cells(p(5,5,D), [p(4,3,D1),p(3,4,D1),p(4,5,D),p(5,4,D)]) :- D1 is D - 1.

% Data

map(['..#.#',
     '#.##.',
     '.#..#',
     '#....',
     '....#']).
