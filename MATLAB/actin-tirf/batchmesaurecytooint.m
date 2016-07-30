function meanInt = batchmeasurecytooint()

% Get files.
[fileNameStrCell, folderNameStr] = uigetfile('*C0.tiff', 'Select images', ...
    'MultiSelect', 'on');
if ~iscell(fileNameStrCell)
    fileNameStrCell = {fileNameStrCell};
end

meanIntCell = cellfun(@(x) binarizecytoo(folderNameStr, x), ...
    fileNameStrCell, 'UniformOutput', false);
meanInt = [meanIntCell{:}];


end

function meanIntRow = binarizecytoo(folderNameStr, fileNameStr)

rawIm = imread([folderNameStr, fileNameStr]);
dogIm = dogfilter(rawIm, 7);
normIm = mat2gray(dogIm);
bwIm = im2bw(normIm, graythresh(normIm));
Stats = regionprops(bwIm, rawIm, 'MeanIntensity');
meanIntRow = [Stats(:).MeanIntensity] - mean(rawIm(~bwIm));


end

