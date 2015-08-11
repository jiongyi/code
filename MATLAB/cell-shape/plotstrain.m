function plotstrain(CellStatsCell)
% Initialize variables.
noFrames = numel(CellStatsCell);
meanHorizProjRow = zeros(1, noFrames);
% Loop over each frame.
for iFrame = 1 : noFrames
    tmpMajorAxisLengthRow = [CellStatsCell{iFrame}(:).MajorAxisLength];
    tmpOrientatonRadRow = [CellStatsCell{iFrame}(:).Orientation] / 180 * pi;
    meanHorizProjRow(iFrame) = mean(tmpMajorAxisLengthRow .* ...
        tmpOrientatonRadRow);
end
% Normalize strain.
meanHorizProjRow = meanHorizProjRow / meanHorizProjRow(1);
prctStrainRow = (meanHorizProjRow - 1) * 100;

figure('color', 'w');
plot(prctStrainRow);
set(gca, 'box', 'off', 'tickdir', 'out', 'linewidth', 1.5);
xlabel('Frame No');
ylabel('Percent horizontal strain');
end