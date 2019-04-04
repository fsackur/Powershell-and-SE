
<#
    This is an approximation for demo purposes, not my employer's actual code!

    One point to take away from this sample is that it's touching Github in
    some different way on almost every line.

    Another is that it's not a general solution, it only gives us a list of filepaths.

    Another is that it's inflexible in how we choose branches or releases.
#>


function Download-ModuleAndGetDependencyOrder
{
    [CmdletBinding()]
    param
    (
        [string]$Name,

        [version]$Version,

        [string]$Branch,    # Optional. Default to master and look for a release

        [string]$Token,

        [int]$Depth = 0
    )

    if ($Depth -gt 20) {throw "Stack overflow!"}    # Because, recursion


    # This will accumulate the dependencies
    $ImportOrder = [ArrayList]::new()


    # Do the download
    if ($Branch)
    {
        Download-GithubBranch -Name $Name -Branch $Branch `
            -Token $Token -OutPath $OutPath
    }
    else
    {
        Download-GithubRelease -Name $Name -Version $Version `
            -Token $Token -OutPath $OutPath
    }


    # Read the dependencies of the current module
    $Psd1Path = Join-Path $OutPath "$Name.psd1"
    $ParsedPsd1 = Import-ModuleManifest $Psd1Path

    foreach ($RequiredModule in $ParsedPsd1.RequiredModules)
    {
        # Recurse
        # Assume we want the same branch name for each dependency!
        $DependencyImportOrder = Download-ModuleAndGetDependencyOrder `
            -Name $RequiredModule.Name -Version $RequiredModule.Version -Branch $Branch `
            -Token $Token -OutPath $OutPath -Depth ($Depth+1)


        # Add the dependencies BEFORE the current module
        foreach ($Dependency in $DependencyImportOrder)
        {
            $ImportOrder.Add($Dependency)
        }
    }


    # Add the current module AFTER the dependencies
    $ImportOrder.Add($OutPath)

    return $ImportOrder
}