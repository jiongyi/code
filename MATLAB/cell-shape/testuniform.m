function testuniform(dataRow)
a = min(dataRow);
b = max(dataRow);
[f, x] = ecdf(dataRow);
noPoints = numel(dataRow);
[fTheo, xTheo, floTheo, fupTheo] = ecdf(linspace(a, b, noPoints));
figure('color', 'white');
plot(x, f);
set(gca, 'box', 'off', 'tickdir', 'out', 'linewidth', 1.5);
hold on;
plot(xTheo, fTheo, 'r');
plot(xTheo, floTheo, '--r');
plot(xTheo, fupTheo, '--r');
hold off;
xlabel('Absolute orientation (rad)');
ylabel('Cumulative frequency');
legend('Observed', 'Expected', 'Location', 'SouthEast');
end