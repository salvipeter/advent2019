% -*- mode: prolog -*-

check_asteroid(M, X-Y) :- nth1(Y, M, R), string_chars(R, L), nth1(X, L, #).

create_map(M) :-
    map(L), size(S),
    findall(X-Y, (between(1, S, X), between(1, S, Y), check_asteroid(L, X-Y)), M).

asteroid(M, P) :- member(P, M).

normalize(X-Y, G, X1-Y1) :-
    G is gcd(abs(X), abs(Y)),
    X1 is X / G, Y1 is Y / G.

visible(M, X-Y, X1-Y1) :-
    Dx is X1 - X, Dy is Y1 - Y,
    \+ (Dx = 0, Dy = 0),
    normalize(Dx-Dy, G, Dx1-Dy1),
    \+ (G1 is G - 1, between(1, G1, I),
        X2 is X + Dx1 * I, Y2 is Y + Dy1 * I,
        asteroid(M, X2-Y2)).

visible_count(M, S, P, N) :-
    findall(X-Y, (between(1, S, X), between(1, S, Y),
                  asteroid(M, X-Y), visible(M, P, X-Y)),
            L),
    length(L, N).

candidate(M, S, c(X-Y,N)) :-
    between(1, S, X), between(1, S, Y), asteroid(M, X-Y),
    visible_count(M, S, X-Y, N).

adv10(X) :-
    create_map(M), size(S),
    findall(N-P, candidate(M, S, c(P,N)), L),
    keysort(L, L1), last(L1, X).

best_location(32-21).

rotations(S, L) :-
    findall(R-r(X,Y), (between(0, S, X), between(1, S, Y), R is X rdiv Y), F),
    sort(1, @<, F, L1), pairs_values(L1, L).

quadrant1(r(X,Y), r(X,Y1)) :- Y1 is -Y.
quadrant2(r(X,Y), r(Y,X)).
quadrant3(r(X,Y), r(X1,Y)) :- X1 is -X.
quadrant4(r(X,Y), r(Y1,X1)) :- X1 is -X, Y1 is -Y.

all_rotations(S, L) :-
    rotations(S, R),
    maplist(quadrant1, R, R1),
    maplist(quadrant2, R, R2),
    maplist(quadrant3, R, R3),
    maplist(quadrant4, R, R4),
    append(R3, R4, A1),
    append(R2, A1, A2),
    append(R1, A2, L).

% First asteroid in line of sight (if any)
asteroid_sighting(M, S, X-Y, r(Dx,Dy), X1-Y1) :-
    between(1, S, I),
    X1 is X + Dx * I, Y1 is Y + Dy * I,
    asteroid(M, X1-Y1), !.

vaporize_asteroid(M, P, M1) :- select(P, M, M1).

% next_asteroid(+Map, +Size, +Pos, +Rot, -Map1, -Rot1, -X)
next_asteroid(M, S, P, [R0|Rs], M1, Rs, X) :-
    asteroid_sighting(M, S, P, R0, X), !,
    vaporize_asteroid(M, X, M1).
next_asteroid(M, S, P, [_|Rs], M1, R1, X) :-
    next_asteroid(M, S, P, Rs, M1, R1, X).

vaporize(N, M, S, P, R0, [], X) :- % start a new rotation
    vaporize(N, M, S, P, R0, R0, X).
vaporize(N, M, S, P, R0, R, X) :-
    next_asteroid(M, S, P, R, M1, R1, Next),
    ( N = 1, X = Next
    ; N1 is N - 1, vaporize(N1, M1, S, P, R0, R1, X)
    ).

adv10b(Z) :-
    create_map(M), size(S), best_location(P), all_rotations(S, R),
    vaporize(200, M, S, P, R, R, X-Y),
    Z is (X - 1) * 100 + (Y - 1), !.

% Data

size(40).
map(['##.###.#.......#.#....#....#..........#.', '....#..#..#.....#.##.............#......', '...#.#..###..#..#.....#........#......#.', '#......#.....#.##.#.##.##...#...#......#', '.............#....#.....#.#......#.#....', '..##.....#..#..#.#.#....##.......#.....#', '.#........#...#...#.#.....#.....#.#..#.#', '...#...........#....#..#.#..#...##.#.#..', '#.##.#.#...#..#...........#..........#..', '........#.#..#..##.#.##......##.........', '................#.##.#....##.......#....', '#............#.........###...#...#.....#', '#....#..#....##.#....#...#.....#......#.', '.........#...#.#....#.#.....#...#...#...', '.............###.....#.#...##...........', '...#...#.......#....#.#...#....#...#....', '.....#..#...#.#.........##....#...#.....', '....##.........#......#...#...#....#..#.', '#...#..#..#.#...##.#..#.............#.##', '.....#...##..#....#.#.##..##.....#....#.', '..#....#..#........#.#.......#.##..###..', '...#....#..#.#.#........##..#..#..##....', '.......#.##.....#.#.....#...#...........', '........#.......#.#...........#..###..##', '...#.....#..#.#.......##.###.###...#....', '...............#..#....#.#....#....#.#..', '#......#...#.....#.#........##.##.#.....', '###.......#............#....#..#.#......', '..###.#.#....##..#.......#.............#', '##.#.#...#.#..........##.#..#...##......', '..#......#..........#.#..#....##........', '......##.##.#....#....#..........#...#..', '#.#..#..#.#...........#..#.......#..#.#.', '#.....#.#.........#............#.#..##.#', '.....##....#.##....#.....#..##....#..#..', '.#.......#......#.......#....#....#..#..', '...#........#.#.##..#.#..#..#........#..', '#........#.#......#..###....##..#......#', '...#....#...#.....#.....#.##.#..#...#...', '#.#.....##....#...........#.....#...#...']).
