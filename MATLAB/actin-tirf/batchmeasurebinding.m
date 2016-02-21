function batchNormMeanIntRow = batchmeasurebinding()

% Select actin channel images.
[fileNameStrCell, folderNameStr] = uigetfile('*C0.tiff', ...
    'Select actin images', 'MultiSelect', 'on');
if ~iscell(fileNameStrCell)
    fileNameStrCell = {fileNameStrCell};
end

% Load and process images.
noImages = numel(fileNameStrCell);
normMeanIntCell = cell(1, noImages);
for i = 1 : noImages
    TmpActin.rawIm = imread([folderNameStr, fileNameStrCell{i}]);
    tmpAbpFileNameStr = [fileNameStrCell{i}(1 : end - 11), '488_C1.tiff'];
    TmpAbp.rawIm = imread([folderNameStr, tmpAbpFileNameStr]);
    [normMeanIntCell{i}, tmpOverIm] = measurebinding(TmpActin, TmpAbp);
    imwrite(tmpOverIm, [folderNameStr, ...
        fileNameStrCell{i}(1 : end - 12), '_bw.tiff']);
end

% Plot measurements.
batchNormMeanIntRow = [normMeanIntCell{:}];
binRow = linspace(min(batchNormMeanIntRow), ...
    ceil(max(batchNormMeanIntRow)), 20);
countRow = hist(batchNormMeanIntRow, binRow);
figure('color', 'white');
bar(binRow, countRow, 'hist');
set(gca, 'box', 'off', 'tickdir', 'out', 'fontsize', 14);

end

function [normMeanIntRow, overIm] = measurebinding(Actin, Abp)

% Binarize actin image.
Actin.normIm = mat2gray(Actin.rawIm);
Actin.eqIm = adapthisteq(Actin.normIm);
Actin.ocIm = imopenclose(Actin.eqIm, 2);
Actin.dogIm = mat2gray(dogfilter(Actin.ocIm, 4));
Actin.bwIm = im2bw(Actin.dogIm, graythresh(Actin.dogIm));

% Segment actin filaments and compute properties.
Segment = regionprops(Actin.bwIm, Abp.rawIm, 'Area', 'MajorAxisLength', ...
    'Perimeter', 'PixelIdxList', 'MeanIntensity', 'PixelValues');

% Normalize to background.
noSegments = numel(Segment);
meanBackInt = mean(Abp.rawIm(~Actin.bwIm));
for i = 1 : noSegments
    Segment(i).normMeanInt = Segment(i).MeanIntensity / meanBackInt;
end

normMeanIntRow = [Segment(:).normMeanInt];

% Make binarized.
overIm = imoverlay(Actin.normIm, bwperim(Actin.bwIm), [0, 1, 0]);
end