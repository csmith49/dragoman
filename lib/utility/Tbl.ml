module type KEY = sig
    type t
    val equal : t -> t -> bool
    val compare : t -> t -> int
    val to_string : t -> string
end

module type VALUE = sig
    type t
    val equal : t -> t -> bool
    val to_string : t -> string
end

module Make (Key : KEY) (Value : VALUE) = struct
    (* types that are exposed *)
    type key = Key.t
    type value = Value.t
    
    type row = value list
    type keyed_row = (key * value) list
    type column = value list

    type t = {
        rows : row list;
        keys : key list;
        is_identity : bool;
    }

    type mapping = (key * key) list
    
    (* utility stuff *)
    let getter (key : key) (tbl : t) : row -> value option =
        let index = CCList.find_idx 
            (fun k -> Key.equal k key) 
            tbl.keys
                |> CCOpt.map fst in
        match index with
            | Some i -> (fun r -> CCList.get_at_idx i r)
            | _ -> (fun _ -> None)

    module KeySet = CCSet.Make(Key)

    let row_equal = CCList.equal Value.equal

    (* exposed accessors *)
    let get key tbl =
        let getter = getter key tbl in
        let values = CCList.map getter tbl.rows in
            values |> CCList.all_some
    
    let keys tbl = tbl.keys

    let rows tbl = tbl.rows

    let get_row idx tbl = CCList.get_at_idx idx tbl.rows

    (* exposed constructors *)
    let empty keys = {
        rows = [];
        keys = keys;
        is_identity = false;
    }

    let join_identity = {
        rows = [];
        keys = [];
        is_identity = true;
    }

    let of_list keys rows =
        let ok_length r = 
            (CCList.length keys) == (CCList.length r) in
        let all_ok = CCList.for_all ok_length rows in
        if all_ok then Some {
            rows = rows;
            keys = keys;
            is_identity = false;
        } else None

    (* exposed manipulation functions *)
    let project keys tbl =
        let getters = CCList.map (fun k -> getter k tbl) keys in
        let project_row r =
            CCList.map (fun g -> g r) getters
                |> CCList.all_some in
        let rows = CCList.map project_row tbl.rows
            |> CCList.all_some in
        match rows with
            | Some rows -> Some { rows = rows; keys = keys; is_identity = false; }
            | None -> None

    let rename mapping tbl =
        let keys = CCList.map (fun k ->
            match CCList.assoc_opt ~eq:Key.equal k mapping with
                | Some k' -> k'
                | _ -> k
        ) tbl.keys in {
            tbl with keys = keys;
        }

    let join left right =
        (* check to make sure neither are the identity *)
        if left.is_identity then right else
        if right.is_identity then left else
        (* convert both bunches of keys to sets *)
        let left_keys = KeySet.of_list left.keys in
        let right_keys = KeySet.of_list right.keys in
        (* get the final list of keys *)
        let keys = KeySet.union left_keys right_keys
            |> KeySet.to_list in
        (* get the keys in both rows *)
        let both = KeySet.inter left_keys right_keys in
        (* check if lrow and rrow match on all shared keys *)
        let check lrow rrow =
            KeySet.for_all (fun k -> 
                let lvalue = getter k left lrow in
                let rvalue = getter k right rrow in
                match lvalue, rvalue with
                    | Some lv, Some rv -> Value.equal lv rv
                    | _ -> false
            ) both in
        (* for possible combination of rows, check if they match and concat accordingly *)
        let rows = [left.rows ; right.rows]
            |> CCList.cartesian_product
            |> CCList.filter_map (fun xs -> match xs with
                | [l ; r] -> 
                    if check l r then Some (l @ r) else None
                | _ -> None) in
        (* this contains too much info - keys in both now in each row twice - we rely on project to fix this *)
        let cross_prod = {
            keys = left.keys @ right.keys;
            rows = rows;
            is_identity = false;
        } in
        match project keys cross_prod with
            | Some tbl -> tbl
            | None -> empty keys (* this case should not happen *)

    let join_all tbls =
        CCList.fold_left join join_identity tbls

    let keyed_rows tbl = 
        let key_up row = CCList.map2 (fun k -> fun v -> (k, v)) tbl.keys row in
        CCList.map key_up tbl.rows

    let filter pred tbl =
        let rows = tbl
            |> keyed_rows
            |> CCList.filter pred
            (* unkey each row *)
            |> CCList.map (CCList.map snd) in 
        {
            tbl with rows = rows;
        }

    (* exposed comparisons *)
    let equal left right =
        (* check if left and right use the same keys *)
        if not (KeySet.equal (KeySet.of_list left.keys) (KeySet.of_list right.keys)) then false else
        (* if they do, reoreder right to match left *)
        let right = project left.keys right |> CCOpt.get_exn in
        (* check that every row in left is a row in right *)
        let left_in_right = left.rows
            |> CCList.for_all (fun r -> CCList.mem ~eq:row_equal r right.rows) in
        if not left_in_right then false else
        (* check that every row in right is a row in left *)
        let right_in_left = right.rows
            |> CCList.for_all (fun r -> CCList.mem ~eq:row_equal r left.rows) in
        if not right_in_left then false else
        (* if all the above, call the two tables equal *)
        true

    (* exposed output stuff *)
    let to_csv ?(delimiter=",") tbl =
        let header = tbl.keys
            |> CCList.map Key.to_string
            |> CCString.concat delimiter in
        let rows = tbl.rows
            |> CCList.map (CCList.map Value.to_string)
            |> CCList.map (CCString.concat delimiter) in
        CCString.concat "\n" (header :: rows)
end