% -- Arquivo: limpar_outliers.m (Versão Genérica com múltiplas saídas e método de interpolação customizável) --

function [cleaned_series, outlier_indices] = limpar_outliers(input_series, threshold_factor,method_interp)
%
% REMOVE_OUTLIERS
%
% Remove outliers from a time series by linear interpolation.
%
%   cleaned_series = LIMPAR_OUTLIERS(input_series, threshold_factor)
%   detecta outliers na série de entrada (input_series) e os substitui.
%
%   A detecção é baseada no Z-score da primeira derivada da série. Pontos
%   adjacentes a uma derivada cujo Z-score excede o threshold_factor são
%   marcados como outliers e substituídos por interpolação linear usando
%   os pontos vizinhos válidos.
%   Uma explicação sobre o Z-score com abordagem mais didática, gerada em
%   colaboração com o Gemini - modelo de linguagem da Google, pode ser
%   encontrada em:
%   https://github.com/htakanaca/AI-Assisted-Learning/blob/main/Z-score-content/Gemini/zscore_explicacao-ptbr.md
%
%   INPUTS:
%   input_series: Vetor (coluna ou linha) com os dados da série temporal.
%   threshold_factor: Fator limiar para o Z-score (ex: 3, 4, 5).
%   method_interp: String com o método para interp1 (ex: 'linear', 'spline', 'pchip').
%
%   OUTPUT:
%   cleaned_series: Vetor com a série limpa, do mesmo tamanho da entrada.
%   outlier_indices: Índices das posições dos outliers modificados. Se não
%   houve modificação, será um vetor vazio.
%
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


%% --- Verificação dos dados de entrada e declaração de variáveis ---
% Garante que a entrada seja um vetor coluna para consistência interna
is_row = isrow(input_series);
if is_row
    input_series = input_series';
end

% --- VALIDAÇÃO DOS ARGUMENTOS DE ENTRADA ---
series_length = length(input_series);
series_indices = (1:series_length)';
% Inicia a saída como uma cópia da entrada:
cleaned_series = input_series;
% Inicializa a saída de índices como vazia:
outlier_indices = []; 
% Define os métodos de interpolação que permitimos:
allowed_methods = {'linear', 'spline', 'pchip', 'nearest', 'next', 'previous'};

% Verifica se o método fornecido está na lista de permitidos:
if ~ismember(lower(method_interp), allowed_methods)
    % Se não estiver, lança um erro informativo:
    error(['\n\n' ...
        '******************************\n' ...
        '***       ATENÇÃO!         ***\n' ...
        '******************************\n' ...
        'Método de interpolação inválido. Escolha um dos seguintes: %s'], strjoin(allowed_methods, ', '));
end
%% --- Detecção dos índices de Outliers ---
% Calcula a primeira derivada (diff) e seu Z-score:
diff_series = diff(input_series);
series_std = std(diff_series);

% Evita divisão por zero se a série for constante:
if series_std > 0
    zscore_diff = (diff_series - mean(diff_series)) / series_std;
else
    zscore_diff = zeros(size(diff_series)); % Sem variação, sem outliers
end

% Detecção de candidatos a outlier:
is_candidate = abs(zscore_diff) >= threshold_factor;

if ~any(is_candidate)
    % Se a entrada era uma linha, retorna uma linha:
    if is_row
        cleaned_series = cleaned_series';
    end
    return; % Retorna a série original se nada for encontrado
end

%% --- Construção da Máscara de Outliers ---
% Definição do início de fim do grupo de outlier:
starts = find(diff([false; is_candidate]) == 1);
ends   = find(diff([is_candidate; false]) == -1);

% Cria uma máscara lógica para os pontos de outliers:
outlier_mask = false(size(input_series));
for i = 1:length(starts)
    outlier_mask(starts(i) : ends(i) + 1) = true;
end

outlier_mask(1) = false;
outlier_mask(end) = false;

%% --- Substituição por Interpolação ---
if any(outlier_mask)
    % Encontra e define os índices para a saída:
    outlier_indices = find(outlier_mask);    
    % Marca os pontos com dados bons:
    good_points_mask = ~outlier_mask;
    good_indices = series_indices(good_points_mask);
    good_values  = input_series(good_points_mask);
    
    % Interpola para encontrar os novos valores para os pontos marcados
    interpolated_values = interp1(good_indices, good_values, series_indices(outlier_mask), method_interp);
    
    % Guarda os dados com outliers substituídos na variável de saída:
    cleaned_series(outlier_mask) = interpolated_values;
end

% Garante que o formato da saída (linha/coluna) seja o mesmo da entrada:
if is_row
    cleaned_series = cleaned_series';
    outlier_indices = outlier_indices';
end

end