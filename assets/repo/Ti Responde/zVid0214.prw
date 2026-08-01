/*

    Esse é um exemplo disponibilizado no Terminal de Informação
    Confira o artigo sobre esse assunto, no seguinte link: https://terminaldeinformacao.com/2025/12/23/fechando-uma-tela-em-mvc-atraves-de-comandos-ti-responde-0214/

*/


//Bibliotecas
#Include "TOTVS.ch"
#Include "FWMVCDef.ch"

/*/{Protheus.doc} User Function zVid0214
Função para simular o fechar em MVC sem clicar no botão Fechar
@type  Function
@author Atilio
@since 30/09/2024
/*/

User Function zVid0214()
    Local aArea   := FWGetArea()
    Local cFunBkp := FunName()

    DbSelectArea('SA2')
    SA2->(DbSetOrder(1)) //Filial + Código + Loja

    //Se conseguir posicionar no Fornecedor
    If SA2->(DbSeek(FWxFilial('SA2') + "F00002"))
        //Define o atalho
        SetKey(K_CTRL_H, { || fFechaMVC() })

        //Abre a tela de fornecedores
        SetFunName("MATA020")
        FWExecView('Visualizacao Teste', 'MATA020', MODEL_OPERATION_VIEW)
        SetFunName(cFunBkp)

        //Desativa o atalho, após sair da tela de fornecedores
        SetKey(K_CTRL_H, Nil)
    EndIf

    FWRestArea(aArea)
Return

Static Function fFechaMVC()
    Local aArea := FWGetArea()
    Local nAtual
	Local bAction := {|| }
    //Busca a tela e os objetos dentro dela
    Private nAtuPvt
    Private oPai       := GetWndDefault()
    Private aControles := oPai:aControls

    //Percorre todos os objetos da tela
    For nAtual := 1 To Len(aControles)
        nAtuPvt := nAtual

        //Intercepta o botão de fehcar e tela
        If ValAtrib("aControles[nAtuPvt]:bAction") != "U"
            //Se o texto do botão for Fechar
			If Upper(Alltrim(aControles[nAtuPvt]:cCaption)) == "FECHAR"

                //Captura o bAction do botão e dispara ele
                bAction := aControles[nAtuPvt]:bAction
                eVal(bAction)
			EndIf
        EndIf

    Next

    FWRestArea(aArea)
Return

Static Function ValAtrib(cVar)
Return Type(cVar)
