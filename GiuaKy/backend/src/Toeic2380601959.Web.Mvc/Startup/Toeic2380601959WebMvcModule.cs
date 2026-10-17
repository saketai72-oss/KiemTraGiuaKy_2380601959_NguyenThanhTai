using Abp.Modules;
using Abp.Reflection.Extensions;
using Toeic2380601959.Configuration;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;

namespace Toeic2380601959.Web.Startup;

[DependsOn(typeof(Toeic2380601959WebCoreModule))]
public class Toeic2380601959WebMvcModule : AbpModule
{
    private readonly IWebHostEnvironment _env;
    private readonly IConfigurationRoot _appConfiguration;

    public Toeic2380601959WebMvcModule(IWebHostEnvironment env)
    {
        _env = env;
        _appConfiguration = env.GetAppConfiguration();
    }

    public override void PreInitialize()
    {
        Configuration.Navigation.Providers.Add<Toeic2380601959NavigationProvider>();
    }

    public override void Initialize()
    {
        IocManager.RegisterAssemblyByConvention(typeof(Toeic2380601959WebMvcModule).GetAssembly());
    }
}
