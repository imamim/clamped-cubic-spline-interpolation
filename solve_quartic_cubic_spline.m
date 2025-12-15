function [coeffs] = solve_quartic_cubic_spline(waypoints, times, v_in, a_in, v_out)
    % waypoints: [y0, y1, ..., yN] (N+1 nokta)
    % times: [t0, t1, ..., tN] (Zaman noktaları)
    % v_in, a_in: Başlangıç Hız ve İvme
    % v_out: Bitiş Hızı (Clamped)

    N = length(waypoints) - 1; % Aralık sayısı
    dt = diff(times);          % Her aralığın süresi (delta t)
    
    % Bilinmeyen Sayısı: 
    % 1. Aralık (Quartic): 4 katsayı (c1, c2, c3, c4) -> c0 biliniyor
    % Diğerleri (Cubic): 3 katsayı (c1, c2, c3) * (N-1)
    num_unknowns = 4 + 3 * (N - 1);
    
    % Matrisleri Hazırla (Ax = B)
    A = zeros(num_unknowns, num_unknowns);
    B = zeros(num_unknowns, 1);
    
    row = 1; % Satır sayacı
    
    %% 1. BLOK: BAŞLANGIÇ KOŞULLARI (Interval 1 - Quartic)
    % Denklem 1: Başlangıç Hızı (c1 = v_in)
    % Sütunlar: c1_1, c2_1, c3_1, c4_1 ...
    A(row, 1) = 1; 
    B(row) = v_in;
    row = row + 1;
    
    % Denklem 2: Başlangıç İvmesi (2*c2 = a_in)
    A(row, 2) = 2;
    B(row) = a_in;
    row = row + 1;
    
    %% 2. BLOK: İÇ GEÇİŞLER VE KONUM
    % Kolon İndekslerini takip etmek için pointerlar
    % col_prev: Şu anki aralığın katsayılarının başlangıç sütunu
    % col_next: Bir sonraki aralığın katsayılarının başlangıç sütunu
    
    col_prev = 1; 
    
    for i = 1:N
        dti = dt(i);
        y_diff = waypoints(i+1) - waypoints(i);
        
        % --- Konum Denklemi (Her aralık hedef noktaya varmalı) ---
        if i == 1 % Quartic
            % c1*t + c2*t^2 + c3*t^3 + c4*t^4 = dy
            A(row, col_prev:col_prev+3) = [dti, dti^2, dti^3, dti^4];
        else % Cubic
            % c1*t + c2*t^2 + c3*t^3 = dy
            A(row, col_prev:col_prev+2) = [dti, dti^2, dti^3];
        end
        B(row) = y_diff;
        row = row + 1;
        
        % --- Süreklilik Denklemleri (Son aralık hariç) ---
        if i < N
            % Bir sonraki aralığın sütun başlangıcı
            if i == 1
                col_next = 5; % 4 (quartic) + 1
            else
                col_next = col_prev + 3;
            end
            
            % Hız Sürekliliği: V_end_prev - V_start_next = 0
            % Türev: c1 + 2*c2*t + 3*c3*t^2 (+ 4*c4*t^3)
            if i == 1 % Quartic -> Cubic geçişi
                val_prev = [1, 2*dti, 3*dti^2, 4*dti^3];
                A(row, col_prev:col_prev+3) = val_prev;
            else % Cubic -> Cubic geçişi
                val_prev = [1, 2*dti, 3*dti^2];
                A(row, col_prev:col_prev+2) = val_prev;
            end
            
            % Sonraki aralığın başlangıç hızı (t=0) -> sadece c1
            A(row, col_next) = -1; 
            B(row) = 0;
            row = row + 1;
            
            % İvme Sürekliliği: A_end_prev - A_start_next = 0
            % 2. Türev: 2*c2 + 6*c3*t (+ 12*c4*t^2)
            if i == 1 % Quartic -> Cubic
                val_prev_acc = [0, 2, 6*dti, 12*dti^2];
                A(row, col_prev:col_prev+3) = val_prev_acc;
            else % Cubic -> Cubic
                val_prev_acc = [0, 2, 6*dti];
                A(row, col_prev:col_prev+2) = val_prev_acc;
            end
            
            % Sonraki aralığın başlangıç ivmesi (t=0) -> 2*c2
            A(row, col_next+1) = -2;
            B(row) = 0;
            row = row + 1;
            
            % Kolon indeksini güncelle
            col_prev = col_next;
        end
    end
    
    %% 3. BLOK: BİTİŞ KOŞULU (Son Hız - Clamped)
    % Son aralık her zaman Cubic olduğu için son 3 sütunu kullanırız.
    dtn = dt(N);
    cols_last = num_unknowns-2 : num_unknowns; % Son 3 sütun (c1, c2, c3)
    
    % V_end = v_out
    A(row, cols_last) = [1, 2*dtn, 3*dtn^2];
    B(row) = v_out;
    
    %% ÇÖZÜM
    X = A \ B;
    
    %% ÇIKTIYI DÜZENLEME (Struct Yapısı)
    coeffs = struct();
    idx = 1;
    for i = 1:N
        coeffs(i).c0 = waypoints(i); % Sabit terim
        if i == 1
            coeffs(i).c1 = X(idx);
            coeffs(i).c2 = X(idx+1);
            coeffs(i).c3 = X(idx+2);
            coeffs(i).c4 = X(idx+3);
            coeffs(i).type = 'Quartic';
            idx = idx + 4;
        else
            coeffs(i).c1 = X(idx);
            coeffs(i).c2 = X(idx+1);
            coeffs(i).c3 = X(idx+2);
            coeffs(i).c4 = 0; % Cubic olduğu için c4 yok
            coeffs(i).type = 'Cubic';
            idx = idx + 3;
        end
        coeffs(i).dt = dt(i);
    end
end