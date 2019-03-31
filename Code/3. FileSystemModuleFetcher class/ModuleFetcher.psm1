using namespace System.Collections.Generic
using namespace System.Management.Automation
using namespace Microsoft.PowerShell.Commands

class ModuleFetcher
{
    ModuleFetcher ()
    {
        # Hack to make the class abstract
        # If test is needed because this .ctor can be called from derived
        # class .ctors, and we don't want to throw in that case
        if ($this.GetType() -eq [ModuleFetcher])
        {
            throw ([NotImplementedException]::new(
                "Abstract class ModuleFetcher cannot be instantiated. You must use a derived class."
            ))
        }
    }

    [PSModuleInfo] GetModule([ModuleSpecification]$ModuleSpec)
    {
        # Hack to make the method abstract
        throw ([NotImplementedException]::new(
            "Abstract method GetModule must be overridden in a derived class."
        ))
    }
}
