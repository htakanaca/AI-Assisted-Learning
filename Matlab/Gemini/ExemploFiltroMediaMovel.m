%--------------------------------------------------------------------------
% Nome do Script: [Ex: ExemploFiltroMediaMovel.m ou ExemploFiltroPassaBaixaIIR.m]
% Descrição: Este script demonstra o funcionamento da função filter no MATLAB,
%            aplicando um [filtro de média móvel / filtro passa-baixa IIR]
%            a um sinal de exemplo.
%
% Desenvolvido com o auxílio de: Gemini (Google AI)
% Data de Criação: Junho de 2025
% Versão: 1.0
%--------------------------------------------------------------------------

% 1. Gerar um sinal de teste
Fs = 1000; % Frequência de amostragem (1000 Hz)
t = 0:1/Fs:1-1/Fs; % Vetor de tempo de 1 segundo

% Sinal com duas frequências: uma baixa (10 Hz) e uma alta (150 Hz)
freq_baixa = 10; % Hz
freq_alta = 150; % Hz
x = 0.7*sin(2*pi*freq_baixa*t) + sin(2*pi*freq_alta*t) + 0.2*randn(size(t)); % Sinal + ruído

% 2. Projetar um filtro passa-baixa Butterworth
% Ordem do filtro (complexidade). Uma ordem maior significa um filtro mais "nítido".
ordem_filtro = 4;
% Frequência de corte normalizada. Deve estar entre 0 e 1, onde 1 corresponde à frequência de Nyquist (Fs/2).
% Queremos cortar tudo acima de uns 50 Hz. Então, 50 / (Fs/2) = 50 / 500 = 0.1
freq_corte_norm = 50 / (Fs/2);

[b, a] = butter(ordem_filtro, freq_corte_norm, 'low');

% Exibir os coeficientes b e a para visualização
fprintf('Coeficientes b (numerador):\n');
disp(b);
fprintf('Coeficientes a (denominador):\n');
disp(a);

% 3. Aplicar o filtro
y = filter(b, a, x);

% 4. Plotar os resultados
figure;

subplot(2,1,1);
plot(t, x, 'b');
title('Sinal Original (10Hz + 150Hz + Ruído)');
xlabel('Tempo (s)');
ylabel('Amplitude');
grid on;

subplot(2,1,2);
plot(t, y, 'r', 'LineWidth', 1.5);
title('Sinal Filtrado (Componente de Alta Frequência Removida)');
xlabel('Tempo (s)');
ylabel('Amplitude');
grid on;

% Para uma análise mais profunda, podemos ver o espectro de frequência
figure;
N = length(x);
f = Fs*(0:(N/2))/N; % Eixo de frequência

Y_fft_x = fft(x);
P2_x = abs(Y_fft_x/N);
P1_x = P2_x(1:N/2+1);
P1_x(2:end-1) = 2*P1_x(2:end-1);

Y_fft_y = fft(y);
P2_y = abs(Y_fft_y/N);
P1_y = P2_y(1:N/2+1);
P1_y(2:end-1) = 2*P1_y(2:end-1);

subplot(2,1,1);
plot(f, P1_x, 'b');
title('Espectro de Frequência do Sinal Original');
xlabel('Frequência (Hz)');
ylabel('|X(f)|');
xlim([0 Fs/2]);
grid on;

subplot(2,1,2);
plot(f, P1_y, 'r');
title('Espectro de Frequência do Sinal Filtrado');
xlabel('Frequência (Hz)');
ylabel('|Y(f)|');
xlim([0 Fs/2]);
grid on;
