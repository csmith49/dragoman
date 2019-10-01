type relation_key = string

type selector = [
    | `Equal of Variable.t * Variable.t
    | `EqualConst of Variable.t * Value.t
    | `And of selector * selector
    | `Or of selector * selector
]

type t = [
    | `Relation of relation_key
    | `Select of selector * t
    | `Project of Variable.t list * t
    | `Rename of Variable.Mapping.t * t
    | `Join of t * t
    | `Empty
]

module X = struct
    let left = Variable.of_string "left"
    let right = Variable.of_string "right"
end

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
    | `Empty -> "empty"
and selector_to_string = function
    | `And (l, r) -> Printf.sprintf "(%s & %s)"
        (selector_to_string l)
        (selector_to_string r)
    | `Or (l, r) -> Printf.sprintf "(%s | %s)"
        (selector_to_string l)
        (selector_to_string r)
    | `EqualConst (x, v) -> Printf.sprintf "%s = %s"
        (Variable.to_string x)
        (Value.to_string v)
    | `Equal (x, y) -> Printf.sprintf "%s = %s"
        (Variable.to_string x)
        (Variable.to_string y)

(* TO SQL STRINGS *)

let rec selector_to_sql = function
    | `EqualConst (x, v) -> Printf.sprintf "%s = %s"
        (Variable.to_string x)
        (Value.to_string v)
    | `Equal (x, y) -> Printf.sprintf "%s = %s"
        (Variable.to_string x)
        (Variable.to_string y)
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
    | `Empty -> "()"

(* EVALUATION *)

let rec evaluate_selector (selector : selector) : Table.keyed_row -> bool = fun row -> match selector with
    | `EqualConst (x, v) -> begin match CCList.assoc_opt ~eq:Variable.equal x row with
        | Some res -> Value.equal res v
        | None -> false end
    | `Equal (x, y) ->
        let get k = CCList.assoc_opt ~eq:Variable.equal k row in
        begin match get x, get y with
            | Some f, Some g -> Value.equal f g
            | _ -> false end
    | `And (left, right) -> (evaluate_selector left row) && (evaluate_selector right row)
    | `Or (left, right) -> (evaluate_selector left row) || (evaluate_selector right row)


let rec evaluate store = function
    | `Relation rk -> begin match Store.relation store rk with
        | Some relation ->
            Table.of_relation relation X.left X.right
        | None -> None end
    | `Select (selector, relation) ->
        let tbl = evaluate store relation in
        let pred = evaluate_selector selector in
            CCOpt.map (Table.filter pred) tbl
    | `Project (vars, relation) ->
        let tbl = evaluate store relation in
            CCOpt.flat_map (Table.project vars) tbl
    | `Rename (mapping, relation) ->
        let tbl = evaluate store relation in
            CCOpt.map (Table.rename mapping) tbl
    | `Join (left, right) ->
        let left_tbl = evaluate store left in
        let right_tbl = evaluate store right in
            CCOpt.map2 Table.join left_tbl right_tbl
    | `Empty -> Some (Table.empty [])