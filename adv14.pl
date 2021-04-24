% -*- mode: prolog -*-

% ore(Chemical, N, Store, Store1, Ore)
ore(ore, N, S, S, N) :- !.
ore(C, N, S, S2, O) :-
    select(C-M, S, S1), !,
    N1 is N - M,
    ore(C, N1, S1, S2, O).
ore(C, N, S, S2, O) :-
    factory(C-K, L),
    M is ceiling(N / K),
    R is M * K - N,
    ( R = 0, S1 = S
    ; R > 0, S1 = [C-R|S]
    ),
    ore_list(M, L, S1, S2, OL),
    sum_list(OL, O).

ore_list(_, [], S, S, []).
ore_list(M, [C-N|L], S, S2, [O|OL]) :-
    N1 is M * N,
    ore(C, N1, S, S1, O),
    ore_list(M, L, S1, S2, OL).

fuel_ore(N, X) :- ore(fuel, N, [], _, X), !.

adv14(X) :- fuel_ore(1, X).

upper_bound(N, I, U) :-
    fuel_ore(I, O),
    O < N, !, I1 is I * 2,
    upper_bound(N, I1, U).
upper_bound(_, I, I).

bisection(N, L, U, X) :-
    M is (L + U) // 2,
    ( M =:= L, X = L
    ; M > L, fuel_ore(M, O),
      ( O < N, bisection(N, M, U, X)
      ; O > N, bisection(N, L, M, X)
      )
    ).

adv14b(X) :-
    N = 1000000000000,
    upper_bound(N, 1, U),
    bisection(N, 1, U, X).

% Data

factory(zspl-6, [hjdm-1, bmpdp-1, drcx-8, tctbl-2, kgwdj-1, brlf-16, lwpb-2, kdfq-7]).
factory(lchrc-6, [pvrck-1, rslr-3, jbzd-4]).
factory(pnqlp-9, [fcbvc-10, tsjsj-1, sqcq-20]).
factory(tszj-6, [mbvl-1]).
factory(zslvh-4, [hwgqf-1]).
factory(hrzh-1, [tbdsc-1, tszj-13]).
factory(rsfjr-3, [rslr-1, ljwm-1]).
factory(mbvl-2, [vmzfb-1]).
factory(zwlgk-4, [dsthj-4, tszj-2, mbvl-13]).
factory(zcvl-1, [mktz-1, rvfjb-18, rslr-1, hrzh-2, zwlgk-14, rjftv-4]).
factory(dlpmh-9, [kdfq-6, pnqlp-1, hrzh-1]).
factory(gwjc-5, [dsvt-1, drcx-22, rjftv-18, mktz-2, fvzbx-13, sltnz-15, zslvh-7]).
factory(rjftv-8, [jzsj-2, zslvh-3, hnrxc-6]).
factory(gfvg-7, [tszj-1]).
factory(jbzd-4, [vmzfb-5]).
factory(tsjsj-1, [pbfz-1, jbzd-23, ljwm-2]).
factory(vmzfb-7, [zpqd-7]).
factory(pxhk-8, [lchrc-2]).
factory(hwgqf-6, [tszj-2, kcxmf-1, fkjgc-1]).
factory(fcbvc-1, [pbfz-4]).
factory(sqcq-8, [gmwhm-1, jqbkw-4]).
factory(pvrck-5, [shmp-5]).
factory(drcx-3, [kcxmf-10]).
factory(kdfq-6, [vmzfb-15, rsfjr-2]).
factory(cjlg-2, [hnrxc-35]).
factory(brlf-9, [mktz-8, fcbvc-1, hjdm-12]).
factory(gmwhm-8, [ore-171]).
factory(lwpb-3, [rvfjb-8, cjlg-3, sltnz-9]).
factory(fvzbx-3, [pxhk-1, rsfjr-2]).
factory(kgwdj-8, [cjlg-1, hrzh-1, mktz-10]).
factory(fkjgc-3, [rsfjr-1]).
factory(mktz-2, [nxczm-1, fkjgc-31]).
factory(mblwl-6, [xlwbp-18]).
factory(ftgk-8, [hnrxc-22]).
factory(dsvt-7, [kgwdj-3, mlbj-1, hjdm-5]).
factory(nxczm-5, [kdfq-9]).
factory(cvtr-5, [rvfjb-2, lgdkl-4, pxhk-1]).
factory(lgdkl-9, [rsfjr-1, gmwhm-6, tsjsj-20]).
factory(rbdp-9, [kcxmf-5]).
factory(fuel-1, [gwjc-6, zcvl-16, jzsj-29, zspl-1, mblwl-35, bwfrh-30, msfdb-2, bmpdp-13, ftgk-11, zwlgk-1]).
factory(hjdm-8, [gfvg-6, tvqp-2]).
factory(jzsj-6, [cjlg-1, pbfz-13]).
factory(bmpdp-3, [cvtr-3]).
factory(msfdb-8, [fpkmv-16, zslvh-1]).
factory(tbdsc-8, [jbzd-9, lchrc-12]).
factory(ljwm-3, [ore-133]).
factory(shmp-7, [ore-107]).
factory(fpkmv-9, [kdfq-1, ljwm-1]).
factory(bwfrh-4, [pxhk-3]).
factory(jqbkw-4, [ore-123]).
factory(xlwbp-8, [fvzbx-2, jzsj-1]).
factory(zpqd-2, [ore-117]).
factory(hnrxc-7, [nxczm-7]).
factory(kcxmf-8, [mlbj-1, rslr-22]).
factory(rvfjb-8, [tbdsc-2]).
factory(sltnz-7, [kdfq-1, dsthj-23]).
factory(mlbj-6, [rsfjr-3]).
factory(rslr-9, [pvrck-5, sqcq-2]).
factory(tvqp-5, [lgdkl-1, mbvl-17, pnqlp-6]).
factory(tctbl-6, [rbdp-3]).
factory(dsthj-2, [dlpmh-1, gfvg-1, mbvl-3]).
factory(pbfz-1, [vmzfb-21, ljwm-2]).
