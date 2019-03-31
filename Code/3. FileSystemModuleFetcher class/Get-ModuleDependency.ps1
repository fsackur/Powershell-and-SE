using namespace Microsoft.PowerShell.Commands
using module .\ModuleSpec.psm1
using module .\ModuleFetcher.psm1
using module .\MockModuleFetcher.psm1
using module .\FilesystemModuleFetcher.psm1

function Get-ModuleDependency
{
    [CmdletBinding(DefaultParameterSetName = 'Mock')]
    [OutputType([ModuleSpec])]
    param
    (
        [Parameter(Mandatory, Position = 0)]
        [ModuleSpec]$Node,

        [Parameter(Mandatory, ParameterSetName = 'FromFilesystem')]
        [switch]$SearchFilesystem
    )


    [ModuleFetcher]$Fetcher = $null

    if ($PSCmdlet.ParameterSetName -eq 'Mock')
    {
        $Fetcher = [MockModuleFetcher]::new()
    }
    elseif ($PSCmdlet.ParameterSetName -eq 'FromFilesystem')
    {
        $ModuleRoot = Join-Path (Split-Path $PSScriptRoot) 'MockModuleRoot'
        $Fetcher = [FilesystemModuleFetcher]::new($ModuleRoot)
    }


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

$Roof = Get-ModuleDependency 'Roof'
$Roof.PrintTree()

# $Human = Get-ModuleDependency 'Human' -SearchFilesystem
# $Human.PrintTree()
