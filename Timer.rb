#
#
#This class is part of the scheduler actions Rubye.
#Copyright Matheus Lessa <mlessadev@gmail.com>
#
#
#
#Main Author: Matheus Lessa #{MLessa}
#Other collaborators: 


class Timer < Thread

def initialize (ano,mes,dia,hora,minuto,modo,comando)  
@ano = ano.to_i
@mes = mes.to_i
@dia = dia.to_i
@hora = hora.to_i
@minuto = minuto.to_i
@comando = comando.to_s

# Quando modo=0 o usuario selecionou um dia e uma hora para a execucao da acao
# Quando modo=1 o usuario escolheu executar a acao apos tempo determinado

#<comment>
# Tudo bem, a rotina que controla quando a acao sera executada está 
# esteticamente horrorosa, porém foi a melhor maneira que eu encontrei
# pra econimizar memoria.Caso alguém saiba como implementar isso de melhor
# maneira será MUITO bem vindo
#</comment>
 
  
  case modo
    when 0
      super do
          exec=false      
          while Time.now.year != @ano
           sleep 1
          end
          while Time.now.year == @ano && !exec 
            while Time.now.month == @mes && !exec
              while Time.now.day == @dia && !exec
               while Time.now.hour == @hora && !exec 
                while Time.now.min == @minuto && !exec
                  system "sudo #{@comando}"         
                  exec = true              
                end             
                sleep 1
               end            
              sleep 1
              end
             sleep 1
             end 
            sleep 1   
           end    
      end          
  when 1  
      super do
        timeInSeconds = @hora*3600 + @minuto*60 
        control=0
        while control < timeInSeconds
          sleep 1
          control+=1
        end
        system "sudo #{@comando}"
     end  
end
  
end
end

