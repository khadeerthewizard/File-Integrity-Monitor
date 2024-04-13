$l = Get-Location
$counteq = $args.Count -eq 1
if(-not $counteq){
    Write-Host "Wrong Usage"
    Write-Host "Usage-> ./fim.ps1 [folder path to be monitored]"
    return
}

$tbm = $args[0]

Write-Host "Welcome to FIM"
Write-Host "1) Baseline Create"
Write-Host "2) Baseline Update"
Write-Host "3) Monitor"
$res = Read-Host "Enter your choice"

if($res -eq 1){
    $baselinePath = Join-Path $l baseline.csv
    if(Test-Path -Path $baselinePath){
        Write-Host "Baseline Already Exists"
    }
    else{
        $files = Get-ChildItem -Path $tbm
        "path,hash" | Out-File $baselinePath -Append
        foreach($file in $files){
            $hash = Get-FileHash -Path $file.FullName -Algorithm SHA512
            "$($hash.Path),$($hash.Hash)" | Out-File $baselinePath -Append
        }
    }
}
elseif ($res -eq 2) {
    $baselinePath = Join-Path $l baseline.csv
    if(Test-Path -Path $baselinePath){
        Remove-Item -Path $baselinePath
        "path,hash" | Out-File $baselinePath -Append
        $files = Get-ChildItem -Path $tbm
        foreach($file in $files){
            $hash = Get-FileHash -Path $file.FullName -Algorithm SHA512
            "$($hash.Path),$($hash.Hash)" | Out-File $baselinePath -Append
        }
    }

}
elseif($res -eq 3) {
    while ($true) {
        Start-Sleep -Seconds 1
        # if exists or not
        $baselinePath = Join-Path $l baseline.csv
        if(Test-Path -Path $baselinePath){
            $baselineFiles = Import-Csv -Path $baselinePath -Delimiter ","
            foreach($file in $baselineFiles){
                if(Test-Path -Path $file.path){
                }
                else{
                    Write-Host "$($file.path) has been deleted from the $($tbm)"
                }
            }
            $files = Get-ChildItem -Path $tbm
            foreach($file in $files){
                $existbool = $baselineFiles.path -contains $file.FullName
                if(-not $existbool){
                    Write-Host "$($file) File inserted"
                }
            }
            foreach($file in $baselineFiles){
                $computedHash = Get-FileHash -Path $file.path -Algorithm SHA512
                $ifequal = $computedHash.hash -eq $file.hash
                if(-not $ifequal){
                    Write-Host "$($file.path) hash been compromised"
                }
            }
        }
        else {
                Write-Host "Baseline Not found"
        }

    }
}


Write-Host $res