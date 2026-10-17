using Abp.ObjectMapping;
using Toeic2380601959.Sessions;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace Toeic2380601959.Web.Views.Shared.Components.TenantChange;

public class TenantChangeViewComponent : Toeic2380601959ViewComponent
{
    private readonly ISessionAppService _sessionAppService;
    private readonly IObjectMapper _objectMapper;

    public TenantChangeViewComponent(ISessionAppService sessionAppService, IObjectMapper objectMapper)
    {
        _sessionAppService = sessionAppService;
        _objectMapper = objectMapper;
    }

    public async Task<IViewComponentResult> InvokeAsync()
    {
        var loginInfo = await _sessionAppService.GetCurrentLoginInformations();
        var model = _objectMapper.Map<TenantChangeViewModel>(loginInfo);
        return View(model);
    }
}
