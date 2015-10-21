function ftcsdiffusion()
%% Initialize variables.
cMat = poissrnd(10, 100);
D = 5;
dt = 1.25e-4;
ds = 0.2;
alpha = D * dt / (ds^2);
%% Iterate.
if dt <= ds^2 / (4 * D)
    for i = 1 : 100
        cMat = cMat + alpha * (imfilter(cMat, [1, -2, 1], 'replicate') + ...
            imfilter(cMat, [1; -2; 1], 'replicate'));
        disp(num2str(sum(cMat(:))));
    end
else
    error('Stability condition not met');
end
%% Plot solution.
figure('color', 'white');
imshow(cMat, []); colormap jet; colorbar; axis equal off;
end