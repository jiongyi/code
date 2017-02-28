function dogIm = imdog(rawIm, pxDiameter)

% Make gaussian filter objects.
sigma1 = 1 / (1 +  sqrt(2)) * pxDiameter;
sigma2 = sqrt(2) * sigma1;
gauss1Filt = fspecial('gaussian', 6 * round(sigma1) + 1, sigma1);
gauss2Filt = fspecial('gaussian', 6 * round(sigma2) + 1, sigma2);

grayIm = im2double(rawIm);

gauss1Im = imfilter(grayIm, gauss1Filt, 'replicate');
gauss2Im = imfilter(grayIm, gauss2Filt, 'replicate');

dogIm = gauss1Im - gauss2Im;
dogIm = dogIm - min(dogIm(:));
end