/*

    Esse é um exemplo disponibilizado no Terminal de Informação
    Confira o artigo sobre esse assunto, no seguinte link: https://terminaldeinformacao.com/2025/12/30/abrindo-uma-tela-em-mvc-dentro-de-outra-tela-em-mvc-usando-fwexecview-ti-responde-0216/

*/


/*
    Tabela:
        Z39 - Clientes x Dias de Entrega
    Índices:
        1 - Z39_FILIAL + Z39_CLICOD + Z39_CLILOJ + Z39_DIASEM
    Campos
        Z39_FILIAL - padrão do sistema
        Z39_CLICOD - código do cliente (mesmo tamanho do A1_COD)
        Z39_CLILOJ - loja do cliente (mesmo tamanho do A1_LOJA)
        Z39_DIASEM - número do dia da semana, tamanho 2, como caractere
        Z39_DESCRI - nome do dia da semana (Segunda, Terca, etc), tamanho 10, como caractere
        Z39_ENTREG - lógico define se tem entrega no dia (true) ou não (false)
        Z39_HORINI - hora inicial para entregar no cliente, como caractere, máscara @R 99:99
        Z39_HORFIM - hora máxima para entregar no cliente, como caractere, máscara @R 99:99
*/


//Bibliotecas
#Include "Totvs.ch"
#Include "FWMVCDef.ch"

//Variveis Estaticas
Static cTitulo    := "Clientes x Dias de Entrega"
Static cCamposChv := "Z39_CLICOD;Z39_CLILOJ;"
Static cTabPai    := "Z39"

/*/{Protheus.doc} User Function zVid0216
Clientes x Dias de Entrega
@author Atilio
@since 01/10/2024
@version 1.0
@type function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/

User Function zVid0216()
	Local aArea   := FWGetArea()
	Local oBrowse
	Private aRotina := {}

	//Definicao do menu
	aRotina := MenuDef()

	//Instanciando o browse
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias(cTabPai)
	oBrowse:SetDescription(cTitulo)
	oBrowse:DisableDetails()

	//Ativa a Browse
	oBrowse:Activate()

	FWRestArea(aArea)
Return Nil

/*/{Protheus.doc} MenuDef
Menu de opcoes na funcao zVid0216
@author Atilio
@since 01/10/2024
@version 1.0
@type function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/

Static Function MenuDef()
	Local aRotina := {}

	//Adicionando opcoes do menu
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.zVid0216" OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar" ACTION "VIEWDEF.zVid0216" OPERATION 4 ACCESS 0

Return aRotina

/*/{Protheus.doc} ModelDef
Modelo de dados na funcao zVid0216
@author Atilio
@since 01/10/2024
@version 1.0
@type function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/

Static Function ModelDef()
	Local oStruPai   := FWFormStruct(1, cTabPai, {|cCampo| Alltrim(cCampo) $ cCamposChv})
	Local oStruFilho := FWFormStruct(1, cTabPai)
	Local aRelation := {}
	Local oModel
	Local bPre := Nil
	Local bPos := Nil
	Local bCancel := Nil


	//Cria o modelo de dados para cadastro
	oModel := MPFormModel():New("zVid216M", bPre, bPos, /*bCommit*/, bCancel)
	oModel:AddFields("Z39MASTER", /*cOwner*/, oStruPai)
	oModel:AddGrid("Z39DETAIL","Z39MASTER",oStruFilho,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)
	oModel:SetDescription("Modelo de dados - " + cTitulo)
	oModel:GetModel("Z39MASTER"):SetDescription( "Dados de - " + cTitulo)
	oModel:GetModel("Z39DETAIL"):SetDescription( "Grid de - " + cTitulo)
	oModel:SetPrimaryKey({})

	//Fazendo o relacionamento
	aAdd(aRelation, {"Z39_FILIAL", "FWxFilial('Z39')"} )
	aAdd(aRelation, {"Z39_CLICOD", "Z39_CLICOD"})
	aAdd(aRelation, {"Z39_CLILOJ", "Z39_CLILOJ"})
	oModel:SetRelation("Z39DETAIL", aRelation, Z39->(IndexKey(1)))

    //Desativando a exclusão e inclusão de linhas
    oModel:GetModel("Z39DETAIL"):SetNoDeleteLine(.T.)
    oModel:GetModel("Z39DETAIL"):SetNoInsertLine(.T.)

Return oModel

/*/{Protheus.doc} ViewDef
Visualizacao de dados na funcao zVid0216
@author Atilio
@since 01/10/2024
@version 1.0
@type function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/

Static Function ViewDef()
	Local oModel     := FWLoadModel("zVid0216")
	Local oStruPai   := FWFormStruct(2, cTabPai, {|cCampo| Alltrim(cCampo) $ cCamposChv})
	Local oStruFilho := FWFormStruct(2, cTabPai, {|cCampo| ! Alltrim(cCampo) $ cCamposChv})
	Local oView

	//Cria a visualizacao do cadastro
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("VIEW_Z39", oStruPai, "Z39MASTER")
	oView:AddGrid("GRID_Z39",  oStruFilho,  "Z39DETAIL")

	//Partes da tela
	oView:CreateHorizontalBox("CABEC", 30)
	oView:CreateHorizontalBox("GRID", 70)
	oView:SetOwnerView("VIEW_Z39", "CABEC")
	oView:SetOwnerView("GRID_Z39", "GRID")

	//Titulos
	oView:EnableTitleView("VIEW_Z39", "Cabecalho - Z39")
	oView:EnableTitleView("GRID_Z39", "Grid - Z39")

	//Adicionando campo incremental na grid
	oView:AddIncrementField("GRID_Z39", "Z39_DIASEM")

Return oView

/*/{Protheus.doc} User Function z216Alt
Função para acionar a alteração do vínculo do cliente com os dias
@type  Function
@author Atilio
@since 01/10/2024
/*/

User Function z216Alt()
    Local aArea     := FWGetArea()
    Local cFunBkp   := FunName()
    Local cCliente  := SA1->A1_COD
    Local cLoja     := SA1->A1_LOJA
    Local nDia      := 0
    Local cDia      := ""
    Local cDescri   := ""
    Local aTamanho := MsAdvSize()
    Local nJanLarg := aTamanho[5]
    Local nJanAltu := aTamanho[6]
    Local oDlgTemp
    Local bInit := {||}
    Private aRotina := {}

    DbSelectArea("Z39")
    Z39->(DbSetOrder(1)) // Z39_FILIAL + Z39_CLICOD + Z39_CLILOJ + Z39_DIASEM

    //Percorre os dias da semana
    For nDia := 1 To 7
        cDia    := StrZero(nDia, 2)
        cDescri := DiaSemana( , , nDia)

        //Se o dia atual não foi encontrado para esse cliente
        If ! Z39->(MsSeek(FWxFilial("Z39") + cCliente + cLoja + cDia))

            //Cria o registro
            RecLock("Z39", .T.)
                Z39->Z39_FILIAL := FWxFilial("Z39")
                Z39->Z39_CLICOD := cCliente
                Z39->Z39_CLILOJ := cLoja
                Z39->Z39_DIASEM := cDia
                Z39->Z39_DESCRI := cDescri
                Z39->Z39_ENTREG := .F.
                Z39->Z39_HORINI := ""
                Z39->Z39_HORFIM := ""
            Z39->(MsUnlock())
        EndIf
    Next

    //Se acionar assim, ele abre a tela do browse
    //FWExecView('Clientes x Dias de Entrega', 'zVid0216', MODEL_OPERATION_UPDATE, /*oDlg*/, {|| .T.}, {|| .T.})

    //Cria a janela temporária
    oDlgTemp := TDialog():New(0, 0, nJanAltu, nJanLarg, cTitulo, , , , , CLR_BLACK, RGB(250, 250, 250), , , .T.)

        //Define o bloco ao inicilizar a tela para acionar a rotina para cadastrar cliente x dias de entrega e em seguida depois que confirmar, encerrar a dialog
        SetFunName("zVid0216")
        bInit := {|| FWExecView('Clientes x Dias de Entrega', 'zVid0216', MODEL_OPERATION_UPDATE, /*oDlg*/, {|| .T.}, {|| .T.}), oDlgTemp:End() }
        SetFunName(cFunBkp)

    //Ativa a janela temporária e aciona o bloco de inicialização
    oDlgTemp:Activate(, , , .T., {|| .T.}, , bInit )

    FWRestArea(aArea)
Return


/*/{Protheus.doc} User Function CRM980MDEF
Adiciona outras ações na tela de clientes
@type  Function
@author Atilio
@since 01/10/2024
/*/

User Function CRM980MDEF()
    Local aArea      := FWGetArea()
    Local aNovBotoes := {}

    //Adiciona as opções novas
    ADD OPTION aNovBotoes TITLE "* Clientes x Dias de Entrega" ACTION "u_z216Alt()" OPERATION 8 ACCESS 0

    FWRestArea(aArea)
Return aNovBotoes
