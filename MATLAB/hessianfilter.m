function [ridgeIm, isLinePointMat] = hessianfilter(rawIm)
% Check if image is class double.
if ~strcmp(class(rawIm), 'double')
    rawIm = im2double(rawIm);
end

% Compute hessian components.
[dxMat, dyMat] = gradient(rawIm);
[dxxMat, dxyMat] = gradient(dxMat);
[dyxMat, dyyMat] = gradient(dyMat);

% Solve for smallest eigenvalue.
noPixels = numel(rawIm);
eigenMat = zeros(size(rawIm));
ridgeIm = zeros(size(rawIm));
tMat = zeros(size(rawIm));
pxMat = zeros(size(rawIm));
pyMat = zeros(size(rawIm));
isLinePointMat = false(size(rawIm));
nxMat = zeros(size(rawIm));
nyMat = zeros(size(rawIm));
for iPixel = 1 : noPixels
    [tmpEigenVecMat, tmpEigenValMat] = eig(...
        [dxxMat(iPixel), dxyMat(iPixel); dyxMat(iPixel), dyyMat(iPixel)]);
    tmpEigenValCol = diag(tmpEigenValMat);
    [eigenMat(iPixel), idxMinEigenVal] = min(tmpEigenValCol);
    nx = tmpEigenVecMat(1, idxMinEigenVal);
    ny = tmpEigenVecMat(2, idxMinEigenVal);
    nxMat(iPixel) = nx;
    nyMat(iPixel) = ny;
    tMat(iPixel) = -(dxMat(iPixel) * nx + dyMat(iPixel) * ny) / ...
        (dxxMat(iPixel) * nx^2 + 2 * dxyMat(iPixel) * nx * ny + ...
        dyyMat(iPixel) * ny^2);
    pxMat(iPixel) = tMat(iPixel) * nx;
    pyMat(iPixel) = tMat(iPixel) * ny;
    if (abs(pxMat(iPixel)) <= 0.5) && (abs(pyMat(iPixel)) <= 0.5)
        isLinePointMat(iPixel) = true;
    end
    if eigenMat(iPixel) >= 0
        ridgeIm(iPixel) = 0;
    elseif eigenMat(iPixel) < 0
        ridgeIm(iPixel) = -eigenMat(iPixel);
    end
end
figure;
quiver(pxMat, pyMat);
end