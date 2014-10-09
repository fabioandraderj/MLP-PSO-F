%%%%%%% FABIO ANDRADE %%%%%%%%%
% fabio@ieee.org
% Dissertação CEFET/RJ 2014

% FUNÇÃO QUE CALCULA A FUNÇÃO DE FITNESS DO PSO %

function [cost]=avalia_PSO(par,input_pos,input_neg,N,Inputs)
    

input_pos_neg=[input_pos;input_neg];

    H_ind=find(par(1,1:N)<=0)+N+Inputs*N;
    C1_ind=find(par(1,N+1:N+Inputs*N)<=0);
    
    X=par(1,N+1+Inputs*N:end-N);   
    X(C1_ind)=0;
    X(H_ind)=0;

    %Implementação manual da avaliação da rede
    W1=X(1:Inputs*N);
    B1=X(Inputs*N+1:Inputs*N+N);
    W2=X(Inputs*N+N+1:Inputs*N+N+N);
    B2=X(Inputs*N+N+N+1);
    
    tansig_ind=find(par(1,end-N+1:end)<=0);
    linear_ind=find(par(1,end-N+1:end)>0);
    
    
    for q=1:size(input_pos_neg,1)
        for w=1:N
             H1(q,w)=input_pos_neg(q,:)*W1(w:(size(W1,2)/Inputs):Inputs*N)'+B1(w);
        end
        H1(tansig_ind)=tansig(H1(tansig_ind));  

    end
    saidas_pos_neg=(H1*W2'+B2)';

     saidas_pos=saidas_pos_neg(1,1:size(input_pos,1));
     saidas_neg=saidas_pos_neg(1,size(input_pos,1)+1:end);

     [PSO.pd_vec,PSO.pf_vec,PSO.limiares,PSO.area]=funcao_calcula_ROC(saidas_pos,saidas_neg);  

    cost=1-PSO.area;

