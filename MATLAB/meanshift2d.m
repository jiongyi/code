function meanShiftIm = meanshift2d(rawIm, kernelWidth, ...
    tolerance, maxNoIterations)
% Make sure kernel width is odd.
if mod(kernelWidth, 2) == 0 || kernelWidth < 3
    error('Kernel width must be odd (>= 3).');
end

% Initialize variables.
gaussFiltObj = fspecial('gaussian', kernelWidth, ...
    kernelWidth / 6);
currentIm = rawIm;
nextIm = imfilter(currentIm, gaussFiltObj, 'replicate');
gap =  mean(abs(nextIm(:) - currentIm(:)));

if ~exist('maxNoIterations', 'var')
    maxNoIterations = 1000;
    disp('Setting maximum number of iterations to 1000');
end
iterationNo = 1;

if ~exist('tolerance', 'var')
    tolerance = 1e-4;
    disp('Setting tolerance to 1e-4');
end

% Execute loop.
while (gap >= tolerance) && (iterationNo <= maxNoIterations)
    iterationNo = iterationNo + 1;
    currentIm = nextIm;
    nextIm = imfilter(currentIm, gaussFiltObj, 'replicate');
    gap = mean(abs(nextIm(:) - currentIm(:)));
end

if (iterationNo == maxNoIterations)
    disp('Maximum number of iterations has been reached.');
end
meanShiftIm = currentIm;

figure('color', 'white');
imshow(currentIm, []);
colormap summer;
colorbar;