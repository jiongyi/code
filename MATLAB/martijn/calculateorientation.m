function [thetaRow, muAligned, stdAligned] = calculateorientation(cellMaskIm)
%% Extract object properties.
RegProp = regionprops(cellMaskIm, ...
    'Centroid', 'Orientation', 'MajorAxisLength');
% rRow = [RegProp(:).MajorAxisLength] / 2;
% xyCol = vertcat(RegProp(:).Centroid);
% xRow = xyCol(:, 1)';
% yRow = xyCol(:, 2)';
thetaRow = -[RegProp(:).Orientation] / 180 * pi;
%% Plot long-axis orientation.
% figure;
% imshow(cellMaskIm);
% hold on;
% quiver(xRow, yRow, rRow .* cos(thetaRow), rRow .* sin(thetaRow), ...
%     'b', 'LineWidth', 2);
% hold off;
%% Bootstrap percentage of cell's whose long-axis is orientated fewer than 45-degrees from the horizontal line.
noTrials = 1000;
noPoints = numel(thetaRow);
percentAlignedRow = zeros(1, noTrials);
for iTrial = 1 : noTrials
    percentAlignedRow(iTrial) = sum(...
        datasample(abs(thetaRow / pi * 180), noPoints) <= 15) / noPoints;
end
% figure, hist(percentAlignedRow);
muAligned = mean(percentAlignedRow);
stdAligned = std(percentAlignedRow);
