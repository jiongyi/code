function dynamicequations()
% Initialize constants.
meanConcentration = 100;
noPointsPerSide = 1000;
timeInterval = 0.05;
spaceInterval = 0.2;
speed = 1;
diffusionCoeff = 5;
k = 1;
xi = 80;
gamma = 100;
activeTemp = 40;
noSteps = 50;
lambda = 0.1;

% Initialize concentration field matrix.
cMat = poissrnd(meanConcentration, noPointsPerSide);
% cMat = padarray(cMat, [1, 1], 'replicate', 'both');

% Initialize orientation field matrix.
uMat = zeros(noPointsPerSide);
vMat = zeros(noPointsPerSide);
for i = 1 : numel(cMat)
    thetaRow = 2 * pi * rand(1, cMat(i));
    uMat(i) = mean(cos(thetaRow));
    vMat(i) = mean(sin(thetaRow));
end
uMat(:, 1) = 0; % Enforce boundary conditions: zero normal velocity.
uMat(:, end) = 0;
vMat(1, :) = 0;
vMat(end, :) = 0;

% Set up advection matrices for the Lax method.
beta = timeInterval / 2 / spaceInterval;
cFiltObj = zeros(3);
cFiltObj([2, 4, 6, 8]) = 1;
horFiltObj = [-1, 0, 1];
verFiltObj = [-1; 0; 1];

% Set up Crank-Nicolson stencil for diffusion.
alpha = diffusionCoeff * timeInterval / (spaceInterval)^2;
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
diffusionMat = zeros(noPointsPerSide);
for i = 1 : noSteps
    % Update relative sliding.
    uHorDiffMat = imfilter(uMat, horFiltObj, 'replicate') / ...
        2 / spaceInterval;
    uVerDiffMat = imfilter(uMat, verFiltObj, 'replicate') / ...
        2 / spaceInterval;
    vHorDiffMat = imfilter(vMat, horFiltObj, 'replicate') / ...
        2 / spaceInterval;
    vVerDiffMat = imfilter(vMat, verFiltObj, 'replicate') / ...
        2 / spaceInterval;
    uLambdaMat = -lambda * uMat .* uHorDiffMat - ...
        lambda * vMat .* uVerDiffMat;
    vLambdaMat = -lambda * uMat .* vHorDiffMat - ...
        lambda * vMat .* vVerDiffMat;
    
    % Update advection.
    advectionMat = 0.25 * imfilter(cMat, cFiltObj, 'replicate') - ...
        beta * (imfilter(speed * uMat .* cMat, horFiltObj, 'replicate') + ...
        imfilter(speed * vMat .* cMat, verFiltObj, 'replicate'));
    % Update diffusion.
    for j = 1 : noPointsPerSide
        % Rows.
        diffusionMat(j, :) = tridag(aCol, bCol, cCol, ...
            rhsMat * advectionMat(j, :)')';
    end
        % Columns.
    for k = 1 : noPointsPerSide
        diffusionMat(:, k) = tridag(aCol, bCol, cCol, ...
            rhsMat * diffusionMat(:, k));
    end
    % Update concentration matrix.
    cMat = diffusionMat;
    
    % Update orientation field.
    uMat = uMat + timeInterval * uLambdaMat;
    vMat = vMat + timeInterval * vLambdaMat;
    disp(num2str(sum(cMat(:))));
end

figure('color', 'white');
imshow(cMat, []); colormap jet; colorbar; axis equal off;

figure('color', 'white');
quiver(uMat, vMat, 'LineWidth', 2); axis equal off;