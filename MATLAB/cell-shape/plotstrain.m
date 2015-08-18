function [prctStrainRow, semHorizProjRow] = plotstrain(CellStatsCell)
% Initialize variables.
noFrames = numel(CellStatsCell);
meanHorizProjRow = zeros(1, noFrames);
semHorizProjRow = zeros(1, noFrmaes);
% Loop over each frame.
for iFrame = 1 : noFrames
    tmpMajorAxisLengthRow = [CellStatsCell{iFrame}(:).MajorAxisLength];
    tmpOrientatonRadRow = [CellStatsCell{iFrame}(:).Orientation] / 180 * pi;
    tmpHorizProjRow = tmpMajorAxisLengthRow .* cos(tmpOrientationRadRow);
    tmpNoPoints = numel(tmpHorizProjRow);
    meanHorizProjRow(iFrame) = mean(tmpHorizProjRow);
    semHorizProjRow(iFrame) = std(tmpHorizProjRow) / sqrt(tmpNoPoints);
end
% Normalize strain.
semHorizProjRow = semHorizProjRow ./ meanHorizProjRow * 100;
meanHorizProjRow = meanHorizProjRow / meanHorizProjRow(1);
prctStrainRow = (meanHorizProjRow - 1) * 100;

figure('color', 'w');
plot(prctStrainRow);
set(gca, 'box', 'off', 'tickdir', 'out', 'linewidth', 1.5);
xlabel('Frame No');
ylabel('Percent horizontal strain');
end
