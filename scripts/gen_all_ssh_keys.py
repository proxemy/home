#!/usr/bin/python3

import os

HOSTNAMES = { "TODO" : "get from secrets" }
SSH_KEY_GEN = "TODO: get from secrets"

nix_str = ""

for hname in HOSTNAMES.keys():
	os.system(f"{SSH_KEY_GEN} -f out/{hname} -C {hname}")

def read_key(k):
	return k.read()[:-1] # cut off trailing new line

for hname, alias in HOSTNAMES.items():

	with open(f"out/{hname}.pub", "r") as pub, \
		open(f"out/{hname}", "r") as priv:

		nix_str += f"""
"${{hostNamesAliases.{alias}}}" = {{
  pub = "{read_key(pub)}";
  priv = ''
{read_key(priv)}
  '';
}};
"""

print(nix_str)
