function contractility()
% Generate orientation vector field.
spaceInterval = 0.2;
noPointsPerSide = 20;
thetaMat = 2 * pi * rand(noPointsPerSide);
uMat = cos(thetaMat);
uMat(:, [1, 2]) = 0; % Enforce boundary conditions: zero normal velocity.
uMat(:, [end, end - 1]) = 0;
vMat = sin(thetaMat);
vMat([1, 2], :) = 0; % Enforce boundary conditions.
vMat([end, end - 1], :) = 0;

% Set up concentration field.
averageConcentration = 10;
cMat = poissrnd(averageConcentration, noPointsPerSide - 2);
cMat = padarray(cMat, [1, 1], 'replicate', 'both');

% Plot initial vector field.
figure('color', 'white');
quiver(uMat, vMat, 0, 'LineWidth', 2); axis equal off;

% Generate contractility field.
xi = 80;
horDiffFiltObj = [-1, 0, 1];
verDiffFiltObj = [-1; 0; 1];
noSteps = 100;
timeInterval = 0.05;
for i = 1 : noSteps
uXiMat = xi * imfilter(cMat, horDiffFiltObj, 'replicate') / ...
    2 / spaceInterval;
vXiMat = xi * imfilter(cMat, verDiffFiltObj, 'replicate') / ...
    2 / spaceInterval;
uMat = uMat + uXiMat * timeInterval;
vMat = vMat + vXiMat * timeInterval;
end
figure('color', 'white');
quiver(uXiMat, vXiMat, 'LineWidth', 2, 'Color', 'red'); axis equal off;
end