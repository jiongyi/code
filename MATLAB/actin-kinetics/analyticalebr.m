function [vEq, aEq, wEq] = analyticalebr(fL, doPlot)
if nargin == 1
    doPlot = 'no';
end

n = 10; % nucleation rate
kappa = 0.5; % capping rate
d0 = 0.5; % free dissociation rate
VMax = 500; % free polymerization rate
VDep = 2.2; % free depolymerization rate
l = 2.2; % average length increment
kT = 4.1; % thermal energy
fb = 10; % strength of attachment bond
k = 1; % spring constant
V0 = fb * d0 / k;

% Non-dimensional variables
e1 = (fb * l / kT) * (kappa / d0);
e2 = VMax / V0;
e3 = VDep / V0;
e4 = (fL * l / kT) * (kappa / n);

v = linspace(0, 25, 1000);
wv = arrayfun(@(x) w(x), v);
wv2 = wv.^2;
rhs = e2 * exp(-e1 * v .* wv2 - e4 ./ wv) - e3;
delta = abs(v - rhs);
vEq = v(delta == min(delta));
aEq = n / d0 * w(vEq);
wEq = n / kappa;

% Plot.
if strcmp(doPlot, 'yes')
    figure('color', 'white', 'PaperPositionMode', 'auto');
    plot(v, rhs);
    hold on;
    plot(v, v);
    hold off;
    set(gca, 'tickdir', 'out', 'box', 'off');
    xlabel('velocity = V / V_0');
    legend('RHS', 'LHS');
end

end

function y = w(v)
fun = @(x) x .* exp(v * x + (1 - exp(v * x)) / v);
y = integral(fun, 0, Inf);
end