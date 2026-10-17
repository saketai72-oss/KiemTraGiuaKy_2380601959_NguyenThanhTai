using Abp.Application.Services;
using Toeic2380601959.Sessions.Dto;
using System.Threading.Tasks;

namespace Toeic2380601959.Sessions;

public interface ISessionAppService : IApplicationService
{
    Task<GetCurrentLoginInformationsOutput> GetCurrentLoginInformations();
}
