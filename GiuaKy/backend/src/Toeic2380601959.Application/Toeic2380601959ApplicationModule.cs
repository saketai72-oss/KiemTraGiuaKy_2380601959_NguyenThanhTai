using Abp.AutoMapper;
using Abp.Modules;
using Abp.Reflection.Extensions;
using Toeic2380601959.Authorization;
using Toeic2380601959.EntityFrameworkCore;

namespace Toeic2380601959;

[DependsOn(
    typeof(Toeic2380601959CoreModule),
    typeof(Toeic2380601959EntityFrameworkModule),
    typeof(AbpAutoMapperModule))]
public class Toeic2380601959ApplicationModule : AbpModule
{
    public override void PreInitialize()
    {
        Configuration.Authorization.Providers.Add<Toeic2380601959AuthorizationProvider>();
    }

    public override void Initialize()
    {
        var thisAssembly = typeof(Toeic2380601959ApplicationModule).GetAssembly();

        IocManager.RegisterAssemblyByConvention(thisAssembly);

        Configuration.Modules.AbpAutoMapper().Configurators.Add(
            // Scan the assembly for classes which inherit from AutoMapper.Profile
            cfg => cfg.AddMaps(thisAssembly)
        );
    }
}
