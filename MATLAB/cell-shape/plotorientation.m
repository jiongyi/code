function plotorientation(CellStatsCell)
orientationDegCell = cellfun(@(x) [x(:).Orientation], CellStatsCell, ...
    'UniformOutput', false);
cosOrientationCell = cellfun(@cos, orientationDegCell, ...
    'UniformOutput', false);
meanCosOrientationRow = cellfun(@mean, cosOrientationCell);

orientationAbsDegCell = cellfun(@abs, orientationDegCell, ...
    'UniformOutput', false);
[tOutCell, rOutCell] = cellfun(@(x) rose(x / 180 * pi, 24), ...
    orientationAbsDegCell, 'UniformOutput', false);
rOutNormCell = cellfun(@(x) x / sum(x), rOutCell, 'UniformOutput', false);
rOutNormMat = cat(2, rOutNormCell{:})';
figure('color', 'w');
imshow(rOutNormMat);
colormap jet;

figure('color', 'w');
plotSpread(orientationDegCell);
set(gca, 'box', 'off', 'tickdir', 'out', 'linewidth', 1.5);
xlabel('Frame No');
ylabel('Orientation (rad)');

figure('color', 'w');
plot(meanCosOrientationRow);
set(gca, 'box', 'off', 'tickdir', 'out', 'linewidth', 1.5);
xlabel('Frame No');
ylabel('Mean cosine of orientation');
end