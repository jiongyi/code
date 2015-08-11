function dogIm = dogfilter(rawIm, objWidth)
% Applies difference-of-gaussian filtering to rawIm. Kernel size is
% determined from objWidth. The output is scaled to [0, 1].
if ~strcmp(class(rawIm), 'double')
    error('Convert image to class double first.');
end

% Calculate sigmas.
sigma1 = objWidth / (1 + sqrt(2));
sigma2 = sqrt(2) * objWidth;

% Filter and subtract.
smallIm = imfilter(rawIm, fspecial('gaussian', ...
    ceil(6 * sigma1 + 1), sigma1), 'replicate');
bigIm = imfilter(rawIm, fspecial('gaussian', ...
    ceil(6 * sigma2 + 1), sigma2), 'replicate');
dogIm = smallIm - bigIm;
minValue = min(dogIm(:));
if minValue < 0
    dogIm = dogIm - minValue;
end