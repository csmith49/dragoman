type t = string

let of_json = Utility.JSON.string

let to_json s = `String s

let compare = CCString.compare
let equal = CCString.equal

let hash = CCString.hash

let to_string s = s