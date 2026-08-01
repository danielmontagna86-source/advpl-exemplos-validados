/*

    Esse é um exemplo disponibilizado no Terminal de Informação
    Confira o artigo sobre esse assunto, no seguinte link: https://terminaldeinformacao.com/2025/12/16/mostrando-acentuacao-numa-api-feita-em-rest-ti-responde-0212/

*/


//Bibliotecas
#Include "Totvs.ch"
#Include "RESTFul.ch"

/*/{Protheus.doc} WSRESTFUL zWsTest
Teste Acentuação
@author Atilio
@since 14/09/2024
@version 1.0
@type wsrestful
/*/

WSRESTFUL zWsTest DESCRIPTION 'Teste Acentuação'
    //Métodos
    WSMETHOD GET    TST1    DESCRIPTION 'Retorna mensagem de teste (com problemas)'  WSSYNTAX '/zWsTest/get_tst1'                       PATH 'get_tst1'        PRODUCES APPLICATION_JSON
    WSMETHOD GET    TST2    DESCRIPTION 'Retorna mensagem de teste (com acentuação)' WSSYNTAX '/zWsTest/get_tst2'                       PATH 'get_tst2'        PRODUCES APPLICATION_JSON
    WSMETHOD GET    TST3    DESCRIPTION 'Retorna mensagem de teste (cp1252)'         WSSYNTAX '/zWsTest/get_tst3'                       PATH 'get_tst3'        PRODUCES APPLICATION_JSON
END WSRESTFUL

/*/{Protheus.doc} WSMETHOD GET TST1
Mensagem de teste (que terá problemas)
@author Atilio
@since 14/09/2024
@version 1.0
@type method
/*/

WSMETHOD GET TST1 WSSERVICE zWsTest
    Local lRet       := .T.
    Local jResponse  := JsonObject():New()

    //Monta uma mensagem que tenha descrição
    jResponse['id']  := 1
    jResponse['obs'] := "Mensagem em CP1252 enviando no padrao UTF-8"
    jResponse['msg'] := "O sabiá não sabia que o sábio sabia que o sabiá não sabia assobiar."
    Self:SetContentType('application/json')
    Self:SetResponse(jResponse:toJSON())
Return lRet

/*/{Protheus.doc} WSMETHOD GET TST2
Mensagem de teste (com acentuação)
@author Atilio
@since 14/09/2024
@version 1.0
@type method
/*/

WSMETHOD GET TST2 WSSERVICE zWsTest
    Local lRet       := .T.
    Local jResponse  := JsonObject():New()

    //Define o retorno
    jResponse['id']  := 2
    jResponse['obs'] := "Enviando no padrão UTF-8 convertendo a string de CP1252 com EncondeUTF8"
    jResponse['msg'] := "O sabiá não sabia que o sábio sabia que o sabiá não sabia assobiar."
    Self:SetContentType('application/json') //Quando não manda nada, o charset fica como utf-8
    Self:SetResponse(EncodeUTF8(jResponse:toJSON()))
Return lRet

/*/{Protheus.doc} WSMETHOD GET TST3
Mensagem de teste (com acentuação, usando cp1252)
@author Atilio
@since 14/09/2024
@version 1.0
@type method
/*/

WSMETHOD GET TST3 WSSERVICE zWsTest
    Local lRet       := .T.
    Local jResponse  := JsonObject():New()

    //Monta uma mensagem que tenha descrição
    jResponse['id']  := 3
    jResponse['obs'] := "String em CP1252 e modificando o charset direto no content-type"
    jResponse['msg'] := "O sabiá não sabia que o sábio sabia que o sabiá não sabia assobiar."
    Self:SetContentType('application/json;  charset=cp1252;')
    Self:SetResponse(jResponse:toJSON())
Return lRet
