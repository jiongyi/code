function dynamicalequations(patchSize, spaceInterval)
% Initialize parameters.
noBoxesPerSide = ceil(patchSize / spaceInterval);
diffCoeff = 5;
kOne = 5;
kTwo = 0;
xi = 80;
alpha = 100;
beta = 100;
activeTemp = 20;
zeroVel = 1;

% Initialize filament concentration and orientation matrix.
concMat = poissrnd(1, noBoxesPerSide);
concMat = concMat(2 : end - 1, 2 :  end - 1);
    concMat = padarray(concMat, [1, 1], 'replicate', 'both');
filOrMat = 2 * pi * rand(noBoxesPerSide);
horizOrMat = cos(filOrMat);
vertOrMat = sin(filOrMat);

noSteps = 5;
timeInterval = 0.05; % Time interval is 0.125 s.

% Display initial state.
figure('color', 'white');
imshow(concMat, []);
colormap jet;
colorbar;
title('Initial concentration');
disp(sum(concMat(:)));

for i = 1 : noSteps
    % Update concentration.
    horizActAdvMat = zeroVel * concMat .* horizOrMat;
    vertActAdvMat = zeroVel * concMat .* vertOrMat;
    [horizConcGradMat, vertConcGradMat] = gradient(concMat, ...
        1 / spaceInterval);
    horizCurrMat = horizActAdvMat - diffCoeff * horizConcGradMat;
    vertCurrMat = vertActAdvMat - diffCoeff * vertConcGradMat;
    divCurrMat = divergence(horizCurrMat, vertCurrMat) * spaceInterval;
    concMat = concMat - divCurrMat * timeInterval;
    concMat = concMat(2 : end - 1, 2 :  end - 1);
    concMat = padarray(concMat, [1, 1], 'replicate', 'both');
    
    % Update relative sliding.
    [horizOrGradMat, ~] = gradient(padarray(horizOrMat, [1, 1], ...
        'replicate', 'both'), 1 / spaceInterval);
    horizOrGradMat = horizOrGradMat(2 : end - 1, 2 : end - 1);
    [~, vertOrGradMat] = gradient(padarray(vertOrMat, [1, 1], ...
        'replicate', 'both'), 1 / spaceInterval);
    vertOrGradMat = vertOrGradMat(2 : end - 1, 2 : end - 1);
    divOrMat = horizOrGradMat + vertOrGradMat;
    
    lambda = xi * zeroVel * mean(concMat(:));
    horizRelSlidMat = -lambda * horizOrMat .* horizOrGradMat .* horizOrMat;
    vertRelSlidMat = -lambda * vertOrMat .* vertOrGradMat .* vertOrMat;
    
    % Update relative alignment.
    [horizOrGrad2Mat, ~] = gradient(padarray(horizOrGradMat, [1, 1], ...
        'replicate', 'both'), 1 / spaceInterval);
    horizOrGrad2Mat = horizOrGrad2Mat(2 : end - 1, 2 : end - 1);
    [~, vertOrGrad2Mat] = gradient(padarray(vertOrGradMat, [1, 1], ...
        'replicate', 'both'), 1 / spaceInterval);
    vertOrGrad2Mat = vertOrGrad2Mat(2 : end - 1, 2 : end - 1);
    [horizGradDivOrMat, vertGradDivOrMat] = gradient(padarray(divOrMat, ...
        [1, 1], 'replicate', 'both'), 1 / spaceInterval);
    horizGradDivOrMat = horizGradDivOrMat(2 : end - 1, 2 : end - 1);
    vertGradDivOrMat = vertGradDivOrMat(2 : end - 1, 2 : end - 1);
    
    horizRelAlignMat = kOne * horizOrGrad2Mat + kTwo * horizGradDivOrMat;
    vertRelAlignMat = kOne * vertOrGrad2Mat + kTwo * vertGradDivOrMat;
    
    % Update contractity.
    horizContractMat = xi * horizConcGradMat;
    vertContractMat = xi * vertConcGradMat;
    
    % Update spontaneous polarization.
    magOrMat = sqrt(horizOrMat.^2 + vertOrMat.^2);
    horizSpontPolMat = alpha * horizOrMat - ...
        beta * magOrMat.^2 .* horizOrMat;
    vertSpontPolMat = alpha * vertOrMat - ...
        beta * magOrMat.^2 .* vertOrMat;
    
    % Update active noise.
    horizActNoiseMat = activeTemp ./ concMat * randn(noBoxesPerSide);
    vertActNoiseMat = activeTemp ./ concMat * randn(noBoxesPerSide);
    
    % Update orientation field.
%     diffHorizOrMat = horizRelSlidMat;
%     diffVertOrMat = vertRelSlidMat;
    diffHorizOrMat = horizRelAlignMat + horizContractMat;
    diffVertOrMat = vertRelAlignMat + vertContractMat;
%     diffHorizOrMat = horizRelSlidMat + horizRelAlignMat + ...
%         horizContractMat;
%     diffVertOrMat = vertRelSlidMat + vertRelAlignMat + ...
%         vertContractMat;
%     diffHorizOrMat = horizRelSlidMat + horizRelAlignMat + ...
%         horizContractMat + horizSpontPolMat;
%     diffVertOrMat = vertRelSlidMat + vertRelAlignMat + ...
%         vertContractMat + vertSpontPolMat;
%     diffHorizOrMat = horizRelSlidMat + horizRelAlignMat + ...
%         horizContractMat + horizSpontPolMat + horizActNoiseMat;
%     diffVertOrMat = vertRelSlidMat + vertRelAlignMat + ...
%         vertContractMat + vertSpontPolMat + vertActNoiseMat;
    
    horizOrMat = horizOrMat + diffHorizOrMat * timeInterval;
    vertOrMat = vertOrMat + diffVertOrMat * timeInterval;
end

% Display final state.
figure('color', 'white');
imshow(concMat, []);
% hold on;
% quiver(horizOrMat, vertOrMat, 0);
% hold off;
colormap jet;
colorbar;
title('Final concentration');
disp(sum(concMat(:)));

end