function dynamicalequations(patchSize, spaceInterval)
% Initialize parameters.
diffCoeff = 1e-1; % in squared microns per second.
noBoxesPerSide = round(patchSize / spaceInterval);
[concMat, filOrMat] = initfilaments(noBoxesPerSide);
noSteps = 5000;
timeInterval = 0.125; % Time interval is 0.125 s.

% Display initial state.
figure('color', 'white');
imshow(concMat, []);
colormap jet;
colorbar;
title('Initial concentration');
disp(sum(concMat(:)));

for i = 1 : noSteps
    % Update concentration.
    xDiffConcMat = diff(padarray(concMat, [0, 1], ...
        'replicate', 'both'), 2, 2);
    yDiffConcMat = diff(padarray(concMat, [1, 0], ...
        'replicate', 'both'), 2, 1);
    diffConcMat = xDiffConcMat + yDiffConcMat;
    concMat = concMat + diffCoeff * diffConcMat * timeInterval;
end

figure('color', 'white');
imshow(concMat, []);
colormap jet;
colorbar;
title('Final concentration');
disp(sum(concMat(:)));

end

function [cMat, nMat] = initfilaments(noBoxesPerSide)
noFilaments = noBoxesPerSide^2;

cMat = zeros(noBoxesPerSide);
nMat = zeros(noBoxesPerSide) + zeros(noBoxesPerSide) * 1j;
for i = 1 : noFilaments
    mRand = randi([1, noBoxesPerSide], 1);
    nRand = randi([1, noBoxesPerSide], 1);
    randTheta = 2 * pi * rand(1);
    cMat(mRand, nRand) = cMat(mRand, nRand) + 1;
    nMat(mRand, nRand) = nMat(mRand, nRand) + ...
        cos(randTheta) + sin(randTheta) * 1j;
end
end