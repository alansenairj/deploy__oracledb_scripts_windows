@echo off
setlocal enabledelayedexpansion
chcp 850 > nul

:: Parte da composição do comando sqlplus. Tratamento da execução com ou sem argumentos para ativar padrão ou não. 
if "%~1"=="" (
    echo Executando os scripts utilizando argumentos...
    set "user=ebop"
    set "password=123"
    set "SID=banco_dev_csi"
) else (
    set "user=%~1"
    set "password=%~2"
    set "SID=%~3"
)

:: parte wellcome e versão
echo.
echo "Bem vindo ao bat de deployment de scripts sql da CSI para a Unimed BH."
echo "Esse script executa todos os arquivos contidos dentro da pasta deploy."
echo "Esse script gera um arquivo de logs contendo os resultados da execução de cada script. "
echo "Ao término da execução, envie o arquivo de logs para a CSI avaliar o resultado."
echo " Utilização:  <user> <password> <SID> "
echo "Esse script já possui usuário, senha e SID padrão, mas pode ser passado junto da execução do comando."
echo " Exemplo: deploy_script.bat ebop 123 db_prd"
echo.
set /p "VERSION=Digite a versão do deployment (ex. 05_25_00): "

:: parte das variáveis de log, data e path
:: type nul > ".\db.log"
::set "LOG=.\db.log"

:: Puxar o diretório para o log ser salvo
set "SCRIPT_DIR=%cd%"

:: Ajustando o path do log para receber o redirect
set "LOG=!SCRIPT_DIR!\db%VERSION%.log"
echo o aruivo de logs está em
echo %LOG%

:: Criando o diretório de trabalho e ajuste da data
mkdir .\deploy
set "DEPLOY_DATE=%date%_%time%"
set SOURCEFOLDER=..\cad-qas-database-%VERSION%_win\database\%VERSION%_win\
set DESTINATIONFOLDER=.\deploy\
echo %DEPLOY_DATE%
echo %DEPLOY_DATE% >> %LOG%

:: parte para movimentar os arquivos
echo "=======================================" >> %LOG%
echo MOVENDO OS ARQUIVOS PARA %DESTINATIONFOLDER% >> %LOG%
mkdir %DESTINATIONFOLDER% 2>nul >> %LOG%
if exist %SOURCEFOLDER% (
    move %SOURCEFOLDER%* %DESTINATIONFOLDER% >> %LOG%
    echo Arquivos do Deployment movidos para a pasta DEPLOY com sucesso. >> %LOG%
    echo "=======================================" >> %LOG%
) else (
    echo A pasta de origem não foi encontrada. >> %LOG%
)

:: escrever "exit" dentro de cada sql
echo "=======================================" >> %LOG%
echo Inserindo exit dentro de cada arquivo sql
    pushd %DESTINATIONFOLDER% >> %LOG%
    for %%f in (*.sql) do (
        echo. >> %%f
		echo exit; >> %%f
    )
    popd
echo texto exit inserido em cada arquivo sql. 
echo "=======================================" >> %LOG%

:: ir para o path dos arquivos .sql
cd /d "%DESTINATIONFOLDER%" >> %LOG%
echo Entrando no diretório %cd%
echo %cd% >> %LOG%

:: loop de execução de scripts sql
for %%f in (*.sql) do (

    echo INICIADO : %DEPLOY_DATE% >> %LOG%
    echo "======================================="
    echo EXECUTANDO O SCRIPT: %%f
    echo EXECUTANDO O COMANDO SQLPlus ... >> %LOG%
    sqlplus -S !user!/!password!@!SID! @%%f >> %LOG% 2>&1
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
       
    )
)

:: mensagem de conclusão
echo. >> %LOG%
echo "###################################" >> %LOG%
echo TODOS OS SCRIPTS FORAM EXECUTADOS. >> %LOG%
echo "###################################" >> %LOG%
echo "Deployment terminado. Saindo do arquivo de lotes." >> %LOG%
