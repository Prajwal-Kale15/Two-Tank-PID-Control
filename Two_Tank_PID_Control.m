%% ============================================================
%  ESP8266 + MATLAB Real-Time PID Control + Enhanced Visualization
%  Author: Prajwal Kale
%  Project: Two Tank Interacting System (IoT PID Control)
%  VIT Pune - Instrumentation & Control Engineering
%  ============================================================
clear; close all; clc;

%% ---------- CONFIGURATION ----------
esp_ip = 'http://10.200.118.141';   % Change this to your ESP's IP
Ts = 1;                             % Sampling time [s]
runTime = 200;                      % Total run time [s]

% PID constants
Kp = 2.0;
Ki = 0.4;
Kd = 1.0;

setpoint = 15.0;                    % Desired level [cm]
deadband = 0.5;                     % For ON/OFF control
maxPWM = 1023;

%% ---------- INITIALIZE VARIABLES ----------
steps = runTime / Ts;
time = (0:Ts:runTime)';
level_log = nan(length(time), 1);
error_log = nan(length(time), 1);
u_log = nan(length(time), 1);
integral = 0; lastError = 0;

%% ---------- CONNECTION TEST ----------
disp('Testing ESP8266 connection...');
try
    resp = webread([esp_ip '/data']);
    disp('Connection successful!');
    disp(resp);
catch
    error('Cannot reach ESP8266 at %s. Check Wi-Fi & IP.', esp_ip);
end

%% ---------- SETUP FIGURES ----------
% 1) Water Level Graph
fig1 = figure('Name','Tank Level Response','NumberTitle','off');
hold on; grid on;
xlabel('Time (s)'); ylabel('Water Level (cm)');
title('Graph 1: Tank Water Level vs Time');
level_plot = plot(NaN, NaN, 'b', 'LineWidth', 1.8);
yline(setpoint, '--b', sprintf('Setpoint = %.1f cm', setpoint));
text(5, setpoint + 2, 'PID control stabilizes near 15 cm', 'FontSize', 10, 'Color', 'k');

% 2) PID Output Graph
fig2 = figure('Name','PID Output','NumberTitle','off');
hold on; grid on;
xlabel('Time (s)'); ylabel('PID Output');
title('Graph 2: PID Controller Output');
u_plot = plot(NaN, NaN, 'm', 'LineWidth', 1.8);
text(100, 5, 'Positive = Inlet pump ON, Negative = Outlet pump ON', 'FontSize', 10, 'Color', 'k');

% 3) Pump Activation Graph
fig3 = figure('Name','Pump Activation','NumberTitle','off');
hold on; grid on;
xlabel('Time (s)'); ylabel('Pump Flow (cm^3/s)');
title('Graph 3: Pump Activation Pattern');
inlet_plot  = plot(NaN, NaN, 'g', 'LineWidth', 2.0, 'DisplayName', 'Inlet Pump (Filling)');
outlet_plot = plot(NaN, NaN, 'r', 'LineWidth', 2.0, 'DisplayName', 'Outlet Pump (Draining)');
legend('show');
text(5, 35, 'Green = Water Inlet Active',  'FontSize', 10, 'Color', 'g');
text(5, -35, 'Red = Water Outlet Active', 'FontSize', 10, 'Color', 'r');

%% ---------- MAIN CONTROL LOOP ----------
fprintf('\n=== MATLAB <-> ESP8266 Control Loop Started ===\n');
fprintf('Press Ctrl+C to stop.\n');

for k = 1:length(time)
    tnow = time(k);

    % 1) Read sensor data from ESP8266
    try
        data = webread([esp_ip '/data']);
        level = data.level;
    catch
        warning('Failed to read sensor data at t=%.1f s', tnow);
        if k > 1 && ~isnan(level_log(k-1))
            level = level_log(k-1);
        else
            level = 0;
        end
    end
    level_log(k) = level;

    % 2) PID Computation
    error_val = setpoint - level;
    integral  = integral + error_val * Ts;
    derivative = (error_val - lastError) / Ts;
    u = Kp * error_val + Ki * integral + Kd * derivative;
    lastError = error_val;
    error_log(k) = error_val;
    u_log(k) = u;

    % 3) Send control command to ESP8266
    try
        if u > deadband
            webread(sprintf('%s/control?in=1&out=0', esp_ip));
            action = 'Inlet Pump ON';
        elseif u < -deadband
            webread(sprintf('%s/control?in=0&out=1', esp_ip));
            action = 'Outlet Pump ON';
        else
            webread(sprintf('%s/control?in=0&out=0', esp_ip));
            action = 'Stable';
        end
    catch
        warning('Failed to send control command at t=%.1f s', tnow);
        action = 'Comm Error';
    end

    % 4) Live Plot Updates
    figure(fig1);
    set(level_plot, 'XData', time(1:k), 'YData', level_log(1:k));
    title(sprintf('Tank Level | Current: %.2f cm | %s', level, action));
    drawnow limitrate;

    figure(fig2);
    set(u_plot, 'XData', time(1:k), 'YData', u_log(1:k));
    drawnow limitrate;

    figure(fig3);
    inlet_data  = max(u_log(1:k), 0);
    outlet_data = min(u_log(1:k), 0);
    set(inlet_plot,  'XData', time(1:k), 'YData', inlet_data);
    set(outlet_plot, 'XData', time(1:k), 'YData', outlet_data);
    drawnow limitrate;

    fprintf('t=%4.1f s | Level=%.2f cm | Error=%.2f | u=%.2f | %s\n', ...
        tnow, level, error_val, u, action);
    pause(Ts);
end

fprintf('\n=== Control Loop Completed ===\n');

%% ---------- SAVE RESULTS ----------
dataTable = table(time, level_log, error_log, u_log, ...
    'VariableNames', {'Time_s', 'Level_cm', 'Error_cm', 'ControlSignal'});
filename = sprintf('PID_LOG_%s.csv', datestr(now, 'HHMMSS'));
writetable(dataTable, filename);
fprintf('Data logged and saved as %s\n', filename);
