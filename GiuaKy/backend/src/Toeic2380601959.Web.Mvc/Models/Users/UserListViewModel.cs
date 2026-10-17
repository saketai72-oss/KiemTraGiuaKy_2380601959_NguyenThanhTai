using Toeic2380601959.Roles.Dto;
using System.Collections.Generic;

namespace Toeic2380601959.Web.Models.Users;

public class UserListViewModel
{
    public IReadOnlyList<RoleDto> Roles { get; set; }
}
