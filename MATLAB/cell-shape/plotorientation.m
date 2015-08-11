function plotorientation(CellStatsCell)
orientationAbsDegCell = cellfun(@(x) abs([x(:).Orientation]), ...
    CellStatsCell, 'UniformOutput', false);
binRow = linspace(0, 90, 7);
binCountCell = cellfun(@(x) histc(x, binRow), orientationAbsDegCell, ...
    'UniformOutput', false);
normBinCountCell = cellfun(@(x) x / sum(x), binCountCell, ...
    'UniformOutput', false);
normBinCountMat = vertcat(normBinCountCell{:});
figure('color', 'w');
bar(normBinCountMat, 'stacked');
set(gca, 'box', 'off', 'tickdir', 'out', 'linewidth', 1.5);
xlabel('Frame No');
ylabel('Frequency');
colormap jet;
end