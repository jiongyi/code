function plotnucleardistance(NucleusStatsCell)
% Initialize variables.
noFrames = numel(NucleusStatsCell);
meanNearNeighHorizProjRow = zeros(1, noFrames);
% Loop over each frame.
for iFrame = 1 : noFrames
    tmpCentroidMat = vertcat(NucleusStatsCell{iFrame}(:).Centroid);
    tmpDistMat = pdist2(tmpCentroidMat, tmpCentroidMat);
    tmpMaxDist = max(tmpDistMat(:));
    tmpDistMat = tmpDistMat + tmpMaxDist * eye(size(tmpMaxDist));
end
% Normalize strain.
meanNearNeighHorizProjRow = meanNearNeighHorizProjRow / meanNearNeighHorizProjRow(1);
prctStrainRow = (meanNearNeighHorizProjRow - 1) * 100;

figure('color', 'w');
plot(prctStrainRow);
set(gca, 'box', 'off', 'tickdir', 'out', 'linewidth', 1.5);
xlabel('Frame No');
ylabel('Percent horizontal strain');
end