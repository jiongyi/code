function Binding = ...
    batchmeasurebinding()

% Select actin channel images.
[fileNameStrCell, folderNameStr] = uigetfile('*C0.tiff', ...
    'Select actin images', 'MultiSelect', 'on');
if ~iscell(fileNameStrCell)
    fileNameStrCell = {fileNameStrCell};
end

% Load and process images.
noImages = numel(fileNameStrCell);
FrameCell = cell(1, noImages);
for i = 1 : noImages
    TmpActin.rawIm = imread([folderNameStr, fileNameStrCell{i}]);
    tmpAbpFileNameStr = [fileNameStrCell{i}(1 : end - 12), 't488_C1.tiff'];
    TmpAbp.rawIm = imread([folderNameStr, tmpAbpFileNameStr]);
    [FrameCell{i}, tmpOverIm]  = measurebinding(TmpActin, TmpAbp, 'tophat');
    imwrite(tmpOverIm, [folderNameStr, ...
        fileNameStrCell{i}(1 : end - 13), '_bw.tiff']);
end

% Calculate distribution parameters.
abpNormMeanIntCell = cellfun(@(x) [x(:).abpNormMeanInt], FrameCell, ...
    'UniformOutput', false);
Binding.normMeanIntRow = [abpNormMeanIntCell{:}];
Binding.meanNormMeanInt = mean(Binding.normMeanIntRow);
Binding.stdNormMeanInt = mean(bootstrp(1000, @std, ...63
    Binding.normMeanIntRow));

nmLongestPathCell = cellfun(@(x) [x(:).nmLongestPath], FrameCell, ...
    'UniformOutput', false);
nmLongestPathRow = [nmLongestPathCell{:}];
Binding.totalPathLength = sum(nmLongestPathRow);

% Create field for concentration.
Binding.nMConcentration = [];

end