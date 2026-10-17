using Abp.AspNetCore.Mvc.Views;
using Abp.Runtime.Session;
using Microsoft.AspNetCore.Mvc.Razor.Internal;

namespace Toeic2380601959.Web.Views;

public abstract class Toeic2380601959RazorPage<TModel> : AbpRazorPage<TModel>
{
    [RazorInject]
    public IAbpSession AbpSession { get; set; }

    protected Toeic2380601959RazorPage()
    {
        LocalizationSourceName = Toeic2380601959Consts.LocalizationSourceName;
    }
}
