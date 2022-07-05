module String_map = Map.Make (String)
module Json = Yojson.Basic

let labels_of_tags (tags : Logs.Tag.set) : Json.t String_map.t =
  Logs.Tag.fold
    (fun tag map ->
      match tag with
      | V (tag_definition, tag_value) ->
        let name = Logs.Tag.name tag_definition in
        let tag_string =
          Fmt.str "%a" (Logs.Tag.printer tag_definition) tag_value in
        String_map.update name (fun _v -> Some (`String tag_string)) map)
    tags String_map.empty

let json_fields_of_tags (tags : Logs.Tag.set) : Json.t String_map.t =
  let labels = labels_of_tags tags in
  labels

let add_basic_fields (fields : Json.t String_map.t) level src message =
  let add_if_new name thunk map =
    if String_map.mem name map then map else String_map.add name (thunk ()) map
  in
  let replace key value map =
    String_map.remove key map |> String_map.add key value in
  add_if_new "log.time"
    (fun () -> `String (Ptime.to_rfc3339 @@ Ptime_clock.now ()))
    fields
  |> add_if_new "log.level" (fun () ->
         `String (Logs.level_to_string (Some level)))
  |> add_if_new "log.logger" (fun () -> `String (Logs.Src.name src))
  (* Always include the log message *)
  |> replace "message" (`String message)

let reporter ppf =
  let report src level ~over k msgf =
    let continuation _ =
      over ();
      k () in
    let as_json _header tags k ppf fmt =
      Fmt.kstr
        (fun message ->
          let fields =
            let custom_fields = json_fields_of_tags tags in
            add_basic_fields custom_fields level src message in
          let json : Json.t = `Assoc (String_map.bindings fields) in
          Fmt.kpf k ppf "%s@." (Json.to_string json))
        fmt in
    msgf @@ fun ?header ?(tags = Logs.Tag.empty) fmt ->
    as_json header tags continuation ppf fmt in
  { Logs.report }
