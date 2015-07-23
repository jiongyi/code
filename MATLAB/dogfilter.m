function dogIm = dogfilter(rawIm, objWidth)
doubleIm = im2double(rawIm);
% Calculate sigmas.
sigma1 = objWidth / (1 + sqrt(2));
sigma2 = sqrt(2) * objWidth;
% Filter and subtract.
smallIm = imfilter(doubleIm, fspecial('gaussian', ...
    ceil(6 * sigma1 + 1), sigma1), 'replicate');
bigIm = imfilter(doubleIm, fspecial('gaussian', ...
    ceil(6 * sigma2 + 1), sigma2), 'replicate');
dogIm = mat2gray(smallIm - bigIm);