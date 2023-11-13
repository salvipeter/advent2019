# For generating the data strings of adv06.fs
{
    split($1, x, ")")
    for (i = 1; i <= 2; i++) {
        if (!(x[i] in a))
            a[x[i]] = ++n
        b[NR,i] = a[x[i]]
    }
}
END {
    print a["COM"], "constant COM"
    print a["YOU"], "constant YOU"
    print a["SAN"], "constant SAN"
    print "create data"
    for (i = 1; i <= NR; i++)
        print b[i,1], ",", b[i,2], ","
}
