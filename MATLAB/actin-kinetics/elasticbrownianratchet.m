function [aMean, wMean] = elasticbrownianratchet(fL)
% Initialize variables.
dt = 1e-2; % time step
N = 1e4; % number of iterations
n = 10; % nucleation rate
kappa = 0.5; % capping rate
d0 = 0.5; % free dissociation rate
VMax = 500; % free polymerization rate
VDep = 2.2; % free depolymerization rate
l = 2.2; % average length increment
kT = 4.1; % thermal energy
fb = 10; % strength of attachment bond
k = 1; % spring constant

% Iterate.
a = zeros(1, N); % number of attached filaments.
w = zeros(1, N); % number of working filaments.
x = 0; % extension vector
V = zeros(1, N); % velocity
for i = 1 : (N - 1)
    % Nucleate new stress-free attached filament.
    if exp(-n * dt) < rand(1)
        x(a(i) + 1) = 0;
        a(i) = a(i) + 1;
    end
    % Detach.
    if a(i) > 0
        f = k * x;
        d = d0 * exp(f / fb);
        willDetach = exp(-d * dt) < rand(1, numel(x));
        noDetached = sum(willDetach);
        x(willDetach) = [];
        f(willDetach) = [];
    else
        noDetached = 0;
    end
    % Update.
    a(i + 1) = a(i) - noDetached;
    % Cap.
    if w(i) > 0
        willCap = exp(-kappa * dt) <  rand(1, w(i));
        noCapped = sum(willCap);
    else
        noCapped = 0;
    end
    w(i) = w(i) - noCapped;
    % Update number of working filaments.
    w(i + 1) = w(i) + noDetached;
    % Calculate force per working filament.
    if w(i + 1) > 0
        fw = (fL + sum(f)) / w(i + 1);
    else
        fw = 0;
    end
    % Calculate velocity.
    V(i) = VMax * exp(-fw * l / kT) - VDep;
    % Update coordinates.
    x = x + V(i) * dt;
end
aMean = mean(a);
wMean = mean(w);
figure;
t = 0 : dt : dt * (N - 1);
plot(t, a);
hold on;
plot(t, w);
hold off;
legend('attached', 'working');
end