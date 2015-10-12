function uCol = tridag(aCol, bCol, cCol, rCol)
% Initialize variables.
n = numel(aCol);
gamCol = zeros(n, 1);
if bCol(1) == 0.0
    error('Error 1 in tridag');
else
    bet = bCol(1);
    uCol(1) = rCol(1) / bet;
    for j = 2 : n
        gamCol(j) = cCol(j - 1) /bet;
        bet = bCol(j) - aCol(j) * gamCol(j);
        if bet == 0
            error('Error 2 in tridag');
        else
            uCol(j) = (rCol(j) - aCol(j) * uCol(j - 1)) / bet;
        end;
    end;
    for k = (n - 1) : -1 : 1
        uCol(k) = uCol(k) - gamCol(k + 1) * uCol(k + 1);
    end;
end;
end;
