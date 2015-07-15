function flatIm = imflat(rawIm, objWidth, backWidth)
% Normalize intensities.
normIm = mat2gray(im2double(rawIm));
% Enhance contrast by adaptive histogram equalization.
eqIm = adapthisteq(normIm);
% Difference-of-gaussian filtering.
objIm = imfilter(eqIm, ...
    fspecial('gaussian', 3 * objWidth, objWidth), 'replicate');
backIm = imfilter(eqIm, ...
    fspecial('gaussian', 3 * backWidth, backWidth), 'replicate');
dogIm = mat2gray(objIm - backIm);
flatIm = medfilt2(dogIm);