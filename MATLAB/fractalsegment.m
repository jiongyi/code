function [dIm, AMat] = fractalsegment(rawIm, objWidth)
rawIm = im2double(rawIm);
oldTopIm = rawIm;
oldBotIm = rawIm;
noBlankets  = 100;
[m, n] = size(rawIm);
AMat = zeros([m, n, noBlankets]);

% Calculate area matrices
for i = 1 : noBlankets
    newTopIm = max(oldTopIm + 1, ...
        imdilate(oldTopIm, strel('sq', 3)));
    newBotIm = min(oldBotIm - 1, ...
        imerode(oldBotIm, strel('sq', 3)));
    AMat(:, :, i) = colfilt(newTopIm - newBotIm, ...
        [objWidth, objWidth], 'sliding', @sum) / 2 / i;
    oldTopIm = newTopIm;
    oldBotIm = newBotIm;
end

ACell = mat2cell(AMat, ...
    ones(1, size(AMat, 1)), ones(1, size(AMat, 2)), size(AMat, 3));
ACell = cellfun(@squeeze, ACell, 'UniformOutput', false);
logACell = cellfun(@log, ACell, 'UniformOutput', false);
x = log(1 : noBlankets)';
dIm = zeros(m, n);
parfor i = 1 : numel(logACell)
    fitCoeffRow = polyfit(x, logACell{i}, 1);
    dIm(i) = 2 - fitCoeffRow(1);
end
