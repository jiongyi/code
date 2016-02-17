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
    tmpAbpFileNameStr = [fileNameStrCell{i}(1 : end - 7), 'C1.tiff'];
    TmpAbp.rawIm = imread([folderNameStr, tmpAbpFileNameStr]);
    normMeanIntCell{i} = measurebinding(TmpActin, TmpAbp);
end

% Plot measurements.
batchNormMeanIntRow = [normMeanIntCell{:}];
end

function normMeanIntRow = measurebinding(Actin, Abp)

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
end