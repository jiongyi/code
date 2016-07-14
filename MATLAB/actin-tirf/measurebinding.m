function [Filaments, overIm] = measurebinding(...
    Actin, Abp, flatIm)

% Binarize actin image.
Actin.normIm = mat2gray(Actin.rawIm);
Actin.coIm = imcloseopen(Actin.normIm, 2);
Actin.dogIm = dogfilter(Actin.coIm, 4);
Actin.bwIm = im2bw(mat2gray(Actin.dogIm), ...
    graythresh(mat2gray(Actin.dogIm)));

% Flatten abp image.
Abp.flatIm = im2double(Abp.rawIm) ./ flatIm;

% Region properties.
Filaments = regionprops(Actin.bwIm, Abp.flatIm, 'PixelIdxList', ...
    'PixelValues', 'Image');
noFilaments = numel(Filaments);
for i = 1 : noFilaments
    Filaments(i).nmLongestPath = 160 * longestpath(Filaments(i).Image);
end

% Ignore elements that are shorter than 2 um.
isTooShortRow = [Filaments(:).nmLongestPath] <= 1000;
Filaments(isTooShortRow) = [];
allBwIm = Actin.bwIm;
allOverIm = imoverlay(Actin.normIm, bwperim(allBwIm), [1, 0, 0]);
Actin.bwIm = ismember(labelmatrix(bwconncomp(Actin.bwIm)), ...
    find(~isTooShortRow));

% Calculate binding.
meanBackInt = median(Abp.flatIm(~allBwIm));
noFilaments = numel(Filaments);
for i = 1 : noFilaments
    % Calculate mean intensity normalized to mean background signal.
    Filaments(i).abpNormMeanInt = mean(Filaments(i).PixelValues) / ...
        meanBackInt;
    Filaments(i).abpStdNormMeanInt = std(bootstrp(1000, @mean, ...
        Filaments(i).PixelValues)) / meanBackInt;
end

% Make overlaid.
overIm = imoverlay(mat2gray(Abp.flatIm), bwperim(Actin.bwIm), [0, 1, 0]);
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