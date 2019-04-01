using namespace System.Collections.Generic
using namespace System.Management.Automation
using namespace Microsoft.PowerShell.Commands
using module .\ModuleFetcher.psm1
using module .\ModuleSpec.psm1

class FilesystemModuleFetcher : ModuleFetcher
{
    FilesystemModuleFetcher ()
    {
        $this.ModulePath = $env:PSModulePath -split ';' -replace '\\?$'
    }

    FilesystemModuleFetcher ([string[]] $ModulePath)
    {
        $this.ModulePath = $ModulePath -split ';' -replace '\\?$'
    }

    hidden [string] $ModulePath

    [PSModuleInfo] GetModule([ModuleSpecification]$ModuleSpec)
    {
        $SearchPath = $this.ModulePath.ForEach({
            Join-Path $_ $ModuleSpec.Name
        })
        Write-Debug "Searching '$($SearchPath -join "', '")'..."

        $Module = (Get-Module $SearchPath -ListAvailable).Where(
            # {$true},
            {([ModuleSpec]$ModuleSpec).IsMetBy($_)},
            'First'
        )

        if ($Module)
        {
            Write-Debug "Found module '$Module'."
            return $Module[0]
        }
        else
        {
            throw ([ItemNotFoundException]::new("No modules were found matching argument '$ModuleSpec'."))
        }
    }
}
