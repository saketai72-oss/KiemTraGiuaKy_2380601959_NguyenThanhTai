using Abp.AutoMapper;
using Toeic2380601959.Sessions.Dto;

namespace Toeic2380601959.Web.Views.Shared.Components.TenantChange;

[AutoMapFrom(typeof(GetCurrentLoginInformationsOutput))]
public class TenantChangeViewModel
{
    public TenantLoginInfoDto Tenant { get; set; }
}
