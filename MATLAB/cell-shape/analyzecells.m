function [CellStatsCell, NucleusStatsCell, Contact, Nucleus] = ...
    analyzecells(contactWidth, nucleusWidth)

% Select files.
[cadherinFileNameCell, folderNameStr] = uigetfile('*C1.tiff', ...
    'Select cadherin TIF', 'MultiSelect', 'on');
nucleusFileNameCell = uigetfile('*C0.tiff', ...
    'Select nucleus TIF', folderNameStr, 'MultiSelect', 'on');

% Check if single-string variable needs to be converted into cell.
if ~iscell(cadherinFileNameCell)
    cadherinFileNameCell = {cadherinFileNameCell};
    nucleusFileNameCell = {nucleusFileNameCell};
end

% Load files and project average intensity.
cadherinCell = cellfun(@(x) mean(imstack([folderNameStr, x]), 3), ...
    cadherinFileNameCell, 'UniformOutput', false);
nucleusCell = cellfun(@(x) mean(imstack([folderNameStr, x]), 3), ...
    nucleusFileNameCell, 'UniformOutput', false);

% Loop over each strain point.
noFrames = numel(cadherinCell);
[Contact, Nucleus] = maskcells(cadherinCell{1}, nucleusCell{1}, ...
    contactWidth, nucleusWidth);
if noFrames > 1
    Contact(noFrames).rawIm = [];
    Nucleus(noFrames).rawIm = [];
    for iFrame = 1 : noFrames
        [Contact(iFrame), Nucleus(iFrame)] = maskcells(...
            cadherinCell{iFrame}, nucleusCell{iFrame}, ...
            contactWidth, nucleusWidth);
    end
end

% Extract properties.
CellStatsCell = arrayfun(@(x) regionprops(x.bwIm, ...
    'Area', 'MajorAxisLength', 'Orientation'), ...
    Contact, 'UniformOutput', false);
NucleusStatsCell = arrayfun(@(x) regionprops(x.bwIm, ...
    'Area', 'Centroid'), Nucleus, 'UniformOutput', false);

% Save data.
idxFileSep = find(folderNameStr == filesep);
firstIdx = idxFileSep(end - 1) + 1;
lastIdx = idxFileSep(end) - 1;
saveFileNameStr = folderNameStr(firstIdx : lastIdx);
save([folderNameStr, saveFileNameStr, '-analyzed.mat'], ...
    'CellStatsCell', 'NucleusStatsCell', 'Contact', 'Nucleus', '-v7.3');
end
