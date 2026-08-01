# Catálogo — Fontes/ (utilitários z*)

> Gerado por `scripts/build-index.py` em 2026-08-01 — NÃO editar manualmente.
> Corpus: clone de https://github.com/dan-atilio/AdvPL em `assets/repo/`. Caminhos relativos à raiz do clone.
> 105 fontes utilitários prontos, com ProtheusDOC. Leia o arquivo indicado antes de usar/adaptar.


## E-mail

| Fonte | Descrição |
| --- | --- |
| `Fontes/zBxMail.prw` | Função para buscar anexos de e-Mails da Locaweb / Uol |
| `Fontes/zEnvMail.prw` | Função para disparo do e-mail utilizando TMailMessage e tMailManager com opção de múltiplos anexos |
| `Fontes/zExpMail.prw` | Função que gera a exportação csv de contatos para a Locaweb |
| `Fontes/zOutlook.prw` | Função que abre o outlook para escrever um novo e-mail |

## Excel e planilhas

| Fonte | Descrição |
| --- | --- |
| `Fontes/zBrw2Exc.prw` | Função que exporta dados de um FWBrowse para Excel |
| `Fontes/zExcel2DBF.prw` | Função que converte arquivos do excel (*.xls*) em arquivos dBase (*.dbf), utilizando o LibreOffice para conversão |
| `Fontes/zLog2Excel.prw` | Função que converte um arquivo gerado com IXBLOG em uma planilha para análise |
| `Fontes/zQry2Excel.prw` | Função que recebe uma consulta sql e gera um arquivo do excel, dinamicamente |

## JSON, XML e integração

| Fonte | Descrição |
| --- | --- |
| `Fontes/ASOPM01.prw` | Função que retorna o XML de consulta no Sophus |
| `Fontes/zChooseFile.prw` | Função que abre a tela padrão do Windows Explorer para escolher um arquivo |
| `Fontes/zFTPEnv.prw` | Função que envia um arquivo para um servidor FTP |
| `Fontes/zGerDanfe.prw` | Função que gera a danfe e o xml de uma nota em uma pasta passada por parâmetro |
| `Fontes/zMsgPopup.prw` | Função que mostra um popup de aviso no Windows 10 (Windows Notification Balloon) |
| `Fontes/zPegaMac.prw` | Pegando o MAC Address de máquinas hospedeiras com Windows |
| `Fontes/zPrettyXML.prw` | Função que serve para quebrar um XML e deixá-lo indentado para o usuário |

## SQL e banco de dados

| Fonte | Descrição |
| --- | --- |
| `Fontes/zCompara.prw` | Comparação de campos do Dicionário x SQL Server |
| `Fontes/zConsSQL.prw` | Função para consulta genérica |
| `Fontes/zCpyReg.prw` | Função para copiar registros entre as filiais |
| `Fontes/zEditTmp.prw` | Função para manipulação de registros .dbf |
| `Fontes/zExpTab2.prw` | Função que gera lista das tabelas do Protheus |
| `Fontes/zExpTabs.prw` | Função que gera lista das tabelas do Protheus |
| `Fontes/zImpDoc.prw` | Função para importar objetos para o Banco de Conhecimento |
| `Fontes/zIsLock.prw` | Função que verifica se um registro esta travado na memória (com RecLock por exemplo) |
| `Fontes/zTstEmp.prw` | Função que percorre as empresas / filiais e cria as tabelas no banco |

## Datas e horas

| Fonte | Descrição |
| --- | --- |
| `Fontes/zCodAno.prw` | Função que retorna o ultimo campo código com separação de ano (ex.: 00001/15) |
| `Fontes/zCompacta.prw` | Função para compactar arquivos utilizando .rar ou .zip |
| `Fontes/zDelDoc.prw` | Função para excluir vários documentos de entrada ao mesmo tempo |
| `Fontes/zDiasUteis.prw` | Função que retorna a quantidade de dias úteis entre duas datas |
| `Fontes/zDtExtenso.prw` | Retorna a data por extenso |
| `Fontes/zHr2Val.prw` | Função que converte Hora para Valor |
| `Fontes/zIsMDI.prw` | Função que retorna se está utilizando o MDI (SIGAMDI) |
| `Fontes/zQuinto.prw` | Função que retorna o quinto dia útil de um mês |
| `Fontes/zSalvaProc.prw` | Função que salva as chamadas dos ProcNames em um arquivo |
| `Fontes/zVal2Hora.prw` | Converte valor numérico (ex.: 15.30) para hora (ex.: 15:30) |

## Strings e conversões

| Fonte | Descrição |
| --- | --- |
| `Fontes/zArrToTxt.prw` | Função que exporta um array para Texto |
| `Fontes/zCliFor.prw` | Função que cadastra cliente a partir dos dados do fornecedor |
| `Fontes/zConta.prw` | Função que conta quantos caracteres repetem em uma string |
| `Fontes/zFecPSS.prw` | Função responsável por fechar o sigapss.spf, chamada pelo botão F4 instanciado no login do Protheus pelo P.E. PswValid |
| `Fontes/zFilCNPJ.prw` | Função que retorna o código da filial (no padrão EEFF) através de um CNPJ vindo do parâmetro |
| `Fontes/zMemoToA.prw` | Função Memo To Array, que quebra um texto em um array conforme número de colunas |
| `Fontes/zMsgLog.prw` | Função que mostra uma mensagem de Log com a opção de salvar em txt |
| `Fontes/zSM0CNPJ.prw` | Função que retorna o código da filial |
| `Fontes/zSearch.prw` | Função para pesquisar campos de uma tela de cadastro |
| `Fontes/zTelEstr.prw` | Monta a tela da estrutura customizada |
| `Fontes/zTransNum.prw` | Função para conversão de valor numérico para texto conforme quantidade de decimais informada |
| `Fontes/zTransPDF.prw` | Função que converte imagens para pdf (como as geradas pelo TMSPrinter) |
| `Fontes/zUsrFil.prw` | Função que valida se o usuário tem acesso a filial |
| `Fontes/zValToSoma1.prw` | Função criada para converter um valor numérico em valor caracter do Soma1 |
| `Fontes/zVldGrid.prw` | Executa as validações da Grid |

## Arquivos e diretórios

| Fonte | Descrição |
| --- | --- |
| `Fontes/zAbreArq.prw` | Função para abrir arquivos conforme preferências do Sistema Operacional |
| `Fontes/zAtuPerg.prw` | Função que atualiza o conteúdo de uma pergunta no X1_CNT01 / SXK / Profile |
| `Fontes/zImpAux.prw` | Função que imprime o TMSPrinter em sequencia diferente |
| `Fontes/zLeIXBLog.prw` | Função que lê arquivo gerado pelo IXBLog, e gera um outro apenas com o nome dos pontos de entrada executado |
| `Fontes/zNameFile.prw` | Função que serve para retirar caracteres especiais para nome de arquivos |
| `Fontes/zRecurDir.prw` | Função recursiva de diretórios, que traz arquivos dentro de uma pasta e suas subpastas |
| `Fontes/zRepSX3.prw` | Função que dá replace em campos da SX3, conforme arquivo de origem |
| `Fontes/zTotPag.prw` | Retorna o número total de páginas para imprimir em um relatório |

## Interface e dialogs

| Fonte | Descrição |
| --- | --- |
| `Fontes/zCmbDesc.prw` | Função que retorna a descrição da opção do Combo selecionada |
| `Fontes/zComplMsg.prw` | — |
| `Fontes/zFindProd.prw` | Função feita para agilizar a procura de produtos na grid de rotinas padrões |
| `Fontes/zGrupCod.prw` | Função que preenche o código do produto conforme o grupo |
| `Fontes/zJotTst.prw` | Exemplo de GET em uma integração com JotForms |
| `Fontes/zLastPerg.prw` | Retorna a última pergunta executada pelo Protheus |
| `Fontes/zLogin.prw` | Função para montar a tela de login simplificada |
| `Fontes/zMiniForm.prw` | Funcao Mini Formulas, para executar formulas |
| `Fontes/zPutSX1.prw` | Função para criar Grupo de Perguntas |
| `Fontes/zSlider.prw` | Exemplo de Slideshow em AdvPL |
| `Fontes/zTamImg.prw` | Função que retorna o tamanho da Imagem em pixels, tanto largura, como alteura |

## Pedidos, notas e ERP

| Fonte | Descrição |
| --- | --- |
| `Fontes/zAltSC5.prw` | Função teste criada para ser chamada no Ações Relacionadas do Pedido de Venda, através do P.E. MA410MNU |
| `Fontes/zDbTree.prw` | Histórico de ligações de Clientes |
| `Fontes/zLibPed.prw` | Função para liberação de pedido de venda |
| `Fontes/zSB1Compl.prw` | Função que gera o complemento do produto (SB5) através do produto (SB1) |
| `Fontes/zTotPed.prw` | Função que retorna o valor total do pedido com os impostos |
| `Fontes/zTransp.prw` | Função para consultar pedidos em transportadoras |
| `Fontes/zVerTrans.prw` | Função que verifica se um pedido foi transmitido totalmente |
| `Fontes/zWsCliente.prw` | — |

## Sistema e jobs

| Fonte | Descrição |
| --- | --- |
| `Fontes/zCriaLog.prw` | Função parar criação de logs |
| `Fontes/zErro.prw` | Função que força a exibição de um Error Log para análise |
| `Fontes/zInicio.prw` | Função executada no Programa Inicial, sem precisar usuário e senha |
| `Fontes/zParUsr.prw` | Função para editar o MV_USERS |
| `Fontes/zUsrSrv.prw` | Script para verificar usuarios locais nos servers |

## Outros utilitários

| Fonte | Descrição |
| --- | --- |
| `Fontes/wTransporte.prw` | — |
| `Fontes/zAltPar.prw` | Função que altera parâmetros do tipo Lógico (deve ser um parâmetro com conteúdo lógico na SX6, por exemplo, "MV_CHVNFE") |
| `Fontes/zAppend.prw` | Função de Append em bloco de uma base para outra |
| `Fontes/zCarEspec.prw` | Função que limpa os caracteres especiais dentro de um campo |
| `Fontes/zCnvSoma1.prw` | Função de conversão do Soma1 |
| `Fontes/zCompX3XG.prw` | Função que compara o grupo de campos (SX3 e SXG) |
| `Fontes/zConOut.prw` | Função para substituir o ConOut (por causa do Code Analysis) |
| `Fontes/zConsArr.prw` | Função de exemplo de consulta de dados via Array (zConsArr) |
| `Fontes/zConsEsp.prw` | Função para consulta genérica |
| `Fontes/zConsMark.prw` | Função para consulta genérica com marcação de dados |
| `Fontes/zCriaCEsp.prw` | Função para criar uma consulta específica similar ao criar pelo Configurador, mas via código fonte |
| `Fontes/zCxArren.prw` | Função que faz um box / caixa com borda arredondada em um FWMSPrinter |
| `Fontes/zElemAlt.prw` | Função que altera a posição de um elemento do Array |
| `Fontes/zExpPars.prw` | Função que gera uma lista de parâmetros em HTML |
| `Fontes/zFunTit.prw` | Função que retorna o título da rotina em Execução |
| `Fontes/zGeraB9.prw` | Função que gera saldo inicial |
| `Fontes/zImpSB6.prw` | Função para importar saldos de poder de/em terceiros |
| `Fontes/zIsMVC.prw` | Função que verifica se a função executada atualmente é em MVC |
| `Fontes/zLeBalanca.prw` | Função para testar a integração com balanças |
| `Fontes/zMataTudo.prw` | Função que mata todas as conexões ativas do Protheus |
| `Fontes/zParComma.prw` | Função para edição de um parâmetro (SX6) que tenha separadores como ponto e vírgula |
| `Fontes/zSemanas.prw` | Retorna as semanas entre duas datas |
| `Fontes/zUltNum.prw` | Função que retorna o ultimo campo código |
| `Fontes/zVazio.prw` | Função que verifica se o array está vazio (ou somente com linhas excluídas) |
