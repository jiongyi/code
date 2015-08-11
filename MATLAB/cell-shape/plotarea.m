function plotarea(CellStatsCell)
noFrames = numel(CellStatsCell);
meanAreaRow = zeros(1, noFrames);
semAreaRow = zeros(1, noFrames); 
for iFrame = 1 : noFrames
    noCells = numel(CellStatsCell{iFrame});
    meanAreaRow(iFrame) = mean([CellStatsCell{iFrame}(:).Area]);
    semAreaRow(iFrame) = std([CellStatsCell{iFrame}(:).Area]) / ...
        sqrt(noCells);
end
normMeanAreaRow = meanAreaRow / meanAreaRow(1);
normStdAreaRow = stdAreaRow / stdAreRow(1);
prctMeanAreaRow = (normMeanAreaRow - 1) * 100;
figure('color', 'w');
errorbar(prctMeanAreaRow, normStdAreaRow);
set(gca, 'box', 'off', 'tickdir', 'out', 'linewidth', 1.5);
xlabel('Frame No');
ylabel('Mean cell area');
end