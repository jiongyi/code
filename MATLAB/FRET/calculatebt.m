function btFret = calculatebt(fretStackIm)
    % Split stack to images.
    donorIm = fretStackIm(:, :, 1);
    fretIm = fretStackIm(:, :, 2);
    acceptorIm = fretStackIm(:, :, 3);
    
    % Subtract background.
    donorIm = dogfilter(donorIm);
    fretIm = dogfilter(fretIm);
    acceptorIm = dogfilter(acceptorIm);
    
    % Figure out positive regions.
    normIm = mat2gray(donorIm);
    bwIm = im2bw(normIm, graythresh(normIm));
    
    % Calculate bleed-through ratio.
    btFret = mean(fretIm(bwIm)) / mean(donorIm(bwIm));
end
