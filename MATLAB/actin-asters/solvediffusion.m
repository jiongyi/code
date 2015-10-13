function solvediffusion2d()

% Initialize variables.
spaceInterval = 0.2;
timeInterval = 0.05;
diffusionCoefficient = 5;
noSteps = 2000;
alpha = diffusionCoefficient * timeInterval / (spaceInterval)^2;
rCol = poissrnd(10, 1000, 1);

% Set up Crank-Nicolson stencil.
aCol = -1 * alpha * ones(1000, 1);
bCol = (1 + 2 * alpha) * ones(1000, 1);
cCol = aCol;

% Apply no-flux boundary conditions.
bCol([1, end]) = (1 + alpha);

% Loop.
uCol = rCol;
for i = 1 : noSteps
    uCol = tridag(aCol, bCol, cCol, uCol);
end

% Plot results.
figure('color', 'white');
plot(rCol, 'LineWidth', 2);
hold on;
plot(uCol, 'r', 'LineWidth', 2);
hold off;
set(gca, 'box', 'off', 'tickdir', 'out', 'LineWidth', 2, 'fontsize', 14);
ylabel('Concentration', 'fontsize', 14);
xlabel('x', 'fontsize', 14);
disp(num2str(sum(rCol)));
disp(num2str(sum(uCol)));
end