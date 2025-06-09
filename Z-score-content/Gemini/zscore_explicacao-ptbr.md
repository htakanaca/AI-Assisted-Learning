Explicação didática do Modelo Gemini (Flash 2.5, em junho/2025) sobre o uso da medida estatística Z-score como método de avaliação de outliers em dados de parâmetros oceanográficos.

Referências aos scripts de substituição de outliers nos repositórios:
https://github.com/htakanaca/laboceano-bloco1-nivel-mar
https://github.com/htakanaca/laboceano-bloco2-correntes-marinhas


O Que É o Z-score (E Por Que Usamos Ele)?
O Z-score (também conhecido como escore-Z, pontuação padrão ou standard score) é uma medida estatística que descreve a posição de um ponto de dados em relação à média de um grupo de pontos, em unidades de desvio padrão.

A fórmula que você tem é exatamente a definição do Z-score:

Z= 
σ
X−μ
​
 

Onde:

X: É um ponto de dado individual (diff_nivel, no caso do script 'bloco1_n3_outliers_substitution.m').
μ: É a média (mean) da população ou amostra de dados (mean(diff_nivel)).
σ: É o desvio padrão (standard deviation) da população ou amostra de dados (std(diff_nivel)).
Para que serve o Z-score?
O Z-score tem duas finalidades principais no seu contexto:

Padronização (Escalonamento): Ele transforma os dados para uma escala comum, independentemente de suas unidades originais. Após a transformação, os dados terão:

Média = 0
Desvio Padrão = 1 Isso é o que chamamos de normalização ou padronização. É por isso que você observa que zscore_diff tem média próxima de zero e desvio padrão próximo de um.
Medir Quão "Anormal" um Ponto É: O Z-score nos diz a quantos desvios padrão um ponto de dado está da média.

Um Z-score de 0 significa que o ponto de dado é exatamente igual à média.
Um Z-score de +1 significa que o ponto de dado está 1 desvio padrão acima da média.
Um Z-score de -2 significa que o ponto de dado está 2 desvios padrão abaixo da média.

Quanto maior o valor absoluto do Z-score (seja positivo ou negativo), mais "anormal" ou incomum é aquele ponto de dado em relação ao restante do conjunto.

Por Que Você Não Vê Muita Mudança ao Subtrair a Média (mean(diff_nivel))?
Você observou que diff_nivel já está "em torno de 0" e que subtrair a média não muda muito. Isso acontece porque:

diff_nivel = diff(nivel_adcp(1:ii));: Quando você calcula a derivada (diff) de uma série temporal como o nível do mar (que é principalmente harmônico, como a maré, ou suave), o resultado diff_nivel representa as mudanças incrementais entre pontos consecutivos. Se a série é relativamente suave, essas mudanças (ou seja, diff_nivel) tenderão a oscilar em torno de zero.
Média de diff_nivel é Próxima de Zero: Se diff_nivel oscila em torno de zero, a mean(diff_nivel) também será muito próxima de zero.
Consequência: Se mean(diff_nivel) é quase zero, então (diff_nivel - mean(diff_nivel)) é quase o mesmo que diff_nivel.
No entanto, o zscore é Crucial por Causa do Desvio Padrão (std)!
Mesmo que a média seja zero, o desvio padrão (std(diff_nivel)) não será zero. E é o desvio padrão que está controlando a "escala" dos seus dados.

Ao dividir por std(diff_nivel), você está fazendo duas coisas muito importantes para a detecção de outliers:

Padronizando a Variabilidade: Você está transformando as diferenças em "unidades de desvio padrão". Isso significa que, independentemente da amplitude típica das mudanças no nível do mar (que é o que std(diff_nivel) representa), um Z-score de, digamos, 3 sempre significa "3 desvios padrão da média".
Tornando o Limiar Universal: Isso permite que você use um fator_limiar (como 2, 3, 3.5, etc.) que é universal para a detecção de outliers.
Se você disser abs(zscore_diff) >= 3, você está dizendo "quero encontrar pontos que estejam pelo menos 3 desvios padrão da média".
Sem o Z-score, você teria que usar abs(diff_nivel) >= algum_limiar_fixo. Mas esse algum_limiar_fixo dependeria da escala dos seus dados e do desvio padrão diff_nivel. Um limiar = 0.1 pode ser um outlier para uma série, mas não para outra.
Exemplo para ilustrar a importância do std:
Matlab

% Cenario A: Diferencas pequenas
diff_nivel_A = [-0.01 -0.02 0.05 0.01 -0.03 0.8]; % Um outlier 0.8
mean_A = mean(diff_nivel_A); % Cerca de 0.13
std_A = std(diff_nivel_A);   % Cerca de 0.33

zscore_diff_A = (diff_nivel_A - mean_A) / std_A;
% zscore_diff_A(6) para 0.8 seria: (0.8 - 0.13) / 0.33 = ~2.03

% Cenario B: Diferencas grandes (mesmo padrao, mas escala maior)
diff_nivel_B = [-10 -20 50 10 -30 800]; % O mesmo outlier, mas escala 1000x maior
mean_B = mean(diff_nivel_B); % Cerca de 133
std_B = std(diff_nivel_B);   % Cerca de 330

zscore_diff_B = (diff_nivel_B - mean_B) / std_B;
% zscore_diff_B(6) para 800 seria: (800 - 133) / 330 = ~2.02 (QUASE O MESMO Z-SCORE!)
Nesse exemplo, o valor absoluto do outlier (0.8 vs 800) mudou drasticamente, mas o Z-score permaneceu praticamente o mesmo. Isso acontece porque o std se ajusta à escala dos dados.

Conclusão para o seu script ('bloco1_n3_outliers_substitution.m'):
Você está usando o Z-score corretamente para:

Padronizar as diferenças: Transforma-as em unidades de desvio padrão.
Permitir um limiar universal: O fator_limiar agora significa "quantos desvios padrão de distância da média" e funciona para diferentes escalas de dados de nível do mar (diferentes amplitudes de ruído ou pequenas variações).
Detectar pontos "incomuns": Um grande Z-score indica um ponto que se afasta muito do comportamento típico das mudanças.
Então, mesmo que a média seja pequena, a divisão pelo desvio padrão é o que torna o Z-score uma ferramenta poderosa e escalável para detecção de outliers.

