function combineexperiments(propertyStr)
	[fileNameStr, folderNameStr] = uigetfile('*.mat', ...
		'Select .mat files storing results', 'MultiSelect', 'on');
	if ~iscell(fileNameStr)
		fileNameStr = {fileNameStr};
	end

	noFiles = numel(fileNameStr);
	normBinCountCell = cell(1, noFiles);
	prctStrainCell = cell(1, noFiles);
	orientationAbsDegCell = cell(1, noFiles);
	semPrctStrainCell = cell(1, noFiles);
	for i = 1 : noFiles
		load([folderNameStr, fileNameStr{i}], 'CellStatsCell');
		[normBinCountCell{i}, prctStrainCell{i}] = ...
			plotstrain(CellStatsCell);
	end
end
