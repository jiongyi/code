function isRegMaxIm = maskregionalmax(nucleusIm, objWidth)
%% Normalize and clean up.
normIm = mat2gray(im2double(nucleusIm));
eqIm = adapthisteq(normIm);
[m, n] = size(nucleusIm);
backIm = imfilter(eqIm, fspecial('average', ...
    round(0.10 * min(m, n))), 'replicate');
flatIm = mat2gray(eqIm - backIm);
medIm = medfilt2(flatIm);
%% Open-close median-filtered image.
erodedIm = imerode(medIm, strel('disk', objWidth));
openedIm = imreconstruct(erodedIm, medIm);
dilatedIm = imdilate(openedIm, strel('disk', objWidth));
closedIm = imcomplement(imreconstruct(imcomplement(dilatedIm), ...
    imcomplement(openedIm)));
closedIm = mat2gray(closedIm);
isRegMaxIm = imopen(imregionalmax(closedIm), strel('sq', 3));
end