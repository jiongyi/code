function [muRow, isTransitionRow] = kalmanfilter(signalRow, threshold)

% Initialize variables.
N = numel(signalRow);
muRow = zeros(1, N);
muRow(1) = signalRow(1);
stdRow = zeros(1, N);
stdRow(1) = inf;
isTransitionRow = false(1, N);

% Iterate.
sumSqDiff = 0;
j = 1;
for i = 2 : N
    deviation = abs(signalRow(i) - muRow(i - 1));
    if deviation < max(3 * stdRow(i - 1), threshold)
        % Counts as part of a piecewise-constant signal
        j = j + 1;
        muRow(i) = ((j - 1) * muRow(i - 1) + signalRow(i)) / j;
        sumSqDiff = sumSqDiff + (signalRow(i) - muRow(i)) * ...
            (signalRow(i) - muRow(i - 1));
        stdRow(i) = sqrt(sumSqDiff / j);
    else
        isTransitionRow(i) = true;
        muRow(i) = signalRow(i);
        sumSqDiff = 0;
        j = 1;
        stdRow(i) = inf;
    end
end

figure('color', 'white');
plot(signalRow, 'color', [0.8, 0.8, 0.8], 'linewidth', 1.5);
hold on;
plot(muRow, 'r', 'linewidth', 1.5);
set(gca, 'box', 'off', 'tickdir', 'out', 'linewidth', 1.5);
ylabel('Force (pN)');
xlabel('Index');

figure('color', 'white');
plot(stdRow, 'linewidth', 1.5);
set(gca, 'box', 'off', 'tickdir', 'out', 'linewidth', 1.5);
ylabel('Estimated \sigma');
xlabel('Index');