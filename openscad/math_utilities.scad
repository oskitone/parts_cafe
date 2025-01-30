function sum(v) = [for(p=v) 1]*v;

function slice(list, start = 0, end) =
    end == 0
        ? []
        : [for (i = [start : (end == undef ? len(list) : end) - 1]) list[i]]
;

function cat(L1, L2) = [for(L=[L1, L2], a=L) a];