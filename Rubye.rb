#
#       Copyright 2010 Matheus Lessa <mlessadev@gmail.com>
#
#       This program is free software; you can redistribute it and/or modify
#       it under the terms of the GNU General Public License as published by
#       the Free Software Foundation; either version 2 of the License, or
#       (at your option) any later version.
#       
#       This program is distributed in the hope that it will be useful,
#       but WITHOUT ANY WARRANTY; without even the implied warranty of
#       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#       GNU General Public License for more details.
#       
#       You should have received a copy of the GNU General Public License
#       along with this program; if not, write to the Free Software
#       Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#       MA 02110-1301, USA.


#Main Author: Matheus Lessa #{MLessa}
#Other collaborators:


require 'libglade2'
require 'Timer' 
require 'Acao'

class RubyeGlade 
     
  def initialize(glade_xml)    
    @builder = Gtk::Builder.new
    @builder.add_from_file(glade_xml)
    @builder.connect_signals {|handler| method(handler) }     
    system("gksu -D 'Rubye' ''")      
    load_widgets()    
    @timer= Thread.new {Thread.stop}    
    on_btnAtualTime_clicked(nil)      
    @mainWindow.show_all       
    check_file()   
    Acao.load_combo_actions(@cmbAcao)   
  end  
  
  # ---------- > Abaixo metodos globais da aplicacao
  
# Metodo para carregar as variaveis com os widgets necessarios
  def load_widgets ()
    @mainWindow           = @builder.get_object('mainWindow')
    @spinHora             = @builder.get_object('spinHora')
    @spinMinuto           = @builder.get_object('spinMinuto')
    @calendar             = @builder.get_object('calendar')
    @lblTempo             = @builder.get_object('lblTempo')
    @altAcao              = @builder.get_object('altAcao')    
    @btnAtualTime         = @builder.get_object('btnAtualTime')
    @cmbModo              = @builder.get_object('cmbModo')
    @cmbAcao              = @builder.get_object('cmbAcao')  
    @aboutDialog          = @builder.get_object('aboutDialog') 
    @errorDialog          = @builder.get_object('errorDialog') 
    @acaoWindow           = @builder.get_object('acaoWindow')
    @txtNovaAcaoNome      = @builder.get_object('txtNovaAcaoNome')
    @txtNovaAcaoComando   = @builder.get_object('txtNovaAcaoComando')
    @cmbAcaoEditar        = @builder.get_object('cmbAcaoEditar')
    @txtEditarAcaoNome    = @builder.get_object('txtEditarAcaoNome')
    @txtEditarAcaoComando = @builder.get_object('txtEditarAcaoComando')
    @cmbAcaoApagar        = @builder.get_object('cmbAcaoApagar')       
  end
  
  # metodo que checa se o arquivo actions.yml existe e caso nao exista
  # chama o metodo write_default para escreve-lo
  def check_file()    
    if File.zero?("actions.yml") || !File.exist?("actions.yml")
      Acao.write_default()
    end 
  end  
  
  #metodo que recebe o um comboBox e retorna o comando equivalente ao nome
  #da acao selecionada
  def find_command(comboBox)
    nomeAcao = comboBox.active_text().to_s    
    return Acao.get_acao(nomeAcao).comando    
  end
    
    #metodo que invoca o metodo load_combo_actions da classe Acao para
    # atualizar os dados dos combos  
    def refresh_combos()
      Acao.load_combo_actions(@cmbAcaoApagar)      
      Acao.load_combo_actions(@cmbAcaoEditar)
      Acao.load_combo_actions(@cmbAcao)      
  end
  
# ---------- > Abaixo metodos dos eventos da tela principal (mainWindow)    
    
  # Metodo de acao do botao altAcao
  def on_altAcao_toggled(widget)    
    if @altAcao.active?      
      if !validData?
           @errorDialog.show_all
           @altAcao.set_active(false)
        else          
          set_actionStatus()
          # Intância de Timer recebendo os parametros de desligamento. 
          #P.S: usa-se @calendar.month+1 pois o widget interpreta janeiro=0, fevereiro=1 e assim suscessivamente
          @timer = Timer.new(@calendar.year,@calendar.month+1,@calendar.day,@spinHora.value,@spinMinuto.value,@cmbModo.active().to_i,find_command(@cmbAcao))      
          @timer.run
          set_DisabledControls
          @altAcao.set_label("Parar")         
      end
    else     
      if @timer.alive?
         @timer.terminate!
      end
       set_EnableControls(@cmbModo.active().to_i)       
       @altAcao.set_label("Começar")
       set_actionStatus(false)
       
    end
  end 
  
  # Metodo da acao do botao btnAtualTime
  def on_btnAtualTime_clicked (widget)   
    @calendar.set_month(Time.now.month-1)
    @calendar.set_year(Time.now.year) 
    @calendar.set_day(Time.now.day) 
    @spinHora.set_value(Time.now.hour)
    @spinMinuto.set_value(Time.now.min)
  end
  
  # Metodo da acao do combo box cmb_Modo
  def on_cmbModo_changed(widget)
     if @cmbModo.active().to_i == 0
        @calendar.sensitive=true
        @spinHora.set_value(Time.now.hour)
        @spinMinuto.set_value(Time.now.min)
        @btnAtualTime.sensitive=true
     else
        @calendar.sensitive=false
        @spinHora.set_value(0)
        @spinMinuto.set_value(0)
        @btnAtualTime.sensitive=false
     end
  end

  # Metodo de acao do botao fechar da janela mainWindow
  def on_mainWindow_delete_event(widget, arg0)
    Gtk.main_quit    
  end 
  
  # Metodo da acao de "correr" os meses para tras implementado de forma
 # a impedir que seja selecionado um mês anterior ao atual
 def on_calendar_prev_month
  if @calendar.month < Time.now.month-1
     @calendar.set_month(Time.now.month-1)
  end
 end
 
 # Metodo da acao de "correr" os anos para tras implementado de forma
 # a impedir que seja selecionado um ano anterior ao atual
 def on_calendar_prev_year
  if @calendar.year < Time.now.year
     @calendar.set_year(Time.now.year)
  end
end 

# ---------- > Abaixo metodos de controle de aparicao das janelas secundarias


  def on_actionAjudaSobre_activate
    @aboutDialog.show_all()
  end
  
  def on_actionEditarAcoes_activate
    @acaoWindow.show_all()
  end
  
  def on_acaoWindow_delete_event
    @acaoWindow.set_visible(false)
  end
  
 def on_aboutDialog_response   
   @aboutDialog.set_visible(false)
 end 
 
 def on_errorDialog_response
   @errorDialog.set_visible(false)
 end
 
 # ---------- > Abaixo metodos auxiliares da tela principal (mainWindow)

  # Metodo p/ validar a data escolhida
  def validData?     
    return true if @cmbModo.active().to_i==1    
   if @calendar.month+1 == Time.now.month && @calendar.day < Time.now.day     
     return false     
   elsif isToday? 
     if (@spinHora.value == Time.now.hour && @spinMinuto.value <= Time.now.min) || @spinHora.value < Time.now.hour
       return false     
     end     
   end   
   return true
 end

  # Metodo p/ verificar se o dia programado he igual ao dia atual
 def isToday?
   today = [Time.now.year,Time.now.month,Time.now.day]
   if @calendar.date == today # @calendar.date retorna um array no formato [ano,mês,dia]
      return true
   else
      return false 
   end   
 end
   
    # Torna os controles insensiveis as acoes dependendo do tipo modo de execucao
  def set_EnableControls(comboIndex)    
     @spinHora.sensitive=true  
     @spinMinuto.sensitive=true
     @cmbModo.sensitive=true
     @cmbAcao.sensitive=true
     if  comboIndex == 0          
       @calendar.sensitive=true
       @btnAtualTime.sensitive=true 
    end
  end
    # Torna os controles sensiveis as acoes
  def set_DisabledControls    
    @spinHora.sensitive=false  
    @spinMinuto.sensitive=false  
    @calendar.sensitive=false 
    @btnAtualTime.sensitive=false
    @cmbModo.sensitive=false
    @cmbAcao.sensitive=false
  end 
  
  # Seta a data e a hora programada paro a execucao da acao na label lblTempo
 def set_actionStatus(set=true)
   if set
     if @cmbModo.active().to_i==0
         # funcao sprintf usada apenas para formatar o valor das horas e minutos
          @lblTempo.set_label("#{@calendar.day}/#{@calendar.month}/#{@calendar.year} às #{sprintf("%02d",@spinHora.value.to_i)}:#{sprintf("%02d",@spinMinuto.value.to_i)}")
     else
          # IMPLEMENTAR contador regressivo em Thread para exibir o tempo restante
          @lblTempo.set_label("#{@spinHora.value.to_i} hora(s) e #{@spinMinuto.value.to_i} minuto(s)")
     end  
   else
     @lblTempo.set_label("")
   end
 end 
    
# ---------- > Abaixo metodos dos eventos da tela de manipulacao de acões (acaoWindow)

# metodo executado toda vez que a janela de acao he exibida
def on_acaoWindow_show
 refresh_combos()
end

# metodo de acao do botao btnNovaAcaoLimpar
def on_btnNovaAcaoLimpar_clicked
 @txtNovaAcaoNome.set_text("")
 @txtNovaAcaoComando.set_text("")
end

# metodo de acao do botao btnNovaAcaoSalvar
def on_btnNovaAcaoSalvar_clicked
  acao = Acao.get_acao(@txtNovaAcaoNome.text.strip)
  if !(acao.is_a? Acao)
    if @txtNovaAcaoComando.text.strip.length > 0 && !@txtNovaAcaoComando.text.empty? && @txtNovaAcaoNome.text.strip.length > 0 && !@txtNovaAcaoNome.text.empty?
       acao = Acao.new(@txtNovaAcaoNome.text,@txtNovaAcaoComando.text)        
       Acao.add(acao)        
       refresh_combos()
       on_btnNovaAcaoLimpar_clicked     
    end
 end
end

#metodo de acao do botao btnEditarAcaoLimpar
def on_btnEditarAcaoLimpar_clicked
 @txtEditarAcaoComando.set_text("")
 @txtEditarAcaoNome.set_text("")
end

#metodo de acao do botao btnEditarAcaoSalvar
def on_btnEditarAcaoSalvar_clicked  
    if @txtEditarAcaoNome.text.strip.length > 0 && !@txtEditarAcaoNome.text.empty? && @txtEditarAcaoComando.text.strip.length > 0 && !@txtEditarAcaoComando.text.empty?
      acao_nome = @cmbAcaoEditar.active_text().to_s
      acao_novoNome = @txtEditarAcaoNome.text.strip
      acao_novoComando = @txtEditarAcaoComando.text.strip
      Acao.edit(acao_nome, acao_novoNome, acao_novoComando)    
      refresh_combos()
    end  
end

#metodo invocado toda vez que o valor comboBox cmbAcaoEditar he alterado
def on_cmbAcaoEditar_changed 
  cmbAcaoEditar_texto = @cmbAcaoEditar.active_text().to_s 
  if cmbAcaoEditar_texto.length > 0
    selected_action = Acao.get_acao(cmbAcaoEditar_texto)
    @txtEditarAcaoNome.set_text(selected_action.nome)
    @txtEditarAcaoComando.set_text(selected_action.comando)
  end  
end

#metodo de acao do botao btnApagarAcao
def on_btnApagarAcao_clicked
  Acao.delete(@cmbAcaoApagar.active_text())
  refresh_combos()
end
# ----------->    
end

# Main program   
  RubyeGlade.new("Rubye.glade")  
  Gtk.main
