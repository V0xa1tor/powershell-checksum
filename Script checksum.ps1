#
# Script para gerar e comparar checksum de um arquivo
#
# Criador: Vítor Menezes Oliveira
# Data: 2025-06-17
#



Add-Type -AssemblyName System.Windows.Forms;

# File
$global:FileBrowser = New-Object System.Windows.Forms.OpenFileDialog;
$global:FileBrowser.InitialDirectory = $PSScriptRoot;
$global:OutputFile = "";

# Checksum
$global:FileChecksum = "";
$global:ChecksumToCompare = "";
$global:ChecksumsAreEqual = $false;

# Algorithm
$global:Algorithm = "MD5";
$global:Algorithms = "SHA1", "SHA256", "SHA384", "SHA512", "MACTripleDES", "MD5", "RIPEMD160";

#                  0      1      2       3       4       5
$global:Options = $true, $true, $false, $false, $false, $true;



function UI {
    Write-Host "";
    Write-Host " Script para gerar e comparar checksum de um arquivo";
    Write-Host "-----------------------------------------------------";
    Write-Host "";

    # Algoritmo
    Write-Host " Algoritmo: " -NoNewline;
    Write-Host -ForegroundColor Yellow $global:Algorithm;
    Write-Host "";

    # Arquivo selecionado
    Write-Host " Arquivo selecionado: " -NoNewline;
        if ($global:FileBrowser.FileName.Length -eq 0) { Write-Host -ForegroundColor DarkGray "[Nenhum]"; }
        else { Write-Host -ForegroundColor Yellow $global:FileBrowser.FileName; }

    # Checksum do arquivo
    $HashLabel = " Checksum do arquivo:";
    if ($global:FileBrowser.FileName.Length -eq 0) {
        Write-Host -ForegroundColor DarkGray ($HashLabel + " [Calcule o checksum]");
    } elseif ($global:FileChecksum.Length -eq 0) {
        Write-Host $HashLabel -NoNewline;
        Write-Host -ForegroundColor DarkGray (" [Calcule o checksum]");
    } else {
        Write-Host $HashLabel -NoNewline;
        # Comparação
        if (($global:FileChecksum.Length -gt 0) -and  ($global:ChecksumToCompare.Length -gt 0)) {
            if ($global:ChecksumsAreEqual) {
                Write-Host -ForegroundColor Green (" $global:FileChecksum");
            } else {
                Write-Host -ForegroundColor Red (" $global:FileChecksum");
            }
        } else {
            Write-Host -ForegroundColor Yellow (" $global:FileChecksum");
        }
    }

    # Comparar com (checksum)
    $ChecksumCompareLabel = "        Comparar com:";
    if($global:Options[3]) {
        if($global:ChecksumToCompare.Length -eq 0) {
            Write-Host $ChecksumCompareLabel -NoNewline;
            Write-Host -ForegroundColor DarkGray " [Checksum para comparar]";
        } else {
            Write-Host $ChecksumCompareLabel -NoNewline;
            # Comparação
            if (($global:FileChecksum.Length -gt 0) -and  ($global:ChecksumToCompare.Length -gt 0)) {
                if ($global:ChecksumsAreEqual) {
                    Write-Host -ForegroundColor Green (" $global:ChecksumToCompare");
                } else {
                    Write-Host -ForegroundColor Red (" $global:ChecksumToCompare");
                }
            } else {
               Write-Host -ForegroundColor Yellow (" $global:ChecksumToCompare");
            }
        }
    }
    else {
        Write-Host -ForegroundColor DarkGray ($ChecksumCompareLabel + " [Checksum para comparar]");
    }

    Write-Host "";
    Write-Host "-----------------------------------------------------";
    Write-Host "";

    $Option1 = " 1 - Selecionar arquivo";
    if ($global:Options[1]) { Write-Host $Option1; }
    else { Write-Host -ForegroundColor DarkGray $Option1; }

    $Option2 = " 2 - Calcular checksum do arquivo selecionado";
    if ($global:Options[2]) { Write-Host $Option2; }
    else { Write-Host -ForegroundColor DarkGray $Option2; }

    $Option3 = " 3 - Comparar checksum com outro";
    if ($global:Options[3]) { Write-Host $Option3; }
    else { Write-Host -ForegroundColor DarkGray $Option3; }

    $Option4 = " 4 - Exportar checksum para um arquivo de texto";
    if ($global:Options[4]) {
        $FilePath = $global:FileBrowser.FileName.Split("\");
        $FileName = $FilePath[$FilePath.Length - 1];
        $global:OutputFile = ($FileName + "." + $global:Algorithm.ToLower());
        Write-Host $Option4 -NoNewline;
        Write-Host -ForegroundColor Yellow (" `".\" + $global:OutputFile + "`"");
    } else { Write-Host -ForegroundColor DarkGray $Option4; }

    $Option5 = " 5 - Mudar o algoritmo";
    if ($global:Options[5]) { Write-Host $Option5; }
    else { Write-Host -ForegroundColor DarkGray $Option5; }

    $Option0 = " 0 - Sair";
    if ($global:Options[0]) { Write-Host $Option0; }
    else { Write-Host -ForegroundColor DarkGray $Option0; }

    Write-Host "";
}

function VerifyOptionsUI {

    # Option 1
    if(!$global:Options[1]) { $global:Options[1] = $true; }

    # Option 2
    if($global:FileBrowser.FileName.Length -eq 0) { $global:Options[2] = $false; }
    else { $global:Options[2] = $true; }

    # Option 3
    if($global:FileChecksum.Length -gt 0) { $global:Options[3] = $true; }
    else { $global:Options[3] = $false; }

    # Option 4
    if($global:FileChecksum.Length -gt 0) { $global:Options[4] = $true; }
    else { $global:Options[4] = $false; }

    # Option 5
    if(!$global:Options[5]) { $global:Options[5] = $true; }

    # Option 0
    if(!$global:Options[0]) { $global:Options[0] = $true; }
}

function SelectFile {
    if ($global:FileBrowser.ShowDialog() -eq "OK") {
        $global:FileChecksum = "";
        $global:ChecksumToCompare = "";
        $global:ChecksumsAreEqual = $false;
    }
}

function CalculateChecksum {

    # Verificar se o arquivo existe
    if (Test-Path $global:FileBrowser.FileName) {
        # Calcular checksum
        $global:FileChecksum = (Get-FileHash $global:FileBrowser.FileName -Algorithm $global:Algorithm).Hash.ToLower().Trim();
    } else {
        # Resetar informações
        $global:FileBrowser.Reset();
        $global:FileChecksum = "";
        $global:ChecksumToCompare = "";
        $global:ChecksumsAreEqual = $false;
    }
}

function CompareChecksum {
    Write-Host "";
    Write-Host "Informe o checksum para fazer a comparação";

    $input = (Read-Host "Checksum ($global:Algorithm)").Trim();
    if($input.Length -gt 0) {
        $global:ChecksumToCompare = $input;
        if($global:FileChecksum -eq $global:ChecksumToCompare) {
            $global:ChecksumsAreEqual = $true;
        } else {
            $global:ChecksumsAreEqual = $false;
        }
    }
}

function ExportChechsum {
    if($global:FileChecksum.Length -ne 0) {
        $global:FileChecksum | Out-File -FilePath ($PSScriptRoot + "\" + $global:OutputFile);
    }
}

function ChangeAlgorithm {
    Write-Host "";
    Write-Host "Algorítmos disponíveis:";
    Write-Host "";
    for($i = 0; $i -lt $global:Algorithms.Length; $i++) {
        Write-Host (" " + ($i+1) + " - ") -NoNewline;
        Write-Host -ForegroundColor Cyan $global:Algorithms[$i];
    }
    Write-Host "";

    $input = (Read-Host "Informe o algorítmo");
    if(([int]$input -ge 1) -and ([int]$input -le $global:Algorithms.Length)) {
        $global:FileChecksum = "";
        $global:ChecksumToCompare = "";
        $global:ChecksumsAreEqual = $false;
        $global:Algorithm = $global:Algorithms[([int]$input - 1)];
    } elseif ($global:Algorithms.Contains($input.ToString().ToUpper())) {
        $global:FileChecksum = "";
        $global:ChecksumToCompare = "";
        $global:ChecksumsAreEqual = $false;
        $global:Algorithm = $input.ToString().ToUpper();
    }
}



# Script loop
while($true) {
    VerifyOptionsUI;
    Clear-Host; # Clear UI
    Start-Sleep -Milliseconds 100;
    UI; # Draw UI

    try {
        $input = [int](Read-Host "Selecione uma opção");
        if ($global:Options[$input]) {
            switch ($input) {
                1 { SelectFile; }
                2 { CalculateChecksum; }
                3 { CompareChecksum; }
                4 { ExportChechsum; }
                5 { ChangeAlgorithm; }
                0 { Exit; }
            }
        }
    } catch { }
}
