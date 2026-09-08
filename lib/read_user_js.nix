user_js_text:
with builtins;
let
  prefs_list = filter (line: line != "" && line != [ ]) (split "\n" user_js_text);

  parseLine =
    line:
    let
      m = match ''user_pref\("([^"]+)", (.*)\);.*?'' line;
    in
    if m == null || (builtins.match "^_user.js.parrot$" (elemAt m 0) != null) then
      { rejected = line; }
    else
      {
        name = elemAt m 0;
        value = fromJSON (elemAt m 1);
      };

  result = filter (x: x != null) (map parseLine prefs_list);

in
with builtins;
{
  parsed = listToAttrs (filter (x: (!hasAttr "rejected" x)) result);
  rejected = concatMap (x: [ x.rejected ]) (filter (x: (hasAttr "rejected" x)) result);
}
