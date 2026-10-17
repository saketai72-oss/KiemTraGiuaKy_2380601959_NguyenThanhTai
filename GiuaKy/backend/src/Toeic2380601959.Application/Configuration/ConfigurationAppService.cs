using Abp.Authorization;
using Abp.Runtime.Session;
using Toeic2380601959.Configuration.Dto;
using System.Threading.Tasks;

namespace Toeic2380601959.Configuration;

[AbpAuthorize]
public class ConfigurationAppService : Toeic2380601959AppServiceBase, IConfigurationAppService
{
    public async Task ChangeUiTheme(ChangeUiThemeInput input)
    {
        await SettingManager.ChangeSettingForUserAsync(AbpSession.ToUserIdentifier(), AppSettingNames.UiTheme, input.Theme);
    }
}
