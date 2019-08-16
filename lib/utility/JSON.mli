type 'a parser = Yojson.Basic.t -> 'a option

module Parse : sig
    val list : 'a parser -> Yojson.Basic.t -> 'a list option
    val assoc : (string * 'a parser) list -> Yojson.Basic.t -> (string * 'a) list option
end

val assoc : Yojson.Basic.t -> string -> Yojson.Basic.t option
val string : Yojson.Basic.t -> string option
val int : Yojson.Basic.t -> int option
val list : Yojson.Basic.t -> Yojson.Basic.t list option