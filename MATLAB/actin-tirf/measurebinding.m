function [Filaments, overIm] = measurebinding(Actin, Abp, flatChoiceStr)

% Binarize actin image.
Actin.normIm = mat2gray(Actin.rawIm);
Actin.coIm = imcloseopen(Actin.normIm, 2);
Actin.dogIm = dogfilter(Actin.coIm, 6);
Actin.bwIm = im2bw(mat2gray(Actin.dogIm), ...
    graythresh(mat2gray(Actin.dogIm)));

% Denoise Abp image.
Abp.denoisedIm = medfilt2(wiener2(double(Abp.rawIm)));

% Region properties.
if strcmp(flatChoiceStr, 'cidre')
    Filaments = regionprops(Actin.bwIm, Abp.denoisedIm, 'PixelIdxList', ...
        'PixelValues', 'Image');
elseif strcmp(flatChoiceStr, 'tophat')
    Abp.tophatIm = imtophat(Abp.denoisedIm, strel('ball', 5, 5));
    Filaments = regionprops(Actin.bwIm, Abp.tophatIm, 'PixelIdxList', ...
        'PixelValues', 'Image');
end
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
if strcmp(flatChoiceStr, 'cidre')
    meanBackInt = mean(Abp.denoisedIm(~allBwIm));
elseif strcmp(flatChoiceStr, 'tophat')
    meanBackInt = mean(Abp.tophatIm(~allBwIm));
end
noFilaments = numel(Filaments);
for i = 1 : noFilaments
    % Calculate mean intensity normalized to mean background signal.
   Filaments(i).abpNormMeanInt = mean(Filaments(i).PixelValues) - ...
        meanBackInt;
    Filaments(i).abpStdNormMeanInt = std(Filaments(i).abpNormMeanInt);
end

% Make image overlay.
if strcmp(flatChoiceStr, 'cidre')
    overIm = imoverlay(mat2gray(Abp.denoisedIm), bwperim(Actin.bwIm), [0, 1, 0]);
elseif strcmp(flatChoiceStr, 'tophat')
    overIm = imoverlay(mat2gray(Abp.tophatIm), bwperim(Actin.bwIm), [0, 1, 0]);
end

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