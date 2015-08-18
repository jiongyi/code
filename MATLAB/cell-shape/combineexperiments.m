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
end

function binbystrain(meanPrctStrainRow, semPrctStrainRow)
end
