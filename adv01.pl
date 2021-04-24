% -*- mode: prolog -*-

fuel(Mass, Fuel) :- Fuel is Mass // 3 - 2.

adv01(X) :-
    findall(F, (mass(M), fuel(M, F)), L),
    sum_list(L, X).

fuel_rec(Mass, Fuel) :- Fuel is max(Mass // 3 - 2, 0).
fuel_rec(0, Fuel, Fuel).
fuel_rec(Mass, Acc, Fuel) :-
    Mass > 0, fuel_rec(Mass, F),
    Acc1 is Acc + F, fuel_rec(F, Acc1, Fuel).

adv01b(X) :-
    findall(F, (mass(M), fuel_rec(M, 0, F)), L),
    sum_list(L, X).

% Data

mass(85644).
mass(52584).
mass(72349).
mass(83834).
mass(56593).
mass(108492).
mass(94585).
mass(97733).
mass(62732).
mass(103113).
mass(133259).
mass(132647).
mass(52460).
mass(51299).
mass(115749).
mass(121047).
mass(69451).
mass(54737).
mass(62738).
mass(116686).
mass(57293).
mass(97273).
mass(128287).
mass(139440).
mass(97583).
mass(130263).
mass(79307).
mass(118198).
mass(82514).
mass(70679).
mass(64485).
mass(119346).
mass(136281).
mass(114724).
mass(73580).
mass(76314).
mass(126198).
mass(97635).
mass(114655).
mass(104195).
mass(99469).
mass(70251).
mass(82815).
mass(79531).
mass(58135).
mass(80625).
mass(73106).
mass(139806).
mass(138478).
mass(136605).
mass(111472).
mass(149915).
mass(95928).
mass(126905).
mass(70496).
mass(147999).
mass(148501).
mass(114025).
mass(75716).
mass(113473).
mass(95390).
mass(104466).
mass(138715).
mass(53053).
mass(79502).
mass(98601).
mass(115139).
mass(122315).
mass(88402).
mass(124332).
mass(140107).
mass(50912).
mass(104885).
mass(142005).
mass(145938).
mass(118556).
mass(101858).
mass(51142).
mass(94100).
mass(99421).
mass(84544).
mass(137234).
mass(126374).
mass(107333).
mass(82439).
mass(125373).
mass(51212).
mass(99358).
mass(82821).
mass(89913).
mass(67513).
mass(136907).
mass(133707).
mass(139988).
mass(96914).
mass(130672).
mass(66474).
mass(120729).
mass(50131).
mass(67475).
