function meanIntRow = batchmeasurecytooint()

% Get files.
[fileNameStrCell, folderNameStr] = uigetfile('*C0.tiff', 'Select images', ...
    'MultiSelect', 'on');
if ~iscell(fileNameStrCell)
    fileNameStrCell = {fileNameStrCell};
end

meanIntCell = cellfun(@(x) binarizecytoo(folderNameStr, x), ...
    fileNameStrCell, 'UniformOutput', false);
meanIntRow = [meanIntCell{:}];


end

function meanIntRow = binarizecytoo(folderNameStr, fileNameStr)

rawIm = imread([folderNameStr, fileNameStr]);
tophatIm = imtophat(rawIm, strel('ball', 14, 14));
dogIm = dogfilter(im2double(rawIm), 7);
normIm = mat2gray(dogIm);
bwIm = im2bw(normIm, graythresh(normIm));
Stats = regionprops(bwIm, tophatIm, 'MeanIntensity');
meanIntRow = [Stats(:).MeanIntensity] - mean(tophatIm(~bwIm));
imwrite(tophatIm, [folderNameStr, fileNameStr(1 :  end - 5), '_tophat.tiff']);
end

