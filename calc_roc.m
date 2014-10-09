%#############
% Funcao do Matlab para o cálculo da ROC, baseado na funcao em C.
%
% Alan Franco
%
%############

function [PD_VEC, PF_VEC, AREA]=calc_roc(limiares,dados_classe,dados_nao_classe);

PD_VEC = zeros(size(limiares,1),1);
PF_VEC = zeros(size(limiares,1),1);

	for ind_lim=1:size(limiares,1)
		limiar = limiares(ind_lim,1);

		% PD
		acum_cont_pd = 0;
		for ind_classe=1:size(dados_classe,1)
		
			if dados_classe(ind_classe,1) >= limiar
				acum_cont_pd = acum_cont_pd + 1;
			end
		end

		% PF
		acum_cont_pf = 0;
		for ind_nao_classe=1:size(dados_nao_classe,1)

			if dados_nao_classe(ind_nao_classe,1) >= limiar
				acum_cont_pf = acum_cont_pf + 1;
			end
		end
	
		PD_VEC(ind_lim,1) = acum_cont_pd/size(dados_classe,1);
		PF_VEC(ind_lim,1) = acum_cont_pf/size(dados_nao_classe,1);
	end



	% AREA    
 	AREA = -trapz(PF_VEC,PD_VEC);  %calcula a área
%   AREA = ppval(fnint(csape(PD_VEC,PF_VEC)),max(PD-VEC))
end
