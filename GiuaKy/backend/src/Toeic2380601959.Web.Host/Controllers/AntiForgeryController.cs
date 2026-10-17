using Abp.Web.Security.AntiForgery;
using Toeic2380601959.Controllers;
using Microsoft.AspNetCore.Antiforgery;

namespace Toeic2380601959.Web.Host.Controllers
{
    public class AntiForgeryController : Toeic2380601959ControllerBase
    {
        private readonly IAntiforgery _antiforgery;
        private readonly IAbpAntiForgeryManager _antiForgeryManager;

        public AntiForgeryController(IAntiforgery antiforgery, IAbpAntiForgeryManager antiForgeryManager)
        {
            _antiforgery = antiforgery;
            _antiForgeryManager = antiForgeryManager;
        }

        public void GetToken()
        {
            _antiforgery.SetCookieTokenAndHeader(HttpContext);
        }

        public void SetCookie()
        {
            _antiForgeryManager.SetCookie(HttpContext);
        }
    }
}
