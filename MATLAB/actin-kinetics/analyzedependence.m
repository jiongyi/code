function analyzedependence(kRow)
[maxRate, idx] = max(kRow);
xRow = 1 : maxRate;
meanFilFluxRow = zeros(1, maxRate);
stdFilFluxRow = zeros(1, maxRate);
meanPolPwrRow = zeros(1, maxRate);
stdPolPwrRow = zeros(1, maxRate);
for i = 1 : maxRate
    kRow(idx) = i;
    [bootFilFluxRow, bootPolPwrRow] = arrayfun(@(x) simulatepol(kRow), ...
        1 : 100);
    meanFilFluxRow(i) = mean(bootFilFluxRow);
    meanPolPwrRow(i) = mean(bootPolPwrRow);
    stdFilFluxRow(i) = std(bootFilFluxRow);
    stdPolPwrRow(i) = std(bootPolPwrRow);
end

% figure;
errorbar(xRow, meanFilFluxRow, stdFilFluxRow);
xlabel('k (/s)');
ylabel('Filament flux (/s)');

% figure;
% errorbar(xRow, meanPolPwrRow, stdPolPwrRow);
% xlabel('k (/s)');
% ylabel('Filament flux (/s)');
end