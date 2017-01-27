function [filFlux, polPwr] = simulatepol(kRow)
kA = kRow(1);
kN = kRow(2);
kP = kRow(3);
kC = kRow(4);
% Initialize.
noIterations = 1000;
wh2StateRow = blanks(noIterations);
filStateRow = blanks(noIterations);
timeRow = zeros(1, noIterations);

% Iterate.
wh2StateRow(1) = 'e';
filStateRow(1) = 'e';
for i = 1 : (noIterations - 1)
    updatestate();
end

isPolRow = filStateRow == 'p' | filStateRow == 's';
Filaments = regionprops(isPolRow, (filStateRow == 'p'), 'Area', 'PixelValues');
noFilaments = numel(Filaments);
filFlux = noFilaments / sum(timeRow);
filLengthRow = arrayfun(@(x) sum([x(:).PixelValues]) + 1, Filaments);
polPwr = sum(filLengthRow) / sum(timeRow);

% Plot results.
% disp(['Number of filaments/s: ', num2str(filFlux)]);
% figure('color', 'white', 'PaperPositionMode', 'auto');

% maxFilLength = max(filLengthRow);
% [y, x] = hist(filLengthRow, 1 : maxFilLength);
% b = bar(x, y, 'hist');
% b(1).FaceColor = 'white';
% b(1).EdgeColor = 'blue';
% set(gca, 'tickdir', 'out', 'box', 'off');
% xlabel('Filament length (units)');
% ylabel('Counts');

    function updatestate()
        switch wh2StateRow(i)
            case 'e'
                % If empty just figure out time to G-actin occupancy.
                timeRow(i + 1) = log(1 / rand) / kA;
                wh2StateRow(i + 1) = 'a';
                if filStateRow(i) == 'p' || filStateRow(i) == 'n'
                    filStateRow(i + 1) = 's';
                elseif filStateRow(i) == 'e'
                    filStateRow(i + 1) = 'e';
                end
            case 'a'
                % If polymer is capped just figure out time to nucleation.
                if filStateRow(i) == 'c' || filStateRow(i) == 'e'
                    timeRow(i + 1) = log(1 / rand) / kN;
                    wh2StateRow(i + 1) = 'e';
                    filStateRow(i + 1) = 'n';
                % If it isn't capped, figure out time to polymerization or
                % capping.
                elseif filStateRow(i) == 'p' || filStateRow(i) == 'n' || filStateRow(i) == 's'
                    u = rand;
                    kTotal = kP + kC;
                    timeRow(i + 1) = log(1 / u) / kTotal;
                    [~, idx] = histc(u, cumsum([0, kP, kC] / kTotal));
                    if idx == 1
                        wh2StateRow(i + 1) = 'e';
                        filStateRow(i + 1) = 'p';
                    elseif idx == 2
                        wh2StateRow(i + 1) = 'a';
                        filStateRow(i + 1) = 'c';
                    end
                end
        end
    end
end