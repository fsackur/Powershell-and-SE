function Install-Msu
{
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipeline)]
        [string]$MsuFile

        # [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        # [Alias('FullName')]
        # [string]$MsuFile
    )

    process
    {
        # Let's say we need the full path in this function.

        if (-not [IO.Path]::IsPathRooted($MsuFile))
        {
            throw "Full path required"
        }

        Write-Host "Installing MSU $MsuFile"
    }
}


# Without the alias
gci C:\ -File | select -First 5 | ForEach-Object {Install-Msu $_.FullName}

# With the 'FullName' alias
# gci | select -First 5 | Install-Msu

# The modified param block, with the alias, adapts the 'Install-Msu' function
# to the interface expected by the FileInfo type from Get-ChildItem.