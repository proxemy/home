{
  lib,
  feeds ? {
    category1 = {
      feed1_name = "feed1_url";
      feed2_name = "feed2_url";
    };
  },
}:
let
  unpack_map = set: f: lib.attrsets.mapAttrsToList (k: v: (f k v)) set;
  unpack_map_str = set: f: lib.lists.fold (tally: e: tally + e) "" (unpack_map set f);
in
{
  OPML =
    let
      inherit (lib.strings) escapeXML;
      mk_parent_node = name: children: ''
        <outline title="${escapeXML name}" type="folder">
        ${unpack_map_str children mk_entry_node}
        </outline>''\n
      '';
      mk_entry_node = title: url: ''
        ''\t<outline title="${escapeXML title}" xmlUrl="${escapeXML url}"/>
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

  newsboat_url_list =
    let
      mk_named_tagged_urls =
        tag: name_urls:
        builtins.toString (lib.attrsets.mapAttrsToList (name: url: (mk_entry tag name url)) name_urls);
      mk_entry = tag: name: url: ''
        ${url} "~${name}" "${tag}"
      '';
    in
    unpack_map_str feeds mk_named_tagged_urls;
}
