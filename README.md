# Script em lote para implantação SQL

## Descrição

Este script em lote facilita a execução de scripts SQL para a Unimed BH utilizando o SQLPlus da Oracle. Ele executa arquivos SQL em um diretório de implantação especificado, gerando um arquivo de log que captura os resultados de cada execução de script.

# Uso
Execute o script usando o comando:
```
deploy_script.bat [user] [password] [SID]
```
Se executado sem argumentos, o script utiliza credenciais de usuário padrão: ebop, 123, banco_dev_csi.
Para fornecer usuário, senha e SID personalizados, passe-os como argumentos ao executar o script.
Exemplo:

```
deploy_script.bat ebop 123 db_prd

```
# Componentes

## tratamento da execução
com ou sem argumentos para ativar padrão ou não. Parte da composição do comando sqlplus

## Variáveis
```
user: usuário Oracle para acesso ao banco de dados.
password: Senha associada ao usuário Oracle.
SID: Identificador do Sistema (SID) da instância Oracle.
```
## Arquivo de log
LOG: Caminho do arquivo para o log contendo detalhes de 
execução do script.

## ir para o path dos arquivos .sql

```
cd /d "%DB_SCRIPTS_PATH%"
```

## DEPLOY_DATE: 
caminho do diretório para scripts SQL com pastas com carimbo de data/hora para cada implantação.

# Fluxo de Execução

Inicialização: Definir credenciais de usuário padrão se nenhum argumento for fornecido.

## Mensagem de boas-vindas: 
mensagem informativa sobre o propósito e uso do script.

# Loop de execução de script:
Itera todos os arquivos .sql no diretório de implantação.
Executa cada script SQL usando SQLPlus com as credenciais fornecidas ou padrão.
Registra detalhes de execução e erros no arquivo de log.

### tratamento de erros no Loop

```
    if !errorlevel! neq 0 (
        echo "###################################"
        echo "==================================="
        echo Ocorreu um erro na execução de %%f. Veja os logs em %LOG% para obter mais detalhes.
        echo "==================================="
        echo "###################################"
        rem tratamento das condições de erro
    ) else (
        echo "Comando SQLPlus para o script: %%f executado"
        echo Comando SQLPlus para o script: %%f executado >> %LOG%
```

## Mensagem de conclusão: 
Notifica a conclusão bem-sucedida da execução.
