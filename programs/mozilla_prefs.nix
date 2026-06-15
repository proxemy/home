# prefs.js settings for firefox and thunderbird
# TODO: maybe migrate all or most settings in firefox.nix to here.
{
  lib,
  disable_ai ? true,
}:
lib.optionalAttrs disable_ai {
  "browser.ml.chat.enabled" = false;
  "browser.ml.chat.sidebar" = false;
  "browser.ml.chat.menu" = false;
  "browser.ml.chat.page" = false;
  "browser.ml.enable" = false;
  "browser.ml.linkPreview.enabled" = false;
  "browser.ml.pageAssist.enabled" = false;
  "browser.ml.smartAssist.enabled" = false;
  "browser.search.visualSearch.featureGate" = false;
  "browser.tabs.groups.smart.enabled" = false;
  "browser.tabs.groups.smart.userEnabled" = false;
  "extensions.ml.enabled" = false;
  "pdfjs.enableAltText" = false;
  "sidebar.revamp" = false; # optional
  "pdfjs.enableAltTextModelDownload" = false;
  "pdfjs.enableGuessAltText" = false;

  "browser.ai.control.default" = "blocked";
  "browser.ai.control.linkPreviewKeyPoints" = "blocked";
  "browser.ai.control.pdfjsAltText" = "blocked";
  "browser.ai.control.sidebarChatbot" = "blocked";
  "browser.ai.control.smartTabGroups" = "blocked";
  "browser.ai.control.translations" = "blocked";
}
