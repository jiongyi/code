function measurebinding()
% Select actin channel image.
[fileNameStr, folderNameStr] = uigetfile('*C0.tiff', 'Select actin image');

% Load actin image.
Actin.rawIm = imread([folderNameStr, fileNameStr]);

% Load actin binding protein image.
abpFileNameStr = [fileNameStr(1 : end - 7), 'C1.tiff'];
Abp.rawIm = imread([folderNameStr, abpFileNameStr]);

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

figure('color', 'white');
subplot(121);
imshowpair(mat2gray(Abp.rawIm), bwperim(Actin.bwIm));
axis off;

subplot(122);
hist([Segment(:).normMeanInt]);
set(gca, 'box', 'off', 'tickdir', 'out');
xlabel('Average ABP intensity');
ylabel('Counts');
end