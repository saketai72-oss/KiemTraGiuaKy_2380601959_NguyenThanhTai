using Abp.AspNetCore.Mvc.Controllers;
using Abp.IdentityFramework;
using Microsoft.AspNetCore.Identity;

namespace Toeic2380601959.Controllers
{
    public abstract class Toeic2380601959ControllerBase : AbpController
    {
        protected Toeic2380601959ControllerBase()
        {
            LocalizationSourceName = Toeic2380601959Consts.LocalizationSourceName;
        }

        protected void CheckErrors(IdentityResult identityResult)
        {
            identityResult.CheckErrors(LocalizationManager);
        }
    }
}
