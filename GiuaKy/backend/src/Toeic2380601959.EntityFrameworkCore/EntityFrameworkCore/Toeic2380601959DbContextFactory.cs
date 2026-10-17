using Toeic2380601959.Configuration;
using Toeic2380601959.Web;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;
using Microsoft.Extensions.Configuration;

namespace Toeic2380601959.EntityFrameworkCore;

/* This class is needed to run "dotnet ef ..." commands from command line on development. Not used anywhere else */
public class Toeic2380601959DbContextFactory : IDesignTimeDbContextFactory<Toeic2380601959DbContext>
{
    public Toeic2380601959DbContext CreateDbContext(string[] args)
    {
        var builder = new DbContextOptionsBuilder<Toeic2380601959DbContext>();

        /*
         You can provide an environmentName parameter to the AppConfigurations.Get method. 
         In this case, AppConfigurations will try to read appsettings.{environmentName}.json.
         Use Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT") method or from string[] args to get environment if necessary.
         https://docs.microsoft.com/en-us/ef/core/cli/dbcontext-creation?tabs=dotnet-core-cli#args
         */
        var configuration = AppConfigurations.Get(WebContentDirectoryFinder.CalculateContentRootFolder());

        Toeic2380601959DbContextConfigurer.Configure(builder, configuration.GetConnectionString(Toeic2380601959Consts.ConnectionStringName));

        return new Toeic2380601959DbContext(builder.Options);
    }
}
