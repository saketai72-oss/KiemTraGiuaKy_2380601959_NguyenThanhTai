using Toeic2380601959.Configuration.Dto;
using System.Threading.Tasks;

namespace Toeic2380601959.Configuration;

public interface IConfigurationAppService
{
    Task ChangeUiTheme(ChangeUiThemeInput input);
}
