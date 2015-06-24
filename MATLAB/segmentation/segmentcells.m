function shedIm = segmentcells(rawIm, objWidth)
%% Normalize and flatten image.
normIm = mat2gray(im2double(rawIm));
eqIm = adapthisteq(normIm);
psfIm = imfilter(eqIm, fspecial('gaussian', 3 * objWidth, objWidth), ...
    'replicate');
backIm = imfilter(eqIm, ...
    fspecial('gaussian', 30 * objWidth, 10 * objWidth), 'replicate');
dogIm = mat2gray(psfIm - backIm);
medIm = medfilt2(dogIm, [objWidth, objWidth]);
%% Open-close median-filtered image.
erodedIm = imerode(medIm, strel('disk', 3 * objWidth));
openedIm = imreconstruct(erodedIm, medIm);
dilatedIm = imdilate(openedIm, strel('disk', 3 * objWidth));
closedIm = imcomplement(imreconstruct(imcomplement(dilatedIm), ...
    imcomplement(openedIm)));
%% Watershed.
regMinIm = imregionalmin(closedIm);
imposedIm = imimposemin(closedIm, regMinIm);
shedIm = watershed(imposedIm);
imposedIm = imimposemin(closedIm, regMinIm | ~logical(shedIm));
shedIm = watershed(imposedIm);
rgbIm = label2rgb(shedIm, 'jet', 'w', 'shuffle');
figure; imshowpair(normIm, rgbIm, 'montage');
% figure, imshowpair(closedIm, regMinIm, 'montage');
% figure; imshowpair(normIm, medIm, 'montage');
% figure; imshowpair(normIm, closedIm, 'montage');
end