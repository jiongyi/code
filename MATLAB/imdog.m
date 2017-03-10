function dogIm = imdog(rawIm, pxDiameter)

% Make gaussian filter objects.
sigma1 = 1 / (1 +  sqrt(2)) * pxDiameter;
sigma2 = sqrt(2) * sigma1;

gauss1Im = imgaussfilt(rawIm, sigma1);
gauss2Im = imgaussfilt(rawIm, sigma2);

dogIm = gauss1Im - gauss2Im;
dogIm = dogIm - min(dogIm(:));
end