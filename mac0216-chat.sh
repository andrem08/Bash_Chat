#!/bin/bash
#  AO PREENCHER(MOS) ESSE CABEÇALHO COM O(S) MEU(NOSSOS) NOME(S) E
#  O(S) MEU(NOSSOS) NÚMERO(S) USP, DECLARO(AMOS) QUE SOU(MOS) O(S)
#  ÚNICO(S) AUTOR(ES) E RESPONSÁVEL(IS) POR ESSE PROGRAMA. TODAS AS
#  PARTES ORIGINAIS DESSE EXERCÍCIO PROGRAMA (EP) FORAM DESENVOLVIDAS
#  E IMPLEMENTADAS POR MIM(NÓS) SEGUINDO AS INSTRUÇÕES DESSE EP E QUE
#  PORTANTO NÃO CONSTITUEM DESONESTIDADE ACADÊMICA OU PLÁGIO. DECLARO
#  TAMBÉM QUE SOU(MOS) RESPONSÁVEL(IS) POR TODAS AS CÓPIAS DESSE
#  PROGRAMA E QUE EU(NÓS) NÃO DISTRIBUÍ(MOS) OU FACILITEI(AMOS) A SUA
#  DISTRIBUIÇÃO. ESTOU(AMOS) CIENTE(S) QUE OS CASOS DE PLÁGIO E
#  DESONESTIDADE ACADÊMICA SERÃO TRATADOS SEGUNDO OS CRITÉRIOS
#  DIVULGADOS NA PÁGINA DA DISCIPLINA. ENTENDO(EMOS) QUE EPS SEM
#  ASSINATURA NÃO SERÃO CORRIGIDOS E, AINDA ASSIM, PODERÃO SER PUNIDOS
#  POR DESONESTIDADE ACADÊMICA.
#
#  Nome(s) :Andre Miyazawa
#  NUSP(s) :11796187
#
#  Referências:
#  https://terminalroot.com.br/2015/07/30-exemplos-do-comando-sed-com-regex.html
#  https://terminalroot.com.br/2015/01/shell-script-validandotele.html
#  https://terminalroot.com.br/2014/12/dicas-uteis-para-shell-script.html
#  man sed, man grep, man test
#
function VerfServ {
	case $1 in
		#Subtrai da data atual, a data inicial
		"time")	echo `date +%s` - $TIME | bc;;
		#Imprime todos os clientes que estao logados
		"list")
			grep -E -v tty$ /tmp/lista.txt | cut -d ' ' -f2;;
		#Deleta o /tmp/lista.txt e depois cria novamente
		"reset")
			rm /tmp/lista.txt
			> /tmp/lista.txt;;
	esac
}

function VerfCliente {
		case $1 in
		"create")
			#Caso o cliente nao exista, ele vai ser criado
			#Cria mais nao ultiliza o login no cliente
			grep -q " $2 " /tmp/lista.txt
			if [ $? -eq 1 ]; then
				# usuario senha tty
				echo "$* tty" >> /tmp/lista.txt
				sed -i 's/create//g' /tmp/lista.txt
			#Caso contrario, erro
			else echo "ERRO"
			fi;;
		"passwd")
			#Verificar se o cliente existe e se a senha estiver correta.
			#Um cliente pode modificar a senha logado em outro cliente.
			grep -q " $2 $3 " /tmp/lista.txt
			if [ $? -eq 0 ]; then
			#Caso o usuario nao mude a senha, ou seja, digite as duas senhas iguais.
			if [ "$3" != "$4" ]; then
				sed -i "s/ $2 $3 / $2 $4 /g" /tmp/lista.txt
			#Caso contrario, ERRO
			else echo "ERRO"
			fi
			else echo "ERRO"
			fi;;
		"login")
			#Verifica se o terminal ja estiver logado em um cliente.
			grep -q $(tty) /tmp/lista.txt
			if [ $? -eq 1 ]; then
			#Verifica se o cliente ja estiver logado em um terminal.
			grep " $2 " /tmp/lista.txt | grep -q "tty"
			if [ $? -eq 0 ]; then
			#Verifica se o cliente existe e se a senha estiver correta.
			grep -q " $2 $3 " /tmp/lista.txt
			if [ $? -eq 0 ]; then
				#Modifica o final do status para 1 se ele for 0 antes.
				sed -i "s~ $2 $3 tty~ $2 $3 $(tty)~g" /tmp/lista.txt
			#Caso contrario, ERRO.
			else echo "ERRO"
			fi
			else echo "ERRO"
			fi
			else echo "ERRO"
			fi;;
		"quit")
			#Verifica se o cliente estiver logado.
			grep -q -s $(tty) /tmp/lista.txt
			if [ $? -eq 0 ]; then
				#Deslogando.
				sed -i "s~$(tty)~tty~g" /tmp/lista.txt
			fi;;
		"list")
			#Verifica se o cliente estiver logado.
			grep -q $(tty) /tmp/lista.txt
			if [ $? -eq 0 ]; then
				#Imprime todos os cliente que estao logados.
				grep -E -v tty$ /tmp/lista.txt | cut -d ' ' -f2
			#Caso contrario, ERRO.
			else echo "ERRO"
			fi;;
		"msn")
			#Verifica se o cliente estiver logado.
			grep -q $(tty) /tmp/lista.txt
			if [ $? -eq 0 ]; then
			#Verifica se o destinatario estiver logado.
			grep " $2 " /tmp/lista.txt | grep -q -v tty$
			if [ $? -eq 0 ]; then
			#Verifica se o usuario nao foi o mesmo que enviou a mensagem.
			grep $(tty) /tmp/lista.txt | grep -q " $2 "
			if [ $? -eq 1 ]; then
				local ttyDest=`grep " $2 " /tmp/lista.txt | cut -d ' ' -f4`
				local dest=`grep $(tty) /tmp/lista.txt | cut -d ' ' -f2`
				mensagem=($*)
				echo "[Mensagem de $dest]: ${mensagem[@]:2}" >> ${ttyDest}
				echo -n "cliente> " >> ${ttyDest}
			#Caso contrario, ERRO.
			else echo "ERRO"
			fi
			else echo "ERRO"
			fi
			else echo "ERRO"
			fi;;
		"logout")
			#Verifica se o cliente estiver logado.
			grep -q $(tty) /tmp/lista.txt
			if [ $? -eq 0 ]; then
				#Deslogando.
				sed -i "s~$(tty)~tty~g" /tmp/lista.txt
			#Caso contrario ERRO.
			else echo "ERRO"
			fi;;
	esac
}
#Funcao principal. Verifica se foi cliente ou servidor, se nao imprime ERRO e sai do programa.
case $1 in
	servidor)
		#Guardar o tempo que o servidor iniciou.
		TIME=`date +%s`
		#cria um arquivo chamado lista.txt em /tmp/
		> /tmp/lista.txt
		until [ "${TIPO}" = "quit" ]; do
			echo -n "servidor> "
			read TIPO
			VerfServ $TIPO
		done
		#Apaga o arquivo lista.txt
		rm /tmp/lista.txt;;

	cliente)
		#Testa se o arquivo lista.txt existe, ou seja, o servidor foi iniciado
		test -e /tmp/lista.txt
		if [ $? -eq 0 ]; then
			until [ "${TIPO}" = "quit" ]; do
				echo -n "cliente> "
				read TIPO
				#Testa se o arquivo lista.txt ainda existe, ou seja, o servidor nao ultilizou quit
				test -e /tmp/lista.txt
				if [ $? -eq 1 ]; then
					echo "ERRO"
					TIPO="quit"
				fi
				VerfCliente $TIPO
			done
		else echo "ERRO"
		fi;;
	#O caso em que o programa seja iniciado diferente de cliente ou servidor.
	*)	echo "ERRO";;
esac
exit 0
