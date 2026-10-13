{ lib, pkgs, ... }:
let
  desktopFile = "onlyoffice-desktopeditors.desktop";
  officeMimeTypes = [
    "application/msword"
    "application/msword-template"
    "application/vnd.ms-word.document.macroEnabled.12"
    "application/vnd.ms-word.template.macroEnabled.12"
    "application/vnd.ms-excel"
    "application/vnd.ms-excel.sheet.macroEnabled.12"
    "application/vnd.ms-excel.sheet.binary.macroEnabled.12"
    "application/vnd.ms-excel.template.macroEnabled.12"
    "application/vnd.ms-powerpoint"
    "application/vnd.ms-powerpoint.presentation.macroEnabled.12"
    "application/vnd.ms-powerpoint.slideshow.macroEnabled.12"
    "application/vnd.ms-powerpoint.template.macroEnabled.12"
    "application/vnd.ms-visio.drawing.main+xml"
    "application/vnd.ms-visio.drawing.macroEnabled.main+xml"
    "application/vnd.ms-visio.stencil.main+xml"
    "application/vnd.ms-visio.stencil.macroEnabled.main+xml"
    "application/vnd.ms-visio.template.main+xml"
    "application/vnd.ms-visio.template.macroEnabled.main+xml"
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
    "application/vnd.openxmlformats-officedocument.wordprocessingml.template"
    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    "application/vnd.openxmlformats-officedocument.spreadsheetml.template"
    "application/vnd.openxmlformats-officedocument.presentationml.presentation"
    "application/vnd.openxmlformats-officedocument.presentationml.slideshow"
    "application/vnd.openxmlformats-officedocument.presentationml.template"
    "application/vnd.apple.pages"
    "application/vnd.apple.numbers"
    "application/vnd.apple.keynote"
    "application/vnd.oasis.opendocument.text"
    "application/vnd.oasis.opendocument.text-flat-xml"
    "application/vnd.oasis.opendocument.text-template"
    "application/vnd.oasis.opendocument.spreadsheet"
    "application/vnd.oasis.opendocument.spreadsheet-flat-xml"
    "application/vnd.oasis.opendocument.spreadsheet-template"
    "application/vnd.oasis.opendocument.presentation"
    "application/vnd.oasis.opendocument.presentation-flat-xml"
    "application/vnd.oasis.opendocument.presentation-template"
    "application/vnd.oasis.opendocument.graphics"
    "application/vnd.sun.xml.writer"
    "application/vnd.sun.xml.writer.template"
    "application/vnd.sun.xml.calc"
    "application/vnd.sun.xml.impress"
    "application/wps-office.wps"
    "application/wps-office.wpt"
    "application/wps-office.et"
    "application/wps-office.ett"
    "application/wps-office.dps"
    "application/wps-office.dpt"
    "application/x-hwp"
    "application/rtf"
    "text/csv"
    "text/tab-separated-values"
  ];
  defaultApplications = lib.genAttrs officeMimeTypes (_: [ desktopFile ]);
in
{
  home.packages = with pkgs; [ onlyoffice-desktopeditors ];

  xdg.mimeApps = {
    associations.added = defaultApplications;
    inherit defaultApplications;
  };
}
