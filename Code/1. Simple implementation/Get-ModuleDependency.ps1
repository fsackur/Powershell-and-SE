using module .\ModuleSpec.psm1

function Get-ModuleDependency
{
    [CmdletBinding()]
    [OutputType([ModuleSpec])]
    param ()

    $Roof       = [ModuleSpec]'Roof'
    $Walls      = [ModuleSpec]'Walls'
    $Foundation = [ModuleSpec]'Foundation'


    # Set Roof as parent of Walls, and Walls as child of Roof
    $Roof.Children.Add($Walls)
    $Walls.Parent = $Roof

    # Set Walls as parent of Foundation, and Foundation as child of Walls
    $Walls.Children.Add($Foundation)
    $Foundation.Parent = $Walls

    return $Roof
}


Write-Host ""
Write-Host ""
$Roof = Get-ModuleDependency
$Roof.PrintTree()
