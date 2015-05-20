function focusedIm = findfocus(objWidth)

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
end