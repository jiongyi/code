function calculatefret(filePathStr)

    fretStackStruct = loadimages(filePathStr);
    % Split stack to images.
    donorIm = fretStackStruct.donorIm;
    fretIm = fretStackStruct.fretIm;
    acceptorIm = fretStackStruct.acceptorIm;
    
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
%     bwIm = im2bw(mat2gray(normIm), graythresh(mat2gray(normIm)));
    idxFretIm = corrIm ./ normIm;
    idxFretIm(isnan(idxFretIm)) = 0;
    idxFretIm(idxFretIm == inf) = 0;
    idxFretIm = imfilter(idxFretIm, fspecial('gaussian', 7, 2), ...
        'replicate');
    idxFretIm(~bwIm) = 0;
    
%     % Display results.
    overIm = imoverlay(mat2gray(normIm), bwperim(~bwIm), [0, 1, 0]);
    figure('color', 'w'); imshowpair(overIm, label2rgb(round(10 * idxFretIm)), 'montage'); colorbar;
    title(fretStackStruct.nameStr);
    print(gcf, '-dpng', '-r600', [fretStackStruct.folderNameStr, ...
        fretStackStruct.nameStr, '_fret_ratio']);
end
