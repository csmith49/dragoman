type relation_key = string

module KeyMap = CCMap.Make(CCString)

type t = Relation.t KeyMap.t

let empty = KeyMap.empty

let add store key rel = KeyMap.add key rel store

let relations store = store |> KeyMap.to_list |> CCList.map fst

let relation store key = KeyMap.get key store

let of_list = KeyMap.of_list