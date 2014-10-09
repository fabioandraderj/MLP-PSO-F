%%%%%%% FABIO ANDRADE %%%%%%%%%
% fabio@ieee.org
% Disserta��o CEFET/RJ 2014
% OTIMIZA��O POR ENXAME DE PART�CULAS APLICADA AO DESENVOLVIMENTO 
% DE MODELOS NEURAIS PARA SUPORTE AO DIAGN�STICO DE TUBERCULOSE PULMONAR


clear all;

load sintomas_cluster_junto_TODOSFEATURES.mat

clusters=1; %escolhe a quantidade de clusters
contador=0;



for a=1:4
    %CARREGA O CONJUNTO DE DESENVOLVIMENTO (TREINO/VAL) A SER UTILIZADO
    fold=a; %escolhe de 1 a 4 qual o conjunto de treino usar
    tst_tb_pos=[];
    tst_tb_neg=[];
    
    %Monta conjunto de teste
    for cluster=1:clusters
        tst_tb_pos=[tst_tb_pos;treino_val_teste{clusters}.teste_pos{fold}{cluster}];
        tst_tb_neg=[tst_tb_neg;treino_val_teste{clusters}.teste_neg{fold}{cluster}];
    end
    
    %Realiza o procedimento de sorteio e treinamento 10 vezes
    for k=1:10




for cluster=1:clusters
    
    % Separa o conjunto que ser�o utilizado no treinamento em 5-fold
Indices_pos{cluster}=crossvalind('Kfold',size(treino_val_teste{clusters}.treino_val_pos{fold}{cluster},1),5);
Indices_neg{cluster}=crossvalind('Kfold',size(treino_val_teste{clusters}.treino_val_neg{fold}{cluster},1),5);


end



% Repete para cada conjunto de valida��o
for i=1:5
    
treino_tb_pos=[];
treino_tb_neg=[];
val_tb_pos=[];
val_tb_neg=[];

val2_tb_pos=[];
val2_tb_neg=[];
    
    %monta conjuntos de treino e valida��o
    for cluster=1:clusters
        val_Ind_pos{cluster}=find(Indices_pos{cluster}==i);
        val_Ind_neg{cluster}=find(Indices_neg{cluster}==i);
        treino_Ind_pos{cluster}=find(Indices_pos{cluster}~=i);
        treino_Ind_neg{cluster}=find(Indices_neg{cluster}~=i); 
        
        
        treino_tb_pos=[treino_tb_pos;treino_val_teste{clusters}.treino_val_pos{fold}{cluster}(treino_Ind_pos{cluster},:)];
        treino_tb_neg=[treino_tb_neg;treino_val_teste{clusters}.treino_val_neg{fold}{cluster}(treino_Ind_neg{cluster},:)];
        
        val_tb_pos=[val_tb_pos;treino_val_teste{clusters}.treino_val_pos{fold}{cluster}(val_Ind_pos{cluster},:)];
        val_tb_neg=[val_tb_neg;treino_val_teste{clusters}.treino_val_neg{fold}{cluster}(val_Ind_neg{cluster},:)];
  end
        
        
        %Replica os dados de tb_pos
        treino_tb_pos=[treino_tb_pos;treino_tb_pos];  
        val_tb_pos=[val_tb_pos;val_tb_pos]; 
        
        %Define os dados e os alvos de treino e valida��o
        alvos_treino=[ones(size(treino_tb_pos,1),1); -ones(size(treino_tb_neg,1),1)];
        dados_treino=[treino_tb_pos;treino_tb_neg];
        alvos_val=[ones(size(val_tb_pos,1),1); -ones(size(val_tb_neg,1),1)];
        dados_val=[val_tb_pos;val_tb_neg];
        
        % NORMALIZAR IDADE
        media=mean(dados_treino(:,1));
        desvio=std(dados_treino(:,1));

        dados_treino(:,1)=(dados_treino(:,1)-media)/desvio;
        treino_tb_pos(:,1)=(treino_tb_pos(:,1)-media)/desvio;
        treino_tb_neg(:,1)=(treino_tb_neg(:,1)-media)/desvio;
        dados_val(:,1)=(dados_val(:,1)-media)/desvio;
        val_tb_pos(:,1)=(val_tb_pos(:,1)-media)/desvio;
        val_tb_neg(:,1)=(val_tb_neg(:,1)-media)/desvio;
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % REPETIR 5x e salvar rede com AUC de valida��o mais pr�x da m�dia

        area_max_PSO=0;
        

        %%%%%%%%%%%%%%%%%%%%%%%%%%%MLP-PSO
        N=20; %m�ximo de neur�nios na camada intermedi�ria da rede
        Inputs=size(treino_val_teste{1}.teste_pos{1}{1},2); %numero de features (vari�veis) da rede
        popsize = 25;   % Tamanho da popula��o
        npar = N+Inputs*N+N*Inputs+N+N+1+N; % Dimens�o do problema (n�mero de vari�veis da rede neural)
        maxit = 600; % N�mero m�ximo de itera��es
        c1 = 2; % Par�metro pessoal
        c2 = 2; % Par�metro social
        K=1; % Fator de constri��o
%        w=0.5; %Fator de In�rcia ser� variado linearmente
        lb=-1; ub=1; %limites do dom�nio
        lv=-1; uv=1; %limites da velocidade
        
       %rodar cinco vezes e pegar o mais pr�x da m�dia
       for i_PSO=1:5
                 
            % Inicializando as part�culas e as velocidades
%             par=random('Normal',(ub+lb)/2,(abs(ub-lb))/2,popsize,npar); % Inicia as part�culas com valores aleat�rios gaussianos
            par=random('unif',lb,ub,popsize,npar); % Inicia as part�culas com valores aleat�rios uniformes
            par(par<lb)=lb; %limita a posi��o das part�culas pelos limites do dom�nio
            par(par>ub)=ub;
            vel = rand(popsize,npar);   % velocidades iniciais aleat�rias uniformes
            vel(vel<lv)=lv; %limita as velocidades
            vel(vel>uv)=uv;

            %AVALIA��O INICIAL
            cost = avalia_PSO(par,treino_tb_pos,treino_tb_neg,N,Inputs);
            
%%%%%%%%%%%%%%%%%%%%%%%%%% para gr�fico de converg�ncia
%             minc=0;
%             meanc=0;
%             globalmin=0;
%             minc_val=0;
%             minc_tst=0;
%             minc(1)=min(cost); % f(x) m�nimo
%             meanc(1)=mean(cost); % f(x) m�dio
%             globalmin=minc(1); % Inicializa o f(x) do m�nimo global
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Inicializa o m�nimo local de cada part�cula
            pbest = par;    % inicializa��o da posi��o do primeiro m�nimo local
            localcost = cost;  % f(x) m�nimo local
            % Encontrando a melhor posi��o inicial
            [globalcost,indx] = min(cost);
            gbest=par(indx,:);
            
            %determina a itera��o que come�a a avalia��o da AUC de val
            ultimo=160;
            
            iter=0;
%             gLoss=0; %crit�rio de parada do MLP-PSO n�o utilizado
%             validacoes=5;
%             while (falhas<validacoes) && (iter<maxit) && (gLoss<5)

            %parada apenas por n�mero de itera��es
            while (iter<maxit)
           
                iter = iter + 1;
                 w=(0.9-0.4)*0.4*(maxit-iter)/maxit; %Fator de In�rcia variado linearmente
                
                r1 = rand(popsize,npar);    % valores aleat�rios entre 0 e 1
                r2 = rand(popsize,npar);    % valores aleat�rios entre 0 e 1
                vel = K*(w*vel + c1 *r1.*(pbest-par) + c2*r2.*(ones(popsize,1)*gbest-par));
                vel(vel<lv)=lv; %limita as velocidades
                vel(vel>uv)=uv;

                % Atualiza as posi��es
                par = par + vel;    % atualiza a posi��o das particulas
                par(par<lb)=lb;     %limita as part�culas pelos limites do dom�nio
                par(par>ub)=ub;

                % Avalia o novo enxame
                cost = avalia_PSO(par,treino_tb_pos,treino_tb_neg,N,Inputs);   % Calcula f(x) das part�culas
                
                % Atualiza a posi��o do melhor local de cada part�cula
                bettercost = cost < localcost;
                localcost = localcost.*not(bettercost) + cost.*bettercost;
                pbest(find(bettercost),:) = par(find(bettercost),:);

                % Atualiza a posi��o do melhor global
                [temp, t] = min(localcost);
                if temp<globalcost
                gbest=par(t,:); indx=t; globalcost=temp;
                end
                
                %resultados
%                  [iter globalcost] % exibe o resultado em cada itera��o
%%%%%%%%%%%%%%%%%%%%%%%%%%%% para gr�fico
%                 minc(iter+1)=min(cost); % m�nimo da itera��o
%                 globalmin(iter+1)=globalcost; % melhor f(x) at� a itera��o
%                 meanc(iter+1)=mean(cost); % f(x) m�dio da itera��o
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                %Escolha da rede
                
                if ~rem(iter,1) && (iter>160)
                cost_val=avalia_PSO2(gbest,val_tb_pos,val_tb_neg,N,Inputs);

                if (iter>=161) && (iter-ultimo==1)
                    ultimo=iter;
                    if iter==161
                        melhor_val=cost_val;
                        PSO=gbest;
                        melhor_iter=iter;
                    end
                   
                if cost_val<melhor_val
                    melhor_val=cost_val;
                    falhas=0;
                    PSO=gbest;
                    melhor_iter=iter;
                else
%                    gLoss=100*((cost_val/melhor_val)-1) %criterios de
%                    parada do MLP-PSO n�o utilizados
%                    falhas=falhas+1
                end
                
                end
             
                
%%%%%%%%%%%%%%%%% PARA GR�FICO
%         tst_tb_pos2=tst_tb_pos;
%         tst_tb_neg2=tst_tb_neg;
%         tst_tb_pos2(:,1)=(tst_tb_pos2(:,1)-media)/desvio;
%         tst_tb_neg2(:,1)=(tst_tb_neg2(:,1)-media)/desvio;  
%           cost_tst=avalia_PSO2(gbest,tst_tb_pos2,tst_tb_neg2,N,Inputs);
%               minc_val(iter+1)=cost_val; % m�nimo da itera��o
%                minc_tst(iter+1)=cost_tst;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               
                end

            end
            
            modelos{i_PSO}=PSO;
            melhor_val_area(i_PSO)=1-melhor_val;
            miter(i_PSO)=melhor_iter;
            
            
%%%%%%%%%%%%%% Gr�fico - Plota alguns indicadores
%         % tracejado verde - f(x) m�dio da itera��o
%         % linha azul - melhor m�nimo da itera��o
%         % ponto e virgula vermelho - gbest
%         % ponto azul - f(x) da valida��o
% 
%             figure
%             iters=0:length(minc)-1;
%             plot(iters,minc,'-',iters,meanc,':',iters,globalmin,'-.', iters,minc_val,'--',iters,minc_tst,'.');
%             axis([0 size(iters,2) 0 1])
%             xlabel('itera��o');ylabel('f(x)');
% %%%%%%%%%%%%%%%%%%%%%%%%%%
       end

        [~, idx]=min(abs(melhor_val_area - mean(melhor_val_area))); %mais proximo da media
        modelo=modelos{idx};
        melhor_iter2=miter(idx);
        
        %%% Alagoritmo de poda de vari�veis %%%%%%
        % comentar se n�o deseja retirar vari�veis
        TRN_PSO_area=1-avalia_PSO2(modelo,treino_tb_pos,treino_tb_neg,N,Inputs);
        percentual=0.995; %valor de r
        [~,~,sintomas_retirados,~]=retira_sintomas(modelo,treino_tb_pos,treino_tb_neg,N,Inputs,TRN_PSO_area,percentual);
        treino_tb_pos(:,sintomas_retirados)=0;
        treino_tb_neg(:,sintomas_retirados)=0;
        val_tb_pos(:,sintomas_retirados)=0;
        val_tb_neg(:,sintomas_retirados)=0;
        tst_tb_pos(:,sintomas_retirados)=0;
        tst_tb_neg(:,sintomas_retirados)=0;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
                
      TRN_PSO_area=1-avalia_PSO2(modelo,treino_tb_pos,treino_tb_neg,N,Inputs);
      
      VAL_PSO_area=1-avalia_PSO2(modelo,val_tb_pos,val_tb_neg,N,Inputs);  
      
      tst_tb_pos2=tst_tb_pos;
      tst_tb_pos2=tst_tb_pos;
      tst_tb_pos2(:,1)=(tst_tb_pos2(:,1)-media)/desvio;
      tst_tb_neg2(:,1)=(tst_tb_neg2(:,1)-media)/desvio;  
      TST_PSO_area=1-avalia_PSO2(modelo,tst_tb_pos2,tst_tb_neg2,N,Inputs);
  
      H_ind=find(modelo(1,1:N)<=0); %neuronios zerados
      C1_ind=find(modelo(1,N+1:N+Inputs*N)<=0); %conex�es n�o ativas

    
contador=contador+1
area_PSO_anova{clusters}.resultado(contador,1)=i;
area_PSO_anova{clusters}.resultado(contador,2)=VAL_PSO_area;
area_PSO_anova{clusters}.resultado(contador,3)=a;
area_PSO_anova{clusters}.resultado(contador,4)=TRN_PSO_area;
area_PSO_anova{clusters}.resultado(contador,5)=TST_PSO_area;
area_PSO_anova{clusters}.resultado(contador,6)=melhor_iter2;
area_PSO_anova{clusters}.resultado(contador,7)=N-size(H_ind,2);
area_PSO_anova{clusters}.resultado(contador,8)=34-size(sintomas_retirados,2);
area_PSO_anova{clusters}.modelos{contador,1}=modelo;
area_PSO_anova{clusters}.media(contador)=media;
area_PSO_anova{clusters}.desvio(contador)=desvio;
area_PSO_anova{clusters}.sintomas_retirados{contador,1}=sintomas_retirados;
save('area_PSO_Fabio_anova','area_PSO_anova');
        

end

end

end
          