%%%%%%% FABIO ANDRADE %%%%%%%%%
% fabio@ieee.org
% Dissertação CEFET/RJ 2014

% FUNÇÃO QUE CALCULA A FUNÇÃO DE FITNESS DO PSO %

function [cost]=avalia_PSO(par,input_pos,input_neg,N,Inputs)

input_pos_neg=[input_pos;input_neg];

parfor i=1:size(par,1) %processamento paralelo
    
    H_ind=find(par(i,1:N)<=0)+N+Inputs*N;
    C1_ind=find(par(i,N+1:N+Inputs*N)<=0);
    
    X=par(i,N+1+Inputs*N:end-N);   
    X(C1_ind)=0; %desabilita conexões não utilizadas
    X(H_ind)=0;  %zera neurônios não utilizados

    %Implementação manual da avaliação da rede
    W1=X(1:Inputs*N);
    B1=X(Inputs*N+1:Inputs*N+N);
    W2=X(Inputs*N+N+1:Inputs*N+N+N);
    B2=X(Inputs*N+N+N+1);
    
    tansig_ind=find(par(i,end-N+1:end)<=0); %vetor F
    linear_ind=find(par(i,end-N+1:end)>0);  %vetor F
    
    
    H1=zeros(size(input_pos_neg,1),N);    
for q=1:size(input_pos_neg,1)
        for w=1:N
             H1(q,w)=input_pos_neg(q,:)*W1(w:(size(W1,2)/Inputs):Inputs*N)'+B1(w);
        end
        
    end

    H1(tansig_ind)=tansig(H1(tansig_ind));  %aplica tansig

    
     saidas_pos_neg{i}=(H1*W2'+B2)';
     saidas_pos{i}=saidas_pos_neg{i}(1,1:size(input_pos,1));
     saidas_neg{i}=saidas_pos_neg{i}(1,size(input_pos,1)+1:end);
     
     
     [~,~,~,area(i)]=funcao_calcula_ROC(saidas_pos{i},saidas_neg{i});  
     
end

     cost=1-area;

