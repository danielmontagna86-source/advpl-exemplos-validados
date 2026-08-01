/*

    Esse é um exemplo disponibilizado no Terminal de Informação
    Confira o artigo sobre esse assunto, no seguinte link: https://terminaldeinformacao.com/2025/11/25/mostrando-a-descricao-do-produto-na-sd1-ti-responde-0206/

*/


//Bibliotecas
#Include "TOTVS.ch"

/*/{Protheus.doc} User Function MT103IPC
Atualiza os itens do Documento de Entrada conforme o Pedido de Compras
@type  Function
@author Atilio
@since 02/09/2024
@see https://tdn.totvs.com/display/public/PROT/MT103IPC+-+Atualiza+campos+customizados+no+Documento+de+Entrada
/*/

User Function MT103IPC()
    Local aArea     := GetArea()
    Local nLinha    := ParamIXB[1]

    //Aciona nossa customização para preencher a descrição do produto
    u_zVid0206(nLinha)

    FWRestArea(aArea)
Return

/*/{Protheus.doc} User Function zVid0206
Preenche a descrição do produto, conforme o que estava no pedido de compras
@type  Function
@author Atilio
@since 02/09/2024
/*/

User Function zVid0206(nLinha)
    Local aArea     := FWGetArea()
    Local nPosDesc  := GDFieldPos("D1_X_DESCR")

    //Atualiza a descrição do produto, conforme o pedido de compra
    If ! Empty(SC7->C7_DESCRI)
        aCols[nLinha][nPosDesc] := SC7->C7_DESCRI
    EndIf

    FWRestArea(aArea)
Return
