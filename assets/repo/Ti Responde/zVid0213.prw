/*

    Esse é um exemplo disponibilizado no Terminal de Informação
    Confira o artigo sobre esse assunto, no seguinte link: https://terminaldeinformacao.com/2025/12/18/ofuscar-um-campo-no-cadastro-via-codigo-fonte-ti-responde-0213/

*/


//Bibliotecas
#Include "Totvs.ch"

/*/{Protheus.doc} User Function CRMA980
Cadastro de Clientes
@author Atilio
@since 23/09/2024
@version 1.0
@type function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
     *-------------------------------------------------*
     Por se tratar de um p.e. em MVC, salve o nome do
     arquivo diferente, por exemplo, CRMA980_pe.prw
     *-----------------------------------------------*
     A documentacao de como fazer o p.e. esta disponivel em https://tdn.totvs.com/pages/releaseview.action?pageId=208345968
@see http://autumncodemaker.com
/*/

User Function CRMA980()
	Local aArea := FWGetArea()
	Local aParam := PARAMIXB
	Local xRet := .T.
	Local oObj := Nil
	Local cIdPonto := ""
	Local cIdModel := ""

	//Se tiver parametros
	If aParam != Nil

		//Pega informacoes dos parametros
		oObj := aParam[1]
		cIdPonto := aParam[2]
		cIdModel := aParam[3]

		//Para a inclusao de botoes na ControlBar
		If cIdPonto == "BUTTONBAR"
			xRet := {}

            //Aciono aqui a função, pois os componentes já foram carregados na tela
            u_zVid0213()
		EndIf

	EndIf

	FWRestArea(aArea)
Return xRet

/*/{Protheus.doc} User Function zVid0213
Função para deixar os campos A1_DDD, A1_TEL, A1_EMAIL e A1_HPAGE ofuscados
@type  Function
@author Atilio
@since 23/09/2024
@version version
/*/

User Function zVid0213()
    Local aArea        := FWGetArea()
    Local nAtual       := 0
    //Variáveis de controle dos objetos da tela
    Private oPai       := GetWndDefault()
    Private aControles := oPai:aControls
    Private nAtuPvt    := 0

    //Percorrendo os objetos criados da tela
    For nAtual := 1 To Len(aControles)
        nAtuPvt := nAtual

        //Se tiver variável e descrição
        If Type("aControles[nAtuPvt]:cReadVar") != "U" .And. Type("aControles[nAtuPvt]:cToolTip") != "U"

            //Somente se tiver conteúdo de TGet
            If ! Empty(aControles[nAtuPvt]:cReadVar) .And. ! Empty(aControles[nAtuPvt]:cToolTip) .And. 'M->' $ Upper(aControles[nAtuPvt]:cReadVar)
                cCampo := Alltrim(aControles[nAtuPvt]:cReadVar)

                //Se for os campos DDD, Telefone, eMail ou Site
                If cCampo + ";" $ "M->A1_DDD;M->A1_TEL;M->A1_EMAIL;M->A1_HPAGE;"
                    aControles[nAtuPvt]:lObfuscate := .T.
                EndIf

            EndIf
        EndIf
    Next


    FWRestArea(aArea)
Return
