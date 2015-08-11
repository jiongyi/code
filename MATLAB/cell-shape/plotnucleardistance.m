function plotnucleardistance(NucleusStatsCell)
% Initialize variables.
noFrames = numel(NucleusStatsCell);
meanNearNeighHorizDistRow = zeros(1, noFrames);
% Loop over each frame.
for iFrame = 1 : noFrames
    tmpCentroidMat = vertcat(NucleusStatsCell{iFrame}(:).Centroid);
    tmpDistMat = pdist2(tmpCentroidMat, tmpCentroidMat);
    tmpMaxDist = max(tmpDistMat(:));
    tmpDistMat = tmpDistMat + tmpMaxDist * eye(size(tmpDistDist));
    [~, idxCol] = min(tmpDistMat, [], 2);
    tmpHorizDistMat = pdist2(tmpCentroidMat(:, 1), tmpCentroidMat(:, 1));
    noNuclei = size(tmpHorizDistMat, 1);
    meanNearNeighHorizDistRow(iFrame) = mean(arrayfun(@(x, y) ...
        tmpHorizDistMat(x, y), 1 : noNuclei, idxCol));
end
% Normalize strain.
meanNearNeighHorizDistRow = meanNearNeighHorizDistRow / ...
    meanNearNeighHorizDistRow(1);
prctStrainRow = (meanNearNeighHorizDistRow - 1) * 100;

figure('color', 'w');
plot(prctStrainRow);
set(gca, 'box', 'off', 'tickdir', 'out', 'linewidth', 1.5);
xlabel('Frame No');
ylabel('Percent horizontal strain');
end