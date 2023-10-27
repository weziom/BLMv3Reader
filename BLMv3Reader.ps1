<#
    .SYNOPSIS
        BLM (Building List Management) v3 file parser
    .DESCRIPTION
        BLMv3Reader takes a BLM file, parses it and creates a custom object, you
        can then do whatever you wish with the resultant object.
    .EXAMPLE
        $reader = New-Object BLMv3Reader $path
        $reader.properties | ForEach-Object {
            # Print out the agent reference for each property
            $_.AGENT_REF
        }
        
#>

class BLMv3Reader {

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$file

    [Array]$headers
    [Array]$definitions
    [Array]$properties

    BLMv3Reader() {
        $this.file = ""
        $this.headers = @()
        $this.definitions = @()
        $this.properties = @()
    }

    BLMv3Reader([string]$file) {

        # Check file exists and type
        if(-Not(Test-Path $file) -and $file.Contains(".BLM")) {
            throw "File does not exist."
        }

        # Read file contents
        $this.file = $file
        $_fileContents = Get-Content -Path $this.file -Raw

        try {
            # Read the headers and parse
            $headers_match = [Regex]::Matches($_fileContents, "(?smi)#HEADER#(.*?)#").Groups[1].Value
            $this.headers = ConvertFrom-String -InputObject $headers_match -Delimiter ':'
            
            # Read the definitions and parse
            $match_definitions = [Regex]::Matches($_fileContents, "(?smi)#DEFINITION#\s+(.*?)\^~").Groups[1].Value -split '\^'
            $this.definitions = $match_definitions

            # Read the data contents and parse
            $data_matches = [Regex]::Matches($_fileContents, "(?sm)#DATA#(.*?)#").Groups[1].Value
            $parsed_data = $data_matches -split '~'

            # Finally, put it all together.
            $this.properties = $parsed_data | ConvertFrom-Csv -Delimiter '^' -Header $this.definitions
        }
        catch {
            Write-Host "Error parsing BLM v3 file."
        }
    }
}
