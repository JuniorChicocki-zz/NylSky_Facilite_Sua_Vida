CREATE PROCEDURE [dbo].[sp_GravaIntegracaoExpedicao](@NumeroCarga VARCHAR(6), @IdUsuario INT)
AS BEGIN
    DECLARE @Registros AS INTEGER;
    IF(ISNULL(@NumeroCarga, ''))='' BEGIN
        RETURN;
    END;
    SET @NumeroCarga=(CASE WHEN ISNULL(@NumeroCarga, '')='' THEN '-1' ELSE @NumeroCarga END);
    SELECT      tmpCargas.IdPreVenda, Venda.CódigoDoCliente AS IdCliente
    INTO        #tmpPedidos
    FROM        (SELECT DISTINCT DetalheCarga.[NúmeroDoPedido] AS IdPreVenda
                 FROM   [Detalhes das Cargas] DetalheCarga
                 WHERE  DetalheCarga.NúmeroDaCarga=@NumeroCarga) AS tmpCargas
    INNER JOIN  [Pre Venda] Venda ON Venda.NumeroDaPreVenda=tmpCargas.IdPreVenda
    WHERE       Venda.NumeroDaPreVenda NOT IN(SELECT    tblIntegracao_Expedicao.NO_Entrega
                                              FROM      tblIntegracao_Expedicao
                                              WHERE     NO_Carga=@NumeroCarga);
    IF(SELECT   COUNT(DISTINCT IdPreVenda)FROM  #tmpPedidos)>0 BEGIN
        SELECT      Itens.NumeroDaPreVenda, Itens.CódigoDoProduto AS Id_Produto, Produtos.CódigoDaFábrica AS CD_Automacao, Itens.Quantidade AS NO_Quantidade, (CAST(Itens.Quantidade AS DECIMAL(16, 2))/ CAST(ISNULL(Produtos.divisor, 1) AS DECIMAL(16, 2))) AS NO_Volume, (Produtos.VL_Peso) AS NO_Peso_liquido, CAST((((CAST(Produtos.VL_Peso AS DECIMAL(16, 2))+Produtos.VL_TaraCaixa))/ CAST(ISNULL(Produtos.divisor, 1) AS DECIMAL(16, 2))* CAST(Itens.Quantidade AS DECIMAL(16, 2))) AS DECIMAL(16, 2)) AS NO_Peso_bruto, Itens.Quantidade AS QtdePedido
        INTO        #tmpItens
        FROM        [Detalhes da Pre Venda] Itens
        INNER JOIN  #tmpPedidos ON #tmpPedidos.IdPreVenda=Itens.NumeroDaPreVenda
        INNER JOIN  Produtos ON Produtos.CódigoDeBarra=Itens.CódigoDoProduto;
        INSERT INTO tblIntegracao_Expedicao_Destinatario(ID_Cliente, NM_Razao, NM_Fantasia, DS_Endereco, NM_Bairro, NM_Cidade, SG_UF, NO_Telefone, Cnpj, NO_CEP, NO_IE)
                    SELECT  Clientes.[CódigoDoCliente], Clientes.DS_Razao_social, Clientes.NomeDoCliente, Clientes.[Endereço], Clientes.Bairro, Clientes.Cidade, Clientes.UF, Clientes.Telefone, Clientes.CgcCpf, Clientes.CEP, Clientes.InscRg
                    FROM    Clientes
                    WHERE   Clientes.CgcCpf NOT IN(SELECT   Cnpj FROM   tblIntegracao_Expedicao_Destinatario)AND Clientes.CódigoDoCliente IN(SELECT DISTINCT IdCliente FROM #tmpPedidos);
        INSERT INTO tblIntegracao_Expedicao(ID_Cliente, NO_Entrega, NO_Carga, DT_Expedicao, NO_Status, TP_Validada, ID_Destinatario, ID_Usuario)
                    SELECT      Venda.[CódigoDoCliente], NumeroDaPreVenda, @NumeroCarga, CURRENT_TIMESTAMP, 0, 0, Destinatario.ID, @IdUsuario
                    FROM        [Pre Venda] Venda
                    INNER JOIN  Clientes ON Clientes.[CódigoDoCliente]=Venda.[CódigoDoCliente]
                    INNER JOIN  tblIntegracao_Expedicao_Destinatario Destinatario ON Destinatario.Cnpj=Clientes.CgcCpf
                    WHERE       Venda.NumeroDaPreVenda IN(SELECT    DISTINCT   IdPreVenda FROM #tmpPedidos);
        INSERT INTO tblIntegracao_Expedicao_Item(ID_Expedicao, ID_Produto, CD_Automacao, NO_Quantidade, NO_Volume, NO_Peso_bruto, NO_Peso_liquido, QtdePedido)
                    SELECT  (SELECT TOP 1   Expedicao.ID
                             FROM   tblIntegracao_Expedicao Expedicao
                             WHERE  Expedicao.NO_Carga=CAST(@NumeroCarga AS INT)AND Expedicao.NO_Entrega=CAST(#tmpItens.NumeroDaPreVenda AS INT)),
                            #tmpItens.Id_Produto,
                            #tmpItens.CD_Automacao,
                            CAST(#tmpItens.NO_Quantidade AS DECIMAL(16, 2)),
                            #tmpItens.NO_Volume,
                            #tmpItens.NO_Peso_bruto,
                            CAST(#tmpItens.NO_Peso_liquido AS DECIMAL(16, 2)),
                            CAST(#tmpItens.QtdePedido AS DECIMAL(16, 2))
                    FROM    #tmpItens;
        UPDATE  [Pre Venda]
        SET     TP_Fechado=0
        WHERE   NumeroDaPreVenda IN(SELECT  IdPreVenda FROM #tmpPedidos);
    END;
    DROP TABLE #tmpItens;
    DROP TABLE #tmpPedidos;
END;
