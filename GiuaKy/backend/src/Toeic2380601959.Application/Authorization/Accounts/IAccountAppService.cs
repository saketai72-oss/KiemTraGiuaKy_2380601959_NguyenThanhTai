using Abp.Application.Services;
using Toeic2380601959.Authorization.Accounts.Dto;
using System.Threading.Tasks;

namespace Toeic2380601959.Authorization.Accounts;

public interface IAccountAppService : IApplicationService
{
    Task<IsTenantAvailableOutput> IsTenantAvailable(IsTenantAvailableInput input);

    Task<RegisterOutput> Register(RegisterInput input);
}
