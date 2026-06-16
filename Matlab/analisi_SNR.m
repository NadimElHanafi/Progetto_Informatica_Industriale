clear all; close all;

% Parametri del segnale originale (da TestGenerateSignal)
Nb    = 8;
tclk  = 20e-9;
NFIFO_values = [32, 64, 128];

mypath = 'C:/Users/Nadim/Desktop/FPGA_DigitalSignalFiltering/DigitalSignalFiltering/DigitalSignalFiltering.sim/sim_1/behav/xsim/';
filenames = {'output_NFIFO32.txt', 'output_NFIFO64.txt', 'output_NFIFO128.txt'};

% Carica il segnale originale da TestGenerateSignal
FS   = 256;
SNRdB_input = 0;
SNR  = 10^(SNRdB_input/20);
pnoise_orig = FS / (2*SNR*sqrt(2) + 3);
A0   = pnoise_orig * SNR * sqrt(2);

T0   = (2^Nb) * tclk;
f0   = 1/T0;
Mperiods = 20;
N_tot = Mperiods * 2^Nb;      % campioni totali
N_vhd = 4096;                 % campioni letti da VIVADO

t_full = (1:N_tot) / N_tot * T0 * Mperiods;
t_vhd  = t_full(1:N_vhd);

% Segnale puro (solo sinusoide, senza offset di rumore)
ysignal_pure = A0 + A0*sin(2*pi*f0*t_vhd);
signal_rms   = rms(ysignal_pure - mean(ysignal_pure));

% Loop sui 3 file
SNR_dB = zeros(1,3);
noise_rms = zeros(1,3);

figure('Name','Confronto output filtro per NFIFO=32/64/128');
hold on; grid on;
colors = ['r','g','b'];

for i = 1:3
    % Leggi file VIVADO
    d = importdata(strcat(mypath, filenames{i}));
    y = bin2dec(num2str(d));
    y = double(y(1:N_vhd))';

    % Rimuovi DC offset prima di calcolare SNR
    y_ac = y - mean(y);

    % SNR 
    SNR_dB(i) = snr(y_ac);

    % RMS
    noise_rms(i) = rms(y_ac) / (10^(SNR_dB(i)/20) * sqrt(1 + 10^(-SNR_dB(i)/10)));

    % Plot
    plot(t_vhd, y, colors(i), 'LineWidth', 1.5, ...
         'DisplayName', sprintf('NFIFO=%d', NFIFO_values(i)));
end

% Overlay segnale puro di riferimento
plot(t_vhd, ysignal_pure, '--k', 'LineWidth', 2, 'DisplayName', 'Segnale puro');
xlabel('Time [s]'); ylabel('Digital [-]');
legend('show', 'Location', 'southeast'); 
title('Output filtro VIVADO vs segnale puro');

% Tabella riassuntiva SNR
fprintf('\nTABELLA SNR\n');
fprintf('%-10s %-15s %-15s %-20s\n', 'NFIFO', 'Banda filtro', 'Noise RMS', 'SNR [dB]');
fs = 1/tclk;
for i = 1:3
    fcutoff = fs / (2 * NFIFO_values(i));
    fprintf('%-10d %-15.0f %-15.4f %-20.2f\n', ...
    NFIFO_values(i), fs/(2*NFIFO_values(i)), noise_rms(i), SNR_dB(i));
end

% Salva figura
saveas(gcf, 'confronto_NFIFO_all.png');

figure('Name','Frequency Response');
fs = 1/tclk;
for i = 1:3
    NFIFO = NFIFO_values(i);
    fcutoff = 0.5*fs/NFIFO;
    b = fir1(NFIFO, fcutoff/(0.5*fs), 'low');
    [hf, w] = freqz(b, 1, 2048);
    f = 0.5*fs*w/pi;
    subplot(2,1,1);
    semilogx(f, 20*log10(abs(hf)+eps), 'LineWidth', 2, ...
             'DisplayName', sprintf('NFIFO=%d', NFIFO));
    hold on; grid on; ylabel('[dB]'); title('Magnitude');
    subplot(2,1,2);
    semilogx(f, (180/pi)*angle(hf), 'LineWidth', 2);
    hold on; grid on;
    xlabel('Frequency [Hz]'); ylabel('[deg]'); title('Phase');
end
subplot(2,1,1); legend('show');
saveas(gcf, 'frequency_response_all.png');

%% Plot evoluzione rumore residuo (stima diretta della fondamentale dai dati)
figure('Name','Residual Noise Evolution');
hold on; grid on;
colors_noise = ['r','g','b'];

c_ref = cos(2*pi*f0*t_vhd);
s_ref = sin(2*pi*f0*t_vhd);

for i = 1:3
    NFIFO = NFIFO_values(i);

    d = importdata(strcat(mypath, filenames{i}));
    y = bin2dec(num2str(d));
    y = double(y(1:N_vhd))';
    y_ac = y - mean(y);

    % Stima ampiezza e fase REALI presenti nell'uscita (Fourier projection)
    a_coef = 2/length(y_ac) * sum(y_ac .* c_ref);
    b_coef = 2/length(y_ac) * sum(y_ac .* s_ref);
    fundamental_fit = a_coef*c_ref + b_coef*s_ref;

    noise_residual = y_ac - fundamental_fit;

    plot(t_vhd, noise_residual, colors_noise(i), 'LineWidth', 1.0, ...
         'DisplayName', sprintf('NFIFO=%d', NFIFO));
end

xlabel('Time [s]');
ylabel('Residual Noise [LSB]');
title('Residual Noise Evolution after Filtering');
lgd = legend('show');
lgd.Location = 'best';

saveas(gcf, 'noise_evolution.png');