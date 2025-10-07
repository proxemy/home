{
  pkgs,
  feeds ? { },
}:
let
  escape_xml = pkgs.lib.strings.escapeXML;
  unpack_map = set: f: pkgs.lib.attrsets.mapAttrsToList (k: v: (f k v)) set;
  unpack_map_str = set: f: pkgs.lib.lists.fold (tally: e: tally + e) "" (unpack_map set f);
in
{
  OPML =
    let
      mk_parent_node = name: children: ''
        <outline title="${escape_xml name}" type="folder">
        ${unpack_map_str children mk_entry_node}
        </outline>''\n
      '';
      mk_entry_node = title: url: ''
      ''\t<outline title="${escape_xml title}" xmlUrl="${escape_xml url}"/>
      '';
    in
    ''
      <?xml version="1.0"?>
      <opml version="1.0">
      <head>
        <title>OPML Feed List</title>
      </head>
      <body>
      ${unpack_map_str feeds mk_parent_node}
      </body>
      </opml>
    '';
}
