function relativesliding()
% Generate orientation vector field.
spaceInterval = 0.2;
noPointsPerSide = 10;
thetaMat = 2 * pi * rand(noPointsPerSide);
uMat = cos(thetaMat);
uMat(:, [1, 2]) = 0; % Enforce boundary conditions: zero normal velocity.
uMat(:, [end, end - 1]) = 0;
vMat = sin(thetaMat);
vMat([1, 2], :) = 0; % Enforce boundary conditions.
vMat([end, end - 1], :) = 0;

% Plot initial vector field.
figure('color', 'white');
quiver(uMat, vMat, 0, 'LineWidth', 2); axis equal off;

% Generate sliding field.
horDiffFiltObj = [-1, 0, 1];
verDiffFiltObj = [-1; 0; 1];
uHorDiffMat = imfilter(uMat, horDiffFiltObj, 'replicate') / ...
    2 / spaceInterval;
uVerDiffMat = imfilter(uMat, verDiffFiltObj, 'replicate') / ...
    2 / spaceInterval;
vHorDiffMat = imfilter(vMat, horDiffFiltObj, 'replicate') / ...
    2 / spaceInterval;
vVerDiffMat = imfilter(vMat, verDiffFiltObj, 'replicate') / ...
    2 / spaceInterval;

lambda = 1;
uLambdaMat = -lambda * uMat .* uHorDiffMat - lambda * vMat .* uVerDiffMat;
vLambdaMat = -lambda * uMat .* vHorDiffMat - lambda * vMat .* vVerDiffMat;

figure('color', 'white');
quiver(uLambdaMat, vLambdaMat, 0, 'LineWidth', 2, 'Color', 'red'); axis equal off;
end