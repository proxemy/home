{ pkgs, feeds ? [] }:
{
  OPMLtree = ""
    <?xml version="1.0"?>
    <opml version="1.0">
    <head>
      <title>OPML Feed List</title>
    </head>
    <body>
      ${pkgs.lib.lists.foldl (nodes: url: nodes + "<outline xmlUrl='${url}'>\n") "" feeds}
    </body>
  "";
}
