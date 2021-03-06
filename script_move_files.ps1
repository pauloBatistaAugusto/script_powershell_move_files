#Autor: Paulo Augusto Batista
#Atualização: 13/01/2021
#Objetivo do Script: Mover os arquivos por ftp

try
{

 $server = "server"
 $dir = "dir"  

 $userFtp = "userFtp" 
 $passFtp = "passFtp"  

 $Logfile = "C:\Log\arquivo.log"
 $diretoriosComArquivosParaEnvio = "C:\scriptFtp\diretorios.txt"

 $diretorioAtual

 Function LogWrite
 {
    Param ([string]$logstring)
	
    $dataLog = Get-Date
    $dataLog = ($dataLog.toString("dd-MM-yyyy HH:mm:ss"))
    
    Add-content $Logfile -value  ("[" + $dataLog + "] - " + $logstring)
    
    #Se maior que 1MB apaga
    $arquivoLog = Get-Item $Logfile
    if($arquivoLog.length -gt 1mb)
     {
      $arquivoLog.Delete()
     }
 }
 
 #Percorre o arquivo txt com os diretorios parametrizados
  Get-Content $diretoriosComArquivosParaEnvio | Where-Object {$_ -match $regex} | ForEach-Object{
  
    $diretorioAtual = $_
    
    LogWrite ("Diretório atual: " + $diretorioAtual)
    $filelist = Get-ChildItem -Path $diretorioAtual -Filter *.txt -Recurse 
 
     foreach($item in $filelist)
     {
           
      $dateDataAtual = Get-Date
      $dateDataAtualMenos1 = $dateDataAtual.AddMinutes(-1)
      $dateDataUltimaEscritaNoArquivo = $item.LastWriteTime
       
      if($item.length -gt 0)
      {
        
      LogWrite ("Data atual: " + $dateDataAtual.toString("dd-MM-yyyy HH:mm:ss"))
      LogWrite ("Última escrita do arquivo: " + $dateDataUltimaEscritaNoArquivo.toString("dd-MM-yyyy HH:mm:ss"))
            
       if( $dateDataAtualMenos1 -gt $dateDataUltimaEscritaNoArquivo)#Se o arquivo com a última a escrita mais de 1 minuto copia para o local desejado
        {
       
         LogWrite ("Movendo arquivo: " + $item.fullname + " para: " + $server +"->" + $dir)
             
         "open $server 
         userFtp $userFtp $passFtp
         cd $dir     
         " +
         ($item.fullname | %{ "put ""$_""`n" }) | ftp -i -in
             
         $item.Delete()
         LogWrite ("Arquivo Apagado: "  + $item.fullname)
        }
      else
        {
         LogWrite ("Arquivo não vai ser movido, última escrita a menos de 1 minuto atrás: " + $item.fullname)
        }
      }
      else
      {
        LogWrite ("Diretório sem arquivos: " + $diretorioAtual)
      } 
     }
    }
 }
catch
{
  LogWrite $_.Exception.Message.toString(); 
}