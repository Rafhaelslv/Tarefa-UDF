/*1. Criar uma database, criar as tabelas abaixo, definindo o tipo de dados e a relação PK/FK e popular
com alguma massa de dados de teste (Suficiente para testar UDFs)
Funcionário (Código, Nome, Salário)
Dependendente (Código_Dep, Código_Funcionário, Nome_Dependente, Salário_Dependente)
a) Código no Github ou Pastebin de uma Function que Retorne uma tabela:
(Nome_Funcionário, Nome_Dependente, Salário_Funcionário, Salário_Dependente)
b) Código no Github ou Pastebin de uma Scalar Function que Retorne a soma dos Salários dos
dependentes, mais a do funcionário.*/
USE master
DROP DATABASE UDF
CREATE DATABASE UDF
GO
USE UDF
GO
CREATE TABLE FUNCIONARIO(
cod_func			INT				NOT NULL,
nome_func			VARCHAR(50)		NOT NULL,
salario_func		DECIMAL(7,2)	NOT NULL
PRIMARY KEY (cod_func)
)
GO

CREATE TABLE DEPENDENTE(
cod_dep			INT				NOT NULL,
cod_func		INT				NOT NULL,
nome_dep		VARCHAR(50)		NOT NULL,
salario_dep		DECIMAL(7,2)	NOT NULL
PRIMARY KEY (cod_dep),
FOREIGN KEY (cod_func) REFERENCES FUNCIONARIO (cod_func)
)

INSERT INTO FUNCIONARIO VALUES
(1, 'Fulano', 1000.0),
(2, 'Beltrano', 1200.0),
(3, 'Cicrano', 2000.0)

INSERT INTO DEPENDENTE VALUES
(3 ,1, 'Sapopembo', 1050.0),
(4, 2, 'Osasco', 1250.0),
(7, 3, 'favela', 2005.0),
(9, 2, 'alemao', 1250.0),
(5, 3, 'fafa', 2005.0)



SELECT * FROM DEPENDENTE
SELECT * FROM FUNCIONARIO

-- Criando função
CREATE FUNCTION fn_salario()
RETURNS @tabela TABLE (
    nome_func VARCHAR(50),
    nome_dep VARCHAR(50),
    salario_func DECIMAL(7,2),
    salario_dep DECIMAL(7,2)
)
AS
BEGIN
    INSERT INTO @tabela (nome_func, nome_dep, salario_func, salario_dep)
    SELECT f.nome_func, d.nome_dep, f.salario_func, d.salario_dep
    FROM FUNCIONARIO f
    INNER JOIN DEPENDENTE d ON d.cod_func = f.cod_func;

    RETURN
END

-- Chamada da função
SELECT * FROM fn_salario()

--Scalar Function que Retorne a soma dos Salários dos dependentes, mais a do funcionário

CREATE FUNCTION fn_soma_salario2 (@cod_funcionario INT)
RETURNS DECIMAL(7,2)
AS
BEGIN
    DECLARE @total_salario DECIMAL(7,2);

    SELECT @total_salario = ISNULL(SUM(salario_dep), 0) + (SELECT salario_func FROM FUNCIONARIO WHERE cod_func = @cod_funcionario)
    FROM DEPENDENTE
    WHERE cod_func = @cod_funcionario;

    RETURN @total_salario
END

SELECT dbo.fn_soma_salario2(3)



/*2. Fazer uma Function que retorne
a) a partir da tabela Produtos (codigo, nome, valor unitário e qtd estoque), quantos produtos
estão com estoque abaixo de um valor de entrada
b) Uma tabela com o código, o nome e a quantidade dos produtos que estão com o estoque
abaixo de um valor de entrada
*/

CREATE TABLE PRODUTOS (
codigo			INT				NOT NULL, 
nome			VARCHAR(50)		NOT NULL, 
valor_uni		DECIMAL(7, 2)	NOT NULL,
qtd_estoque		INT				NOT NULL
primary key (codigo)
)

INSERT INTO PRODUTOS VALUES
(3 ,'Xbox', 1050.0, 4),
(10 ,'PS4', 1250.0, 10),
(6 ,'Xbox One', 2350.0, 6),
(9 ,'Xbox Series', 3050.0, 15),
(1 ,'PS5', 3700.0, 12)

CREATE FUNCTION fn_baixo_estoque()
RETURNS @tabela TABLE(
nome			VARCHAR(50),
qtd_estoque		int
)
BEGIN
	INSERT INTO @tabela (nome, qtd_estoque)
	SELECT nome, qtd_estoque
	FROM PRODUTOS

	RETURN
END

SELECT dbo.fn_baixo_estoque()
WHERE qtd__estoque < 10


/*3. Criar, uma UDF, que baseada nas tabelas abaixo, retorne
Nome do Cliente, Nome do Produto, Quantidade e Valor Total, Data de hoje
Tabelas iniciais:
Cliente (Codigo, nome)
Produto (Codigo, nome, valor)
*/