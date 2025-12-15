% Test Verileri
waypoints = [0, 10, 25, 40, 50]; % Yükseklik/Konum
times = [0, 2, 5, 8, 10];        % Zaman
v_in = 0;   % Başlangıç Hızı
a_in = 5;   % Başlangıç İvmesi (Sert giriş)
v_out = 0;  % Bitiş Hızı (Düz çıkış)

% Fonksiyonu Çağır
coeffs = solve_quartic_cubic_spline(waypoints, times, v_in, a_in, v_out);

% Çizim
figure; hold on; grid on;
xlabel('Zaman (s)'); ylabel('Konum (m)');
title('Quartic Girişli Hibrit Spline');

t_total = [];
pos_total = [];
vel_total = [];
acc_total = [];

current_t = times(1);

for i = 1:length(coeffs)
    dt = coeffs(i).dt;
    t_seg = linspace(0, dt, 100);
    
    c0 = coeffs(i).c0; c1 = coeffs(i).c1; 
    c2 = coeffs(i).c2; c3 = coeffs(i).c3; c4 = coeffs(i).c4;
    
    % Polinom Hesabı
    P = c0 + c1*t_seg + c2*t_seg.^2 + c3*t_seg.^3 + c4*t_seg.^4;
    V = c1 + 2*c2*t_seg + 3*c3*t_seg.^2 + 4*c4*t_seg.^3;
    A = 2*c2 + 6*c3*t_seg + 12*c4*t_seg.^2;
    
    plot(current_t + t_seg, P, 'LineWidth', 2);
    
    current_t = current_t + dt;
end

% Kontrol Noktalarını İşaretle
plot(times, waypoints, 'ro', 'MarkerFaceColor', 'r');


%% Cubic Spline
pp_x = spline(times,[v_in,waypoints,v_out]);
tau_samples = linspace(times(1),times(end),1000);

x_samples = ppval(pp_x, tau_samples);

hold on
plot(tau_samples,x_samples)