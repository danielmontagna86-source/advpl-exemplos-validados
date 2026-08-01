/*

    Esse é um exemplo disponibilizado no Terminal de Informação
    Confira o artigo sobre esse assunto, no seguinte link: https://terminaldeinformacao.com/2025/11/18/deixar-pre-salvo-os-dados-em-uma-tela-ti-responde-0204/

*/


//Bibliotecas
#Include "TOTVS.ch"

/*/{Protheus.doc} User Function MA103BUT
Adiciona botões dentro da tela de manipulação do Documento de Entrada
@type  Function
@author Atilio
@since 19/08/2024
@version version
@see https://tdn.totvs.com/pages/releaseview.action?pageId=102269141
/*/

User Function MA103BUT()
	Local aArea   := FWGetArea()
	Local aAreaF1 := SF1->(FWGetArea())
	Local aAreaD1 := SD1->(FWGetArea())
    Local aBotoes := {}

    //Adiciona no array de botões do Outras Ações
	aAdd(aBotoes, {"BUDGETY", {|| U_zVid0204(.F.)} , "* Buscar Produtos Informados" })

	FWRestArea(aAreaD1)
	FWRestArea(aAreaF1)
	FWRestArea(aArea)
Return aBotoes

/*/{Protheus.doc} User Function MT100LOK
Ponto de Entrada na validação da linha do documento de entrada
@type  Function
@author Atilio
@since 19/08/2024
@version version
@see https://tdn.totvs.com/pages/releaseview.action?pageId=6085397
/*/

User Function MT100LOK()
	Local aArea   := FWGetArea()
	Local aAreaF1 := SF1->(FWGetArea())
	Local aAreaD1 := SD1->(FWGetArea())
    Local lRet    := .T.

    //Se não tiver sendo acionado pela própria função de popular a grid
	If ! FWIsInCallStack("U_zVid0204")
		u_zVid0204(.T.)
	EndIf

	FWRestArea(aAreaD1)
	FWRestArea(aAreaF1)
	FWRestArea(aArea)
Return lRet

/*/{Protheus.doc} User Function zVid0204
Grava ou le os produtos que estavam informados na grid do documento de entrada
@type  Function
@author Atilio
@since 17/08/2024
@param lGravar, Lógico, Define se vai gravar o log (.T.) ou vai ler (.F.)
/*/

User Function zVid0204(lGravar)
    Local aArea       := FWGetArea()
    Local cUsrAtu     := RetCodUsr()
    Local cUsrsLog    := SuperGetMV("MV_X_USENT", .F., "000000;")
    Private cPastaTmp := GetTempPath() + "entr_" + dToS(Date()) + "\"
    Default lGravar   := .F.

    //Se não for processo automático
    If ! IsBlind() .And. ! l103Auto
        //Se o usuário tiver nos logs
        If cUsrAtu $ cUsrsLog

            //Se a pasta não existir, cria
            If ! ExistDir(cPastaTmp)
                MakeDir(cPastaTmp)
            EndIf

            //Se for para gravar o log
            If lGravar
                //Somente se tiver mais de uma linha
                fGravaLog()
            Else
                //Somente se foi iniciado o cálculo fiscal (tiver inserido um produto)
                If ! Empty(aCols[1][GDFieldPos("D1_COD")])
                    fBuscaLog()
                Else
                    ExibeHelp("Help u_zVid0204", "Não foi inicializado os cálculos fiscais!", "Insira ao menos 1 produto na primeira linha!")
                EndIf
            EndIf

        Else
            If ! lGravar
                ExibeHelp("Help u_zVid0204", "Usuário sem acesso nessa rotina!", "Contate o Administrador (parâmetro MV_X_USENT)!")
            EndIf
        EndIf
    EndIf

    FWRestArea(aArea)
Return

Static Function fGravaLog()
    Local cArquiTmp := cA100For + "_" + cNFiscal + "_" + cSerie + ".txt"
    Local cTexto    := ""
    Local nAtual    := 0
    Local aColsAux  := aClone(aCols)
    Local nPosItem  := GDFieldPos("D1_ITEM")
    Local nPosProd  := GDFieldPos("D1_COD")
    Local nPosQtde  := GDFieldPos("D1_QUANT")
    Local nPosVUni  := GDFieldPos("D1_VUNIT")
    Local nPosCTES  := GDFieldPos("D1_TES")
    Local nPosPedi  := GDFieldPos("D1_PEDIDO")
    Local nPosIPed  := GDFieldPos("D1_ITEMPC")
    Local nPosCFOP  := GDFieldPos("D1_CF")
    Local nPosDele  := Len(aHeader) + 1

    //Percorre as linhas, e se não tiver excluida, grava na variável
    For nAtual := 1 To Len(aColsAux)
        If ! aColsAux[nAtual][nPosDele]
            cTexto += aColsAux[nAtual][nPosItem] + ";"
            cTexto += aColsAux[nAtual][nPosProd] + ";"
            cTexto += cValToChar(aColsAux[nAtual][nPosQtde]) + ";"
            cTexto += cValToChar(aColsAux[nAtual][nPosVUni]) + ";"
            cTexto += aColsAux[nAtual][nPosCTES] + ";"
            cTexto += aColsAux[nAtual][nPosPedi] + ";"
            cTexto += aColsAux[nAtual][nPosIPed] + ";"
            cTexto += aColsAux[nAtual][nPosCFOP] + ";"
            cTexto += CRLF
        EndIf
    Next

    //Gera o arquivo texto
    MemoWrite(cPastaTmp + cArquiTmp, cTexto)
Return

Static Function fBuscaLog()
    Processa( {|| fLeArquiv()}, "Lendo arquivo...")
Return

Static Function fLeArquiv()
    Local nAtual   := 0
    Local cArquivo := cPastaTmp + cA100For + "_" + cNFiscal + "_" + cSerie + ".txt"
    Local oFile
    Local nColuna   := 0
    Local aCampos   := {"D1_ITEM", "D1_COD", "D1_QUANT", "D1_VUNIT", "D1_TES", "D1_PEDIDO", "D1_ITEMPC", "D1_CF"}
    Local aLinMold  := aClone(aCols[1])
    Local aDadosAux := {}
    Local cCampo    := ""
    Local nPosCampo := 0

    //Somente se o arquivo existir
    If File(cArquivo)
        //Abrindo o arquivo
        oFile := FWFileReader():New(cArquivo)

        //Se o arquivo pode ser aberto
        If (oFile:Open())

            //Se não for fim do arquivo
            If ! (oFile:EoF())
                //Zera o aCols
                aCols := {}
                MaFisClear()

                //Definindo o tamanho da régua
                aLinhas := oFile:GetAllLines()
                ProcRegua(Len(aLinhas))

                //Método GoTop não funciona, deve fechar e abrir novamente o arquivo
                oFile:Close()
                oFile := FWFileReader():New(cArquivo)
                oFile:Open()

                While (oFile:HasLine())

                    //Incrementando a régua
                    nAtual++
                    IncProc("Analisando linha " + cValToChar(nAtual) + " de " + cValToChar(Len(aLinhas)) + "...")

                    //Buscando o texto da linha atual
                    cLinAtu := oFile:GetLine()

                    //Se tiver conteúdo na linha atual
                    If ! Empty(cLinAtu)
                        aDadosAux := Separa(cLinAtu, ";")

                        //Se tiver a mesma quantidade de campos
                        If Len(aDadosAux) >= Len(aCampos)
                            //Adiciona uma linha no aCols
                            aAdd(aCols, aClone(aLinMold))
                            n := Len(aCols)
                            //oGetDados:oBrowse:nAt := n

                            //Define o produto e aciona as validações e gatilhos
                            MaFisIniLoad(n)
                            For nColuna := 1 To Len(aCampos)
                                //Busca o campo atual
                                cCampo    := aCampos[nColuna]
                                nPosCampo := GDFieldPos(cCampo)

                                //Se o tipo do campo for numérico, atualiza
                                If GetSX3Cache(cCampo, "X3_TIPO") == "N"
                                    aDadosAux[nColuna] := Val(aDadosAux[nColuna])
                                EndIf

                                //Atualiza o campo em memória
                                aCols[n][nPosCampo] := aDadosAux[nColuna]
                                __readVar           := "M->" + cCampo
                                &(__readVar)        := aCols[n][nPosCampo]

                                //Se não for os campos que não são digitáveis
                                If ! Alltrim(cCampo) + ";" $ "D1_ITEM;D1_PEDIDO;D1_ITEMPC;"

                                    //Executa as validações de campo
                                    &( GetSX3Cache(cCampo, "X3_VALID") )
                                    &( GetSX3Cache(cCampo, "X3_VLDUSER") )

                                    //Executa os gatilhos
                                    If ExistTrigger(cCampo)
                                        RunTrigger( ;
                                            2,;           //nTipo (1=Enchoice; 2=GetDados; 3=F3)
                                            n,;           //Linha atual da Grid quando for tipo 2
                                            Nil,;         //Não utilizado
                                            ,;            //Objeto quando for tipo 1
                                            cCampo;       //Campo que dispara o gatilho
                                        )
                                    EndIf
                                EndIf

                                //Atualiza a grid
                                //eVal(bGDRefresh)
                            Next

                            //Atualiza o total
                            aCols[n][GDFieldPos("D1_TOTAL")] := aCols[n][GDFieldPos("D1_QUANT")] * aCols[n][GDFieldPos("D1_VUNIT")]

                            //Atualiza o MaFis* para calculo dos impostos
                            MaFisLoad("IT_PRODUTO", aCols[n][GDFieldPos("D1_COD")],   n)
                            MaFisLoad("IT_QUANT",   aCols[n][GDFieldPos("D1_QUANT")], n)
                            MaFisLoad("IT_PRCUNI",  aCols[n][GDFieldPos("D1_VUNIT")], n)
                            MaFisLoad("IT_VALMERC", aCols[n][GDFieldPos("D1_TOTAL")], n)
                            MaFisLoad("IT_TES",     aCols[n][GDFieldPos("D1_TES")],   n)
                            MaFisEndLoad(n)

                            //Executa a validação de linha
                            A103LinOk()
                        EndIf
                    EndIf
                EndDo

                //Atualiza a tela
                If Len(aCols) == 0
                    aAdd(aCols, aClone(aLinMold))
                EndIf
                n := 1
                GetDRefresh()
            EndIf

            //Fecha o arquivo e finaliza o processamento
            oFile:Close()
        EndIf

    Else
        FWAlertError("Arquivo não encontrado!", "Atenção")
    EndIf
Return
