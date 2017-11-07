function hessianIm = hessianfilter(rawIm, sigma)
% Check if image is class double.
if ~strcmp(class(rawIm), 'double')
    rawIm = im2double(rawIm);
end

% Compute hessian components.
[dxMat, dyMat] = gradient(rawIm);
[dxxMat, dxyMat] = gradient(dxMat);
[~, dyyMat] = gradient(dyMat);

% Apply gaussian filter.
gaussFilt = fspecial('gaussian', 6 * sigma + 1, sigma);
dxMat = imfilter(dxMat, gaussFilt, 'symmetric');
dyMat = imfilter(dyMat, gaussFilt, 'symmetric');
dxxMat = imfilter(dxxMat, gaussFilt, 'symmetric');
dxyMat = imfilter(dxyMat, gaussFilt, 'symmetric');
dyyMat = imfilter(dyyMat, gaussFilt, 'symmetric');


bMat = -dxxMat - dyyMat;
cMat = -dxyMat.^2 + dxxMat .* dyyMat;

lambdaOneMat = -bMat + sqrt(bMat.^2 - 4 * cMat);
lambdaTwoMat = -bMat - sqrt(bMat.^2 - 4 * cMat);
hessianIm = min(cat(3, lambdaOneMat, lambdaTwoMat), [], 3);