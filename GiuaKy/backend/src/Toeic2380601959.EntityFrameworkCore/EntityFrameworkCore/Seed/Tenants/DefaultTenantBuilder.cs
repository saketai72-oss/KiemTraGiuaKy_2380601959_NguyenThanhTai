using Abp.MultiTenancy;
using Toeic2380601959.Editions;
using Toeic2380601959.MultiTenancy;
using Microsoft.EntityFrameworkCore;
using System.Linq;

namespace Toeic2380601959.EntityFrameworkCore.Seed.Tenants;

public class DefaultTenantBuilder
{
    private readonly Toeic2380601959DbContext _context;

    public DefaultTenantBuilder(Toeic2380601959DbContext context)
    {
        _context = context;
    }

    public void Create()
    {
        CreateDefaultTenant();
    }

    private void CreateDefaultTenant()
    {
        // Default tenant

        var defaultTenant = _context.Tenants.IgnoreQueryFilters().FirstOrDefault(t => t.TenancyName == AbpTenantBase.DefaultTenantName);
        if (defaultTenant == null)
        {
            defaultTenant = new Tenant(AbpTenantBase.DefaultTenantName, AbpTenantBase.DefaultTenantName);

            var defaultEdition = _context.Editions.IgnoreQueryFilters().FirstOrDefault(e => e.Name == EditionManager.DefaultEditionName);
            if (defaultEdition != null)
            {
                defaultTenant.EditionId = defaultEdition.Id;
            }

            _context.Tenants.Add(defaultTenant);
            _context.SaveChanges();
        }
    }
}
