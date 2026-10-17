using Microsoft.EntityFrameworkCore;
using System.Data.Common;

namespace Toeic2380601959.EntityFrameworkCore;

public static class Toeic2380601959DbContextConfigurer
{
    public static void Configure(DbContextOptionsBuilder builder, string connectionString)
    {
        builder.UseSqlServer(connectionString)
               .ConfigureWarnings(w => w.Ignore(Microsoft.EntityFrameworkCore.Diagnostics.RelationalEventId.PendingModelChangesWarning));
    }

    public static void Configure(DbContextOptionsBuilder<Toeic2380601959DbContext> builder, string connectionString)
    {
        builder.UseSqlServer(connectionString)
               .ConfigureWarnings(w => w.Ignore(Microsoft.EntityFrameworkCore.Diagnostics.RelationalEventId.PendingModelChangesWarning));
    }

    public static void Configure(DbContextOptionsBuilder<Toeic2380601959DbContext> builder, DbConnection connection)
    {
        builder.UseSqlServer(connection)
               .ConfigureWarnings(w => w.Ignore(Microsoft.EntityFrameworkCore.Diagnostics.RelationalEventId.PendingModelChangesWarning));
    }
}
