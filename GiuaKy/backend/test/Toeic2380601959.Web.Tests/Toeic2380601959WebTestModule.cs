using Abp.AspNetCore;
using Abp.AspNetCore.TestBase;
using Abp.Modules;
using Abp.Reflection.Extensions;
using Toeic2380601959.EntityFrameworkCore;
using Toeic2380601959.Web.Startup;
using Microsoft.AspNetCore.Mvc.ApplicationParts;

namespace Toeic2380601959.Web.Tests;

[DependsOn(
    typeof(Toeic2380601959WebMvcModule),
    typeof(AbpAspNetCoreTestBaseModule)
)]
public class Toeic2380601959WebTestModule : AbpModule
{
    public Toeic2380601959WebTestModule(Toeic2380601959EntityFrameworkModule abpProjectNameEntityFrameworkModule)
    {
        abpProjectNameEntityFrameworkModule.SkipDbContextRegistration = true;
    }

    public override void PreInitialize()
    {
        Configuration.UnitOfWork.IsTransactional = false; //EF Core InMemory DB does not support transactions.
    }

    public override void Initialize()
    {
        IocManager.RegisterAssemblyByConvention(typeof(Toeic2380601959WebTestModule).GetAssembly());
    }

    public override void PostInitialize()
    {
        IocManager.Resolve<ApplicationPartManager>()
            .AddApplicationPartsIfNotAddedBefore(typeof(Toeic2380601959WebMvcModule).Assembly);
    }
}