function TimeLapse = ...
    timevsmeanint()

% Select actin channel time-lapse.
[fileNameStr, folderNameStr] = uigetfile('*C0.tiff', ...
    'Select actin images', 'MultiSelect', 'off');

% Load images.
actinStack = imstack([folderNameStr, fileNameStr]);
abpStack = imstack([folderNameStr, fileNameStr(1 : end - 11), ...
    't488_C1.tiff']);
noImages = size(actinStack, 3);
TimeLapse.meanIntRow = zeros(1, noImages);
TimeLapse.stdIntRow = zeros(1, noImages);
for i = 1 : noImages
    TmpActin.rawIm = actinStack(:, :, i);
    TmpAbp.rawIm = abpStack(:, :, i);
    [TmpFilaments, tmpOverIm] = measurebinding(TmpActin, TmpAbp, 'tophat');
    TimeLapse.meanIntRow(i) = mean([TmpFilaments(:).abpNormMeanInt]);
    TimeLapse.stdIntRow(i) = std([TmpFilaments(:).abpNormMeanInt]);
    imwrite(tmpOverIm, [folderNameStr, fileNameStr(1 : end - 11), ...
        'bw_overlay.tiff'], 'writemode', 'append');
end
end