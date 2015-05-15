function [focusedIm, maskIm] = findfocus(objWidth)

% Pick z-stack.
[fileNameStr, folderNameStr] = uigetfile('*.TIF', ...
    'Choose z-stack', '/home/jiongyi/Documents/MATLAB/fret/');

% Load z-stack.
infoStruct = imfinfo([folderNameStr, fileNameStr]);
noImages = numel(infoStruct);
stackMat = zeros(infoStruct(1).Height, infoStruct(1).Width, noImages);
meanAbsGradRow = zeros(1, noImages);
for k = 1 : noImages
    stackMat(:, :, k) = imread([folderNameStr, fileNameStr], k, 'Info', ...
        infoStruct);
    meanAbsGradRow(k) = mean(mean(abs(gradient(imfilter(stackMat(:, :, k), ...
        fspecial('gaussian', objWidth * 3, objWidth), 'replicate')))));
end

idxFocused = find(meanAbsGradRow == max(meanAbsGradRow));
focusedIm = stackMat(:, :, idxFocused(1));
figure;
imshow(focusedIm, []);
maskIm = logmask(focusedIm, objWidth);
end

function maskIm = logmask(rawIm, objWidth)
rawIm = medfilt2(rawIm);
rawIm = im2double(rawIm);
normIm = mat2gray(rawIm);
logFiltIm = imfilter(normIm, fspecial('log', objWidth * 3, objWidth), ...
    'replicate');
logFiltIm = imcomplement(mat2gray(logFiltIm));

backFiltIm = imfilter(logFiltIm, ...
    fspecial('gaussian', objWidth * 30, objWidth * 10), 'replicate');
logFiltIm = logFiltIm - backFiltIm;
logFiltIm(logFiltIm < 0) = 0;
logFiltIm = mat2gray(logFiltIm);
maskIm = im2bw(logFiltIm, graythresh(logFiltIm));
maskIm = imclose(maskIm, strel('sq', 3));
end