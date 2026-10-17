using Abp.Authorization.Roles;
using Toeic2380601959.Authorization.Users;
using System.ComponentModel.DataAnnotations;

namespace Toeic2380601959.Authorization.Roles;

public class Role : AbpRole<User>
{
    public const int MaxDescriptionLength = 5000;

    public Role()
    {
    }

    public Role(int? tenantId, string displayName)
        : base(tenantId, displayName)
    {
    }

    public Role(int? tenantId, string name, string displayName)
        : base(tenantId, name, displayName)
    {
    }

    [StringLength(MaxDescriptionLength)]
    public string Description { get; set; }
}
