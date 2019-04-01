using namespace Microsoft.PowerShell.Commands
using module .\ModuleSpec.psm1
using module .\ModuleFetcher.psm1
using module .\MockModuleFetcher.psm1
using module .\FilesystemModuleFetcher.psm1
Update-FormatData -AppendPath .\ModuleSpec.ps1xml

function Get-ModuleDependency
{
    [CmdletBinding()]
    [OutputType([ModuleSpec])]
    param
    (
        [Parameter(Mandatory, Position = 0)]
        [ModuleSpec]$Node,

        [Parameter(Mandatory, Position = 1)]
        [ModuleFetcher]$Fetcher
    )


    [PSModuleInfo]$NodeAsModule = $Fetcher.GetModule($Node)

    $NodeAsModule.RequiredModules.ForEach({
        $ChildNode = [ModuleSpec]$_
        $ChildNode.Parent = $Node
        $PSBoundParameters.Node = $ChildNode
        $Node.Children.Add((Get-ModuleDependency @PSBoundParameters))
    })

    return $Node
}


Write-Host ""
Write-Host ""

# $MockFetcher = [MockModuleFetcher]::new()
# $Roof = Get-ModuleDependency 'Roof' $MockFetcher
# $Roof

$ModuleRoot = Join-Path (Split-Path $PSScriptRoot) 'MockModuleRoot'
$FsFetcher = [FilesystemModuleFetcher]::new($ModuleRoot)

$Human = Get-ModuleDependency 'Human' $FsFetcher
$Human.ToList()


# $Human.GetImportOrder() | ForEach-Object {Import-Module (Join-Path $ModuleRoot $_.Name)}
