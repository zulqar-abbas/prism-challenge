module Response = {
  type t

  @send
  external json: t => Js.Promise.t<Js.Json.t> = "json"

  @send
  external text: t => Js.Promise.t<string> = "text"

  @get
  external ok: t => bool = "ok"

  @get
  external status: t => int = "status"

  @get
  external statusText: t => string = "statusText"
}

type options = {
  method: string,
  headers: Js.Dict.t<string>,
  body: option<string>,
}

@val
external fetch: (string, options) => Js.Promise.t<Response.t> = "fetch"

let fetchJson = (~headers=Js.Dict.empty(), url: string): Js.Promise.t<Js.Json.t> =>
  fetch(url, {method: "GET", headers: headers, body: None}) |> Js.Promise.then_(res =>
    if !Response.ok(res) {
      res->Response.text->Js.Promise.then_(text => {
        let msg = `${res->Response.status->Js.Int.toString} ${res->Response.statusText}: ${text}`
        Js.Exn.raiseError(msg)
      }, _)
    } else {
      res->Response.json
    }
  )

type method = PUT | POST

let postJson = (
  url: string, 
  body: Js.Json.t
): Js.Promise.t<Js.Json.t> => {
  let headers = Js.Dict.empty();
  Js.Dict.set(headers, "Content-Type", "application/json")

  fetch(
    url,
    {
      method: "PUT",
      headers: headers,
      body: Some(Js.Json.stringify(body)),
    },
  )
  |> Js.Promise.then_(res =>
    if !Response.ok(res) {
      res->Response.text->Js.Promise.then_(text => {
        let msg = `${res->Response.status->Js.Int.toString} ${res->Response.statusText}: ${text}`
        Js.Exn.raiseError(msg)
      }, _)
    } else {
      res->Response.json
    }
  )
}