function thetaRow = calculateorientation(isCellIm)
%% Extract object properties.
RegProp = regionprops(isCellIm, ...
    'Centroid', 'Orientation', 'MajorAxisLength');
thetaRow = -[RegProp(:).Orientation] / 180 * pi;
% Plot long-axis orientation.
% rRow = [RegProp(:).MajorAxisLength] / 2;
% xyCol = vertcat(RegProp(:).Centroid);
% xRow = xyCol(:, 1)';
% yRow = xyCol(:, 2)';
% figure;
% imshow(isCellIm);
% hold on;
% quiver(xRow, yRow, rRow .* cos(thetaRow), rRow .* sin(thetaRow), ...
%     'b', 'LineWidth', 2);
% hold off;