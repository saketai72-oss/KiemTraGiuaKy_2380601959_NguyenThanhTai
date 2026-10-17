using System.ComponentModel.DataAnnotations;

namespace Toeic2380601959.Users.Dto;

public class ChangeUserLanguageDto
{
    [Required]
    public string LanguageName { get; set; }
}