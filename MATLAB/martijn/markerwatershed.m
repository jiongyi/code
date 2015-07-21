function [isCellIm, fusedIm] = markerwatershed(rawIm, objWidth, isRegMaxIm)
% Normalize and flatten image.
eqIm = adapthisteq(mat2gray(im2double(rawIm)));
dogIm = dogfilter(eqIm, objWidth);
% Open-close median-filtered image.
openClosedIm = imopenclose(dogIm, objWidth);
% Watershed.
minImposedIm = imimposemin(openClosedIm, isRegMaxIm);
shedIm = watershed(minImposedIm);
% Binarize.
isCellIm = imclearborder(shedIm > 1);
cellOutlineIm = cat(3, zeros(size(isCellIm)), bwperim(isCellIm), ...
    zeros(size(isCellIm)));
fusedIm = imfuse(openClosedIm, cellOutlineIm, 'blend');
end