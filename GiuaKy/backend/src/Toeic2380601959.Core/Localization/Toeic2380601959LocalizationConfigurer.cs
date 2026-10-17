using Abp.Configuration.Startup;
using Abp.Localization.Dictionaries;
using Abp.Localization.Dictionaries.Xml;
using Abp.Reflection.Extensions;

namespace Toeic2380601959.Localization;

public static class Toeic2380601959LocalizationConfigurer
{
    public static void Configure(ILocalizationConfiguration localizationConfiguration)
    {
        localizationConfiguration.Sources.Add(
            new DictionaryBasedLocalizationSource(Toeic2380601959Consts.LocalizationSourceName,
                new XmlEmbeddedFileLocalizationDictionaryProvider(
                    typeof(Toeic2380601959LocalizationConfigurer).GetAssembly(),
                    "Toeic2380601959.Localization.SourceFiles"
                )
            )
        );
    }
}
