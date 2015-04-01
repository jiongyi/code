function idxFretIm = calculatefret(fretStackIm)
    % Split stack to images.
    donorIm = fretStackIm(:, :, 1);
    fretIm = fretStackIm(:, :, 2);
    acceptorIm = fretStackIm(:, :, 3);
    
    % Subtract background.
    donorIm = dogfilter(donorIm);
    fretIm = dogfilter(fretIm);
    acceptorIm = dogfilter(acceptorIm);
    % Correct for bleed-through and cross-talk.
    a = 0.47;
    b = 0.18;
    corrIm = imsubtract(fretIm, a * donorIm);
    corrIm = imsubtract(corrIm, b * acceptorIm);
    corrIm(corrIm <= 0) = 0;
    % Figure out positive regions.
    normIm = mat2gray(mean(cat(3, donorIm, corrIm, acceptorIm), 3));
    bwIm = im2bw(normIm, graythresh(normIm));
    % Calculate FRET index.
    idxFretIm = corrIm ./ acceptorIm;
    idxFretIm(isnan(idxFretIm)) = 0;
    idxFretIm(isinf(idxFretIm)) = 0;
    idxFretIm(~bwIm) = 0;
    idxFretIm = imfilter(idxFretIm, fspecial('average', 6), ...
'symmetric');
    figure('color', 'w'); imagesc(idxFretIm); colorbar; axis square off;
    title('FRET index');
end
