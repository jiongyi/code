function fretStackIm = loadimages()
% Get file names.
[cfpFileNameStr, folderNameStr] = uigetfile('*CFP.tiff', ...
'Select donor channel file', ...
'/home/jiongyi/VirtualShare/');
yfpFileNameStr = [cfpFileNameStr(1 : end - 8), 'YFP.tiff'];
fretFileNameStr = [cfpFileNameStr(1 : end - 8), 'yFRET.tiff'];

% Load images.
cfpIm = double(imread([folderNameStr, cfpFileNameStr]));
yfpIm = double(imread([folderNameStr, yfpFileNameStr]));
fretIm = double(imread([folderNameStr, fretFileNameStr]));

% Load flat-field correction files and normalize to mean.
flatFolderNameStr = '/home/jiongyi/Documents/MATLAB/fret/';
cfpFlatIm = double(imread([flatFolderNameStr, 'acceptorFlatIm.tiff']));
% cfpFlatIm = cfpFlatIm / mean(cfpFlatIm(:));
yfpFlatIm = double(imread([flatFolderNameStr, 'donorFlatIm.tiff']));
% yfpFlatIm = yfpFlatIm / mean(yfpFlatIm(:));
fretFlatIm = double(imread([flatFolderNameStr, 'fretFlatIm.tiff']));
% fretFlatIm = fretFlatIm / mean(fretFlatIm(:));

% Flat-field correction.
cfpIm = cfpIm - cfpFlatIm;
cfpIm(isinf(cfpIm)) = 0;
yfpIm = yfpIm - yfpFlatIm;
yfpIm(isinf(yfpIm)) = 0;
fretIm = fretIm - fretFlatIm;
fretIm(isinf(fretIm)) = 0;
fretStackIm = cat(3, cfpIm, yfpIm, fretIm);
end