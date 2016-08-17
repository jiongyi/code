function [xPolyRow, yPolyRow] = horiksarea(data)
data = data + eps;
[f, x] = ksdensity(data + eps, 'support', 'positive');
xPolyRow = [-f, f(end - 1 : -1 : 1)];
xPolyRow = xPolyRow ./ max(xPolyRow);
yPolyRow = [x, x(end - 1 : -1 : 1)];
end
