include "eliom_svg_event_handler_base.mli"
  subst type event := (Dom_html.event Js.t -> unit) Eliom_lib.client_value
   and type mouseEvent := (Dom_html.mouseEvent Js.t -> unit) Eliom_lib.client_value
   and type keyboardEvent := (Dom_html.keyboardEvent Js.t -> unit) Eliom_lib.client_value
