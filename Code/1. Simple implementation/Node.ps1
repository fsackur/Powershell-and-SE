using namespace System.Collections.Generic

class Node
{
    # The properties that make this a tree node
    [Node]$Parent
    [ICollection[Node]]$Children = [List[Node]]::new()



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
            $ChildTree = $Child._PrintTree(($Indentation + "   "))
            $null = $SB.Append($ChildTree)
        }

        return $SB.ToString()
    }
}



























$Node = [Node]::new()
$Node.Children.Add([Node]::new())
$Node.Children.Add([Node]::new())
$Node.Children.Add([Node]::new())
$Node.Children[0].Children.Add([Node]::new())
$Node.Children[0].Children.Add([Node]::new())
$Node.Children[0].Children[1].Children.Add([Node]::new())
$Node.Children[1].Children.Add([Node]::new())
cls
Write-Host ""
$Node.PrintTree()
