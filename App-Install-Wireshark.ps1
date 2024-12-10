param(
	[string]$Version,
	[string]$Path,
	[switch]$Force,
	$Update,
	[switch]$Uninstall
)

function Get-LatestWireshark {
    # URL of the Wireshark x64 download page
    $url = "https://www.wireshark.org/download/win64/"

    try {
        # Download the HTML content of the page
        $htmlContent = Invoke-WebRequest -Uri $url -UseBasicParsing
        
        # Extract links that end with ".exe"
        $exeLinks = $htmlContent.Links | Where-Object { $_.href -match "\.exe$" }

        if ($exeLinks.Count -eq 0) {
            Write-Error "No .exe files found on the page."
            return $null
        }

        # Find the first .exe link
        $latestExe = $exeLinks | Sort-Object -Property href -Descending | Select-Object -First 1

        # Return the full download link
        $latestExeUri = [Uri]::new($url, $latestExe.href).AbsoluteUri
        Write-Output $latestExeUri
    } catch {
        Write-Error "An error occurred: $_"
        return $null
    }
}

# Example usage
$latestWireshark = Get-LatestWireshark
if ($latestWireshark) {
    Write-Host "Latest Wireshark x64 Installer URL: $latestWireshark"
}



#--------------------------------------------------#
# settings
#--------------------------------------------------#

$Configs = @{
	# Url = "https://1.eu.dl.wireshark.org/win64/Wireshark-win64-1.10.5.exe"
    Url = $latestWireshark
    Path = "$(Split-Path -Path $MyInvocation.MyCommand.Definition -Parent)\"
}

$Configs | ForEach-Object{

    try{

        $_.Result = $null
        if(-not $_.Path){$_.Path = $Path}
        $Config = $_

        #--------------------------------------------------#
        # add app
        #--------------------------------------------------#

        if(-not $Uninstall){

            #--------------------------------------------------#
            # check condition
            #--------------------------------------------------#

            if($_.ConditionExclusion){            
                $_.ConditionExclusionResult = $(Invoke-Expression $Config.ConditionExclusion -ErrorAction SilentlyContinue)        
            }    
            if(($_.ConditionExclusionResult -eq $null) -or $Force){
                    	
                #--------------------------------------------------#
                # download
                #--------------------------------------------------#

                $_.Downloads = $_.Url | ForEach-Object{
                    Get-File -Url $_ -Path $Config.Path
                }       			

                #--------------------------------------------------#
                # installation
                #--------------------------------------------------#
								
                $_.Downloads | ForEach-Object{
                    Start-Process -FilePath $(Join-Path $_.Path $_.Filename) -ArgumentList "/S /desktopicon=yes" -Wait
                }
                		
                #--------------------------------------------------#
                # configuration
                #--------------------------------------------------#	
                
                #--------------------------------------------------#
                # cleanup
                #--------------------------------------------------#

                $_.Downloads | ForEach-Object{
                    Remove-Item (Join-Path $_.Path $_.Filename) -Force
                }
                		
                #--------------------------------------------------#
                # finisher
                #--------------------------------------------------#
                		
                if($Update){$_.Result = "AppUpdated";$_
                }else{$_.Result = "AppInstalled";$_}
            		
            #--------------------------------------------------#
            # condition exclusion
            #--------------------------------------------------#
            		
            }else{
            	
                $_.Result = "ConditionExclusion";$_
            }

        #--------------------------------------------------#
        # remove app
        #--------------------------------------------------#
        	
        }else{
            
            $Executable = "C:\Program Files\Wireshark\uninstall.exe"; if(Test-Path $Executable){Start-Process -FilePath $Executable -ArgumentList "/S" -Wait}
                
            $_.Result = "AppUninstalled";$_
        }

    #--------------------------------------------------#
    # catch error
    #--------------------------------------------------#

    }catch{

        $Config.Result = "Error";$Config
    }
}
