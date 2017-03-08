function [vEq, aEq, wEq] = analyticalautoebrnpf(loadForce, doPlot)
if nargin == 1
    doPlot = 'no';
end

kN = 10; % nucleation rate
kC = 0.5; % capping rate
d0 = 0.5; % free dissociation rate
vPolMax = 500; % free polymerization rate
vDep = 2.2; % free depolymerization rate
l = 2.2; % average length increment
kT = 4.1; % thermal energy
fb = 10; % strength of attachment bond
k = 1; % spring constant
v0 = fb * d0 / k;

% Additional variables from autocatalytic and NPF model.
W0 = 1;
kA = 1;
kP = vPolMax / l;

% Non-dimensional variables
e1 = (fb * l / kT) * (kC / d0);
e2 = vPolMax / v0;
e3 = vDep / v0;
e4 = (loadForce * l) / kT / W0 / kA / kN * kC * kP;

v = linspace(0, 25, 1000);
wv = arrayfun(@(x) w(x), v);
wv2 = wv.^2;
rhs = e2 * exp(-e1 * v .* wv2 - e4) - e3;
delta = abs(v - rhs);
vEq = v(delta == min(delta));
wEq = W0 * (kA / kC) * (kN / kP);
aEq = kC / d0 * w(vEq) * wEq;

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