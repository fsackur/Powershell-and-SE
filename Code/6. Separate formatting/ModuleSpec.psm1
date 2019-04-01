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

    ModuleSpec ([PSModuleInfo]$Module) : base (
        $(
            $Hashtable = @{
                ModuleName    = $Module.Name
                ModuleVersion = $Module.Version
            }
            if ($Module.Guid -and $Module.Guid -ne [Guid]'00000000-0000-0000-0000-000000000000')
            {
                $Hashtable.Guid = $Module.Guid
            }

            $Hashtable
        )
    )
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

    # How many levels of parents this spec has
    hidden [int]$_Generation = -1   # 'Uninitialised' value

    [int] GetGeneration()
    {
        if ($this._Generation -ne -1)
        {
            return $this._Generation
        }

        if ($this.Parent)
        {
            $this._Generation = $this.Parent.GetGeneration() + 1
        }
        else
        {
            $this._Generation = 0
        }

        return $this._Generation
    }


    # Does a module meet the requirements of this module spec?
    [bool] IsMetBy([PSModuleInfo]$Module)
    {
        return (
            $this.Name -eq $Module.Name -and
            (-not $this.Guid -or $Module.Guid -eq $this.Guid) -and
            (-not $this.Version -or $Module.Version -ge $this.Version) -and
            (-not $this.MaximumVersion -or $Module.Version -le ([version]$this.MaximumVersion)) -and
            (-not $this.RequiredVersion -or $Module.Version -eq $this.RequiredVersion)
        )
    }


    # Get a depth-first list
    [IList[ModuleSpec]] ToList()
    {
        $List = [List[ModuleSpec]]::new()
        return $this._ToList($List)
    }

    hidden [IList[ModuleSpec]] _ToList([IList[ModuleSpec]]$List)
    {
        $null = $List.Add($this)
        foreach ($Child in $this.Children)
        {
            $null = $Child._ToList($List)
        }
        return $List
    }


    # Get a reversed list that can be imported dependencies-first
    [ICollection[ModuleSpec]] GetImportOrder()
    {
        $List = $this.ToList()
        $List.Reverse()
        return $List
    }
}