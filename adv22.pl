% -*- mode: prolog -*-

card(_, [], K, K).
card(N, [new|Ts], K, X) :-
    K1 is N - K - 1,
    card(N, Ts, K1, X).
card(N, [cut(C)|Ts], K, X) :-
    K1 is (K - C) mod N,
    card(N, Ts, K1, X).
card(N, [deal(D)|Ts], K, X) :-
    K1 is (D * K) mod N,
    card(N, Ts, K1, X).

adv22(X) :- technique(Ts), card(10007, Ts, 2019, X), !.

% Idea: let the card be given in the form M X + P

operations(_, [], D, D).
operations(N, [new|Ts], deck(M,P), X) :-
    M1 is -M, P1 is N - P - 1,
    operations(N, Ts, deck(M1,P1), X).
operations(N, [cut(C)|Ts], deck(M,P), X) :-
    P1 is (P - C) mod N,
    operations(N, Ts, deck(M,P1), X).
operations(N, [deal(D)|Ts], deck(M,P), X) :-
    M1 is (M * D) mod N, P1 is (P * D) mod N,
    operations(N, Ts, deck(M1,P1), X).

% After K iterations, X should become 2020,
% so we need to find Y such that
%
%   (M^K Y + P (M^K - 1) / (M - 1)) mod N = 2020

% Solve A X mod N = B
solve(N, A, B, X) :-
    euclid(A, N, I, _),
    X is I * B mod N.

% Extended Euclidean algorithm (from Rosetta Code)
% Computes X and Y s.t. A X + B Y = gcd(A, B)
euclid(_, 0, 1, 0) :- !.
euclid(A, B, X, Y) :-
    divmod(A, B, Q, R),
    euclid(B, R, S, X),
    Y is S - Q * X.

adv22b(X) :-
    technique(Ts),
    Size = 119315717514047,
    Iterations = 101741582076661,
    operations(Size, Ts, deck(1,0), deck(M,P)),
    MK is powm(M, Iterations, Size),
    A is MK * (M - 1) mod Size,
    P1 is P * (MK - 1) mod Size,
    B is (2020 * (M - 1) - P1) mod Size,
    solve(Size, A, B, X), !.

% Data

technique([deal(64), new, cut(1004), deal(31), cut(5258), new, deal(5), cut(-517), deal(67), new, cut(-4095), deal(27), cut(4167), deal(30), cut(-5968), new, deal(40), new, deal(57), cut(-5128), deal(75), new, deal(75), cut(-1399), deal(12), cut(-2107), deal(9), cut(-7110), new, deal(14), cut(3318), new, deal(57), cut(-8250), deal(5), new, cut(903), deal(28), new, cut(2546), deal(68), cut(9343), deal(67), cut(-6004), deal(24), new, cut(-816), deal(66), new, deal(13), cut(5894), deal(43), new, cut(4550), deal(67), cut(-3053), deal(42), new, deal(32), cut(-5985), deal(18), cut(-2808), deal(44), cut(-1586), deal(16), cut(2173), deal(53), cut(5338), deal(48), cut(-2640), deal(36), new, deal(13), cut(-5520), deal(61), cut(-3199), new, cut(4535), deal(17), cut(-4277), deal(72), cut(-7377), new, deal(37), cut(6665), new, cut(908), new, cut(9957), deal(31), cut(9108), deal(44), cut(-7565), deal(33), cut(-7563), deal(23), cut(-3424), deal(63), cut(-3513), deal(74)]).
