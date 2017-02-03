function fvpol(forceRow)

[a0, w0] = arrayfun(@(x) elasticbrownianratchet(0), 1 : 100);
aNorm = mean(a0);
wNorm = mean(w0);
tNorm = aNorm + wNorm;

noForces = numel(forceRow);
a = zeros(1, noForces);
aStd = zeros(1, noForces);
w = zeros(1, noForces);
wStd = zeros(1, noForces);
t = zeros(1, noForces);
tStd = zeros(1, noForces);
for i = 1 : noForces
    [aCurr, wCurr] = arrayfun(@(x) elasticbrownianratchet(forceRow(i)), ...
        1 : 100);
    aCurr = aCurr / tNorm;
    wCurr = wCurr / tNorm;
    a(i) = mean(aCurr);
    aStd(i) = std(aCurr);
    w(i) = mean(wCurr);
    wStd(i) = std(wCurr);
    t(i) = a(i) + w(i);
    tStd(i) = std(aCurr + wCurr);
end

figure;
hold all;
errorbar(forceRow, a, aStd);
errorbar(forceRow, w, wStd);
errorbar(forceRow, t, tStd);
hold off;
legend('attached', 'working', 'total');
end