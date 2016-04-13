function [normMeanIntRow, overIm] = measurebinding(Actin, Abp)

% Binarize actin image.
Actin.normIm = mat2gray(Actin.rawIm);
Actin.eqIm = adapthisteq(Actin.normIm, 'distribution', 'exponential');
Actin.coIm = imcloseopen(Actin.eqIm, 2);
Actin.dogIm = dogfilter(Actin.coIm, 2, 6);
Actin.bwIm = im2bw(mat2gray(Actin.dogIm), ...
    graythresh(mat2gray(Actin.dogIm)));
Actin.bwIm = imclearborder(Actin.bwIm);

% Region properties.
Filaments = regionprops(Actin.bwIm, Abp.rawIm, 'PixelIdxList', ...
    'PixelValues', 'Image');
noFilaments = numel(Filaments);
for i = 1 : noFilaments
    Filaments(i).nmLongestPath = 160 * longestpath(Filaments(i).Image);
end

% Ignore elements that are shorter than 2 um.
isTooShortRow = [Filaments(:).nmLongestPath] <= 2000;
Filaments(isTooShortRow) = [];
Actin.bwIm = ismember(labelmatrix(bwconncomp(Actin.bwIm)), ...
    find(~isTooShortRow));

% Calculate binding.
meanBackInt = mean(Abp.rawIm(~Actin.bwIm));
noFilaments = numel(Filaments);
for i = 1 : noFilaments
    Filaments(i).normMeanInt = sum(Filaments(i).PixelValues) / meanBackInt / ...
        Filaments(i).nmLongestPath;
end

normMeanIntRow = [Filaments(:).normMeanInt];

% Make binarized.
overIm = imoverlay(Actin.normIm, bwperim(Actin.bwIm), [0, 1, 0]);
end

function pathLength = longestpath(im)
    thinIm = bwmorph(im, 'thin', inf);
    [yMat, xMat] = find(bwmorph(thinIm, 'endpoints'));
    dIm = bwdistgeodesic(thinIm, xMat(1), yMat(1), 'quasi-euclidean');
    dIm = round(dIm * 8) / 8;
    pathLength = max(dIm(:));
end