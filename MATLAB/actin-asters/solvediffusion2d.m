function solvediffusion2d()

% Initialize variables.
spaceInterval = 0.2;
timeInterval = 0.05;
diffusionCoefficient = 5;
noSteps = 100;
noPointsPerSide = 1000;
alpha = diffusionCoefficient * timeInterval / (spaceInterval)^2;
rMat = poissrnd(10, noPointsPerSide);

% Set up Crank-Nicolson stencil.
aCol = -0.5 * alpha * ones(1000, 1);
bCol = (1 + alpha) * ones(1000, 1);
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

% Loop.
uMat = rMat;
for i = 1 : noSteps
    for j = 1 : noPointsPerSide
        % Rows.
        uMat(j, :) = tridag(aCol, bCol, cCol, rhsMat * uMat(j, :)')';
    end
        % Columns.
    for k = 1 : noPointsPerSide
        uMat(:, k) = tridag(aCol, bCol, cCol, rhsMat * uMat(:, k));
    end
end

% Plot results.
figure('color', 'white');
imshow(rMat, []);
colormap jet;
colorbar;
title('Initial concentration field');

figure('color', 'white');
imshow(uMat, []);
colormap jet;
colorbar;
title('Final concentration field');
disp(num2str(sum(rMat(:))));
disp(num2str(sum(uMat(:))));
end