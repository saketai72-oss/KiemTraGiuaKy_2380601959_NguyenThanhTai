using Abp.AspNetCore.Mvc.Authorization;
using Toeic2380601959.Controllers;
using Microsoft.AspNetCore.Mvc;

namespace Toeic2380601959.Web.Controllers;

[AbpMvcAuthorize]
public class HomeController : Toeic2380601959ControllerBase
{
    public ActionResult Index()
    {
        return View();
    }
}
