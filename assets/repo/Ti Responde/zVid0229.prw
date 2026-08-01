/*

    Esse é um exemplo disponibilizado no Terminal de Informação
    Confira o artigo sobre esse assunto, no seguinte link: https://terminaldeinformacao.com/2026/03/26/mostrar-o-nome-do-cliente-ou-fornecedor-no-pedido-de-venda-ti-responde-0229/

*/


//Bibliotecas
#Include "TOTVS.ch"

/*/{Protheus.doc} zVid0229
Função que busca o nome do cliente ou fornecedor para colocar no pedido de venda
@type user function
@author Atilio
@since 28/07/2025
@version version
@return cNome, Caractere, Nome do Cliente ou Fornecedor
@obs Se for Contexto Real, passos:
    1. Criar o campo C5_X_NOME do tipo Caractere com o mesmo tamanho do A1_NOME e A2_NOME
    2. Criar um gatilho do campo C5_CLIENTE para o C5_X_NOME acionando u_zVid0229() - Obs.: Se usar o campo loja, criar também um gatilho do campo C5_LOJACLI

    Se for Contexto Virtual, passos:
    1. Criar o campo C5_X_NOME do tipo Caractere com o mesmo tamanho do A1_NOME e A2_NOME
    2. Criar um gatilho do campo C5_CLIENTE para o C5_X_NOME acionando u_zVid0229() - Obs.: Se usar o campo loja, criar também um gatilho do campo C5_LOJACLI
    3. Colocar no Inic. Padrão do campo, a expressão: u_zVid0229()
    4. Colocar no Inic. Browse do campo, a expressão: u_zVid0229()
/*/

User Function zVid0229()
    Local aArea   := FWGetArea()
    Local cNome   := ""
    Local cTipo   := ""
    Local cCodigo := ""
    Local cLoja   := ""

    //Se for uma inclusão ou cópia, pega da memória
    If FWIsInCallStack("a410Inclui") .Or. FWIsInCallStack("a410Copia")
        cTipo   := M->C5_TIPO
        cCodigo := M->C5_CLIENTE
        cLoja   := M->C5_LOJACLI

    //Senão, pega o que está salvo na tabela
    Else
        cTipo   := SC5->C5_TIPO
        cCodigo := SC5->C5_CLIENTE
        cLoja   := SC5->C5_LOJACLI
    EndIf

    //Se o tipo for B ou D, pega da tabela de Fornecedores (SA2)
    If cTipo $ "B;D;"
        DbSelectArea("SA2")
        SA2->(DbSetOrder(1)) // A2_FILIAL + A2_COD + A2_LOJA

        //Se conseguir posicionar
        If SA2->(MsSeek(FWxFilial("SA2") + cCodigo + cLoja))
            cNome := SA2->A2_NOME
        EndIf

    //Senão, pega da tabela de Clientes (SA1)
    Else
        DbSelectArea("SA1")
        SA1->(DbSetOrder(1)) // A1_FILIAL + A1_COD + A1_LOJA

        //Se conseguir posicionar
        If SA1->(MsSeek(FWxFilial("SA1") + cCodigo + cLoja))
            cNome := SA1->A1_NOME
        EndIf
    EndIf

    FWRestArea(aArea)
Return cNome
