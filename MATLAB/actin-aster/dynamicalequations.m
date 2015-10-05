function dynamicalequations(patchSize, spaceInterval, noSteps)
% Initialize parameters.
noBoxesPerSide = ceil(patchSize / spaceInterval);
diffCoeff = 5;
advectionRate = 1;
xi = 80;
kOne = 5;
alpha = 100;

% Initialize filament concentration and orientation matrix.
% According to Onsager, c* = 5.3 x 10^20 chains/m^3
concMat = poissrnd(10, noBoxesPerSide);
lambda = xi * advectionRate * mean(concMat(:));
horFilOrMat = zeros(noBoxesPerSide);
vertFilOrMat = zeros(noBoxesPerSide);
for iFil = 1 : noBoxesPerSide^2
    thetaRow = 2 * pi * rand(1, concMat(iFil));
    horFilOrMat(iFil) = sum(cos(thetaRow));
    vertFilOrMat(iFil) = sum(sin(thetaRow));
end

initConcMat = concMat;
timeInterval = 0.05; % Time interval is 0.125 s.
for i = 1 : noSteps
    % Pad concentration matrix.
    padConcMat = padarray(concMat, [2, 2], 'symmetric', 'both');
    
    % Compute first and second partial derivatives of concentration matrix.
    [padHorConcGradMat, padVertConcGradMat] = gradient(padConcMat, ...
        1 / spaceInterval);
    [padHorConcGrad2Mat, ~] = gradient(padHorConcGradMat, ...
        1 / spaceInterval);
    [~, padVertConcGrad2Mat] = gradient(padVertConcGradMat, ...
        1 / spaceInterval);
    
    % Update diffusion.
    padDivDiffusionMat = diffCoeff * (padHorConcGrad2Mat + ...
        padVertConcGrad2Mat);
    
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
    [padHorFilOrDiffMat, ~] = gradient(padHorFilOrMat, ...
        1 / spaceInterval);
    [~, padVertFilOrDiffMat] = gradient(padVertFilOrMat, ...
        1 / spaceInterval);
    [padHorFilOrDiff2Mat, ~] = gradient(padHorFilOrDiffMat, ...
        1 / spaceInterval);
    [~, padVertFilOrDiff2Mat] = gradient(padVertFilOrDiffMat, ...
        1 / spaceInterval);
    
    % Update active advection.
    padHorAdvectionVelMat = advectionRate * padConcMat .* padHorFilOrMat;
    padVertAdvectionVelMat = advectionRate * padConcMat .* padVertFilOrMat;
    [padHorAdvectionVelGradMat, ~] = gradient(padHorAdvectionVelMat, ...
        1 / spaceInterval);
    [~, padVertAdvectionVelGradMat] = gradient(padVertAdvectionVelMat, ...
        1 / spaceInterval);
    padDivAdvectionVelMat = padHorAdvectionVelGradMat + ...
        padVertAdvectionVelGradMat;
    
    % Update concentration matrix.
    concMat = concMat + ...
        padDivDiffusionMat(3 : end - 2, 3 : end - 2) * timeInterval; % - ...
%         padDivAdvectionVelMat(3 : end - 2, 3 : end - 2) * timeInterval;
    
    % Update relative sliding.
    padHorRelSlideMat = -lambda * padHorFilOrMat .* padHorFilOrDiffMat;
    padVertRelSlideMat = -lambda * padVertFilOrMat .* padVertFilOrDiffMat;
    
    % Update relative alignment.
    padHorRelAlignMat = kOne * padHorFilOrDiff2Mat;
    padVertRelAlignMat = kOne * padVertFilOrDiff2Mat;
    
    % Update spontaneous polarization.
    padSqMagFilOrMat = padHorFilOrMat.^2 + padVertFilOrMat.^2;
    padHorSpontPolMat = alpha * (1 - padSqMagFilOrMat) .* padHorFilOrMat;
    padVertSpontPolMat = alpha * (1 - padSqMagFilOrMat) .* padVertFilOrMat;
    
    % Update orientation matrices.
    horFilOrMat = horFilOrMat + ...
        padHorRelSlideMat(3 : end - 2, 3 : end - 2) * timeInterval + ...
        padHorRelAlignMat(3 : end - 2, 3 : end - 2) * timeInterval + ...
        padHorSpontPolMat(3 : end - 2, 3 : end - 2) * timeInterval + ...
        xi * padHorConcGradMat(3 : end - 2, 3 : end - 2) * timeInterval;
    vertFilOrMat = vertFilOrMat + ...
        padVertRelSlideMat(3 : end - 2, 3 : end - 2) * timeInterval + ...
        padVertRelAlignMat(3 : end - 2, 3 : end - 2) * timeInterval + ...
        padVertSpontPolMat(3 : end - 2, 3 : end - 2) * timeInterval + ...
        xi * padVertConcGradMat(3 : end - 2, 3 : end - 2) * timeInterval;
end
figure; imshow([initConcMat, concMat], []); colormap jet; colorbar;