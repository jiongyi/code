function [sortNormBinCountMat, sortPrctStrainRow] = plotorientation(CellStatsCell)
% Calculate frequency of orientation measurements in each angle bin.
orientationAbsDegCell = cellfun(@(x) abs([x(:).Orientation]), ...
    CellStatsCell, 'UniformOutput', false);
binRow = linspace(0, 90, 7);
binCountCell = cellfun(@(x) histc(x, binRow), orientationAbsDegCell, ...
    'UniformOutput', false);
normBinCountCell = cellfun(@(x) x / sum(x), binCountCell, ...
    'UniformOutput', false);
normBinCountMat = vertcat(normBinCountCell{:});

% Calculate percent strain in each frame.
prctStrainRow = plotstrain(CellStatsCell);
[sortPrctStrainRow, sortIdxRow] = sort(prctStrainRow, 'ascend');
sortNormBinCountMat = normBinCountMat(sortIdxRow, :);
figure('color', 'w');
bar(sortNormBinCountMat, 1, 'stacked');
set(gca, 'box', 'off', 'tickdir', 'out', 'linewidth', 1.5);
set(gca, 'ytick', 0 : 0.15 : 1);
ylim(gca, [0, 1]);
xlim(gca, [0.5, numel(CellStatsCell) - 0.5]);
xlabel(gca, 'Percent strain');
idxTick = get(gca, 'xtick');
set(gca, 'xticklabel', arrayfun(@(x) num2str(x, '%.2g'), ...
  sortPrctStrainRow(idxTick), 'UniformOutput', false));
ylabel('Frequency');
colormap jet;
end
