using namespace System.Collections.Generic
using namespace Microsoft.PowerShell.Commands

class ModuleSpec : ModuleSpecification
{
    # Constructors
    ModuleSpec ([string]$Name) : base ($Name)
    {
        # Empty .ctor body because we're just chaining the inherited one
    }

    ModuleSpec ([hashtable]$Hashtable) : base ([hashtable]$Hashtable)
    {}

    ModuleSpec ([ModuleSpecification]$ModuleSpec) : base ($ModuleSpec)
    {}

    ModuleSpec ([PSModuleInfo]$Module) : base ($Module)
    {}


    # Inherit the following properties from ModuleSpecification:
    # Name
    # Guid
    # Version
    # MaximumVersion
    # RequiredVersion


    # The properties that make this a tree node
    [ModuleSpec]$Parent
    [ICollection[ModuleSpec]]$Children = [List[ModuleSpec]]::new()



    # Visual output with dependencies indented
    [string] PrintTree()
    {
        return $this._PrintTree("")
    }

    hidden [string] _PrintTree([string]$Indentation)
    {
        $SB = New-Object System.Text.StringBuilder (200)
        $null = $SB.Append($Indentation).AppendLine($this.ToString())  # Output self

        foreach ($Child in $this.Children)
        {
            # Output children, one by one, with increased indentation
            $ChildTree = $Child._PrintTree(($Indentation + "    "))
            $null = $SB.Append($ChildTree)
        }

        return $SB.ToString()
    }
}