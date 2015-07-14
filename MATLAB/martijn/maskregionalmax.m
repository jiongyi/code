function isRegMaxIm = maskregionalmax(nucleusIm)
%% Initialize variables.
% objwidth is supposed to be on the order of magnitude of subnuclear
% features.
objWidth = 5;
%% Normalize and clean up.
normIm = mat2gray(im2double(nucleusIm));
eqIm = adapthisteq(normIm);
psfIm = imfilter(eqIm, fspecial('gaussian', 9 * objWidth, 3 * objWidth), 'replicate');
backIm = imfilter(eqIm, fspecial('gaussian', 750, 250), 'replicate');
flatIm = mat2gray(psfIm - backIm);
% flatIm = eqIm ./ imfilter(eqIm, fspecial('average', 500), ...
%     'replicate');
medIm = medfilt2(flatIm);
%% Open-close median-filtered image.
erodedIm = imerode(medIm, strel('disk', objWidth));
openedIm = imreconstruct(erodedIm, medIm);
dilatedIm = imdilate(openedIm, strel('disk', 3 * objWidth));
closedIm = imcomplement(imreconstruct(imcomplement(dilatedIm), ...
    imcomplement(openedIm)));
closedIm = mat2gray(closedIm);
isRegMaxIm = imregionalmax(closedIm);
figure, imshowpair(flatIm, isRegMaxIm);
end