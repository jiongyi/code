function plotorientation(CellStatsCell)
orientationRadCell = cellfun(@(x) [x(:).Orientation], CellStatsCell, ...
    'UniformOutput', false);
cosOrientationCell = cellfun(@cos, orientationCell, ...
    'UniformOutput', false);
meanCosOrientationRow = cellfun(@mean, cosOrientationCell);
figure('color', 'w');
plotSpread(orientationRadCell);
set(gca, 'box', 'off', 'tickdir', 'out', 'linewidth', 1.5);
xlabel('Frame No');
ylabel('Orientation (rad)');

figure('color', 'w');
plot(meanCosOrientationRow);
set(gca, 'box', 'off', 'tickdir', 'out', 'linewidth', 1.5);
xlabel('Frame No');
ylabel('Mean cosine of orientation');
end