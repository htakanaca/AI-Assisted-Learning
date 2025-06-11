% -- Arquivo: valida_limpeza_outliers.m --
% Script para testar e validar o algoritmo de limpeza de outliers.
% =>> Utiliza a chamada da fun��o "limpar_outliers" 
%     (arquivo "limpar_outliers.m" neste mesmo diret�rio).

%
% A arquitetura desta solu��o foi constru�da em um processo colaborativo 
% conduzido pela ocean�grafa Hatsue Takanaca de Decco (a "navegadora" do 
% projeto), com o suporte t�cnico e de programa��o do Gemini, um modelo de 
% linguagem da Google.
%
% A colabora��o envolveu um processo interativo de:
%
% Otimiza��o de Performance: 
% Refatora��o de loops para opera��es totalmente vetorizadas no MATLAB.
%
% Modulariza��o: 
% Convers�o da l�gica de processamento em uma fun��o reutiliz�vel 
% (limpar_outliers.m).
% 
% Boas Pr�ticas de C�digo: 
% Implementa��o de um "test suite" (conjunto de testes unit�rios) para 
% validar o algoritmo em m�ltiplos cen�rios, garantindo sua robustez.
%
% Depura��o Colaborativa: 
% An�lise e resolu��o de problemas de compatibilidade relacionados � vers�o 
% do MATLAB. 
%
% Este trabalho, realizado em junho de 2025, exemplifica uma parceria 
% humano-IA onde a especialista define a estrat�gia e os crit�rios de 
% sucesso, enquanto a IA auxilia na implementa��o t�cnica e otimiza��o.
%

%%

clear; clc; close all;

%% === 1. DEFINI��O DOS CASOS DE TESTE ===

% Vetor base "bom"
base = ones(1, 10) * 10; % Uma linha de base no valor 10

% Cen�rio 1: Pico isolado para cima
pico_cima = [base, 10.1, 15, 10.2, base]; 

% Cen�rio 2: Pico isolado para baixo
pico_baixo = [base, 9.9, 5, 10.1, base];

% Cen�rio 3: Bloco de outliers
bloco = [base, 10.1, 14, 14.1, 10.2, base];

% Cen�rio 4: Ru�do intenso (vale e pico)
ruido = [base, 10.1, 4, 16, 10.2, base];

% Cen�rio 5: Dados perfeitamente limpos
dados_limpos = [base, base];

% Cen�rio 6: Degrau
degrau = [10, 10, 10, 10, 12, 12, 12, 12];
degrau_teste = [base, degrau, base];


%% === 2. EXECU��O DOS TESTES ===

% Par�metro do teste
fator_limiar_teste = 3; % Usar um limiar mais baixo para pegar os outliers sint�ticos

% Defini��o do m�todo de interpola��o usado na fun��o de substitui��o de
% outliers:
% Escolha um dos m�todos:
% 'linear', 'spline', 'pchip', 'nearest', 'next', 'previous'
metodo_interp = ['linear'];

% Lista de todos os casos para testar
casos_de_teste = {pico_cima, pico_baixo, bloco, ruido, dados_limpos, degrau_teste};
nomes_dos_casos = {'Pico p/ Cima', 'Pico p/ Baixo', 'Bloco', 'Ru�do Intenso', 'Dados Limpos', 'Degrau'};

figure('Name', 'Valida��o do Algoritmo de Limpeza de Outliers', 'Position', [100, 100, 1200, 800]);

for k = 1:length(casos_de_teste)
    
    % Pega o dado original do caso de teste
    dado_original = casos_de_teste{k};
    
    % Roda a nossa fun��o de limpeza
    [dado_limpo, indices_modificados] = limpar_outliers(dado_original, fator_limiar_teste,metodo_interp); % A fun��o espera vetor coluna
    
    % Plota o resultado
    subplot(3, 2, k);
    hold on;
    plot(dado_original, 'o-', 'DisplayName', 'Original', 'Color', [0.7 0.7 0.7]);
    plot(dado_limpo, '*-', 'DisplayName', 'Limpo', 'LineWidth', 2, 'Color','b');
    
    % Compara se o resultado mudou (para o caso dos dados limpos)
    if isequal(dado_original, dado_limpo)
        resultado_texto = 'Dados n�o alterados (CORRETO)';
        cor_titulo = 'blue';
    else
        resultado_texto = 'Dados alterados (ESPERADO)';
        cor_titulo = 'black';
    end
    
    % T�tulo e legenda
    title(sprintf('Caso %d: %s\n(%s)', k, nomes_dos_casos{k}, resultado_texto), 'Color', cor_titulo);
    legend('show', 'Location', 'best');
    grid on;
    axis tight;
    hold off;
end

% title('Resultados da Valida��o Autom�tica', 'FontSize', 16, 'FontWeight', 'bold');

