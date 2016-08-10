function [Filaments, overIm] = measurebinding(Actin, Abp)

% Binarize actin image.
Actin.normIm = mat2gray(Actin.rawIm);
Actin.coIm = imcloseopen(Actin.normIm, 2);
Actin.dogIm = dogfilter(Actin.coIm, 4);
Actin.bwIm = im2bw(mat2gray(Actin.dogIm), ...
    graythresh(mat2gray(Actin.dogIm)));

% Region properties.
Filaments = regionprops(Actin.bwIm, Abp.rawIm, 'PixelIdxList', ...
    'PixelValues', 'Image');
noFilaments = numel(Filaments);

% Calculate path length.
for i = 1 : noFilaments
    Filaments(i).nmLongestPath = 160 * longestpath(Filaments(i).Image);
end

% Ignore elements that are shorter than 1 um.
isTooShortRow = [Filaments(:).nmLongestPath] <= 1000;
Filaments(isTooShortRow) = [];
allBwIm = Actin.bwIm;
Actin.bwIm = ismember(labelmatrix(bwconncomp(Actin.bwIm)), ...
    find(~isTooShortRow));

% Calculate binding.
meanBackInt = mean(Abp.rawIm(~allBwIm));
noFilaments = numel(Filaments);
for i = 1 : noFilaments
    % Calculate mean intensity normalized to mean background signal.
    Filaments(i).abpNormMeanInt = mean(Filaments(i).PixelValues) - ...
        meanBackInt;
    if Filaments(i).abpNormMeanInt < 0
        Filaments(i).abpNormMeanInt = 0;
    end
    Filaments(i).abpStdNormMeanInt = std(Filaments(i).abpNormMeanInt);
end

% Make image overlay.
overIm = imoverlay(mat2gray(Abp.rawIm), bwperim(Actin.bwIm), [0, 1, 0]);
end

function pathLength = longestpath(im)
    thinIm = bwmorph(im, 'thin', inf);
    [yMat, xMat] = find(bwmorph(thinIm, 'endpoints'));
    if isempty(yMat) || isempty(xMat)
        pathLength = 0;
    else
        dIm = bwdistgeodesic(thinIm, xMat(1), yMat(1), 'quasi-euclidean');
        dIm = round(dIm * 8) / 8;
        pathLength = max(dIm(:));
    end
end