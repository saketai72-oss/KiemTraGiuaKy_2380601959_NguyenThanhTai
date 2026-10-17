using Abp.MultiTenancy;
using Toeic2380601959.Authorization.Users;

namespace Toeic2380601959.MultiTenancy;

public class Tenant : AbpTenant<User>
{
    public Tenant()
    {
    }

    public Tenant(string tenancyName, string name)
        : base(tenancyName, name)
    {
    }
}
