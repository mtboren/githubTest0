
function Copy-VIRole {
<#    .Description
    Copy a role to another role, either in same vCenter or to a different vCenter. Jul 2013, Matt Boren
    This assumes that connections to source/destination vCenter(s) are already established.  If role of given name already exists in destination vCenter, will stop.
    Author:  vNugglets.com -- Jul 2013
    .Example
    Copy-VIRole.ps1 -SrcRoleName SysAdm -DestRoleName SysAdm_copyTest -SrcVCName vcenter.com -DestVCName labvcenter.com
    .Outputs
    VMware.VimAutomation.ViCore.Impl.V1.PermissionManagement.RoleImpl if role is created/updated, String in Warning stream and nothing in standard out otherwise
#>
    param(
        ## source role name
        [parameter(Mandatory=$true)][string]$SrcRoleName_str,
        ## destination role name
        [parameter(Mandatory=$true)]$DestRoleName_str,
        ## source vCenter connection name
        [parameter(Mandatory=$true)]$SrcVCName_str,
        ## destination vCenter connection name
        [parameter(Mandatory=$true)]$DestVCName_str,
        ## WhatIf switch
        [switch]$WhatIf_sw
    ) ## end param

    ## get the VIRole from the source vCenter
    $oSrcVIRole = Get-VIRole -Server $SrcVCName_str -Name $SrcRoleName_str -ErrorAction:SilentlyContinue
    ## if the role does not exist in the source vCenter
    if ($null -eq $oSrcVIRole) {Write-Warning "VIRole '$DestRoleName_str' does not exist in source vCenter '$SrcVCName_str'. No source VIRole from which to copy. Exiting"; exit}
    ## see if there is VIRole by the given name in the destination vCenter
    $oDestVIRole = Get-VIRole -Server $DestVCName_str -Name $DestRoleName_str -ErrorAction:SilentlyContinue

    ## if the role already exists in the destination vCenter
    if ($null -ne $oDestVIRole) {Write-Warning "VIRole '$DestRoleName_str' already exists in destination vCenter '$DestVCName_str'. Exiting"; exit}
    ## else, create the role
    else {
        $strNewVIRoleExpr = 'New-VIRole -Server $DestVCName_str -Name $DestRoleName_str -Privilege (Get-VIPrivilege -Server $DestVCName_str -Id $oSrcVIRole.PrivilegeList){0}' -f $(if ($WhatIf_sw) {" -WhatIf"})
        Invoke-Expression $strNewVIRoleExpr
    } ## end else
} ## end function


<#
Example:
PS vN:\> Copy-VIRole -SrcRoleName MyRole0 -SrcVCName myvcenter.dom.com -DestRoleName MyNewRole -DestVCName vcenter2.dom.com
Name            IsSystem
----            --------
MyNewRole       False

PS vN:\> Get-VIRole MyNewRole -server vcenter2*
Name            IsSystem
----            --------
MyNewRole       False
#>
