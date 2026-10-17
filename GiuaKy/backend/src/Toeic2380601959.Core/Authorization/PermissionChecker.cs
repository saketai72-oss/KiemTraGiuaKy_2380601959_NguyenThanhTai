using Abp.Authorization;
using Toeic2380601959.Authorization.Roles;
using Toeic2380601959.Authorization.Users;

namespace Toeic2380601959.Authorization;

public class PermissionChecker : PermissionChecker<Role, User>
{
    public PermissionChecker(UserManager userManager)
        : base(userManager)
    {
    }
}
