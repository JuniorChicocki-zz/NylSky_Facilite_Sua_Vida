--drop table #tmpTransf

--select C�digoDeBarra, CD_Barra, Estoque, T.NO_Quantidade, (Estoque + T.NO_Quantidade) as estimativa  into #tmpTransf
--from Produtos P
--inner join synchro.dbo.tblTransferencias_detalhe T on t.CD_Barra = p.C�digoDeBarra
--where T.ID_Transferencia = 2165


select p.C�digoDeBarra, p.Estoque, #tmpTransf.estimativa
from Produtos P
inner join tblTransferencias_detalhe T on T.CD_Barra = p.C�digoDeBarra
inner join #tmpTransf on #tmpTransf.c�digodebarra = p.C�digoDeBarra
where p.Estoque <> #tmpTransf.estimativa and t.ID_Transferencia = 3252

select sum(estoque) as estProd from Produtos
select sum(estoque) as estcor from ces_corporate.dbo.Produtos_estoque

--update ces_est_01.dbo.tblEstoque_Movimento set VL_Custo_gerencial_credito = 0 where VL_Custo_gerencial_credito is null

