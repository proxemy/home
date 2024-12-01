# Common NAS config aprtly used by server and client side
{
    ports = [ 2049 ]; # NFSv4 only, TODO: remove legacy 111
    root = "/export"; # TODO: create dedicated and isolated share dir
    options = "(rw,insecure,all_squash)"; # TODO: read only for now
}
