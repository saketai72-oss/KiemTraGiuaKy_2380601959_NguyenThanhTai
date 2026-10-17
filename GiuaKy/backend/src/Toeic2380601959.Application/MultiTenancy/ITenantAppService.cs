using Abp.Application.Services;
using Toeic2380601959.MultiTenancy.Dto;

namespace Toeic2380601959.MultiTenancy;

public interface ITenantAppService : IAsyncCrudAppService<TenantDto, int, PagedTenantResultRequestDto, CreateTenantDto, TenantDto>
{
}

