function relativealignment()
% Generate orientation vector field.
spaceInterval = 0.2;
noPointsPerSide = 20;
thetaMat = 2 * pi * rand(noPointsPerSide);
uMat = cos(thetaMat);
uMat(:, 1) = 0; % Enforce boundary conditions: zero normal velocity.
uMat(:, end) = 0;
vMat = sin(thetaMat);
vMat(1, :) = 0; % Enforce boundary conditions.
vMat(end, :) = 0;

% Plot initial vector field.
figure('color', 'white');
quiver(uMat, vMat, 0, 'LineWidth', 2); axis equal off;

% Generate alignment field.
horDiff2FiltObj = [1, -2, 1];
verDiff2FiltObj = [1; -2; 1];
k = 1;
uKMat = k * imfilter(uMat, horDiff2FiltObj, 'replicate') / ...
    (spaceInterval^2);
vKMat = k * imfilter(vMat, verDiff2FiltObj, 'replicate') / ...
    (spaceInterval^2);

figure('color', 'white');
quiver(uKMat, vKMat, 'LineWidth', 2, 'Color', 'red'); axis equal off;
end