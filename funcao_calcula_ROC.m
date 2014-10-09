%%%%%%% FABIO ANDRADE %%%%%%%%%
% fabio@ieee.org
% Dissertação CEFET/RJ 2014

% FUNÇÃO QUE CALCULA A ÁREA DA ROC %

function [pd_vec,pf_vec,limiares,area]=funcao_calcula_ROC(dados_classe,dados_nao_classe)
%
% [pd_vec,pf_vec,limiares,area]=funcao_calcula_ROC(dados_classe,dados_nao_classe);
%

% Medidas
tam_classe=length(dados_classe);
tam_nao_classe=length(dados_nao_classe);
tam_total=tam_nao_classe+tam_classe;

mat=zeros(tam_total,3);

% Concatena CLASSE e NAO-CLASSE
mat(:,1)=[dados_classe'; dados_nao_classe'];
mat(1:tam_classe,2)=1;
mat(tam_total-tam_nao_classe+1:tam_total,3)=1;

mat=sortrows(mat);
id_classe= mat(:,2)==1;
id_nao_classe= mat(:,3)==1;

% Monta Classe e Nao-Classe ordenados
dados_classe=mat(id_classe,1);
dados_nao_classe=mat(id_nao_classe,1);

% Monta limiares
limiares=mean([mat(2:end,1) mat(1:end-1,1)],2);
limiares=[mat(1,1)-0.5; limiares; mat(end,1)+0.5];

[pd_vec,pf_vec,area]=calc_roc(limiares,dados_classe,dados_nao_classe);



