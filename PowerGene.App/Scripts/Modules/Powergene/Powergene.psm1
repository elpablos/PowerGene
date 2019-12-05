## Prace s builderem (StringBuilder)

# lokalni promenna StringBuilderu
$script:sb = $null

# inicializace Builderu
function Initialize-Builder
{
    $script:sb = New-Object System.Text.StringBuilder
}
Export-ModuleMember -Function 'Initialize-Builder'

# Builder pridani radky
function Add-Line 
{
    param(
        [Parameter(Position=0)][string]$txt
    )
    $script:sb.AppendLine($txt) | Out-Null
}
Export-ModuleMember -Function 'Add-Line'

# Odstraneni posledniho znaku
function Remove-LastChar 
{
    $script:sb.Length--
}
Export-ModuleMember -Function 'Remove-LastChar'

# export builderu
function Out-Builder
{
    return $script:sb.ToString()
}
Export-ModuleMember -Function 'Out-Builder'


## Json

function ConvertFrom-Json {
    <#
    .ForwardHelpTargetName Microsoft.PowerShell.Utility\ConvertFrom-Json
    .ForwardHelpCategory Cmdlet
    #>
    [CmdletBinding(HelpUri = 'http://go.microsoft.com/fwlink/?LinkID=217031', RemotingCapability = 'None')]
    param(
        [Parameter(Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true)]
        [AllowEmptyString()]
        [String] $InputObject,

        [Parameter()]
        [ValidateSet('Object', 'Hashtable')]
        [String] $As = 'Object'
    )

    begin {
        Write-Debug "Beginning $($MyInvocation.Mycommand)"
        Write-Debug "Bound parameters:`n$($PSBoundParameters | out-string)"

        try {
            # Use this class to perform the deserialization:
            # https://msdn.microsoft.com/en-us/library/system.web.script.serialization.javascriptserializer(v=vs.110).aspx
            Add-Type -AssemblyName "System.Web.Extensions, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" -ErrorAction Stop
        }
        catch {
            throw "Unable to locate the System.Web.Extensions namespace from System.Web.Extensions.dll. Are you using .NET 4.5 or greater?"
        }

        $jsSerializer = New-Object -TypeName System.Web.Script.Serialization.JavaScriptSerializer
    }

    process {
        switch ($As) {
            'Hashtable' {
                $jsSerializer.Deserialize($InputObject, 'Hashtable')
            }
            default {
                # If we don't know what to do, use the native cmdlet.
                # This should also catch the -As Object case.

                # Remove -As since the native cmdlet doesn't understand it
                if ($PSBoundParameters.ContainsKey('As')) {
                    $PSBoundParameters.Remove('As')
                }

                Write-Debug "Running native ConvertFrom-Json with parameters:`n$($PSBoundParameters | Out-String)"
                Microsoft.PowerShell.Utility\ConvertFrom-Json @PSBoundParameters
            }
        }
    }

    end {
        $jsSerializer = $null
        Write-Debug "Completed $($MyInvocation.Mycommand)"
    }
}

Export-ModuleMember -Function 'ConvertFrom-Json'

# alternativa k ConvertFrom-Json, vyuziti .NETu
function ConvertFrom-JsonExtend
{
    param (
        [Parameter(Mandatory, Position=0, ValueFromPipeline = $true)]$data
    )
  
    #Add-Type -AssemblyName System.Web.Extensions
    #$JS = New-Object System.Web.Script.Serialization.JavaScriptSerializer
    #return $JS.DeserializeObject($data)

    return ($data | ConvertFrom-Json -As Hashtable)
}
Export-ModuleMember -Function 'ConvertFrom-JsonExtend'

# alternativa k ConvertFrom-Json, vyuziti .NETu
function ConvertTo-JsonExtend
{
    param (
        [Parameter(Mandatory, Position=0, ValueFromPipeline = $true)]$data
    )
  
    return ($data | ConvertTo-Json -Depth 10 -Compress)
}
Export-ModuleMember -Function 'ConvertTo-JsonExtend'

# nacteni jsonu ze souboru
function Read-JsonFile
{
    param (
         [Parameter(Mandatory)][string]$path
    )
    return Get-Content -Path $path -Encoding UTF8 -Raw | ConvertFrom-JsonExtend
}
Export-ModuleMember -Function 'Read-JsonFile'

# nacteni jsonu vcetne konverze do objektu
function Out-JsonFile
{
    param (
        [Parameter(Mandatory, Position=0, ValueFromPipeline = $true)]$data,
        [Parameter(Mandatory)][string]$path
    )

    $data | ConvertTo-Json -Depth 10 -Compress | Out-File $path -Encoding utf8
}
Export-ModuleMember -Function 'Out-JsonFile'

## other

# mnozne cislo od nazvu v anglicnice
function Get-Pluralize
{
    param (
         [Parameter(Mandatory)][string]$name
    )
    # reference because pluralize
    Add-Type -AssemblyName System.Data.Entity.Design
    $culture = New-Object System.Globalization.CultureInfo("en-US")
    return [System.Data.Entity.Design.PluralizationServices.PluralizationService]::CreateService($culture).Pluralize($name)
}
Export-ModuleMember -Function 'Get-Pluralize'

function Get-GenerateLine
{
    param (
        [Parameter(Mandatory)]$data
    )

    $generated = $data.Metadata.UseGenerated
    if ($null -eq $generated){
        $generated = $true
    }

    # generated
    if ($generated -eq $true -and $null -ne $script:sb) {
        Add-Line('// {0} - generated' -f [System.DateTime]::Now)
    }
}
Export-ModuleMember -Function 'Get-GenerateLine'

function Get-GenerateDbLine
{
    param (
        [Parameter(Mandatory)]$data
    )

    $generated = $data.Metadata.UseGenerated
    if ($null -eq $generated){
        $generated = $true
    }

    # generated
    if ($generated -eq $true -and $null -ne $script:sb) {
        Add-Line('/* {0} - generated */' -f [System.DateTime]::Now)
    }
}
Export-ModuleMember -Function 'Get-GenerateDbLine'

function Start-EditorProcess
{
    param (
        [Parameter(Mandatory)][string]$filepath
    )

    Start-Process -filepath "code" -ArgumentList $filepath -Verb runas -WindowStyle Hidden
}
Export-ModuleMember -Function 'Start-EditorProcess'