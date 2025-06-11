% -- Arquivo: valida_limpeza_outliers.m --
% Script para testar e validar o algoritmo de limpeza de outliers.
% =>> Utiliza a chamada da função "limpar_outliers" 
%     (arquivo "limpar_outliers.m" neste mesmo diretório).

%
% A arquitetura desta solução foi construída em um processo colaborativo 
% conduzido pela oceanógrafa Hatsue Takanaca de Decco (a "navegadora" do 
% projeto), com o suporte técnico e de programação do Gemini, um modelo de 
% linguagem da Google.
%
% A colaboração envolveu um processo interativo de:
%
% Otimização de Performance: 
% Refatoração de loops para operações totalmente vetorizadas no MATLAB.
%
% Modularização: 
% Conversão da lógica de processamento em uma função reutilizável 
% (limpar_outliers.m).
% 
% Boas Práticas de Código: 
% Implementação de um "test suite" (conjunto de testes unitários) para 
% validar o algoritmo em múltiplos cenários, garantindo sua robustez.
%
% Depuração Colaborativa: 
% Análise e resolução de problemas de compatibilidade relacionados à versão 
% do MATLAB. 
%
% Este trabalho, realizado em junho de 2025, exemplifica uma parceria 
% humano-IA onde a especialista define a estratégia e os critérios de 
% sucesso, enquanto a IA auxilia na implementação técnica e otimização.
%

%%

clear; clc; close all;

%% === 1. DEFINIÇÃO DOS CASOS DE TESTE ===

% Vetor base "bom"
base = ones(1, 10) * 10; % Uma linha de base no valor 10

% Cenário 1: Pico isolado para cima
pico_cima = [base, 10.1, 15, 10.2, base]; 

% Cenário 2: Pico isolado para baixo
pico_baixo = [base, 9.9, 5, 10.1, base];

% Cenário 3: Bloco de outliers
bloco = [base, 10.1, 14, 14.1, 10.2, base];

% Cenário 4: Ruído intenso (vale e pico)
ruido = [base, 10.1, 4, 16, 10.2, base];

% Cenário 5: Dados perfeitamente limpos
dados_limpos = [base, base];

% Cenário 6: Degrau
degrau = [10, 10, 10, 10, 12, 12, 12, 12];
degrau_teste = [base, degrau, base];


%% === 2. EXECUÇÃO DOS TESTES ===

% Parâmetro do teste
fator_limiar_teste = 3; % Usar um limiar mais baixo para pegar os outliers sintéticos

% Definição do método de interpolação usado na função de substituição de
% outliers:
% Escolha um dos métodos:
% 'linear', 'spline', 'pchip', 'nearest', 'next', 'previous'
metodo_interp = ['linear'];

% Lista de todos os casos para testar
casos_de_teste = {pico_cima, pico_baixo, bloco, ruido, dados_limpos, degrau_teste};
nomes_dos_casos = {'Pico p/ Cima', 'Pico p/ Baixo', 'Bloco', 'Ruído Intenso', 'Dados Limpos', 'Degrau'};

figure('Name', 'Validação do Algoritmo de Limpeza de Outliers', 'Position', [100, 100, 1200, 800]);

for k = 1:length(casos_de_teste)
    
    % Pega o dado original do caso de teste
    dado_original = casos_de_teste{k};
    
    % Roda a nossa função de limpeza
    [dado_limpo, indices_modificados] = limpar_outliers(dado_original, fator_limiar_teste,metodo_interp); % A função espera vetor coluna
    
    % Plota o resultado
    subplot(3, 2, k);
    hold on;
    plot(dado_original, 'o-', 'DisplayName', 'Original', 'Color', [0.7 0.7 0.7]);
    plot(dado_limpo, '*-', 'DisplayName', 'Limpo', 'LineWidth', 2, 'Color','b');
    
    % Compara se o resultado mudou (para o caso dos dados limpos)
    if isequal(dado_original, dado_limpo)
        resultado_texto = 'Dados não alterados (CORRETO)';
        cor_titulo = 'blue';
    else
        resultado_texto = 'Dados alterados (ESPERADO)';
        cor_titulo = 'black';
    end
    
    % Título e legenda
    title(sprintf('Caso %d: %s\n(%s)', k, nomes_dos_casos{k}, resultado_texto), 'Color', cor_titulo);
    legend('show', 'Location', 'best');
    grid on;
    axis tight;
    hold off;
end

% title('Resultados da Validação Automática', 'FontSize', 16, 'FontWeight', 'bold');

