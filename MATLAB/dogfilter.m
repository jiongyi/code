function dogIm = dogfilter(rawIm, objWidth)
% Convert to double.
doubleIm = mat2gray(im2double(rawIm));
% Calculate sigma.
smallSigma = round(objWidth / (1 + sqrt(2)));
bigSigma = round(sqrt(2) * objWidth);

% Filter and subtract.
smallIm = imfilter(doubleIm, fspecial('gaussian', 3 * smallSigma, ...
    smallSigma), 'replicate');
bigIm = imfilter(doubleIm, fspecial('gaussian', 3 * bigSigma, ...
    bigSigma), 'replicate');
dogIm = mat2gray(smallIm - bigIm);