function [cMat, uMat, vMat] = dynamicequations()
%% Initialize constants.
% Onsager prediction for 2d is p = 3 * pi / 2 / (L^2), where L is filament
% length. For L = 250 nm, p ~ 7.5 * 10^13 m^-2, so for dr = 2, p ~ 0.2
cHat = 101;
N = 100;
dt = 0.05 * 3e-2;
% dt = 1.25e-4;
dr = 0.2;
vZero = 1;
D = 5;
K = 5;
xi = 10;
gamma = 100;
Ta = 20;
noSteps = 1000;
lambda = xi * vZero * cHat;

%% Initialize concentration and orientation field matrix.
cMat = poissrnd(cHat, N);
uMat = zeros(N);
vMat = zeros(N);
for i = 1 : numel(cMat)
    thetaRow = 2 * pi * rand(1, cMat(i));
    uMat(i) = mean(cos(thetaRow));
    vMat(i) = mean(sin(thetaRow));
end
% Flow normal to boundaries is zero.
uMat(:, [1, end]) = 0;
vMat([1, end], :) = 0;
% Save initial orientation fields.
uZeroMat = uMat;
vZeroMat = vMat;
sumZeroMat = uZeroMat + vZeroMat;

% Set up advection matrices for the Lax method.
beta = vZero * dt / (2 * dr);
cFiltObj = zeros(3);
cFiltObj([2, 4, 6, 8]) = 1;
xDiffFiltObj = [-1, 0, 1];
yDiffFiltObj = [-1; 0; 1];

% Set up Crank-Nicolson stencil for diffusion.
alpha = D * dt / (dr^2);
aCol = -alpha * ones(N, 1);
bCol = (1 + 2 * alpha) * ones(N, 1);
cCol = aCol;
cHalfMat = zeros(N);

% Apply no-flux boundary conditions.
bCol([1, end]) = (1 + alpha);

% Set up alignment matrix stencil.
kappa = K * dt / (dr)^2;
k1Col = -kappa * ones(N - 2, 1);
k2Col = (1 + 2 * kappa) * ones(N - 2, 1);
k3Col = -kappa * ones(N - 2, 1);

%% Iterate.
meanDivergenceRow = zeros(1, noSteps);
for s = 1 : noSteps
    uOldMat = uMat;
    vOldMat = vMat;
    relativesliding();
    relativealignment();
    contractility();
    polarization();
    disp(num2str(mean(sqrt(uMat(:).^2 + vMat(:).^2))));
    activeforce();
    activeadvection();
    diffusion();
    divMat = divergence(uMat, vMat) / dr;
    meanDivergenceRow(s) = mean(divMat(:));
end

%% Plot results.
figure('color', 'white');
imshow(cMat, []); colormap jet; colorbar;
hold on;
quiver(uMat, vMat, 0, 'LineWidth', 2, 'color', 'black'); axis equal off;
hold off;
title(['T = ', num2str(dt * noSteps), ' s']);

figure('color', 'white');
plot(0 : dt : (noSteps - 1) * dt, meanDivergenceRow, 'LineWidth', 2);
set(gca, 'box', 'off', 'tickdir', 'out', 'fontsize', 14);
xlabel('Time (s)', 'fontsize', 14);
ylabel('Mean divergence', 'fontsize', 14);

%% Subfunctions
    function activeadvection()
        cMat = 0.25 * imfilter(cMat, cFiltObj, 'replicate') - beta * (...
            uOldMat .* imfilter(cMat, [-1, 0, 1], 'replicate') + ...
            cMat .* imfilter(uOldMat, [-1, 0, 1], 'replicate') + ...
            vOldMat .* imfilter(cMat, [-1; 0; 1], 'replicate') + ...
            cMat .* imfilter(vOldMat, [-1; 0; 1], 'replicate'));
    end
    function diffusion()
        for j = 1 : N
            cHalfMat(j, :) = tridag(aCol, bCol, cCol, cMat(j, :)')';
        end
        for k = 1 : N
            cMat(:, k) = tridag(aCol, bCol, cCol, cHalfMat(:, k));
        end
    end
    function relativesliding()
        uCurrMat = uMat;
        vCurrMat = vMat;
        uMat = (-lambda * dt * uZeroMat .* vCurrMat + ...
            (1 + lambda * dt * vZeroMat) .* uCurrMat) ./ ...
            (1 + lambda * dt * sumZeroMat);
        vMat = (-lambda * dt * vZeroMat .* uCurrMat + ...
            (1 + lambda * dt * uZeroMat) .* vCurrMat) ./ ...
            (1 + lambda * dt * sumZeroMat);
    end
    function relativealignment()
    for m = 1 : N
        uMat(m, 2 : end - 1) = tridag(k1Col, k2Col, k3Col, ...
            uMat(m, 2 : end - 1)')';
        vMat(2 : end - 1, m) = tridag(k1Col, k2Col, k3Col, ...
            vMat(2 : end - 1, m));
    end
    end
    function contractility()
        uMat = uMat + ...
            xi * dt / (2 * dr) * imfilter(cMat, xDiffFiltObj, 'replicate');
        uMat(:, [1, end]) = 0;
        vMat = vMat + ...
            xi * dt / (2 * dr) * imfilter(cMat, yDiffFiltObj, 'replicate');
        vMat([1, end], :) = 0;
    end
    function polarization()
        magMat = uMat.^2 + vMat.^2;
        uMat = uMat + dt * gamma * (1 - magMat) .* uMat;
        vMat = vMat + dt * gamma * (1 - magMat) .* vMat;
    end
    function activeforce()
    uMat = uMat + dt * Ta ./ cMat .* randn(N);
    uMat(:, [1, end]) = 0;
    vMat = vMat + dt * Ta ./ cMat .* randn(N);
    vMat([1, end], :) = 0;
    end
end
