function Import-CustomModule
{
    [Cmdletbinding()]
    param
    (
        [Parameter(Mandatory=$true,ParameterSetName='Static',ValueFromPipelineByPropertyName = $true,ValueFromPipeline = $true)]
        [String[]]$StaticModuleName,
        
        [Parameter(ParameterSetName='Static')]
        [String]$StaticModulePath="\\$env:USERDOMAIN\Powershell\modules",
 
        [Parameter(ParameterSetName='Dynamic')]
        [String]$DynamicModulePath="\\$env:USERDOMAIN\Powershell\modules",
        
        [String]$ModuleVersion='Latest'
        
    )
    DynamicParam 
    {
        New-ValidationDynamicParam -Name 'DynamicModuleName' -Mandatory -ParameterSetName 'Dynamic' -ValidateSetOptions (Get-ChildItem "\\$env:USERDOMAIN\Powershell\modules" -Name)
    }
    begin 
    {
        ## Create variables for each dynamic parameter.  If this wasn't done you'd have to reference
        ## any dynamic parameter as the key in the $PsBoundParameters hashtable.
        $PsBoundParameters.GetEnumerator() | foreach { New-Variable -Name $_.Key -Value $_.Value -ea 'SilentlyContinue' }
    }
    Process
    {
        Write-Verbose ("Import-SaasModule:`tProcessing parameterset '{0}'.." -f $PSCmdlet.ParameterSetName)
        
        if ($PSCmdlet.ParameterSetName -eq 'Static')
        {
        
            foreach($m in $StaticModuleName)
            {
                $Module = Join-Path $StaticModulePath -ChildPath "$m\$ModuleVersion\$m"
        
                #Test the Module Path
                if(-not (Test-Path $Module))
                {
                    $message = ("Import-SaasModules:`tThe Module path '{0}' was not found" -f $Module)
                    throw $message        
                }
        
                try
                {          
                    Import-Module -Name $Module -Global -Force -ErrorAction Stop     
                }
                catch
                {
                    $message = "Import-SaasModules:`tCould not import module $Module`n"
                    $message += $Global:Error[0] | Format-List * -Force | Out-String
                    #Write-EventLog -LogName Cortex -Source 'Import-SaasModules' -EntryType Error -Category 10 -EventId 10 -Message $message
                    throw $message    
                }                
            }#End foreach Module              
        }
        elseif($PSCmdlet.ParameterSetName -eq 'Dynamic')
        {
        
            $Module = Join-Path $DynamicModulePath -ChildPath "$DynamicModuleName\$ModuleVersion\$DynamicModuleName"
        
            #Test the Module Path
            if(-not (Test-Path $Module))
            {
                $message = ("Import-SaasModules:`tThe Module path '{0}' was not found" -f $Module)
                throw $message        
            }
        
            try
            {          
                Import-Module -Name $Module -Global -Force -ErrorAction Stop     
            }
            catch
            {
                $message = "Import-SaasModules:`tCould not import module $Module`n"
                $message += $Global:Error[0] | Format-List * -Force | Out-String
                #Write-EventLog -LogName Cortex -Source 'Import-SaasModules' -EntryType Error -Category 10 -EventId 10 -Message $message
                throw $message    
            }                 
        }
    } 
        
}