function isCellIm = contactwatershed(rawIm, objWidth, backWidth, noiseWidth)
% Normalize.
normIm = mat2gray(im2double(rawIm));
% Enhance contrast.
eqIm = adapthisteq(normIm, 'NumTiles', [32, 32]);
% Subtract background.
flatIm = mat2gray(eqIm - imfilter(eqIm, ...
    fspecial('disk', backWidth), 'replicate'));
blurrIm = imfilter(flatIm, ...
    fspecial('gaussian', 3 * objWidth, objWidth), 'replicate');

erodeSE = strel('square', noiseWidth);
% Open by reconstruction.
erodedIm = imerode(blurrIm, erodeSE);
openedIm = imreconstruct(erodedIm, blurrIm);

dilateSE = strel('square', noiseWidth);
% Close by reconstruction.
dilatedIm = imdilate(openedIm, dilateSE);
ocIm = imcomplement(imreconstruct(imcomplement(dilatedIm), ...
    imcomplement(openedIm)));
isRegMinIm = imregionalmin(ocIm);
isRegMinIm = imclose(isRegMinIm, strel('square', 3));
isRegMinIm = imerode(isRegMinIm, strel('square', 3));
% Impose minima.
minIm = imimposemin(ocIm, isRegMinIm);
% Watershed.
shedIm = watershed(minIm);
isCellIm = shedIm > 1;
isCellIm = imclearborder(isCellIm);
figure, imshow(cat(3, 0.8 * bwperim(~isCellIm), zeros(size(normIm)), flatIm));