function plotalignedfractions(thetaCell, threshold)
nFrames = numel(thetaCell);
nTrials = 1000;
thresholdFractionMat = zeros(nFrames, nTrials);
for iTrial = 1 : nTrials
    for iFrame = 1 : nFrames
        resampleRow = datasample(thetaCell{iFrame}, ...
            numel(thetaCell{iFrame}));
        thresholdFractionMat(iFrame, iTrial) = ...
            calculatefraction(resampleRow, threshold);
    end
end
meanThresholdFractionRow = mean(thresholdFractionMat, 2);
stdThresholdFractionRow = std(thresholdFractionMat');
figure('color', 'w');
errorbar(meanThresholdFractionRow, stdThresholdFractionRow, '.');
set(gca, 'tickdir', 'out', 'box', 'off');
xlabel('Frame');
ylabel('Fraction aligned');
end

function thresholdFraction = calculatefraction(rhoRow, threshold)
    thresholdFraction = sum(abs(rhoRow / pi * 180) ...
        <= threshold) / numel(rhoRow);
end