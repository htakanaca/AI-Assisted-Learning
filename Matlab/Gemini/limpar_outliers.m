% -- Arquivo: limpar_outliers.m (Vers�o Gen�rica com m�ltiplas sa�das e m�todo de interpola��o customiz�vel) --

function [cleaned_series, outlier_indices] = limpar_outliers(input_series, threshold_factor,method_interp)
%
% REMOVE_OUTLIERS
%
% Remove outliers from a time series by linear interpolation.
%
%   cleaned_series = LIMPAR_OUTLIERS(input_series, threshold_factor)
%   detecta outliers na s�rie de entrada (input_series) e os substitui.
%
%   A detec��o � baseada no Z-score da primeira derivada da s�rie. Pontos
%   adjacentes a uma derivada cujo Z-score excede o threshold_factor s�o
%   marcados como outliers e substitu�dos por interpola��o linear usando
%   os pontos vizinhos v�lidos.
%   Uma explica��o sobre o Z-score com abordagem mais did�tica, gerada em
%   colabora��o com o Gemini - modelo de linguagem da Google, pode ser
%   encontrada em:
%   https://github.com/htakanaca/AI-Assisted-Learning/blob/main/Z-score-content/Gemini/zscore_explicacao-ptbr.md
%
%   INPUTS:
%   input_series: Vetor (coluna ou linha) com os dados da s�rie temporal.
%   threshold_factor: Fator limiar para o Z-score (ex: 3, 4, 5).
%   method_interp: String com o m�todo para interp1 (ex: 'linear', 'spline', 'pchip').
%
%   OUTPUT:
%   cleaned_series: Vetor com a s�rie limpa, do mesmo tamanho da entrada.
%   outlier_indices: �ndices das posi��es dos outliers modificados. Se n�o
%   houve modifica��o, ser� um vetor vazio.
%
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


%% --- Verifica��o dos dados de entrada e declara��o de vari�veis ---
% Garante que a entrada seja um vetor coluna para consist�ncia interna
is_row = isrow(input_series);
if is_row
    input_series = input_series';
end

% --- VALIDA��O DOS ARGUMENTOS DE ENTRADA ---
series_length = length(input_series);
series_indices = (1:series_length)';
% Inicia a sa�da como uma c�pia da entrada:
cleaned_series = input_series;
% Inicializa a sa�da de �ndices como vazia:
outlier_indices = []; 
% Define os m�todos de interpola��o que permitimos:
allowed_methods = {'linear', 'spline', 'pchip', 'nearest', 'next', 'previous'};

% Verifica se o m�todo fornecido est� na lista de permitidos:
if ~ismember(lower(method_interp), allowed_methods)
    % Se n�o estiver, lan�a um erro informativo:
    error(['\n\n' ...
        '******************************\n' ...
        '***       ATEN��O!         ***\n' ...
        '******************************\n' ...
        'M�todo de interpola��o inv�lido. Escolha um dos seguintes: %s'], strjoin(allowed_methods, ', '));
end
%% --- Detec��o dos �ndices de Outliers ---
% Calcula a primeira derivada (diff) e seu Z-score:
diff_series = diff(input_series);
series_std = std(diff_series);

% Evita divis�o por zero se a s�rie for constante:
if series_std > 0
    zscore_diff = (diff_series - mean(diff_series)) / series_std;
else
    zscore_diff = zeros(size(diff_series)); % Sem varia��o, sem outliers
end

% Detec��o de candidatos a outlier:
is_candidate = abs(zscore_diff) >= threshold_factor;

if ~any(is_candidate)
    % Se a entrada era uma linha, retorna uma linha:
    if is_row
        cleaned_series = cleaned_series';
    end
    return; % Retorna a s�rie original se nada for encontrado
end

%% --- Constru��o da M�scara de Outliers ---
% Defini��o do in�cio de fim do grupo de outlier:
starts = find(diff([false; is_candidate]) == 1);
ends   = find(diff([is_candidate; false]) == -1);

% Cria uma m�scara l�gica para os pontos de outliers:
outlier_mask = false(size(input_series));
for i = 1:length(starts)
    outlier_mask(starts(i) : ends(i) + 1) = true;
end

outlier_mask(1) = false;
outlier_mask(end) = false;

%% --- Substitui��o por Interpola��o ---
if any(outlier_mask)
    % Encontra e define os �ndices para a sa�da:
    outlier_indices = find(outlier_mask);    
    % Marca os pontos com dados bons:
    good_points_mask = ~outlier_mask;
    good_indices = series_indices(good_points_mask);
    good_values  = input_series(good_points_mask);
    
    % Interpola para encontrar os novos valores para os pontos marcados
    interpolated_values = interp1(good_indices, good_values, series_indices(outlier_mask), method_interp);
    
    % Guarda os dados com outliers substitu�dos na vari�vel de sa�da:
    cleaned_series(outlier_mask) = interpolated_values;
end

% Garante que o formato da sa�da (linha/coluna) seja o mesmo da entrada:
if is_row
    cleaned_series = cleaned_series';
    outlier_indices = outlier_indices';
end

end