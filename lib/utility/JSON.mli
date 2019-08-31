type 'a parser = Yojson.Basic.t -> 'a option

module Parse : sig
    val get : string -> 'a parser -> Yojson.Basic.t -> 'a option
    val list : 'a parser -> Yojson.Basic.t -> 'a list option
    val assoc : (string * 'a parser) list -> Yojson.Basic.t -> (string * 'a) list option
    val assoc_items : 'a parser -> Yojson.Basic.t -> (string * 'a) list option
    val assoc_some_items : 'a parser -> Yojson.Basic.t -> (string * 'a) list option
end

module Literal : sig
    val string : Yojson.Basic.t -> string option
    val int : Yojson.Basic.t -> int option
end
