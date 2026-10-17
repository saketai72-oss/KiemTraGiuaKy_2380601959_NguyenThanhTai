using Toeic2380601959.Roles.Dto;
using System.Collections.Generic;

namespace Toeic2380601959.Web.Models.Common;

public interface IPermissionsEditViewModel
{
    List<FlatPermissionDto> Permissions { get; set; }
}