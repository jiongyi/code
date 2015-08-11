function plotorientation(CellStatsCell)
orientationRadCell = cellfun(@(x) [x(:).Orientation], CellStatsCell, ...
    'UniformOutput', false);
figure('color', 'w');
plotStread(orientationRadCell);
set(gca, 'box', 'off', 'tickdir', 'out', 'linewidth', 1.5);
xlabel('Frame No');
ylabel('Percent horizontal strain');
end