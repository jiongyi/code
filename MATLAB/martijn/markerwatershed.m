function cellMaskIm = markerwatershed(rawIm, objWidth, isRegMaxIm)
%% Normalize and flatten image.
normIm = mat2gray(im2double(rawIm));
eqIm = adapthisteq(normIm);
[m, n] = size(rawIm);
backIm = imfilter(eqIm, fspecial('average', round(0.10 * min(m, n))), 'replicate');
dogIm = mat2gray(eqIm - backIm);
medIm = medfilt2(dogIm);
%% Open-close median-filtered image.
erodedIm = imerode(medIm, strel('disk', objWidth));
openedIm = imreconstruct(erodedIm, medIm);
dilatedIm = imdilate(openedIm, strel('disk', objWidth));
closedIm = imcomplement(imreconstruct(imcomplement(dilatedIm), ...
    imcomplement(openedIm)));
%% Watershed.
imposedIm = imimposemin(closedIm, isRegMaxIm);
shedIm = watershed(imposedIm);
% imposedIm = imimposemin(closedIm, isRegMaxIm | ~logical(shedIm));
% shedIm = watershed(imposedIm);
cellMaskIm = imclearborder(shedIm > 1);
% overlaidIm = imoverlay(closedIm, bwperim(cellMaskIm), [0, 1, 0]);
% overlaidIm = imoverlay(overlaidIm, isRegMaxIm, [0, 0, 1]);
% figure, imshow(overlaidIm);
end
