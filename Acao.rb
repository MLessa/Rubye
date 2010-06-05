#
#
#This class is part of the scheduler actions Rubye.
#Copyright Matheus Lessa <mlessadev@gmail.com>
#
#
#
#Main Author: Matheus Lessa #{MLessa}
#Other collaborators:

class Acao
 require 'yaml'
 attr_accessor :nome,:comando
 
 
 def initialize(nome,comando)
   @nome = nome
   @comando = comando
 end
  
  #metodo que retorna um vetor com todas as acoes cadastradas
  def Acao.get_all
    return YAML.load_file("actions.yml")
  end
  
  #metodo que cria o arquivo actions.yml e escreve as acoes padrao
  def Acao.write_default
    acao_halt = Acao.new("Desligar o computador","halt")
    acao_reboot = Acao.new("Reiniciar o computador","reboot")
    File.open("actions.yml","w") do |f|
      YAML.dump([acao_halt,acao_reboot],f)
    end
  end
  
  #metodo que carrega o comboBox recebido por parametro com os nomes das
  #acoes cadastradas
  def Acao.load_combo_actions(comboBox)
    actions_array = Acao.get_all
    (0..actions_array.length).each {comboBox.remove_text(0)}
    actions_array.each {|acao| comboBox.append_text(acao.nome)}
    comboBox.set_active(0)
  end
  
  #metodo responsavel por adicionar uma nova acao ao arquivo
  def Acao.add(new_acao)
    actions_array = get_all
    actions_array += [new_acao]
    rewrite_file(actions_array)
  end
  
  #metodo responsavel por apagar do arquivo a acao cujo nome
  #seja recebido por parametro
  def Acao.delete(nome_acao)    
    actions_array = get_all
    actions_array.each do |acao|      
      if acao.nome == nome_acao
        actions_array -= [acao]
        Acao.rewrite_file(actions_array)
        break
      end     
    end
  end
  
  #metodo responsavel por editar uma acao previamente salva
  def Acao.edit(acao_nome,acao_novoNome,acao_novoComando)
    actions_array = get_all
    actions_array.each do |acao|
      if acao.nome == acao_nome
        acao.nome = acao_novoNome
        acao.comando = acao_novoComando
        rewrite_file(actions_array)
        break
      end
    end    
  end
  
  # metodo responsavel por retornar o objeto Acao cujo nome
  # tenha sido passado pelo parametro
  def Acao.get_acao(acao_nome)
    actions_array = get_all
    actions_array.each do |acao|
      if acao.nome == acao_nome
        return acao
      end
    end
    return nil
  end
  
  # metodo responsavel pro reescrever todo o arquivo com o nome vetor
  # de acoes recebido por parametro
  def Acao.rewrite_file(actions_array)    
    File.open("actions.yml","w") do |f|
       YAML.dump(actions_array,f)
    end    
  end
end
