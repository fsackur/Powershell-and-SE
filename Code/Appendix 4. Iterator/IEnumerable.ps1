
$Array = 1..4


$Array.GetEnumerator()


$Enumerator = $Array.GetEnumerator()
$Enumerator | Get-Member


$Enumerator.Current
$Enumerator.MoveNext()




$Enumerator.Reset()

while ($Enumerator.MoveNext())
{
    $Enumerator.Current
}

# Use case: zipping collections together where there are
# gaps, e.g. matching services to processes by process ID