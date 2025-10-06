{
  pkgs,
  feeds ? { },
}:
let
  unpack_map = set: f: pkgs.lib.attrsets.mapAttrsToList (k: v: (f k v)) set;
  unpack_map_str = set: f: pkgs.lib.lists.fold (tally: e: tally + e) "" (unpack_map set f);
in
{
  OPMLtree =
    let
      mk_parent_node = name: children: ''
        <outline title="${name} type="folder"">\n
          ${unpack_map_str children mk_entry_node}
        </outline>
      '';
      mk_entry_node = title: url: ''
        <outline title="${title}" xmlUrl="${url}">}\n
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
    '';
}
