type t = {
    attributes : string list;
    relations : string list;
}

let of_json json =
    let attributes = Utility.JSON.Parse.get 
        "attributes"
        (Utility.JSON.Parse.list Utility.JSON.Literal.string)
        json in
    let relations = Utility.JSON.Parse.get
        "relations"
        (Utility.JSON.Parse.list Utility.JSON.Literal.string)
        json in
    match attributes, relations with
        | Some attrs, Some rels -> Some {attributes = attrs ; relations = rels;}
        | _ -> None

let attributes view = view.attributes
let relations view = view.relations