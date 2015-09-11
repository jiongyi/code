function Experiment = combineexperiments(axisOptStr)

% Check input arguments.
if ~exist('axisOptStr', 'var')
    error('Please specify which axis to use for strain analysis. Exiting.');
elseif ~strcmp(axisOptStr, 'uni-axial') && ~strcmp(axisOptStr, 'bi-axial')
    error('Please specify a valid strain axis option (uni-axial or bi-axial)');
end

% Get the names of the analyses files containing the regionprops
% structures.
[fileNameStr, folderNameStr] = uigetfile('*.mat', ...
    'Select .mat files storing results', 'MultiSelect', 'on');
% Check if fileNameStr needs to be converted into a cell array.
if ~iscell(fileNameStr)
    fileNameStr = {fileNameStr};
end

% Initialize structure array fields.
noFiles = numel(fileNameStr);
Experiment(noFiles).orientationCell = [];
Experiment(noFiles).meanPrctStrainRow = [];
Experiment(noFiles).semPrctStrainRow = [];
Experiment(noFiles).noCellsRow = [];
Experiment(noFiles).nameStr = [];

% Fill out fields using values from the result files.
for i = 1 : noFiles
    % Load result file.
    load([folderNameStr, fileNameStr{i}], 'CellStatsCell');
    Experiment(i).nameStr = fileNameStr{i};
    % Store the absolute values of orientation measurements in cell arrays.
    Experiment(i).orientationCell = cellfun(@(x) ...
        abs([x(:).Orientation]), CellStatsCell, ...
        'UniformOutput', false);
    % Figure the number of cells in each frame.
    Experiment(i).noCellsRow = cellfun(@numel, CellStatsCell);
    % Store the major-axis length measurements in temporary cell arrays.
    tmpMajorAxisLengthCell = cellfun(@(x) ...
        [x(:).MajorAxisLength], CellStatsCell, ...
        'UniformOutput', false);
    if strcmp(axisOptStr, 'uni-axial')
        tmpStrainDimCell = cellfun(@(x, y) x .* cos(y / 180 * pi), ...
            tmpMajorAxisLengthCell, Experiment(i).orientationCell, ...
            'UniformOutput', false);
    elseif strmcp(axisOptStr, 'bi-axial')
        tmpStrainDimCell = tmpMajorAxisLengthCell;
    end
    
    % Calculate the average strain dimension in each frame.
    tmpMeanStrainDimRow = cellfun(@mean, tmpStrainDimCell);
    % Calculate the standard error of the mean strain dimesion in each
    % frame.
    tmpSemStrainDimRow = cellfun(@std, tmpStrainDimCell) ./ ...
        sqrt(Experiment(i).noCellsRow);
    % Normalize to mean unstrained dimension.
    tmpNormSemStrainDimRow = tmpSemStrainDimRow ./ ...
        tmpMeanStrainDimRow;
    tmpNormMeanStrainDimRow = tmpMeanStrainDimRow / ...
        tmpMeanStrainDimRow(1) - 1;
    % Store the final calculates in the structure array fields.
    Experiment(i).normMeanStrainRow = tmpNormMeanStrainDimRow;
    Experiment(i).normSemStrainRow = tmpNormSemStrainDimRow;
end

% Bin all mean strain calculations.
allMeanStrainRow = [Experiment(:).normMeanStrainRow];
allSemStrainRow = [Experiment(:).normSemStrainRow];
[strainModeRow, idx2ModeRow] = ...
    binstrain(allMeanStrainRow, allSemStrainRow);

% Redistribute the indices into the individual experiments.
noStrainPtsRow = arrayfun(@(x) numel(x.normMeanStrainRow), Experiment);
idx2ModeCell = mat2cell(idx2ModeRow, 1, noStrainPtsRow);
Experiment(noFiles).idx2ModeRow = [];
Experiment(noFiles).strainModeRow = [];
for i = 1 : noFiles
    Experiment(i).idx2ModeRow = idx2ModeCell{i};
    Experiment(i).strainModeRow = unique(strainModeRow(idx2ModeCell{i}), ...
        'stable');
end

% Regroup and histogram data based on binned strain.
binRow = linspace(0, 90, 7);
Experiment(noFiles).grpOrientationCell = [];
Experiment(noFiles).grpOrientationFreqCell = [];
Experiment(noFiles).grpNoCellsRow = [];
for i = 1 : noFiles
    tmpUniqueIdxRow = unique(Experiment(i).idx2ModeRow);
    tmpNoUniqueStrainPts = numel(tmpUniqueIdxRow);
    Experiment(i).grpOrientationCell = cell(1, tmpNoUniqueStrainPts);
    Experiment(i).grpOrientationFreqCell = cell(1, tmpNoUniqueStrainPts);
    Experiment(i).grpNoCellsRow = zeros(1, tmpNoUniqueStrainPts);
    for j = 1 : tmpNoUniqueStrainPts
        % Group all orientation measurements that come from frames that
        % have the same strain mode.
        Experiment(i).grpOrientationCell{j} = ...
            [Experiment(i).orientationCell{Experiment(i).idx2ModeRow ...
            == tmpUniqueIdxRow(j)}];
        Experiment(i).grpNoCellsRow(j) = numel(...
            Experiment(i).grpOrientationCell{j});
        Experiment(i).grpOrientationFreqCell{j} = histc(...
            Experiment(i).grpOrientationCell{j}, binRow) / ...
            Experiment(i).grpNoCellsRow(j);
    end
end

% Combine experiments.
allGrpOrientationFreqCell = [Experiment(:).grpOrientationFreqCell];
allGrpStrainRow = [Experiment(:).strainModeRow];
noStrainPts = numel(strainModeRow);
meanOrientationFreqMat = zeros(noStrainPts, numel(binRow));
semOrientationFreqMat = zeros(noStrainPts, numel(binRow));
binCountsRow = zeros(1, noStrainPts);
for i = 1 : noStrainPts
    tmpGrpOrientationFreqMat = ...
        vertcat(allGrpOrientationFreqCell{allGrpStrainRow == ...
        strainModeRow(i)});
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
xlim(gca, [0.5, numel(strainModeRow) - 0.5]);
xlabel(gca, 'Strain');
idxTick = get(gca, 'xtick');
set(gca, 'xticklabel', arrayfun(@(x) num2str(100 * x, '%2.1f'), ...
  strainModeRow(idxTick), 'UniformOutput', false));
ylabel('Frequency');
colormap summer;
hold on;
for i = 1 : noStrainPts
    errorbar(i * ones(1, 7), cumsum(meanOrientationFreqMat(i, :)), ...
        semOrientationFreqMat(i, :), '.k');
end
hold off;
end


function [strainModeRow, idx2ModeRow] = binstrain(strainRow, semStrainRow)
% Estimate a reasonable precision for clustering data into means.
meanSem = mean(semStrainRow);
beta = (3 / meanSem)^2;

% Perform mean-shift clustering.
clusteredRow = pwc_cluster(strainRow, [], 1, beta, 1, 0, eps)';
tolerance = 1e-5;
[sortClusteredRow, sortIdxRow] = sort(clusteredRow, 'ascend');
diffSortClusteredRow = diff(sortClusteredRow);
isDiffRow = diffSortClusteredRow >= tolerance;
idxDiffRow = cumsum([1, isDiffRow]);
[~, sortSortIdxRow] = sort(sortIdxRow);
idx2ModeRow = idxDiffRow(sortSortIdxRow);
strainModeRow = arrayfun(@(x) ...
    mean(clusteredRow(x == idx2ModeRow)), unique(idx2ModeRow));
end