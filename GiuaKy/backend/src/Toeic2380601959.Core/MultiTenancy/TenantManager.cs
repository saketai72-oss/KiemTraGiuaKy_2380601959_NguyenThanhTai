using Abp.Application.Features;
using Abp.Domain.Repositories;
using Abp.MultiTenancy;
using Toeic2380601959.Authorization.Users;
using Toeic2380601959.Editions;

namespace Toeic2380601959.MultiTenancy;

public class TenantManager : AbpTenantManager<Tenant, User>
{
    public TenantManager(
        IRepository<Tenant> tenantRepository,
        IRepository<TenantFeatureSetting, long> tenantFeatureRepository,
        EditionManager editionManager,
        IAbpZeroFeatureValueStore featureValueStore)
        : base(
            tenantRepository,
            tenantFeatureRepository,
            editionManager,
            featureValueStore)
    {
    }
}
