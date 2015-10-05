function simulateorientation(patchSize, spaceInterval)
% Initialize parameters.
noBoxesPerSide = ceil(patchSize / spaceInterval);
advectionRate = 1;
xi = 80;
kOne = 5;
alpha = 100;
beta = 100;

% Initialize filament concentration and orientation matrix.
% According to Onsager, c* = 5.3 x 10^20 chains/m^3
concMat = poissrnd(1, noBoxesPerSide);
lambda = xi * advectionRate;
horFilOrMat = zeros(noBoxesPerSide);
vertFilOrMat = zeros(noBoxesPerSide);
for iFil = 1 : noBoxesPerSide^2
    thetaRow = 2 * pi * rand(1, concMat(iFil));
    horFilOrMat(iFil) = sum(cos(thetaRow));
    vertFilOrMat(iFil) = sum(sin(thetaRow));
end
figure; quiver(horFilOrMat, vertFilOrMat, 0); axis equal off;
figure; imshow(sqrt(horFilOrMat.^2 + vertFilOrMat.^2), []); colormap jet; colorbar;

noSteps = 1;
timeInterval = 0.05; % Time interval is 0.125 s.
for i = 1 : noSteps
    % Pad and reflect orientation matrices.
    padHorFilOrMat = padarray(horFilOrMat, [2, 2], ...
        'symmetric', 'both');
    padVertFilOrMat = padarray(vertFilOrMat, [2, 2], ...
        'symmetric', 'both');
    padHorFilOrMat([1, 2], :) = -1 * padHorFilOrMat([1, 2], :);
    padHorFilOrMat([end, end - 1], :) = ...
        -1 * padHorFilOrMat([end, end - 1], :);
    padHorFilOrMat(:, [1, 2]) = -1 * padHorFilOrMat(:, [1, 2]);
    padHorFilOrMat(:, [end, end - 1]) = ...
        -1 * padHorFilOrMat(:, [end, end - 1]);
    padVertFilOrMat([1, 2], :) = -1 * padVertFilOrMat([1, 2], :);
    padVertFilOrMat([end, end - 1], :) = ...
        -1 * padVertFilOrMat([end, end - 1], :);
    padVertFilOrMat(:, [1, 2]) = -1 * padVertFilOrMat(:, [1, 2]);
    padVertFilOrMat(:, [end, end - 1]) = ...
        -1 * padVertFilOrMat(:, [end, end - 1]);
    
    % Compute first and second partial derivatives.
    [padHorFilOrDiffMat, ~] = gradient(padHorFilOrMat, spaceInterval);
    [~, padVertFilOrDiffMat] = gradient(padVertFilOrMat, spaceInterval);
    [padHorFilOrDiff2Mat, ~] = gradient(padHorFilOrDiffMat, spaceInterval);
    [~, padVertFilOrDiff2Mat] = gradient(padVertFilOrDiffMat, spaceInterval);
    
    % Update relative sliding.
    padHorRelSlideMat = -lambda * padHorFilOrMat .* padHorFilOrDiffMat;
    padVertRelSlideMat = -lambda * padVertFilOrMat .* padVertFilOrDiffMat;
    
    % Update relative alignment.
    padHorRelAlignMat = kOne * padHorFilOrDiff2Mat;
    padVertRelAlignMat = kOne * padVertFilOrDiff2Mat;
    
    % Update spontaneous polarization.
    padSqMagFilOrMat = padHorFilOrMat.^2 + padVertFilOrMat.^2;
    padHorSpontPolMat = alpha * padHorFilOrMat - ...
        beta * padSqMagFilOrMat .* padHorFilOrMat;
    padVertSpontPolMat = alpha * padVertFilOrMat - ...
        beta * padSqMagFilOrMat .* padVertFilOrMat;
    
    % Update orientation matrices.
    horFilOrMat = horFilOrMat + ...
        padHorRelSlideMat(3 : end - 2, 3 : end - 2) * timeInterval + ...
        padHorRelAlignMat(3 : end - 2, 3 : end - 2) * timeInterval + ...
        padHorSpontPolMat(3 : end - 2, 3 : end - 2) * timeInterval;
    vertFilOrMat = vertFilOrMat + ...
        padVertRelSlideMat(3 : end - 2, 3 : end - 2) * timeInterval + ...
        padVertRelAlignMat(3 : end - 2, 3 : end - 2) * timeInterval + ...
        padVertSpontPolMat(3 : end - 2, 3 : end - 2) * timeInterval;
    figure; quiver(horFilOrMat, vertFilOrMat, 0); axis equal off;
    figure; imshow(sqrt(horFilOrMat.^2 + vertFilOrMat.^2), []); colormap jet; colorbar;
end

