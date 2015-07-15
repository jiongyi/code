function isCellIm = markerwatershed(rawIm, objWidth, isRegMaxIm)
% Normalize and flatten image.
flatIm = imflat(rawIm, objWidth, 10 * objWidth);
% Open-close median-filtered image.
openClosedIm = imopenclose(flatIm, 2);
% Watershed.
minImposedIm = imimposemin(openClosedIm, isRegMaxIm);
shedIm = watershed(minImposedIm);
% Binarize.
isCellIm = imclearborder(shedIm > 1);
end