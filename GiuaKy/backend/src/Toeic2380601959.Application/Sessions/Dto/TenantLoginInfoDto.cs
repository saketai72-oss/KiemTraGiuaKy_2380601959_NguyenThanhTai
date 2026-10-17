using Abp.Application.Services.Dto;
using Abp.AutoMapper;
using Toeic2380601959.MultiTenancy;

namespace Toeic2380601959.Sessions.Dto;

[AutoMapFrom(typeof(Tenant))]
public class TenantLoginInfoDto : EntityDto
{
    public string TenancyName { get; set; }

    public string Name { get; set; }
}
