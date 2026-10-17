using Toeic2380601959.Models.TokenAuth;
using Toeic2380601959.Web.Controllers;
using Shouldly;
using System.Threading.Tasks;
using Xunit;

namespace Toeic2380601959.Web.Tests.Controllers;

public class HomeController_Tests : Toeic2380601959WebTestBase
{
    [Fact]
    public async Task Index_Test()
    {
        await AuthenticateAsync(null, new AuthenticateModel
        {
            UserNameOrEmailAddress = "admin",
            Password = "123qwe"
        });

        //Act
        var response = await GetResponseAsStringAsync(
            GetUrl<HomeController>(nameof(HomeController.Index))
        );

        //Assert
        response.ShouldNotBeNullOrEmpty();
    }
}