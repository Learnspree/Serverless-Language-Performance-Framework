

function buildResourceGroupName
{
    Param
    (
         [Parameter(Mandatory=$true, Position=0)]
         [string] $teststate,
         [Parameter(Mandatory=$true, Position=1)]
         [string] $runtime,
         [Parameter(Mandatory=$true, Position=2)]
         [string] $runtimeVersion,
         [Parameter(Mandatory=$true, Position=3)]
         [string] $region,
         [Parameter(Mandatory=$true, Position=4)]
         [string] $environment
    )

    $regionLowercase = getLowercaseRegionName($region)
    $namePrefix = getTestFunctionNamePrefix($teststate)
    $rgName = "${namePrefix}-${runtime}${runtimeVersion}-${regionLowercase}-${environment}-rg"
    return $rgName
}

function buildFunctionAppName 
{
    Param
    (
         [Parameter(Mandatory=$true, Position=0)]
         [string] $teststate,
         [Parameter(Mandatory=$true, Position=1)]
         [string] $runtime,
         [Parameter(Mandatory=$true, Position=2)]
         [string] $runtimeVersion,
         [Parameter(Mandatory=$true, Position=3)]
         [string] $region,
         [Parameter(Mandatory=$true, Position=4)]
         [string] $environment
    )

    $regionLowercase = getLowercaseRegionName($region)
    $namePrefix = getTestFunctionNamePrefix($teststate)
    $appName = "${namePrefix}-${runtime}${runtimeVersion}-${regionLowercase}-${environment}"
    return $appName
}

function buildFunctionAppARMTemplateParameters($appName, $runtime, $runtimeVersion) {
    # Create the parameters for the file
    if ($runtime -eq "node") {
        $TemplateParams = @{"appName" = "${appName}"; "runtime" = "${runtime}"; "nodeVersion" = "~${runtimeVersion}"}
    }
    else {
        $TemplateParams = @{"appName" = "${appName}"; "runtime" = "${runtime}"}
    }

    return $TemplateParams
}
 
function getLowercaseRegionName($region) {
    # create lowercase version of region with hyphens instead of spaces to help with resource naming
    return "${region}".ToLower().Replace(' ', '-')
}

function getTestFunctionNamePrefix($teststate) {
    # create standard prefix for test function names
    return "spf-azure-test-${teststate}"
}
