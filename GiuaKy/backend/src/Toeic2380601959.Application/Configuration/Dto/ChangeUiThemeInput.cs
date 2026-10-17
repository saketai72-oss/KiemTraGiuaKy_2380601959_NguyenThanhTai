using System.ComponentModel.DataAnnotations;

namespace Toeic2380601959.Configuration.Dto;

public class ChangeUiThemeInput
{
    [Required]
    [StringLength(32)]
    public string Theme { get; set; }
}
