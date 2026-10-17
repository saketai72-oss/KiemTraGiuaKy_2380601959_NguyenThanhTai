using Abp.Application.Services.Dto;
using Abp.AutoMapper;
using Toeic2380601959.Authorization.Users;

namespace Toeic2380601959.Sessions.Dto;

[AutoMapFrom(typeof(User))]
public class UserLoginInfoDto : EntityDto<long>
{
    public string Name { get; set; }

    public string Surname { get; set; }

    public string UserName { get; set; }

    public string EmailAddress { get; set; }
}
