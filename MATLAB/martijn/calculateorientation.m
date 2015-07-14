function thetaRow = calculateorientation(cellMaskIm)
%% Extract object properties.
RegProp = regionprops(cellMaskIm, ...
    'Centroid', 'Orientation', 'MajorAxisLength');
rRow = [RegProp(:).MajorAxisLength] / 2;
xRow = [RegProp(:).Centroid(1)];
yRow = [RegProp(:).Centroid(2)];
thetaRow = -[RegProp(iElement).Orientation] / 180 * pi;
%% Plot long-axis orientation.
figure;
imshow(cellMaskIm);
hold on;
quiver(xRow, yRow, rRow .* cos(thetaRow), rRow .* sin(thetaRow), ...
    'b', 'LineWidth', 2);
hold off;

