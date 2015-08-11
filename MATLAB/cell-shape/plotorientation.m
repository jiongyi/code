function xProjCell = plotorientation(CellStatsCell)
xProjCell = cellfun(@(x) cos([x(:).Orientation] / 180 * pi), ...
    CellStatsCell, 'UniformOutput', false);
end