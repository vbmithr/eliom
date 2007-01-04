(* Ocsigen
 * http://www.ocsigen.org
 * Module pagesearch.mli
 * Copyright (C) 2005 Vincent Balat
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, with linking exception; 
 * either version 2.1 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 *)
(*****************************************************************************)
(*****************************************************************************)
(* Tables of services (global and session tables)                            *)
(* Store and load dynamic pages                                              *)
(*****************************************************************************)
(*****************************************************************************)

open Lwt
open Ocsimisc

exception Ocsigen_Wrong_parameter
exception Ocsigen_404
exception Ocsigen_duplicate_registering of string
exception Ocsigen_register_for_session_outside_session
exception Ocsigen_page_erasing of string
exception Ocsigen_Is_a_directory
exception Ocsigen_malformed_url
exception Ocsigen_service_or_action_created_outside_site_loading
exception Ocsigen_there_are_unregistered_services of string
exception Ocsigen_error_while_loading_site of string
exception Ocsigen_Typing_Error of (string * exn) list
exception Ocsigen_Internal_Error of string
exception Bad_config_tag_for_extension of string
exception Error_in_config_file

(*****************************************************************************)
(** type of URL, without parameter *)
type url_path = string list
type current_url = string list
type current_dir = string list

type file_info = {tmp_filename: string;
                  filesize: int64;
                  original_filename: string}

type request_info = 
    {ri_path_string: string; (** path of the URL *)
     ri_path: string list;   (** path of the URL *)
     ri_params: string;      (** string containing parameters *)
     ri_host: string option; (** Host field of the request (if any) *)
     ri_get_params: (string * string) list;  (** Association list of get parameters*)
     ri_post_params: (string * string) list; (** Association list of post parameters*)
     ri_files: (string * file_info) list; (** Files sent in the request *)
     ri_inet_addr: Unix.inet_addr;        (** IP of the client *)
     ri_ip: string;            (** IP of the client *)
     ri_port: int;             (** Port of the request *)
     ri_user_agent: string;    (** User_agent of the browser *)
     ri_cookies: (string * string) list; (** Cookie sent by the browser *)
     ri_ifmodifiedsince: float option;   (** if-modified-since field *)
     ri_http_frame: Predefined_senders.Stream_http_frame.http_frame} (** The full http_frame *)

type result =
    {res_cookies: (string * string) list;
     res_path: string;
     res_lastmodified: float option;
     res_etag: Http_frame.etag option;
     res_code: int option; (* HTTP code, if not 200 *)
     res_send_page: Predefined_senders.send_page_type;
     res_sender: Predefined_senders.create_sender_type
   }


(** Registration of new extensions *)
type answer =
    Ext_found of result (** OK stop! I found the page *)
  | Ext_not_found (** Page not found. Try next extension. *)
  | Ext_continue_with of request_info (** Used to modify the request 
                                         before giving it to next extension *)

 val register_extension :
     (virtual_hosts -> 
       (request_info -> answer Lwt.t) * 
	 (string list -> Simplexmlparser.ExprOrPatt.texprpatt -> unit)) *
     (unit -> unit) * 
     (unit -> unit) -> unit

val create_virthost : 
    Ocsimisc.virtual_hosts ->
      (request_info -> answer Lwt.t) * 
	(string list -> Simplexmlparser.ExprOrPatt.texprpatt -> unit)

val set_virthosts : (Ocsimisc.virtual_hosts * 
                       (request_info -> answer Lwt.t)) list -> unit

val get_virthosts : unit -> (Ocsimisc.virtual_hosts * 
                               (request_info -> answer Lwt.t)) list

val add_virthost : (Ocsimisc.virtual_hosts * 
                      (request_info -> answer Lwt.t)) -> unit

val do_for_host_matching : 
    string option ->
      int ->
        ((Ocsimisc.virtual_host_part list * int option) list *
           ('a -> answer Lwt.t))
          list -> 'a -> result Lwt.t

(** Profiling *)
val get_number_of_connected : unit -> int
val get_number_of_connected : unit -> int


(** Server internal functions: *)
(** loads a module in the server *)
val incr_connected : unit -> unit
val decr_connected : unit -> unit

val during_initialisation : unit -> bool
val start_initialisation : unit -> unit
val end_initialisation : unit -> unit
