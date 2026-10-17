namespace Toeic2380601959.EntityFrameworkCore.Seed.Host;

public class InitialHostDbBuilder
{
    private readonly Toeic2380601959DbContext _context;

    public InitialHostDbBuilder(Toeic2380601959DbContext context)
    {
        _context = context;
    }

    public void Create()
    {
        new DefaultEditionCreator(_context).Create();
        new DefaultLanguagesCreator(_context).Create();
        new HostRoleAndUserCreator(_context).Create();
        new DefaultSettingsCreator(_context).Create();

        _context.SaveChanges();
    }
}
