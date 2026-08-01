/*

    Esse é um exemplo disponibilizado no Terminal de Informação
    Confira o artigo sobre esse assunto, no seguinte link: https://terminaldeinformacao.com/2026/03/12/webservice-para-inclusao-de-registros-de-forma-generica-ti-responde-0227/

*/


//Bibliotecas
#Include "TOTVS.ch"
#Include "RESTFul.ch"
#Include "TopConn.ch"

WSRESTFUL WSInputData DESCRIPTION "WS de Inclusão e Atualização de Registros"
    //Atributos usados
    WSDATA id AS STRING

    //Métodos usados
    WSMETHOD GET SEARCH DESCRIPTION "Retorna se registro existe conforme parâmetros passados no Body"       WSSYNTAX '/WSInputData/search'          PRODUCES APPLICATION_JSON
    WSMETHOD POST SAVE DESCRIPTION "Inclui o registro (ou atualiza) conforme parâmetros passados no Body"  WSSYNTAX '/WSInputData/save'            PRODUCES APPLICATION_JSON
END WSRESTFUL

/*
Exemplo do JSON para buscar se existe registros (para o caso de perguntar para o usuário se ele deseja atualizar os dados)
É necessário informar:
    + A tabela
    + Os nomes dos campos da chave (concatenado por +)
    + O conteúdo dos campos que serão buscados (concatenado por +)

Exemplo 1 (Currículos):
{
    "table": "SQG",
    "key": "QG_CIC",
    "contents": "00000000000"
}

Exemplo 2 (Clientes):
{
    "table": "SA1",
    "key": "A1_COD+A1_LOJA",
    "contents": "000001+01"
}
*/

WSMETHOD GET SEARCH WSRECEIVE WSSERVICE WSInputData
    Local lRet       := .T.
    Local cJsonBody  := Self:GetContent()
    Local oJsonBody
    Local cError     := ""
    Local oResponse  := JsonObject():New()
    Local cTable     := ""
    Local cKey       := ""
    Local cContents  := ""
    Local aKey       := {}
    Local aContents  := {}
    Local cQueryAux  := ""
    Local nField     := 0
    Local cField     := ""
    Local cContAux   := ""
    Local nTotal     := 0

    //Define o tipo do retorno
    Self:SetContentType("application/json")

    //Se o id estiver vazio
    If Empty(cJsonBody)
        Self:setStatus(500)
        oResponse["errorId"]  := "LOG001"
        oResponse["error"]    := "Body vazio"
        oResponse["solution"] := "Informe o Body"
    Else
        //Pega o JSON enviado no body e transforma em objeto
        oJsonBody  := JsonObject():New()
        cError := oJsonBody:FromJson(cJsonBody)

        //Se tiver algum erro no Parse, encerra a execução
        IF ! Empty(cError)
            Self:setStatus(500)
            oResponse["errorId"]  := "LOG002"
            oResponse["error"]    := "Parse do JSON"
            oResponse["solution"] := "Erro ao fazer o Parse do JSON do Body, verifique a estrutura do JSON"
        Else
            //Pega os parâmetros do body
            cTable    := Alltrim(oJsonBody:GetJsonObject('table'))
            cKey      := Alltrim(oJsonBody:GetJsonObject('key'))
            cContents := Alltrim(oJsonBody:GetJsonObject('contents'))

            //Se a tabela, a chave ou o conteúdo estiver vazio
            If Empty(cTable) .Or. Empty(cKey) .Or. Empty(cContents)
                Self:setStatus(500)
                oResponse["errorId"]  := "LOG003"
                oResponse["error"]    := "Tabela, Chave ou Conteúdo vazio(s)"
                oResponse["solution"] := "Informe corretamente a tabela, a chave e o conteúdo"
            Else
                //Caso seja uma chave composta, transforma em um array
                aKey      := StrTokArr(cKey, "+")
                aContents := StrTokArr(cContents, "+")

                //Monta a busca na tabela, buscando o total de registros
                cQueryAux := " SELECT " + CRLF
                cQueryAux += "     COUNT(*) AS TOTAL " + CRLF
                cQueryAux += " FROM " + CRLF
                cQueryAux += "     " + RetSQLName(cTable) + " AS TAB " + CRLF
                cQueryAux += " WHERE " + CRLF
                cQueryAux += "     D_E_L_E_T_ = ' ' " + CRLF

                //Percorre os campos da chave
                For nField := 1 To Len(aKey)
                    //Se tiver a posição no array de conteúdo
                    If nField <= Len(aContents)
                        cField   := aKey[nField]
                        cContAux := aContents[nField]

                        //Se for um campo de Data, e tiver -, retira o hífen
                        If GetSX3Cache(cField, "X3_TIPO") == "D" .And. "-" $ cContAux
                            cContAux := StrTran(cContAux, "-", "")

                        //Se for campo caractere, adiciona apóstrofo
                        ElseIf GetSX3Cache(cField, "X3_TIPO") == "C"
                            cContAux := "'" + cContAux + "'"
                        EndIf

                        //Agora adiciona na query campo = valor
                        cQueryAux += "     AND " + cField + " = " + cContAux + " " + CRLF
                    EndIf
                Next

                //Executa a query e armazena o total
                TCQuery cQueryAux New Alias "QRY_AUX"
                nTotal := QRY_AUX->TOTAL
                QRY_AUX->(DbCloseArea())

                //No retorno, coloca o total de registros (ai na aplicação, verifica se é igual a 0 ou maior)
                oResponse["total"] := nTotal
            EndIf
        EndIf
    EndIf

    //Define o retorno
    Self:SetResponse(oResponse:toJSON())
Return lRet

/*
Exemplo do JSON para criar / atualizar registros
É necessário informar:
    + A tabela
    + A chave (se existir será update, se não será insert), se for mais de um campo concatenar pelo caractere +
    + Os campos, sendo um array, composto pelo nome do campo e pelo conteúdo (se for data, usar YYYY-MM-DD)

Obs.: Caso queira passar um ini padrão em um campo, passe com # na função, por exemplo, {"fieldname": "QG_CURRIC" , "contents": "#GetSX8Num('SQG','QG_CURRIC')"}

Exemplo 1 (Currículos):
{
    "table": "SQG",
    "key": "QG_CIC",
	"fields" : [
		{
			"fieldname": "QG_NOME",
			"contents": "Daniel"
		},
		{
			"fieldname": "QG_DTCAD",
			"contents": "2022-01-13"
		},
		{
			"fieldname": "QG_PRETSAL",
			"contents": 1200
		},
	]
}

Exemplo 2 (Clientes):
{
    "table": "SA1",
    "key": "A1_COD+A1_LOJA",
	"fields" : [
		{
			"fieldname": "A1_COD",
			"contents": "000000"
		},
		{
			"fieldname": "A1_LOJA",
			"contents": "00"
		},
		{
			"fieldname": "A1_NOME",
			"contents": "Daniel"
		}
	]
}
*/

WSMETHOD POST SAVE WSRECEIVE WSSERVICE WSInputData
    Local lRet       := .T.
    Local cJsonBody  := Self:GetContent()
    Local oJsonBody
    Local cError     := ""
    Local oResponse  := JsonObject():New()
    Local cTable     := ""
    Local cKey       := ""
    Local cAfterExec := ""
    Local oFields
    Local aKey       := {}
    Local cQueryAux  := ""
    Local nKey       := 0
    Local nField     := 0
    Local cField     := ""
    Local cContAux   := ""
    Local cMessage   := ""
    Local nRecNo     := 0
    Local xContAux
    Local aStruct    := {}
    //Local cInit      := ""
    Local cTitle     := ""
    Local cNote      := ""
    Local cType      := ""
    //Local cUsed      := ""
    Local aSubstit := {}
    Local nPosiSub := 0
    Local cReturn  := ""

    //Define o tipo do retorno
    Self:SetContentType("application/json")

    //Se o id estiver vazio
    If Empty(cJsonBody)
        Self:setStatus(500)
        oResponse["errorId"]  := "LOG004"
        oResponse["error"]    := "Body vazio"
        oResponse["solution"] := "Informe o Body"
    Else
        //Pega o JSON enviado no body e transforma em objeto
        oJsonBody  := JsonObject():New()
        cError := oJsonBody:FromJson(cJsonBody)

        //Se tiver algum erro no Parse, encerra a execução
        If ! Empty(cError)
            Self:setStatus(500)
            oResponse["errorId"]  := "LOG005"
            oResponse["error"]    := "Parse do JSON"
            oResponse["solution"] := "Erro ao fazer o Parse do JSON do Body, confira a estrutura do JSON enviado"
        Else
            //Pega os parâmetros do body
            cTable     := Alltrim(oJsonBody:GetJsonObject('table'))
            cKey       := Alltrim(oJsonBody:GetJsonObject('key'))
            If (oJsonBody:GetJsonObject('afterExecute') != Nil)
                cAfterExec := Alltrim(oJsonBody:GetJsonObject('afterExecute'))
            EndIf
            cReturn    := Alltrim(oJsonBody:GetJsonObject('return'))
            oFields   := oJsonBody:GetJsonObject('fields')

            //Se a tabela, a chave ou o conteúdo estiver vazio
            If Empty(cTable) .Or. Empty(cKey) .Or. Empty(oFields)
                Self:setStatus(500)
                oResponse["errorId"]  := "LOG006"
                oResponse["error"]    := "Tabela, Chave ou Campos vazio(s)"
                oResponse["solution"] := "Informe corretamente a tabela, a chave e os campos"
            Else
                //Somente se veio uma informação válida do WS
                If Len(oFields) > 0
                    //Caso seja uma chave composta, transforma em um array
                    aKey      := StrTokArr(cKey, "+")

                    //Monta a busca na tabela, buscando o total de registros
                    cQueryAux := " SELECT " + CRLF
                    cQueryAux += "     TAB.R_E_C_N_O_ AS TABREC " + CRLF
                    cQueryAux += " FROM " + CRLF
                    cQueryAux += "     " + RetSQLName(cTable) + " AS TAB " + CRLF
                    cQueryAux += " WHERE " + CRLF
                    cQueryAux += "     D_E_L_E_T_ = ' ' " + CRLF

                    //Percorre os campos da chave
                    For nKey := 1 To Len(aKey)
                        cField   := aKey[nKey]

                        //Percorre os campos enviados
                        For nField := 1 To Len(oFields)

                            //Se for o mesmo campo
                            If cField == Alltrim(oFields[nField]:GetJsonObject('fieldname'))
                                cContAux := Alltrim(oFields[nField]:GetJsonObject('contents'))

                                //Se for um campo de Data, e tiver -, retira o hífen
                                If GetSX3Cache(cField, "X3_TIPO") == "D" .And. "-" $ cContAux
                                    cContAux := StrTran(cContAux, "-", "")

                                //Se for campo caractere, adiciona apóstrofo
                                ElseIf GetSX3Cache(cField, "X3_TIPO") == "C"
                                    cContAux := "'" + cContAux + "'"
                                EndIf

                                //Agora adiciona na query campo = valor
                                cQueryAux += "     AND " + cField + " = " + cContAux + " " + CRLF
                                Exit
                            EndIf
                        Next
                    Next

                    //Executa a query e armazena o recno do registro
                    TCQuery cQueryAux New Alias "QRY_AUX"
                    If ! QRY_AUX->(EoF())
                        nRecNo    := QRY_AUX->TABREC
                    EndIf
                    QRY_AUX->(DbCloseArea())

                    //Pega a estrutura da tabela
                    DbSelectArea(cTable)
                    aStruct := (cTable)->(DbStruct())

                    //Tratativa para acionar a macro substituição antes do RecLock para não gerar dados vazios
                    For nField := 1 To Len(oFields)
                        cField   := Alltrim(oFields[nField]:GetJsonObject('fieldname'))
                        xContAux := oFields[nField]:GetJsonObject('contents')
                        cTitle   := GetSX3Cache(cField, "X3_TITULO")
                        cType    := GetSX3Cache(cField, "X3_TIPO")

                        //Somente se o campo existir na base
                        If ! Empty(cTitle)

                            //Se for Caractere, e o primeiro for sustenido, faz a execução, tirando o sustenido
                            If cType == "C" .And. Left(xContAux, 1) == "#"

                                //Só irá gravar se for inclusão
                                If nRecno == 0
                                    xContAux := &(SubStr(xContAux, 2))
                                    aAdd(aSubstit, xContAux)
                                EndIf
                            EndIf
                        EndIf
                    Next

                    //Se existir o registro, será uma atualização
                    If nRecno != 0
                        cMessage := "Registro alterado (RecNo: " + cValToChar(nRecNo) + ")"
                        ALTERA   := .T.
                        INCLUI   := .F.
                        (cTable)->(DbGoTo(nRecNo))
                        RecLock(cTable, .F.)

                    //Senão, será uma inclusão
                    Else
                        cMessage := "Registro incluido"
                        ALTERA   := .F.
                        INCLUI   := .T.
                        RecLock(cTable, .T.)

                        /*
                        //Percorre a estrutura, e executa os ini padrão dos campos
                        For nField := 1 To Len(aStruct)
                            cField := aStruct[nField][1]
                            cType  := GetSX3Cache(cField, "X3_TIPO")
                            cInit  := GetSX3Cache(cField, "X3_RELACAO")
                            cUsed  := GetSX3Cache(cField, "X3_USADO")

                            //Se for campo Real, for Caractere, tiver ini padrão e for usado
                            If GetSX3Cache(cField, "X3_CONTEXT") == "R" .And. cType == "C" .And. ! Empty(cInit) .And. X3Uso(cUsed)
                                &(cField) := &(cInit)
                            EndIf
                        Next
                        */
                    EndIf

                    //Percorre os campos
                    For nField := 1 To Len(oFields)
                        cField   := Alltrim(oFields[nField]:GetJsonObject('fieldname'))
                        xContAux := oFields[nField]:GetJsonObject('contents')
                        cTitle   := GetSX3Cache(cField, "X3_TITULO")
                        cType    := GetSX3Cache(cField, "X3_TIPO")
                        cPicture := Alltrim(GetSX3Cache(cField, "X3_PICTURE"))

                        //Somente se o campo existir na base
                        If ! Empty(cTitle)
                            //Se for um campo de Data
                            If cType == "D"
                                //Se tiver -, retira o hífen
                                If "-" $ xContAux
                                    xContAux := StrTran(xContAux, "-", "")
                                EndIf

                                //Agora transforma em data, via sToD
                                xContAux := sToD(xContAux)

                            //Se for Caractere, e o primeiro for sustenido, faz a execução, tirando o sustenido
                            ElseIf cType == "C" .And. Left(xContAux, 1) == "#"
                                //Só irá gravar se for inclusão
                                If INCLUI
                                    If Len(aSubstit) > nPosiSub
                                        nPosiSub++
                                        xContAux := aSubstit[nPosiSub]
                                    Else
                                        Loop
                                    EndIf

                                //Se for alteração, irá pular para esse campo não ser gravado
                                Else
                                    Loop
                                EndIf

                            //Se for caractere, e a máscara for @!, irá transformar para deixar tudo maiúsculo
                            ElseIf cType == "C" .And. cPicture == "@!"
                                xContAux := Upper(xContAux)
                            EndIf
                        Else
                            cNote += "Campo '" + cField + "' nao encontrado na base;"
                        EndIf

                        //Se for campo MEMO, irá salvar com replace
                        If cType == "M"
                            xContAux := StrTran(xContAux, ".rn.", CRLF)
                            Replace &(cField) with xContAux
                        Else
                            &(cField) := xContAux
                        EndIf
                    Next

                    //Destrava a tabela
                    (cTable)->(MsUnlock())

                    //Se existir função a executar após o lock (como a u_SPRSPM02() ao incluir / atualizar um currículo)
                    If ! Empty(cAfterExec)
                        &(cAfterExec)
                    EndIf

                    //No retorno, coloca a mensagem
                    oResponse["message"] := cMessage
                    oResponse["note"]    := cNote
                    oResponse["return"]  := (cTable)->(&(cReturn))
                Else
                    Self:setStatus(500)
                    oResponse["errorId"]  := "LOG007"
                    oResponse["error"]    := "Estrutura JSON"
                    oResponse["solution"] := "Não foram encontrados 'fields' na estrutura passada via JSON"
                EndIf
            EndIf
        EndIf
    EndIf

    //Define o retorno
    Self:SetResponse(oResponse:toJSON())
Return lRet
