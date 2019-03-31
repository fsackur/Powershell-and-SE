using namespace Microsoft.PowerShell.Commands
using module .\ModuleSpec.psm1
using module .\ModuleFetcher.psm1

function Get-ModuleDependency
{
    [CmdletBinding()]
    [OutputType([ModuleSpec])]
    param
    (
        [Parameter(Mandatory, Position = 0)]
        [ModuleSpec]$Node
    )

    [ModuleFetcher]$Fetcher = [ModuleFetcher]::new()

    [PSModuleInfo]$NodeAsModule = $Fetcher.GetModule($Node)

    $NodeAsModule.RequiredModules.ForEach({
        $ChildNode = [ModuleSpec]$_
        $ChildNode.Parent = $Node
        $Node.Children.Add((Get-ModuleDependency $ChildNode))
    })

    return $Node
}


Write-Host ""
Write-Host ""

$Roof = Get-ModuleDependency 'Roof'
$Roof.PrintTree()
