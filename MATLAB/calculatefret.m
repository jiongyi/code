function effIm = calculatefret(donorIm, fretIm, acceptorIm)
    % Correct for bleed-through and cross-talk.
    corrIm = imsubtract(fretIm, 0.47 * donorIm);
    corrIm = imsubtract(corrIm, 0.18 * acceptorIm);
    % Calculate FRET efficiency.
    effIm = corrIm ./ acceptorIm;
    % Zero-out background.
    bwIm = im2bw(acceptorIm, graythresh(mat2gray(acceptorIm)));
    effIm(~bwIm) = 0;
end
