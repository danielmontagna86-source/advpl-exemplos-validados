/*

    Esse é um exemplo disponibilizado no Terminal de Informação
    Confira o artigo sobre esse assunto, no seguinte link: https://terminaldeinformacao.com/2026/04/23/imprimir-texto-em-negrito-em-antigos-fontes-com-setprint-ti-responde-0233/

*/


//Bibliotecas
#Include "TOTVS.ch"

/*/{Protheus.doc} zVid0233
Função para simular em como deixar um texto negrito em um SetPrint
@type user function
@author Atilio
@since 18/09/2025
@example u_zVid0250()
@obs Esse exemplo foi baseado nesse link: https://tdn.totvs.com/pages/releaseview.action?pageId=6815081

    Tem também uma documentação da TOTVS que ensina em como deixar negrito: https://centraldeatendimento.totvs.com/hc/pt-br/articles/360018872251-Cross-Segmento-TOTVS-Backoffice-Linha-Protheus-ADVPL-Montagem-de-Drivers-de-Impress%C3%A3o
/*/

User Function zVid0233()
    Local   aArea    := FWGetArea()
    Local   wnrel
    Local   cString  := "SA1"
    Local   titulo   := "Listagem de Clientes"
    Local   NomeProg := "zVid0250"
    Local   Tamanho  := "M"
    Private aReturn  := {"Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
    Private m_pag

    //Mostra a tela para o usuário confirmar
    wnrel := SetPrint(cString, NomeProg, "", @titulo, "", "", "", .F., .F., .F., Tamanho, , .F.)

    //Define na memória o que foi definido no SetPrint
    SetDefault(aReturn, cString)

    //Aciona a impressão do relatório
    RptStatus({|lEnd| fImprime(@lEnd, wnRel, cString, Tamanho, NomeProg, titulo)}, titulo)

    FWRestArea(aArea)
Return

Static Function fImprime(lEnd, WnRel, cString, Tamanho, NomeProg, titulo)
    Local cabec1   := ""
    Local cabec2   := ""
    Local cRodaTxt := oemtoansi("Rodapé")
    Local nCntImpr := 0
    Local aPosTxt  := {}
    Local nTotal   := 0
    Local nNegrito := 0
    Local nLinha   := 7
    Local nLimite  := 80

    //Monta o cabeçalho das colunas e as posições dos textos
    aAdd(aPosTxt, Len(cabec1))
    cabec1 += AvKey("Codigo", "A1_COD")   + " | "

    aAdd(aPosTxt, Len(cabec1))
    cabec1 += AvKey("Nome",   "A1_NOME")  + " | "

    aAdd(aPosTxt, Len(cabec1))
    cabec1 += AvKey("eMail",  "A1_EMAIL") + " | "

    //Abre a tabela de clientes
    DbSelectArea("SA1")
    SA1->(DbSetOrder(1)) // A1_FILIAL + A1_COD + A1_LOJA
    SA1->(DbGoTop())

    //Define o tamanho da régua
    Count To nTotal
    SetRegua(nTotal)
    SA1->(DbGoTop())

    //Imprime o cabeçalho
    Cabec(titulo, cabec1, cabec2, nomeprog, tamanho, 15)

    //Enquanto houver clientes
    While ! SA1->(EoF())
        //Incrementa a régua
        IncRegua()

        //Se passar do limite, quebra a página
        If nLinha > nLimite
            Roda(nCntImpr, cRodaTxt, Tamanho)
            Cabec(titulo, cabec1, cabec2, nomeprog, tamanho, 15)
            @ nLinha, 0 PSAY __PrtThinLine()
        EndIf

        //Incrementa as informações em memória
        nCntImpr++
        nLinha++

        //Imprime os textos
        @ nLinha, aPosTxt[1] PSay SA1->A1_COD   + " | "
        @ nLinha, aPosTxt[2] PSay SA1->A1_NOME  + " | "
        @ nLinha, aPosTxt[3] PSay SA1->A1_EMAIL + " | "

        //Agora reimprime o eMail mais 5 vezes, pra ele ficar em negrito (incrementa 1 na coluna)
        For nNegrito := 1 To 5
            @ nLinha, aPosTxt[3] +1 PSay SA1->A1_EMAIL
        Next

        SA1->(DbSkip())
    EndDo

    //Se não foi até o fim da página, imprime o rodapé
    If nLinha != nLimite
        Roda(nCntImpr, cRodaTxt, Tamanho)
    EndIf

    //Exibe o relatório em tela
    Set Device To Screen

    //Se for HTML, prepara para gerar o arquivo
    If aReturn[5] == 1
        Set Printer To
        DbCommitAll()
        OurSpool(wnrel)
    EndIf

    //Descarrega o spool
    Ms_Flush()
Return
