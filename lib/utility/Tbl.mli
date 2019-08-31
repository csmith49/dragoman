(** Representation of tables in the SQL sense *)

(** {1} Signatures *)

(** Keys are one mechanism by which tables are indexed, so we must be able to compare them *)
module type KEY = sig
    type t
    val equal : t -> t -> bool
    val compare : t -> t -> int
    val to_string : t -> string
end

(** Values are what are stored in the table

we only require they have the ability to be converted to an easy output format *)
module type VALUE = sig
    type t
    val equal : t -> t -> bool
    val to_string : t -> string
end

(** {1} Module  *)

(** [Make(K)(V)] constructs a module for operating on tables storing values of type [V.t] and indexed by keys of type [K.t] *)
module Make (Key : KEY) (Value : VALUE) : sig
    (** {2} Basic *)

    (** Table types [t] are abstracted away *)
    type t
    
    (** The type of keys is taken from the functor input [Key]  *)
    type key = Key.t

    (** The type of values is taken from the functor input [Value] *)
    type value = Value.t

    (** A row is a horizontal slice of a table, and knows nothing about being indexed by keys *)
    type row = value list

    (** A column is a vertical slice of a table
    
    like rows, columns know nothing of the key that indexes them *)
    type column = value list

    (** {2} Access  *)

    (** [get key tbl] projects out the column indexed by [key], if it exists  *)
    val get : key -> t -> column option

    (** [keys tbl] returns a list of all keys in use by the table  *)
    val keys : t -> key list

    (** [rows tbl] drops all information about indexing via keys and just returns the rows as raw lists *)
    val rows : t -> row list

    (** [get_row i tbl] gets the i'th row, if it exists
    
    equivalent to a safe [(rows tbl) !! i] *)
    val get_row : int -> t -> row option

    (** {2} Construction *)

    (** [empty keys] constructs the table with no rows to be indexed by keys in [keys] *)
    val empty : key list -> t

    (** [join_identity] is a special type of empty table that has no keys associated with it
    
    notably [join join_identity tbl = join tbl join_identity = tbl]  *)
    val join_identity : t

    (** [of_list keys rows] constructs a table from the raw representation - can fail if the rows are jagged *)
    val of_list : key list -> row list -> t option

    (** {2} Manipulation *)
    
    (** [project keys tbl] drops all columns in [tbl] that aren't in the list [keys]
    
    if [keys] contains a key not used in [tbl], the projection will fail *)
    val project : key list -> t -> t option

    (** [mapping] is an association list between keys, used for easy renaming of columns *)
    type mapping = (key * key) list

    (** [rename mapping tbl] simply maps all keys in [tbl]
    
    if a key is not in [mapping], it is not renamed *)
    val rename : mapping -> t -> t

    (** [join left right] constructs the table with:
    1. keys equivalent to the union of [keys left] and [keys right]
    2. only rows that agree on indices in the intersection of [keys left] and [keys right] *)
    val join : t -> t -> t
    
    (** given a list of tables [tbls], [join_all tbls] collapses the list to a single table using [join] *)
    val join_all : t list -> t

    (** [filter key predicate tbl] returns the table of all rows in [tbl] that satisfy [predicate] on the value indexed by [key]
    
    if [key] is not in [keys tbl] then the output will have no rows *)
    val filter : key -> (value -> bool) -> t -> t

    (** {2} Comparison *)

    (** Using careful sorting, we can check if two tables are equivalent *)
    val equal : t -> t -> bool

    (** {2} Output *)

    (** [to_csv ?delimiter=d tbl] constructs a [d]-separated CSV string using the [to_string]s of the [Key] and [Value] modules *)
    val to_csv : ?delimiter:string -> t -> string
end