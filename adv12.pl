% -*- mode: prolog -*-

update_velocity([], [], [], []).
update_velocity([X|Xs], [Y|Ys], [Z|Zs], [Z1|Zs1]) :-
    ( X < Y, Z1 is Z - 1
    ; X > Y, Z1 is Z + 1
    ; X =:= Y, Z1 = Z
    ),
    update_velocity(Xs, Ys, Zs, Zs1).

update_gravity([], M, M).
update_gravity([moon(P,_)|Ms], moon(MP,V), M) :-
    update_velocity(P, MP, V, V1),
    update_gravity(Ms, moon(MP,V1), M).

add_vector([], [], []).
add_vector([X|Xs], [Y|Ys], [X1|Xs1]) :-
    X1 is X + Y,
    add_vector(Xs, Ys, Xs1).

update_position(moon(P,V), moon(P1,V)) :-
    add_vector(P, V, P1).

potential(moon([X,Y,Z],_), P) :-
    P is abs(X) + abs(Y) + abs(Z).

kinetic(moon(_,[X,Y,Z]), K) :-
    K is abs(X) + abs(Y) + abs(Z).

energy(M, T) :-
    potential(M, P), kinetic(M, K),
    T is P * K.

step_moons(Ms, Ms2) :-
    maplist(update_gravity(Ms), Ms, Ms1),
    maplist(update_position, Ms1, Ms2).

simulate(0, M, M).
simulate(N, M, M2) :-
    N > 0, N1 is N - 1,
    step_moons(M, M1),
    simulate(N1, M1, M2).

scan_moons([], []).
scan_moons([s(X,Y,Z)|S], [moon([X,Y,Z],[0,0,0])|M]) :-
    scan_moons(S, M).

adv12(X) :-
    scan(S), scan_moons(S, M),
    simulate(1000, M, M1),
    maplist(energy, M1, E),
    sum_list(E, X), !.

same_on_axis([], [], _).
same_on_axis([moon(P1,V1)|M1], [moon(P2,V2)|M2], I) :-
    nth0(I, P1, X), nth0(I, V1, Y),
    nth0(I, P2, X), nth0(I, V2, Y),
    same_on_axis(M1, M2, I).

simulate_axis(N, M0, M, I, N) :-
    same_on_axis(M0, M, I), !.
simulate_axis(N, M0, M, I, X) :-
    N1 is N + 1,
    step_moons(M, M1), !,
    simulate_axis(N1, M0, M1, I, X).

adv12b(X) :-
    scan(S), scan_moons(S, M0),
    step_moons(M0, M),
    simulate_axis(1, M0, M, 0, X0),
    simulate_axis(1, M0, M, 1, X1),
    simulate_axis(1, M0, M, 2, X2),
    X is lcm(lcm(X0, X1), X2), !.

% Data

scan([s(-16,15,-9),s(-14,5,4),s(2,0,6),s(-3,18,9)]).
