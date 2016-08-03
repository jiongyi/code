function measurecytoosnr()

% Get file names.
[fileNameStr, folderNameStr] = uigetfile('*.tiff', ...
    'Select time lapse file');

% Load file.
rawStack = imstack([folderNameStr, fileNameStr]);

% Binarize stack.
bwIm = binarizecytoo(rawStack);

% Calculate snr.
CytooStats = regionprops(bwIm, 'PixelIdxList');
noObjects = numel(CytooStats);
noFrames = size(rawStack, 3);
snrMat = zeros(noObjects, noFrames);
for iFrame = 1 : noFrames
    currFrame = rawStack(:, :, iFrame);
    currMeanBackgrnd = mean(currFrame(~bwIm));
    for iObj = 1 : noObjects
        snrMat(iObj, iFrame) = mean(currFrame(...
            CytooStats(iObj).PixelIdxList)) - currMeanBackgrnd;
    end
end
meanSnrRow = mean(snrMat, 1);
stdSnrRow = std(snrMat, 1);
upBndRow = meanSnrRow + stdSnrRow;
btBndRow = meanSnrRow - stdSnrRow;

% Plot.
% figure('color', 'white', 'PaperPositionMode', 'auto');
% axes('ActivePositionProperty', 'OuterPosition', 'box', 'off', ...
%     'tickdir', 'out', 'fontsize', 14, 'linewidth', 1.5);

xlabel('Time (min)');
ylabel('Average EGFP-vinculin intensity (AU)');

hold on;
plot(meanSnrRow, 'b', 'linewidth', 1.5);
hArea = area([1 : noFrames, noFrames : -1 : 1], ...
    [btBndRow, upBndRow(end : -1 : 1)]);
set(hArea, 'EdgeColor', 'none', 'FaceColor', 'b');
set(get(hArea, 'Children'), 'FaceAlpha', 0.3);
hold off;


end

function bwIm = binarizecytoo(rawStack)
meanRawIm = mean(rawStack, 3);
meanDogIm = dogfilter(meanRawIm, 7);
meanNormIm = mat2gray(meanDogIm);
bwIm = im2bw(meanNormIm, graythresh(meanNormIm));

end