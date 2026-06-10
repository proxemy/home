# prefs.js settings for firefox and thunderbird
# TODO: maybe migrate all or most settings in firefox.nix to here.
{
  lib,
  disable_ai ? true,
}:
lib.optionalAttrs disable_ai {
  "browser.ml.enable" = false;
  "browser.ml.chat.enabled" = false;
  "browser.ml.pageAssist.enabled" = false;
  "browser.ml.linkPreview.enabled" = false;
  "extensions.ml.enabled" = false;
  "browser.tabs.groups.smart.enabled" = false;
  "browser.search.visualSearch.featureGate" = false;
  "pdfjs.enableAltText" = false;
  "sidebar.revamp" = false; # optional

  "browser.ai.control.default" = "blocked";
  "browser.ai.control.linkPreviewKeyPoints" = "blocked";
  "browser.ai.control.pdfjsAltText" = "blocked";
  "browser.ai.control.sidebarChatbot" = "blocked";
  "browser.ai.control.smartTabGroups" = "blocked";
  "browser.ai.control.translations" = "blocked";
}
