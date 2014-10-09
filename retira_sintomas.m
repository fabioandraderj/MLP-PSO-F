function [percentual_do_ultimo,percentual_do_primeiro,idx,cost_ultimo]=retira_sintomas(modelo,input_pos,input_neg,N,Inputs,AUC,percentual)

          tb_pos3=input_pos;
          tb_neg3=input_neg;
          idx=[];
          k=1;
          
      while k>0

      parfor m=1:size(tb_pos3,2)
          tb_pos4=tb_pos3;
          tb_neg4=tb_neg3;
          tb_pos4(:,m)=0;
          tb_neg4(:,m)=0;
          
          cost(m)=1-avalia_PSO2(modelo,tb_pos4,tb_neg4,N,Inputs);
      end
      
      cost(idx)=0;
      
          [~,idx(k)]=min(abs(cost-AUC));
          if k==1
          percentual_do_ultimo(k)=cost(idx(k))/AUC;
          else
          percentual_do_ultimo(k)=cost(idx(k))/cost_ultimo(k-1);
          end
          
        
          percentual_do_primeiro(k)=cost(idx(k))/AUC;
          
          tb_pos3(:,idx(k))=0;
          tb_neg3(:,idx(k))=0;
          
          cost_ultimo(k)=1-avalia_PSO2(modelo,tb_pos3,tb_neg3,N,Inputs);


          if ((percentual_do_primeiro(k)<percentual) | (percentual_do_primeiro>2-percentual))
          percentual_do_ultimo(k)=[];
          percentual_do_primeiro(k)=[];
          cost_ultimo(k)=[];
          idx(k)=[];
          k=0;
          else
          k=k+1;
          end
          
      end
         