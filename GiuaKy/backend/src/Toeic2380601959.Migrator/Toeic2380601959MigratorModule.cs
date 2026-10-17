using Abp.Events.Bus;
using Abp.Modules;
using Abp.Reflection.Extensions;
using Toeic2380601959.Configuration;
using Toeic2380601959.EntityFrameworkCore;
using Toeic2380601959.Migrator.DependencyInjection;
using Castle.MicroKernel.Registration;
using Microsoft.Extensions.Configuration;

namespace Toeic2380601959.Migrator;

[DependsOn(typeof(Toeic2380601959EntityFrameworkModule))]
public class Toeic2380601959MigratorModule : AbpModule
{
    private readonly IConfigurationRoot _appConfiguration;

    public Toeic2380601959MigratorModule(Toeic2380601959EntityFrameworkModule abpProjectNameEntityFrameworkModule)
    {
        abpProjectNameEntityFrameworkModule.SkipDbSeed = true;

        _appConfiguration = AppConfigurations.Get(
            typeof(Toeic2380601959MigratorModule).GetAssembly().GetDirectoryPathOrNull()
        );
    }

    public override void PreInitialize()
    {
        Configuration.DefaultNameOrConnectionString = _appConfiguration.GetConnectionString(
            Toeic2380601959Consts.ConnectionStringName
        );

        Configuration.BackgroundJobs.IsJobExecutionEnabled = false;
        Configuration.ReplaceService(
            typeof(IEventBus),
            () => IocManager.IocContainer.Register(
                Component.For<IEventBus>().Instance(NullEventBus.Instance)
            )
        );
    }

    public override void Initialize()
    {
        IocManager.RegisterAssemblyByConvention(typeof(Toeic2380601959MigratorModule).GetAssembly());
        ServiceCollectionRegistrar.Register(IocManager);
    }
}
