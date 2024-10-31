%raw(`require("./MarginAndPadding.css")`)

module Prism = {
  type state = {
    value: string, 
    isEdited: bool,
    isFocused: bool,
    isError: bool,
  }
  type style = {
    top: state,
    bottom: state,
    right: state,
    left: state,
  }

  type componentStyles = {
    margin: style,
    padding: style,
  }

  let validateMetric = (input: string): bool => {
    let regex = Js.Re.fromString("^(auto|[0-9]+(px|pt|%))$")
    switch Js.Re.test_(regex, input) {
      | true => false
      | false => true
    }
  }

  @react.component
  let make = () => {
    let initialMarginStyles = {
      top: { value: "auto", isFocused: false, isEdited: false, isError: false },
      right: { value: "auto", isFocused: false, isEdited: false, isError: false },
      bottom: { value: "auto", isFocused: false, isEdited: false, isError: false },
      left: { value: "auto", isFocused: false, isEdited: false, isError: false },
    }

    let initialPaddingStyles = {
      top: { value: "auto", isFocused: false, isEdited: false, isError: false },
      right: { value: "auto", isFocused: false, isEdited: false, isError: false },
      bottom: { value: "auto", isFocused: false, isEdited: false, isError: false },
      left: { value: "auto", isFocused: false, isEdited: false, isError: false },
    }

    let (margin, setMargin) = React.useState(_ => initialMarginStyles);
    let (padding, setPadding) = React.useState(_ => initialPaddingStyles);

    let fetchStyles = () => {
       // Fetch styles for the specific component ID from the backend
        Fetch.fetchJson(`http://localhost:12346/styles/${"1"}`)
        |> Js.Promise.then_(styles => {
          let stylesJson = Js.Json.decodeObject(styles)->Belt.Option.getExn
          Js.Console.log(stylesJson);

          let marginValues = Js.Json.decodeObject(Js.Dict.get(stylesJson, "margin")->Belt.Option.getExn)->Belt.Option.getExn
          let paddingValues = Js.Json.decodeObject(Js.Dict.get(stylesJson, "padding")->Belt.Option.getExn)->Belt.Option.getExn

          let marginTop = Js.Dict.get(marginValues, "top") ->Belt.Option.flatMap(Js.Json.decodeString)->Belt.Option.getWithDefault("")
          let marginBottom = Js.Dict.get(marginValues, "bottom") ->Belt.Option.flatMap(Js.Json.decodeString)->Belt.Option.getWithDefault("")
          let marginLeft = Js.Dict.get(marginValues, "left") ->Belt.Option.flatMap(Js.Json.decodeString)->Belt.Option.getWithDefault("")
          let marginRight = Js.Dict.get(marginValues, "right") ->Belt.Option.flatMap(Js.Json.decodeString)->Belt.Option.getWithDefault("")
          
          let marginState = {
            top: { value: marginTop, isFocused: false, isEdited: false, isError: false },
            bottom: { value: marginBottom, isFocused: false, isEdited: false, isError: false },
            left: { value: marginLeft, isFocused: false, isEdited: false, isError: false },
            right: { value: marginRight, isFocused: false, isEdited: false, isError: false },
          }

          let paddingTop = Js.Dict.get(paddingValues, "top") ->Belt.Option.flatMap(Js.Json.decodeString)->Belt.Option.getWithDefault("")
          let paddingBottom = Js.Dict.get(paddingValues, "bottom") ->Belt.Option.flatMap(Js.Json.decodeString)->Belt.Option.getWithDefault("")
          let paddingLeft = Js.Dict.get(paddingValues, "left") ->Belt.Option.flatMap(Js.Json.decodeString)->Belt.Option.getWithDefault("")
          let paddingRight = Js.Dict.get(paddingValues, "right") ->Belt.Option.flatMap(Js.Json.decodeString)->Belt.Option.getWithDefault("")
          
          let paddingState = {
            top: { value: paddingTop, isFocused: false, isEdited: false, isError: false },
            bottom: { value: paddingBottom, isFocused: false, isEdited: false, isError: false },
            left: { value: paddingLeft, isFocused: false, isEdited: false, isError: false },
            right: { value: paddingRight, isFocused: false, isEdited: false, isError: false },
          }
          setMargin(_ => marginState);
          setPadding(_ => paddingState);

          Js.Promise.resolve();
        })
        |> Js.Promise.catch(error => {
          Js.log("Error while fetching styles: " ++ Js.String.make(error))
          Js.Promise.resolve()
        })
        |> ignore
    }

    React.useEffect0(() => {
      fetchStyles();
      None
    })


    let handleMarginChange = (name, value) => {
      let isValid = validateMetric(value);
      setMargin(prev => {
        switch name {
          | "top" => { ...prev, top: { ...prev.top, value: value, isEdited: true, isError: isValid } }
          | "bottom" => { ...prev, bottom: { ...prev.bottom, value: value, isEdited: true, isError: isValid } }
          | "right" => { ...prev, right: { ...prev.right, value: value, isEdited: true, isError: isValid } }
          | "left" => { ...prev, left: { ...prev.left, value: value, isEdited: true, isError: isValid } }
          | _ => prev
        }
      })
    };

    let handlePaddingChange = (name, value) => {
      let isValid = validateMetric(value);
      setPadding(prev => {
        switch name {
          | "top" => { ...prev, top: { ...prev.top, value: value, isEdited: true, isError: isValid } }
          | "bottom" => { ...prev, bottom: { ...prev.bottom, value: value, isEdited: true, isError: isValid } }
          | "right" => { ...prev, right: { ...prev.right, value: value, isEdited: true, isError: isValid } }
          | "left" => { ...prev, left: { ...prev.left, value: value, isEdited: true, isError: isValid } }
          | _ => prev
        }
      })
    };

  // Handle focus event for margin and padding input fields
  let handleFocus = (name, field) => {
    if (name === "margin") {
      setMargin(prev => {
        switch field {
          | "top" => { ...prev, top: { ...prev.top, isFocused: true } }
          | "bottom" => { ...prev, bottom: { ...prev.bottom, isFocused: true } }
          | "right" => { ...prev, right: { ...prev.right, isFocused: true } }
          | "left" => { ...prev, left: { ...prev.left, isFocused: true } }
          | _ => prev
        }
      })
    } else {
      setPadding(prev => {
        switch field {
          | "top" => { ...prev, top: { ...prev.top, isFocused: true } }
          | "bottom" => { ...prev, bottom: { ...prev.bottom, isFocused: true } }
          | "right" => { ...prev, right: { ...prev.right, isFocused: true } }
          | "left" => { ...prev, left: { ...prev.left, isFocused: true } }
          | _ => prev
        }
      })
    }
  };

  let handleBlur = (name, field) => {
    if (name === "margin") {
      setMargin(prev => {
        switch field {
          | "top" => { ...prev, top: { ...prev.top, isFocused: false } }
          | "bottom" => { ...prev, bottom: { ...prev.bottom, isFocused: false } }
          | "right" => { ...prev, right: { ...prev.right, isFocused: false } }
          | "left" => { ...prev, left: { ...prev.left, isFocused: false } }
          | _ => prev
        }
      })
    } else {
      setPadding(prev => {
        switch field {
          | "top" => { ...prev, top: { ...prev.top, isFocused: false } }
          | "bottom" => { ...prev, bottom: { ...prev.bottom, isFocused: false } }
          | "right" => { ...prev, right: { ...prev.right, isFocused: false } }
          | "left" => { ...prev, left: { ...prev.left, isFocused: false } }
          | _ => prev
        }
      })
    }
  };

  // Reset the isEdited flags for both margin and padding values
  let resetEdits = () => {
    setMargin(prev => ({
      top: { ...prev.top, isEdited: false },
      right: { ...prev.right, isEdited: false },
      bottom: { ...prev.bottom, isEdited: false },
      left: { ...prev.left, isEdited: false }
    }));
    setPadding(prev => ({
      top: { ...prev.top, isEdited: false },
      right: { ...prev.right, isEdited: false },
      bottom: { ...prev.bottom, isEdited: false },
      left: { ...prev.left, isEdited: false }
    }));
  }

  // Save margin and padding styles to the API
  let saveStyles = () => {
    let body = Js.Dict.empty();

    let marginDict = Js.Dict.empty();
    let paddingDict = Js.Dict.empty();

    Js.Dict.set(marginDict, "top", Js.Json.string(margin.top.value));
    Js.Dict.set(marginDict, "bottom", Js.Json.string(margin.bottom.value));
    Js.Dict.set(marginDict, "left", Js.Json.string(margin.left.value));
    Js.Dict.set(marginDict, "right", Js.Json.string(margin.right.value));

    Js.Dict.set(paddingDict, "top", Js.Json.string(padding.top.value));
    Js.Dict.set(paddingDict, "bottom", Js.Json.string(padding.bottom.value));
    Js.Dict.set(paddingDict, "left", Js.Json.string(padding.left.value));
    Js.Dict.set(paddingDict, "right", Js.Json.string(padding.right.value));

    Js.Dict.set(body, "margin", Js.Json.object_(marginDict))
    Js.Dict.set(body, "padding", Js.Json.object_(paddingDict))

    Js.Console.log(body)

   Fetch.postJson(`http://localhost:12346/styles/${"1"}`,Js.Json.object_(body))
    |> Js.Promise.then_(_ => {
        resetEdits();
        Js.Promise.resolve()
    })
    |> Js.Promise.catch(error => {
      Js.log("Error while updating component styles: " ++ Js.String.make(error))
      Js.Promise.resolve()
    })
    |> ignore
  };

  let getClasses = (isFocused: bool, isEdited: bool, isError: bool) => {
    let baseClass = ref("input-field") 
    if isFocused && !isError {
      baseClass.contents = baseClass.contents ++ " focused"
    }

    if isError {
      baseClass.contents = baseClass.contents ++ " error"
    }

    if isEdited && !isError && !isFocused {
      baseClass.contents = baseClass.contents ++ " edited"
    }

    baseClass.contents
  }

  <div>
      <div className="outer-container">
        <input
            key={`margin-top`} 
            className={`input-field ${getClasses(margin.top.isFocused, margin.top.isEdited, margin.top.isError)} margin-top`}
            type_="text"
            name={"top"} 
            value={margin.top.value} 
            onChange={(e) => handleMarginChange("top", ReactEvent.Form.target(e)["value"])} 
            onFocus={(_e) => handleFocus("margin", "top")} 
            onBlur={(_e) => handleBlur("margin", "top")} 
          />
          <input
            key={`margin-bottom`} 
            className={`input-field ${getClasses(margin.bottom.isFocused, margin.bottom.isEdited, margin.bottom.isError)} margin-bottom`}
            type_="text"
            name={"bottom"} 
            value={margin.bottom.value} 
            onChange={(e) => handleMarginChange("bottom", ReactEvent.Form.target(e)["value"])} 
            onFocus={(_e) => handleFocus("margin", "bottom")} 
            onBlur={(_e) => handleBlur("margin", "bottom")} 
          />
          <input
            key={`margin-left`} 
            className={`input-field ${getClasses(margin.left.isFocused, margin.left.isEdited, margin.left.isError)} margin-left`}
            type_="text"
            name={"left"} 
            value={margin.left.value} 
            onChange={(e) => handleMarginChange("left", ReactEvent.Form.target(e)["value"])} 
            onFocus={(_e) => handleFocus("margin", "left")} 
            onBlur={(_e) => handleBlur("margin", "left")} 
          />
          <input
            key={`margin-right`} 
            className={`input-field ${getClasses(margin.right.isFocused, margin.right.isEdited, margin.right.isError)} margin-right`}
            type_="text"
            name={"right"} 
            value={margin.right.value} 
            onChange={(e) => handleMarginChange("right", ReactEvent.Form.target(e)["value"])} 
            onFocus={(_e) => handleFocus("margin", "right")} 
            onBlur={(_e) => handleBlur("margin", "right")} 
          />

        <div className="inner-container">
          <input
              key={`padding-top`} 
              className={`input-field ${getClasses(padding.top.isFocused, padding.top.isEdited, padding.top.isError)} padding-top`}
              type_="text"
              name={"top"} 
              value={padding.top.value} 
              onChange={(e) => handlePaddingChange("top", ReactEvent.Form.target(e)["value"])} 
              onFocus={(_e) => handleFocus("padding", "top")} 
              onBlur={(_e) => handleBlur("padding", "top")} 
            />
            <input
              key={`padding-bottom`} 
              className={`input-field ${getClasses(padding.bottom.isFocused, padding.bottom.isEdited, padding.bottom.isError)} padding-bottom`}
              type_="text"
              name={"bottom"} 
              value={padding.bottom.value} 
              onChange={(e) => handlePaddingChange("bottom", ReactEvent.Form.target(e)["value"])} 
              onFocus={(_e) => handleFocus("padding", "bottom")} 
              onBlur={(_e) => handleBlur("padding", "bottom")} 
            />
            <input
              key={`padding-left`} 
              className={`input-field ${getClasses(padding.left.isFocused, padding.left.isEdited, padding.left.isError)} padding-left`}
              type_="text"
              name={"left"} 
              value={padding.left.value} 
              onChange={(e) => handlePaddingChange("left", ReactEvent.Form.target(e)["value"])} 
              onFocus={(_e) => handleFocus("padding", "left")} 
              onBlur={(_e) => handleBlur("padding", "left")} 
            />
            <input
              key={`padding-right`} 
              className={`input-field ${getClasses(padding.right.isFocused, padding.right.isEdited, padding.right.isError)} padding-right`}
              type_="text"
              name={"right"} 
              value={padding.right.value} 
              onChange={(e) => handlePaddingChange("right", ReactEvent.Form.target(e)["value"])} 
              onFocus={(_e) => handleFocus("padding", "right")} 
              onBlur={(_e) => handleBlur("padding", "right")} 
            />
        </div>
      </div>
      <div className="button-container">
        <button onClick={(_e) => saveStyles()} disabled={
            margin.top.isError 
              || margin.bottom.isError 
              || margin.left.isError 
              || margin.right.isError 
              || padding.top.isError
              || padding.bottom.isError
              || padding.left.isError
              || padding.right.isError
          } className="save-button">{React.string("Save Styles")}</button>
      </div>
    </div>

  }
}