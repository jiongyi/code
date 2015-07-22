function dogIm = dogfilter(rawIm, sigma1, sigma2)
doubleIm = im2double(rawIm);
% Filter and subtract.
smallIm = imfilter(doubleIm, fspecial('gaussian', 6 * sigma1, ...
    sigma1), 'replicate');
bigIm = imfilter(doubleIm, fspecial('gaussian', 6 * sigma2, ...
    sigma2), 'replicate');
dogIm = mat2gray(smallIm - bigIm);