using Abp.AspNetCore.Mvc.ViewComponents;

namespace Toeic2380601959.Web.Views;

public abstract class Toeic2380601959ViewComponent : AbpViewComponent
{
    protected Toeic2380601959ViewComponent()
    {
        LocalizationSourceName = Toeic2380601959Consts.LocalizationSourceName;
    }
}
