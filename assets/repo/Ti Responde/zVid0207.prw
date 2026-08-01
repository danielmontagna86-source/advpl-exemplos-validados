/*

    Esse é um exemplo disponibilizado no Terminal de Informação
    Confira o artigo sobre esse assunto, no seguinte link: https://terminaldeinformacao.com/2025/11/27/preencher-informacoes-do-endereco-conforme-gatilho-do-campo-cep-ti-responde-0207/

*/


//Bibliotecas
#Include "TOTVS.ch"

/*/{Protheus.doc} User Function zVid0207
Função acionada na validação do campo de CEP na tela de Transportadoras
@type  Function
@author Atilio
@since 29/08/2024
@example u_zVid0207()
@obs Deve ser colocado no X3_VLDUSER (Validação de Usuário) da seguinte forma:
    Iif(ExistBlock("zVid0207"), u_zVid0207(), .T.)

    Como pré-requisito, deve ser feito o download da função zViaCEP adaptada pelo Súlivan Simões, disponível nesse link:
    https://terminaldeinformacao.com/2020/08/06/exemplo-de-integracao-com-viacep-usando-fwrest/

/*/

User Function zVid0207()
    Local aArea     := GetArea()
    Local lContinua := .T.
    Private jJson

    //Busca o CEP conforme o campo informado
    jJson := u_zViaCep(M->A4_CEP)

    //Se não veio erro
    If Type("jJson[erro]") == "U"
        //Atualiza os campos com o retorno da função
        M->A4_END     := AvKey(jJson['logradouro'], "A4_END    ")
        M->A4_BAIRRO  := AvKey(jJson['bairro'],     "A4_BAIRRO ")
        M->A4_MUN     := AvKey(jJson['localidade'], "A4_MUN    ")
        M->A4_EST     := AvKey(jJson['uf'],         "A4_EST    ")
        M->A4_COD_MUN := AvKey(jJson['ibge'],       "A4_COD_MUN")
        M->A4_DDD     := AvKey(jJson['ddd'],        "A4_DDD    ")

        //Atualiza a tela
        GetDRefresh()
    EndIf

    RestArea(aArea)
Return lContinua
