# measures of desperation. many unmet edge cases.
lib: ini_text:
with builtins;
let
  remove_empty =
    value: filter (x: x != "" && x != [ ]) (map (y: if isList y then remove_empty y else y) value);

  split_sections = ini: lib.flatten (remove_empty (split "[ \n\t]*\\[([^\]]+)\][\n\t]*" ini));
  split_params_block = b: remove_empty (split "[\n\t]" b);
  split_param_str = s: remove_empty (split "[[:space:] ]*=[[:space:] ]*" s);

  param_tuple_to_attr = p: {
    name = lib.strings.trim (lib.head p);
    value =
      let
        rest = toString (lib.drop 1 p);
      in
      if match "^-?[0-9.]+$" rest != null then (fromJSON rest) else rest;
  };

  sections_values = split_sections ini_text;

  sections_attrs =
    assert (lib.mod (length sections_values) 2) == 0;
    lib.listToAttrs (
      remove_empty (
        lib.imap1 (
          i: v:
          if (lib.mod i 2 == 1) then
            {
              name = v;
              value = elemAt sections_values i;
            }
          else
            [ ]
        ) sections_values
      )
    );

  s_params_list = mapAttrs (s: ps: split_params_block ps) sections_attrs;
  s_params_list_kv = mapAttrs (s: ps: (map (p: split_param_str p) ps)) s_params_list;
  s_params_attrs = mapAttrs (s: ps: (map (p: param_tuple_to_attr p) ps)) s_params_list_kv;

in
builtins.mapAttrs (s: ps: (lib.listToAttrs ps)) s_params_attrs
