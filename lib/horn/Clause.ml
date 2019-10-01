type t = Conjunct.t list

(* getters *)
let variables clause = CCList.flat_map Conjunct.variables clause
    |> CCList.uniq ~eq:Core.Variable.equal

let conjuncts clause = clause

(* mainpulation *)
let remap clause mapping =
    CCList.map (fun conjunct -> Conjunct.remap conjunct mapping) clause

(* to and from json *)
let of_json json = let module J = Utility.JSON in
    J.Parse.list Conjunct.of_json json

let to_json clause = `List (
    clause |> CCList.map Conjunct.to_json
)

(* printing *)
let to_string clause = CCString.concat ", " (CCList.map Conjunct.to_string clause)

let rec to_query = function
    | [] -> `Empty
    | conj :: [] -> Conjunct.to_query conj
    | conj :: rest -> `Join (Conjunct.to_query conj, to_query rest)
