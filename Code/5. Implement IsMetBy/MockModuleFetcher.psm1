using namespace System.Collections.Generic
using namespace System.Management.Automation
using namespace Microsoft.PowerShell.Commands
using module .\ModuleFetcher.psm1

class MockModuleFetcher : ModuleFetcher
{
    [PSModuleInfo] GetModule([ModuleSpecification]$ModuleSpec)
    {
        # Create a mock PSModuleInfo
        $Module = New-Module {} -Name $ModuleSpec.Name


        #region Use reflection to make it look like a real module
        $GuidField    = [PSModuleInfo].GetField('_guid', 'Instance, NonPublic')
        $VersionField = [PSModuleInfo].GetField('_version', 'Instance, NonPublic')
        $ReqField     = [PSModuleInfo].GetField('_requiredModules', 'Instance, NonPublic')
        $ReqSpecField = [PSModuleInfo].GetField('_requiredModulesSpecification', 'Instance, NonPublic')

        $GuidField.SetValue($Module, (New-Guid))
        $VersionField.SetValue($Module, ([version]'1.0'))

        $ReqModuleName = @{
            'Roof'  = 'Walls'
            'Walls' = 'Foundation'
        }[$Module.Name]


        if ($ReqModuleName)
        {
            $ReqField.SetValue(
                $Module,
                ([List[PSModuleInfo]]::new([PSModuleInfo[]]@(New-Module {} -Name $ReqModuleName)))
            )
            $ReqSpecField.SetValue(
                $Module,
                ([List[ModuleSpecification]]::new([ModuleSpecification[]]@($ReqModuleName)))
            )
        }
        #endregion Use reflection to make it look like a real module


        return $Module
    }
}