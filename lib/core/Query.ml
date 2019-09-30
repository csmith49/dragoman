type relation_key = string

type selector = [
    | `Equality of Variable.t * Value.t
    | `And of selector * selector
    | `Or of selector * selector
]

type t = [
    | `Relation of relation_key
    | `Select of selector * t
    | `Project of Variable.t list * t
    | `Rename of Variable.Mapping.t * t
    | `Join of t * t
]

let rec to_string = function
    | `Relation rk -> rk
    | `Select (s, r) -> Printf.sprintf "(select %s %s)"
        (selector_to_string s)
        (to_string r)
    | `Project (xs, r) -> Printf.sprintf "(project (%s) %s)"
        (xs |> CCList.map Variable.to_string |> CCString.concat ", ")
        (to_string r)
    | `Rename (m, r) -> 
        let bts (l, r) = Printf.sprintf "%s/%s"
            (Variable.to_string l)
            (Variable.to_string r) in
        Printf.sprintf "(rename (%s) %s)"
        (m |> CCList.map bts |> CCString.concat ", ")
        (to_string r)
    | `Join (l, r) -> Printf.sprintf "(%s join %s)"
        (to_string l)
        (to_string r)
and selector_to_string = function
    | `And (l, r) -> Printf.sprintf "(%s & %s)"
        (selector_to_string l)
        (selector_to_string r)
    | `Or (l, r) -> Printf.sprintf "(%s | %s)"
        (selector_to_string l)
        (selector_to_string r)
    | `Equality (x, v) -> Printf.sprintf "%s = %s"
        (Variable.to_string x)
        (Value.to_string v)

(* TO SQL STRINGS *)

let rec selector_to_sql = function
    | `Equality (x, v) -> Printf.sprintf "%s = %s"
        (Variable.to_string x)
        (Value.to_string v)
    | `And (l, r) -> Printf.sprintf "(%s) AND (%s)"
        (selector_to_sql l)
        (selector_to_sql r)
    | `Or (l, r) -> Printf.sprintf "(%s) OR (%s)"
        (selector_to_sql l)
        (selector_to_sql r)

let rec to_sql = function
    | `Relation rk -> Printf.sprintf "SELECT * FROM %s" rk
    | `Select (selector, relation) -> Printf.sprintf "SELECT * FROM (%s) WHERE %s"
        (to_sql relation)
        (selector_to_sql selector)
    | `Project (vars, relation) -> Printf.sprintf "SELECT %s FROM (%S)"
        (vars |> CCList.map Variable.to_string |> CCString.concat ", ")
        (to_sql relation)
    | `Rename (mapping, relation) ->
        let bts (l, r) = Printf.sprintf "%s as %s"
            (Variable.to_string l)
            (Variable.to_string r) in
        Printf.sprintf "SELECT %s FROM (%S)"
            (mapping |> CCList.map bts |> CCString.concat ", ")
            (to_sql relation)
    | `Join (l, r) -> Printf.sprintf "SELECT * FROM ((%s) JOIN (%s))"
        (to_sql l)
        (to_sql r)
    | _ -> "NULL"

(* EVALUATION *)

let rec evaluate_selector (selector : selector) : Table.keyed_row -> bool = fun row -> match selector with
    | `Equality (x, v) -> begin match CCList.assoc_opt ~eq:Variable.equal x row with
        | Some res -> Value.equal res v
        | None -> false end
    | `And (left, right) -> (evaluate_selector left row) && (evaluate_selector right row)
    | `Or (left, right) -> (evaluate_selector left row) || (evaluate_selector right row)


let rec evaluate scene = function
    | `Relation rk -> begin match Scene.relation scene rk with
        | Some relation ->
            Table.of_relation relation (Variable.of_string "left") (Variable.of_string "right")
        | None -> None end
    | `Select (selector, relation) ->
        let tbl = evaluate scene relation in
        let pred = evaluate_selector selector in
            CCOpt.map (Table.filter pred) tbl
    | `Project (vars, relation) ->
        let tbl = evaluate scene relation in
            CCOpt.flat_map (Table.project vars) tbl
    | `Rename (mapping, relation) ->
        let tbl = evaluate scene relation in
            CCOpt.map (Table.rename mapping) tbl
    | `Join (left, right) ->
        let left_tbl = evaluate scene left in
        let right_tbl = evaluate scene right in
            CCOpt.map2 Table.join left_tbl right_tbl