{lib, ...}: {
  i18n.defaultLocale = lib.mkDefault "en_IN";
  i18n.supportedLocales = lib.mkDefault ["en_IN/UTF-8" "en_US.UTF-8/UTF-8"];
  i18n.extraLocaleSettings = lib.mkDefault {
    LANGUAGE = "en_IN";
    LC_ADDRESS = "en_IN";
    LC_ALL = "en_IN";
    LC_IDENTIFICATION = "en_IN";
    LC_MEASUREMENT = "en_IN";
    LC_MONETARY = "en_IN";
    LC_NAME = "en_IN";
    LC_NUMERIC = "en_US";
    LC_PAPER = "en_IN";
    LC_TELEPHONE = "en_IN";
    LC_TIME = "en_US";
  };
}
