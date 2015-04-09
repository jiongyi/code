function fretStackStruct = loadimages(filePathStr)
% Get file names.
[folderNameStr, cfpFileNameStr, ext] = fileparts(filePathStr);
folderNameStr = [folderNameStr,  '/'];
cfpFileNameStr = [cfpFileNameStr, ext]; 
yfpFileNameStr = [cfpFileNameStr(1 : end - 8), 'YFP.tiff'];
fretFileNameStr = [cfpFileNameStr(1 : end - 8), 'yFRET.tiff'];

% Load images.
cfpIm = double(imread([folderNameStr, cfpFileNameStr]));
yfpIm = double(imread([folderNameStr, yfpFileNameStr]));
fretIm = double(imread([folderNameStr, fretFileNameStr]));


% Load flat-field correction files and normalize to mean.
flatFolderNameStr = '/home/jiongyi/Documents/MATLAB/fret/';
cfpFlatIm = double(imread([flatFolderNameStr, 'acceptorFlatIm.tiff']));
yfpFlatIm = double(imread([flatFolderNameStr, 'donorFlatIm.tiff']));
fretFlatIm = double(imread([flatFolderNameStr, 'fretFlatIm.tiff']));

% Flat-field/background correction.
% cfpIm = cfpIm - cfpFlatIm;
% cfpIm(cfpIm < 0) = 0;
% yfpIm = yfpIm - yfpFlatIm;
% yfpIm(yfpIm < 0) = 0;
% fretIm = fretIm - fretFlatIm;
% fretIm(fretIm < 0) = 0;

cfpIm = cfpIm ./ cfpFlatIm * mean(cfpFlatIm(:));
fretIm = fretIm ./ fretFlatIm * mean(fretFlatIm(:));
yfpIm = yfpIm ./ yfpFlatIm * mean(yfpFlatIm(:));

% Build structure.
fretStackStruct.donorIm = cfpIm;
fretStackStruct.fretIm = fretIm;
fretStackStruct.acceptorIm = yfpIm;
fretStackStruct.nameStr = cfpFileNameStr(1 : end - 9);
fretStackStruct.folderNameStr = folderNameStr;

end