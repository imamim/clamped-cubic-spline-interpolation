% Parameters
n = 4; % n+1 data points, n segment and n polynomial
number_of_data_points_on_curve = 1000;



number_of_data_points = n+1;


% Think about x: 0 -> 1000 , y = 0, z = 0

x_1 = 0;
x_2 = 1000;

x_data = linspace(x_1,x_2,number_of_data_points);
y_data = zeros(1,number_of_data_points);
z_data = zeros(1,number_of_data_points);


tau = zeros(1,number_of_data_points);

tau(1) = 0;

for i = 1:number_of_data_points-1
    
    x_diff = (x_data(i+1)-x_data(i));
    y_diff = (y_data(i+1)-y_data(i));
    z_diff = (z_data(i+1)-z_data(i));

    tau(i+1) = tau(i) + sqrt(x_diff^2+y_diff^2+z_diff^2);
end

pp_x = spline(tau,[0,x_data,0]);
pp_y = spline(tau,[0,y_data,0]);
pp_z = spline(tau,[0,z_data,0]);

tau_samples = linspace(tau(1),tau(end),number_of_data_points_on_curve);

x_samples = ppval(pp_x, tau_samples);
y_samples = ppval(pp_y, tau_samples);
z_samples = ppval(pp_z, tau_samples);

figure();
tl = tiledlayout(2,2);
nexttile
plot3(x_samples,y_samples,z_samples)
grid('on')
xlabel('North')
ylabel('East')
zlabel('Down')

nexttile
plot(tau_samples, x_samples, 'b', 'LineWidth', 1.5)
hold on
plot(tau,x_data,'o','Color','r','LineWidth', 1.2)
legend('X','X Data')
title('Spline X')
xlabel('Tau')
ylabel('x (m)')

nexttile
plot(tau_samples, y_samples, 'b', 'LineWidth', 1.5)
hold on
plot(tau,y_data,'o','Color','r','LineWidth', 1.2)
legend('Y','Y Data')
title('Spline Y')
xlabel('Tau')
ylabel('y (m)')

nexttile
plot(tau_samples, z_samples, 'b', 'LineWidth', 1.5)
hold on
plot(tau,z_data,'o','Color','r','LineWidth', 1.2)
legend('Z','Z Data')
title('Spline Z')
xlabel('Tau')
ylabel('z (m)')



%% Nokta Kaydirma

figure
ax3d = axes;
hold(ax3d,'on')
grid(ax3d,'on')
xlabel('North')
ylabel('East')
zlabel('Down')
view(3)

% Kontrol noktaları
ctrlPts = gobjects(number_of_data_points,1);

for i = 1:number_of_data_points
    ctrlPts(i) = drawpoint(ax3d, ...
        'Position',[x_data(i), y_data(i), z_data(i)], ...
        'Color','r');
end








function [x_data,y_data,z_data] = getControlPoints(ctrlPts)

N = numel(ctrlPts);

x_data = zeros(1,N);
y_data = zeros(1,N);
z_data = zeros(1,N);

for k = 1:N
    pos = ctrlPts(k).Position;
    x_data(k) = pos(1);
    y_data(k) = pos(2);
    z_data(k) = pos(3);
end
end



function tau = computeTau(x_data,y_data,z_data)

N = numel(x_data);
tau = zeros(1,N);

for i = 1:N-1
    dx = x_data(i+1)-x_data(i);
    dy = y_data(i+1)-y_data(i);
    dz = z_data(i+1)-z_data(i);

    tau(i+1) = tau(i) + sqrt(dx^2 + dy^2 + dz^2);
end
end
