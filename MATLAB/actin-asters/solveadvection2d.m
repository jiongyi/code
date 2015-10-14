function solveadvection2d()
% Initialize variables.
cMat = poissrnd(10, 1000);  % Concentration field.

thetaMat = 2 * pi * rand(1000); % u-v velocity field.
uMat = cos(thetaMat);
uMat(:, 1) = 0;
uMat(:, end) = 0;
vMat = sin(thetaMat);
vMat(1, :) = 0;
vMat(end, :) = 0;

timeInterval = 0.05;    % Discretizing variables.
spaceInterval = 0.2;
alpha = timeInterval / 2 / spaceInterval;
noSteps = 500;

cFiltObj = zeros(3); % Filter matrices for the lax method.
cFiltObj([2, 4, 6, 8]) = 1;
horFiltObj = [-1, 0, 1];
verFiltObj = [-1; 0; 1];

% Iterate.
iMat = cMat;
for i = 1 : noSteps
    cMat = 0.25 * imfilter(cMat, cFiltObj, 'replicate') - ...
        alpha * (imfilter(uMat .* cMat, horFiltObj, 'replicate') + ...
        imfilter(vMat .* cMat, verFiltObj, 'replicate'));
end

% Plot results.
% figure('color', 'white');
% quiver(uMat, vMat, 'LineWidth', 2); axis equal off;
% title('Velocity field');

figure('color', 'white');
imshow(iMat, []); colormap jet; colorbar; axis equal off;
figure('color', 'white');
title('Initial concentration');

imshow(cMat, []); colormap jet; colorbar; axis equal off;
title('Final concentration');
disp(num2str(sum(iMat(:))));
disp(num2str(sum(cMat(:))));
disp(num2str(min(cMat(:))));
end