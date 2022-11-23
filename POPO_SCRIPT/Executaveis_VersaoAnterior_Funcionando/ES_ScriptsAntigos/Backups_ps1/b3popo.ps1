Clear-Host

Import-Module SimplySql
Get-Module SimplySql

$password=ConvertTo-SecureString "dtopassb3" -AsPlainText -Force
$cred=New-Object System.Management.Automation.PSCredential("dtouserb3",$password)

Open-MySqlConnection -server "10.10.0.3" -database "dto_keys" -Credential ($cred)

#..................................................................................................................

#FUNCAO PARA PEGAR UMA NOVA CHAVE NO BANCO
function getKeyDb {
    
    $requisitionResult = Invoke-SqlQuery "SELECT idkey,keycontent FROM general_keys WHERE keystate=0 LIMIT 1;";
    
    if ($requisitionResult -eq $null){

        Write-Host "!!!!!!!   BANCO DE DADOS VAZIO | COLOCAR MAIS CHAVES !!!!!!!!!" -ForegroundColor yellow
        break

    }else{

        return $requisitionResult
    
    }

}

#FUNCAO QUE MUDA O STATUS DA CHAVE PARA CHAVE EM USO
function setStateUsing {

    Invoke-SqlUpdate "UPDATE general_keys SET keystate=1,bancada='b3' WHERE idkey=$idkey;"

}

#FUNCAO QUE MUDA O STATUS DA CHAVE PARA BLOQUEADA
function setStateForBloqued{
    Write-Host "BLOQUEADA"
    $idkey
    $keycontent
    Write-Host "BLOQUEADA"

    Invoke-SqlUpdate "UPDATE general_keys SET keystate=2 WHERE idkey=$idkey;"

}

#FUNCAO QUE MUDA STATUS PARA ATIVADA ATUALIZANDO SERIAL
function setStateForActived{

    Write-Host "ATIVADA"

    $idkey
   
    Write-Host "ATIVADA"
    
    $array = @(wmic bios get serialnumber)
    $serialnumber = $array[2]

    Invoke-SqlUpdate "UPDATE general_keys SET serialcontent='$serialnumber',keystate=3 WHERE idkey=$idkey;"

}

#..................................................................................................................


function ativation {

    Write-Host "------------------TUPINAMPAI------------------" -ForegroundColor DarkYellow`n
    ##**===========================================================================================================================
    ## Estrutura de loop para a ativação e tratamento de erros do sistema

    :loop
    for ($i = 0; $i -ne 1) {
        ##*===============================================
        ## Recebimento da chave do windows
        $chave = getKeyDb
        $idkey = $chave[0]
        $keycont=$chave[1]
        setStateUsing
        ##*===============================================


        ##*===============================================
        #Código de instalação da chave na máquina. 
        $logVbsIpk = cscript slmgr.vbs /ipk $keycont 
        ##*===============================================



        ##*====================================================================================
        #Estrutura de condição if que verifica se a chave do windows foi instalado com sucesso.

        if ($logVbsIpk | sls "instalada com êxito."){$i = 1, (Write-Host "Chave válida e instalada com SUCESSO!!!"-ForegroundColor green)}
        else {$i= 0,(Write-Host "Chave inválida Por favor tente novamente..."`n -ForegroundColor red)}
        $logVbsIpk
        ##*====================================================================================



        ##*====================================================================================
        #Estrutura de condição for e if que verifica se a chave do windows ativou o windows com sucesso.

        for ($i = 0; $i -ne 1) {

            #Código de ativação da chave que foi instalada na máquina. 
            $logVBS = cscript slmgr.vbs /ato 
  
            if ($logVBS | sls "Produto ativado com êxito."){setStateForActived $i = 1, (Write-Host "Máquina Ativada com SUCESSO!!!"-ForegroundColor green)} 
            else {setStateForBloqued Write-Host "Chave Bloqueada Por favor tente novamente..."`n -ForegroundColor red
            break :loop}
            $logVBS
            ##*====================================================================================
            $logDLI = cscript slmgr.vbs /dli
            if ($logDLI | sls "Licenciado"){$i = 1,(Write-Host "Licenciado com SUCESSO!!!"-ForegroundColor green)} else {"Derrota"}
            $logDLI

        }

    }
}


ativation