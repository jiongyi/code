function solveadvectiondiffusion2d()
% Set up simulation domain.
timeInterval = 0.05;    % Discretizing variables.
spaceInterval = 0.2;
noPointsPerSide = 100;

% Set up concentration field.
averageConcentration = 10;
cMat = poissrnd(averageConcentration, noPointsPerSide);

% Set up u-v velocity field.
beta = timeInterval / 2 / spaceInterval;
thetaMat = 2 * pi * rand(noPointsPerSide);
uMat = cos(thetaMat);
uMat(:, 1) = 0; % Enforce boundary conditions: zero normal velocity.
uMat(:, end) = 0;
vMat = sin(thetaMat);
vMat(1, :) = 0; % Enforce boundary conditions.
vMat(end, :) = 0;

% Set up advection matrices for the Lax method.
cFiltObj = zeros(3);
cFiltObj([2, 4, 6, 8]) = 1;
horFiltObj = [-1, 0, 1];
verFiltObj = [-1; 0; 1];

% Set up Crank-Nicolson stencil for diffusion.
diffusionCoefficient = 5;
alpha = diffusionCoefficient * timeInterval / (spaceInterval)^2;
aCol = -0.5 * alpha * ones(noPointsPerSide, 1);
bCol = (1 + alpha) * ones(noPointsPerSide, 1);
cCol = aCol;

% Apply no-flux boundary conditions.
bCol([1, end]) = (1 + 0.5 * alpha);

% Construct RHS matrix.
rhsMat = zeros(noPointsPerSide);
for i = 1 : noPointsPerSide
    rhsMat(i, i) = 1 - alpha;
end
for i = 1 : (noPointsPerSide - 1)
    rhsMat(i, i + 1) = 0.5 * alpha;
    rhsMat(i + 1, i) = 0.5 * alpha;
end
rhsMat(1, 1) = 1 - 0.5 * alpha;
rhsMat(noPointsPerSide, noPointsPerSide) = 1 - 0.5 * alpha;

% Iterate.
noSteps = 1000;
diffusionMat = zeros(noPointsPerSide);
iMat = cMat;
for i = 1 : noSteps
    % Update advection.
    advectionMat = 0.25 * imfilter(cMat, cFiltObj, 'replicate') - ...
        beta * (imfilter(uMat .* cMat, horFiltObj, 'replicate') + ...
        imfilter(vMat .* cMat, verFiltObj, 'replicate'));
    % Update diffusion.
    for j = 1 : noPointsPerSide
        % Rows.
        diffusionMat(j, :) = tridag(aCol, bCol, cCol, rhsMat * advectionMat(j, :)')';
    end
        % Columns.
    for k = 1 : noPointsPerSide
        diffusionMat(:, k) = tridag(aCol, bCol, cCol, rhsMat * diffusionMat(:, k));
    end
    % Update concentration matrix.
    cMat = diffusionMat;
end
% Plot.
figure('color', 'white');
imshow(iMat, []); colormap jet; colorbar; axis equal off;
title('Initial concentration field');

figure('color', 'white');
imshow(cMat, []); colormap jet; colorbar; axis equal off;
title('Final concentration field');

disp(num2str(sum(iMat(:))));
disp(num2str(sum(cMat(:))));
disp(num2str(min(cMat(:))));
end