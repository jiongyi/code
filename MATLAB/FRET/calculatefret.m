function calculatefret(filePathStr)

    fretStackStruct = loadimages(filePathStr);
    % Split stack to images.
    donorIm = fretStackStruct.donorIm;
    fretIm = fretStackStruct.fretIm;
    acceptorIm = fretStackStruct.acceptorIm;
    isPlaqueIm = maskplaques(acceptorIm, 10);
    
    % Subtract background.
    [donorIm, bwIm] = dogfilter(donorIm);
    fretIm = dogfilter(fretIm);
    acceptorIm = dogfilter(acceptorIm);
    
    % Correct for bleed-through and cross-talk.
%     a = 0.47;
%     b = 0.18;
    a = 0.5;
    b = 0.2;
    corrIm = fretIm - a * donorIm - b * acceptorIm;
    
    % Suppress non-sense pixel intensity values.
    corrIm(corrIm < 0) = 0;
    
    % Calculate FRET index.
    normIm = corrIm + donorIm; % like in Borghi et al PNAS 2012.
    idxFretIm = corrIm ./ normIm;
    idxFretIm(isnan(idxFretIm)) = 0;
    idxFretIm(idxFretIm == inf) = 0;
%     idxFretIm = imfilter(idxFretIm, fspecial('gaussian', 7, 2), ...
%         'symmetric');
    idxFretIm(~bwIm) = 0;
%     % Display results.
    noLevels = 11;
    thresholdRow = multithresh(idxFretIm, noLevels - 1);
    labeledIm = imquantize(idxFretIm, thresholdRow);
    meanIdxFretRow = arrayfun(@(x) mean(idxFretIm(labeledIm == x)), ...
        1 : noLevels);
    meanIdxFretIm = zeros(size(acceptorIm));
    [~, idxRow] = sort(meanIdxFretRow, 'ascend');
    for i = 1 : noLevels
        meanIdxFretIm(labeledIm == i) = meanIdxFretRow(i);
    end
    for i = 1 : noLevels
        labeledIm(labeledIm == i) = idxRow(i);
    end
    colorMap = jet(noLevels);
    colorMap(1, :) = [1, 1, 1];
    figure('color', 'white');
    labelCell = arrayfun(@(x) num2str(x, 2), (meanIdxFretRow(idxRow)), ...
        'UniformOutput', false);
    imshow(labeledIm, colorMap); colorbar(...
        'Ytick', 1 : noLevels, 'YTickLabel', labelCell); axis square off;
    title(fretStackStruct.nameStr);
    print(gcf, '-dpng', '-r600', [fretStackStruct.folderNameStr, ...
        fretStackStruct.nameStr, '_fret_ratio']);
    
% Find plaques and display distribution of mean FRET indices.
    isPlaqueIm = isPlaqueIm & bwIm;
    plaqueStruct = regionprops(isPlaqueIm, idxFretIm, 'MeanIntensity', ...
        'Area', 'PixelValues');
    plaqueFretRow = [plaqueStruct(:).MeanIntensity];
    median(plaqueFretRow)
    meanRadius = round(sqrt(mean([plaqueStruct(:).Area])));
    meanFretIdxIm = imfilter(idxFretIm, ...
        fspecial('average', meanRadius), 'symmetric');
    backMeanFretIdxRow = meanFretIdxIm(~isPlaqueIm & bwIm);
    median(backMeanFretIdxRow)
    noPlaques = numel(plaqueStruct);
    backFretRow = datasample(backMeanFretIdxRow, noPlaques);
    figure('color', 'white');
    ecdf(plaqueFretRow); hold all;
    ecdf(backFretRow);
    hold off;
    axis square;
    % Figure out appropriate significant value.
    pRow = zeros(1, 200);
    for i = 1 : 100
        x1 = datasample(plaqueFretRow, noPlaques);
        x2 = datasample(plaqueFretRow, noPlaques);
        [~, pRow(i)] = kstest2(x1, x2, 'Tail', 'smaller');
    end
    alpha = mean(pRow);
    h = kstest2(plaqueFretRow, backFretRow, 'alpha', alpha, ....
        'Tail', 'smaller');
    disp(h);
end
