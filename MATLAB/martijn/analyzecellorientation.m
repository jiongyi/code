function [thetaRow, muAligned, stdAligned] = analyzecellorientation(stackNo)

%% Select files.
[cadherinFileNameStr, folderNameStr] = uigetfile('*.tif', ...
    'Select cadherin TIF');
nucleusFileNameStr = uigetfile('*.tif', ...
    'Select nucleus TIF', folderNameStr);
%% Load files.
cadherinIm = imread([folderNameStr, cadherinFileNameStr], stackNo);
nucleusIm = imread([folderNameStr, nucleusFileNameStr], stackNo);
%% Generate regional maxima mask based on nuclear stain.
isRegMaxIm = maskregionalmax(nucleusIm, 3);
cellMaskIm = markerwatershed(cadherinIm, 3, isRegMaxIm);
%% Calculate orientation.
[thetaRow, muAligned, stdAligned] = calculateorientation(cellMaskIm);