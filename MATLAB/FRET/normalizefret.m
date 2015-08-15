function [Cfp, Fret, Yfp] = normalizefret(Flat)

[cfpFileNameStr, folderNameStr] = uigetfile('*_CFP.tiff', ...
    'Select CFP image');
fretFileNameStr = [cfpFileNameStr(1 : end - 8), 'yFRET.tiff'];
yfpFileNameStr = [cfpFileNameStr(1 : end - 8), 'YFP.tiff'];

% Load images.
Cfp.rawIm = im2double(imread([folderNameStr, cfpFileNameStr]));
Fret.rawIm = im2double(imread([folderNameStr, fretFileNameStr]));
Yfp.rawIm = im2double(imread([folderNameStr, yfpFileNameStr]));

% Flatten images.
Cfp.flatIm = Cfp.rawIm ./ Flat.cfpIm;
Fret.flatIm = Fret.rawIm ./ Flat.fretIm;
Yfp.flatIm = Yfp.rawIm ./ Flat.yfpIm;

% Subtract background.
Cfp.subIm = subtractback(Cfp.flatIm);
Fret.subIm = subtractback(Fret.flatIm);
Yfp.subIm = subtractback(Yfp.flatIm);

% Blurr images.
kernelWidth = 3;
Cfp.blurrIm = imblurr(Cfp.subIm, kernelWidth);
Fret.blurrIm = imblurr(Fret.subIm, kernelWidth);
Yfp.blurrIm = imblurr(Yfp.subIm, kernelWidth);

% Normalize fret.
Fret.corrIm = Fret.blurrIm - 0.4 * Cfp.blurrIm - 0.2 * Yfp.blurrIm;
Fret.corrIm(Fret.corrIm < 0) = 0;
Fret.scaleIm = (Cfp.blurrIm + Fret.corrIm);
Fret.normIm = Fret.corrIm ./ Fret.scaleIm;
[Fret.indIm, Fret.colorMap] = gray2ind(Fret.normIm, 10);

% Display results.
figure('color', 'white');
imshow(Fret.normIm, []);
colormap summer;
colorbar;
title(cfpFileNameStr(1 :  end - 9));

end

function subIm = subtractback(rawIm)
avgFiltObj = fspecial('average', 512);
subIm = rawIm - imfilter(rawIm, avgFiltObj, 'replicate');
minInt = min(subIm(:));
if minInt < 0
    subIm = subIm - minInt;
end
end

function blurrIm = imblurr(rawIm, kernelWidth)
blurrIm = imfilter(rawIm, fspecial('gaussian', kernelWidth, ...
    kernelWidth / 6), 'replicate');
end