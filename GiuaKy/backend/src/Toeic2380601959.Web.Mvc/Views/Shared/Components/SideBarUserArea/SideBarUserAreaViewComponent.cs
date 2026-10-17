using Abp.Configuration.Startup;
using Toeic2380601959.Sessions;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace Toeic2380601959.Web.Views.Shared.Components.SideBarUserArea;

public class SideBarUserAreaViewComponent : Toeic2380601959ViewComponent
{
    private readonly ISessionAppService _sessionAppService;
    private readonly IMultiTenancyConfig _multiTenancyConfig;

    public SideBarUserAreaViewComponent(
        ISessionAppService sessionAppService,
        IMultiTenancyConfig multiTenancyConfig)
    {
        _sessionAppService = sessionAppService;
        _multiTenancyConfig = multiTenancyConfig;
    }

    public async Task<IViewComponentResult> InvokeAsync()
    {
        var model = new SideBarUserAreaViewModel
        {
            LoginInformations = await _sessionAppService.GetCurrentLoginInformations(),
            IsMultiTenancyEnabled = _multiTenancyConfig.IsEnabled,
        };

        return View(model);
    }
}
