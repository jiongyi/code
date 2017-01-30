function [eqE, eqW] = networkdensity(kA, kN, kP, kC)

dt = 1e-3;
N = 1e5;

Et = zeros(1, N);
Wt = zeros(1, N);

Et(1) = 0.01;
Wt(1) = 0;
for i = 1 : (N - 1)
    % Calculate differentials.
    dEdt = kN * Et(i) * Wt(i) - kC * Et(i);
    dWdt = kA * (1 - Wt(i)) - kN * Et(i) * Wt(i) - kP * Et(i) * Wt(i);
    % Update.
    Et(i + 1) = Et(i) + dEdt * dt;
    Wt(i + 1) = Wt(i) + dWdt * dt;
end

% Theoretical values.
thE = kA / kC * (kN - kC) / (kN + kP);
thW = kC / kN;
% Estimated values.
eqE = Et(end);
eqW = Wt(end);

% Plot results.
t = cumsum([0, dt * ones(1, N - 1)]);
figure('color', 'white', 'PaperPositionMode', 'auto');
[h, ax1, ax2] = plotyy(t, Et, t, Wt, 'plot');
set([h(1), h(2)], 'box', 'off', 'tickdir', 'out');
set([ax1, ax2], 'linewidth', 1.5);
xlabel('Time (s)');
ylabel(h(1), '[E(t)]');
ylabel(h(2), '[WA(t)]');
hold(h(1), 'on');
plot(h(1), [t(1), t(end)], [thE, thE], '--', 'linewidth', 1.5);
hold off;
hold(h(2), 'on');
plot(h(2), [t(1), t(end)], [thW, thW], '--', 'linewidth', 1.5);
hold off;
end