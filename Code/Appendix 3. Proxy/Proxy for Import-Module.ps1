

# How to create a proxy command:
# $CommandInfo = Get-Command Import-Module
# [System.Management.Automation.ProxyCommand]::Create($CommandInfo)


function Import-Module
{
    [CmdletBinding(DefaultParameterSetName='Name', HelpUri='https://go.microsoft.com/fwlink/?LinkID=141553')]
    param
    (
        #region parameters faithfully implemented from proxied command
        [switch]
        ${Global},

        [ValidateNotNull()]
        [string]
        ${Prefix},

        [Parameter(ParameterSetName='PSSession', Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [Parameter(ParameterSetName='Name', Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [Parameter(ParameterSetName='CimSession', Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [string[]]
        ${Name},

        [Parameter(ParameterSetName='FullyQualifiedNameAndPSSession', Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [Parameter(ParameterSetName='FullyQualifiedName', Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [Microsoft.PowerShell.Commands.ModuleSpecification[]]
        ${FullyQualifiedName},

        [Parameter(ParameterSetName='Assembly', Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [System.Reflection.Assembly[]]
        ${Assembly},

        [ValidateNotNull()]
        [string[]]
        ${Function},

        [ValidateNotNull()]
        [string[]]
        ${Cmdlet},

        [ValidateNotNull()]
        [string[]]
        ${Variable},

        [ValidateNotNull()]
        [string[]]
        ${Alias},

        [switch]
        ${Force},

        [switch]
        ${PassThru},

        [switch]
        ${AsCustomObject},

        [Parameter(ParameterSetName='CimSession')]
        [Parameter(ParameterSetName='PSSession')]
        [Parameter(ParameterSetName='Name')]
        [Alias('Version')]
        [version]
        ${MinimumVersion},

        [Parameter(ParameterSetName='CimSession')]
        [Parameter(ParameterSetName='PSSession')]
        [Parameter(ParameterSetName='Name')]
        [string]
        ${MaximumVersion},

        [Parameter(ParameterSetName='PSSession')]
        [Parameter(ParameterSetName='Name')]
        [Parameter(ParameterSetName='CimSession')]
        [version]
        ${RequiredVersion},

        [Parameter(ParameterSetName='ModuleInfo', Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [psmoduleinfo[]]
        ${ModuleInfo},

        [Alias('Args')]
        [System.Object[]]
        ${ArgumentList},

        [switch]
        ${DisableNameChecking},

        [Alias('NoOverwrite')]
        [switch]
        ${NoClobber},

        [ValidateSet('Local','Global')]
        [string]
        ${Scope},

        [Parameter(ParameterSetName='PSSession', Mandatory=$true)]
        [Parameter(ParameterSetName='FullyQualifiedNameAndPSSession', Mandatory=$true)]
        [ValidateNotNull()]
        [System.Management.Automation.Runspaces.PSSession]
        ${PSSession},

        [Parameter(ParameterSetName='CimSession', Mandatory=$true)]
        [ValidateNotNull()]
        [CimSession]
        ${CimSession},

        [Parameter(ParameterSetName='CimSession')]
        [ValidateNotNull()]
        [uri]
        ${CimResourceUri},

        [Parameter(ParameterSetName='CimSession')]
        [ValidateNotNullOrEmpty()]
        [string]
        ${CimNamespace},
        #endregion parameters faithfully implemented from proxied command


        # Add a parameter of our own
        [switch]
        $GodMode
    )


    # So we don't break the proxied command
    if ($PSBoundParameters.ContainsKey('GodMode'))
    {
        $null = $PSBoundParameters.Remove('GodMode')
    }


    # Call the proxied command, adding PassThru
    $PSBoundParameters.PassThru = [switch]::Present

    if ($MyInvocation.ExpectingInput)
    {
        $Modules = $input | Microsoft.PowerShell.Core\Import-Module @PSBoundParameters
    }
    else
    {
        $Modules = Microsoft.PowerShell.Core\Import-Module @PSBoundParameters
    }


    # Do the special thing with our parameter
    if ($GodMode)
    {
        foreach ($Module in $Modules)
        {
            & $Module {

                # This runs in the scope of $Module
                $Module = $args[0]
                $Commands = Get-Command -Module $Module   # this will include non-exported functions

                foreach ($Command in $Commands)
                {
                    # Create a scriptblock that always runs in the scope of $Module
                    $CommandScriptblock = [scriptblock]::Create($Command.Definition)
                    $BoundScriptblock = $Module.NewBoundScriptBlock($CommandScriptblock)

                    # Export the command globally
                    Write-Verbose "Exporting $($Command.Name)"
                    Set-Content function:\Global:$($Command.Name) $BoundScriptblock
                }

            } $Module   # pass $Module in to scriptblock as $args[0]
        }
    }


    # Because we hacked it earlier
    if ($PassThru)
    {
        $Modules
    }
}



# sl C:\dev\PoshRSJob
# Import-Module PoshRSJob
# gcm -mo PoshRSJob | measure

# Import-Module PoshRSJob -GodMode
# gcm -mo PoshRSJob | measure
