function effIm = calculatefret(donorIm, fretIm, acceptorIm)
    % Correct for bleed-through and cross-talk.
    a = 0.114;
    b = 0.350;
    corrIm = imsubtract(fretIm, a * donorIm);
    corrIm = imsubtract(corrIm, b * acceptorIm);
    % Calculate FRET efficiency.
    effIm = corrIm ./ acceptorIm;
    % Zero-out background.
    normIm = mat2gray(acceptorIm);
    bwIm = im2bw(normIm, graythresh(normIm));
    effIm = imfilter(effIm, fspecial('gaussian', 6, 2), 'replicate');
    effIm(~bwIm) = 0;
    figure;
    imshow(effIm);
    axis square;
    colorbar;
end
