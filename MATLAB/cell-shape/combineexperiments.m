function Experiment = combineexperiments()
[fileNameStr, folderNameStr] = uigetfile('*.mat', ...
    'Select .mat files storing results', 'MultiSelect', 'on');
if ~iscell(fileNameStr)
    fileNameStr = {fileNameStr};
end

noFiles = numel(fileNameStr);
Experiment(noFiles).orientationCell = [];
Experiment(noFiles).meanPrctStrainRow = [];
Experiment(noFiles).semPrctStrainRow = [];
Experiment(noFiles).noCellsRow = [];
Experiment(noFiles).nameStr = [];
for i = 1 : noFiles
    load([folderNameStr, fileNameStr{i}], 'CellStatsCell');
    Experiment(i).nameStr = fileNameStr{i};
    Experiment(i).orientationCell = cellfun(@(x) ...
        abs([x(:).Orientation]), CellStatsCell, ...
        'UniformOutput', false);
    Experiment(i).noCellsRow = cellfun(@numel, CellStatsCell);
    tmpMajorAxisLengthCell = cellfun(@(x) ...
        [x(:).MajorAxisLength], CellStatsCell, ...
        'UniformOutput', false);
    tmpHorizProjCell = cellfun(@(x, y) x .* cos(y / 180 * pi), ...
        tmpMajorAxisLengthCell, Experiment(i).orientationCell, ...
        'UniformOutput', false);
    tmpMeanHorizProjRow = cellfun(@mean, tmpHorizProjCell);
    tmpSemHorizProjRow = cellfun(@std, tmpHorizProjCell) ./ ...
        sqrt(Experiment(i).noCellsRow);
    tmpNormSemHorizProjRow = tmpSemHorizProjRow ./ ...
        tmpMeanHorizProjRow;
    tmpNormMeanHorizProjRow = tmpMeanHorizProjRow / ...
        tmpMeanHorizProjRow(1) - 1;
    Experiment(i).meanPrctStrainRow = tmpNormMeanHorizProjRow;
    Experiment(i).semPrctStrainRow = tmpNormSemHorizProjRow;
end

catMeanStrainRow = [Experiment(:).meanPrctStrainRow];
catSemStrainRow = [Experiment(:).semPrctStrainRow];
[catClusterRow, catIdxClusterRow] = ...
    binbystrain(catMeanStrainRow, catSemStrainRow);

% Redistribute the indices into the individual experiments.
noStrainPtsRow = arrayfun(@(x) numel(x.meanPrctStrainRow), Experiment);
idxClusterCell = mat2cell(catIdxClusterRow, 1, noStrainPtsRow);
Experiment(noFiles).idxClusterRow = [];
Experiment(noFiles).clusterRow = [];
for i = 1 : noFiles
    Experiment(i).idxClusterRow = idxClusterCell{i};
    Experiment(i).clusterRow = unique(catClusterRow(idxClusterCell{i}), ...
        'stable');
end

% Regroup and histogram data based on binned strain.
binRow = linspace(0, 90, 7);
Experiment(noFiles).grpOrientationCell = [];
Experiment(noFiles).grpOrientationFreqCell = [];
Experiment(noFiles).grpNoCellsRow = [];
for i = 1 : noFiles
    tmpUniqueIdxRow = unique(Experiment(i).idxClusterRow);
    tmpNoUniqueStrainPts = numel(tmpUniqueIdxRow);
    Experiment(i).grpOrientationCell = cell(1, tmpNoUniqueStrainPts);
    Experiment(i).grpOrientationFreqCell = cell(1, tmpNoUniqueStrainPts);
    Experiment(i).grpNoCellsRow = zeros(1, tmpNoUniqueStrainPts);
    for j = 1 : tmpNoUniqueStrainPts
        Experiment(i).grpOrientationCell{j} = ...
            [Experiment(i).orientationCell{Experiment(i).idxClusterRow ...
            == tmpUniqueIdxRow(j)}];
        Experiment(i).grpNoCellsRow(j) = numel(...
            Experiment(i).grpOrientationCell{j});
        Experiment(i).grpOrientationFreqCell{j} = histc(...
            Experiment(i).grpOrientationCell{j}, binRow) / ...
            Experiment(i).grpNoCellsRow(j);
    end
end

% Combine experiments.
catGrpOrientationFreqCell = [Experiment(:).grpOrientationFreqCell];
catGrpStrainRow = [Experiment(:).clusterRow];
noStrainPts = numel(catClusterRow);
meanOrientationFreqMat = zeros(noStrainPts, numel(binRow));
semOrientationFreqMat = zeros(noStrainPts, numel(binRow));
binCountsRow = zeros(1, noStrainPts);
for i = 1 : noStrainPts
    tmpGrpOrientationFreqMat = ...
        vertcat(catGrpOrientationFreqCell{catGrpStrainRow == ...
        catClusterRow(i)});
    binCountsRow(i) = size(tmpGrpOrientationFreqMat, 1);
    meanOrientationFreqMat(i, :) = mean(tmpGrpOrientationFreqMat, 1);
    semOrientationFreqMat(i, :) = std(tmpGrpOrientationFreqMat, 0, 1) / ...
        sqrt(binCountsRow(i));
end

figure('color', 'w');
bar(meanOrientationFreqMat, 1, 'stacked');
set(gca, 'box', 'off', 'tickdir', 'out', 'linewidth', 1.5);
set(gca, 'ytick', 0 : 0.15 : 1);
ylim(gca, [0, 1]);
xlim(gca, [0.5, numel(catClusterRow) - 0.5]);
xlabel(gca, 'Percent strain');
idxTick = get(gca, 'xtick');
set(gca, 'xticklabel', arrayfun(@(x) num2str(100 * x, '%2.1f'), ...
  catClusterRow(idxTick), 'UniformOutput', false));
ylabel('Frequency');
colormap summer;
hold on;
for i = 1 : noStrainPts
    errorbar(i * ones(1, 7), cumsum(meanOrientationFreqMat(i, :)), ...
        semOrientationFreqMat(i, :), '.k');
end
hold off;
end


function [clusterRow, idxClusterRow] = ...
    binbystrain(meanPrctStrainRow, semPrctStrainRow)
% Estimate a reasonable precision for clustering data into means.
meanSem = mean(semPrctStrainRow);
beta = (3 / meanSem)^2;

% Perform mean-shift clustering.
clusteredRow = pwc_cluster(meanPrctStrainRow, [], 1, beta, 1, 0, eps)';
tolerance = 1e-5;
[sortClusteredRow, sortIdxRow] = sort(clusteredRow, 'ascend');
diffSortClusteredRow = diff(sortClusteredRow);
isDiffRow = diffSortClusteredRow >= tolerance;
idxDiffRow = cumsum([1, isDiffRow]);
[~, sortSortIdxRow] = sort(sortIdxRow);
idxClusterRow = idxDiffRow(sortSortIdxRow);
clusterRow = arrayfun(@(x) ...
    mean(clusteredRow(x == idxClusterRow)), unique(idxClusterRow));
end
