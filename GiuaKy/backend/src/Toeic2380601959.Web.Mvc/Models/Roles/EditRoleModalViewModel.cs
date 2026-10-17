using Abp.AutoMapper;
using Toeic2380601959.Roles.Dto;
using Toeic2380601959.Web.Models.Common;

namespace Toeic2380601959.Web.Models.Roles;

[AutoMapFrom(typeof(GetRoleForEditOutput))]
public class EditRoleModalViewModel : GetRoleForEditOutput, IPermissionsEditViewModel
{
    public bool HasPermission(FlatPermissionDto permission)
    {
        return GrantedPermissionNames.Contains(permission.Name);
    }
}
