%%%-------------------------------------------------------------------
%%% File    : mod_sspresence.erl
%%% Author  : Aldo Gordillo
%%% Contact : < social-stream@dit.upm.es >
%%% Purpose : Process events and hooks for Social Stream Presence: http://social-stream.dit.upm.es/
%%% Created : 1 Oct 2011
%%% Version : 2.0
%%%  
%%%
%%% http://social-stream.dit.upm.es/
%%% Copyright © 2011 Social Stream
%%%
%%%-------------------------------------------------------------------

-module(mod_sspresence).
-author('aldo').

-behavior(gen_mod).

-include("ejabberd.hrl").

-export([start/2, stop/1, 
	on_register_connection/3, 
	on_remove_connection/3, 
	on_presence/4, 
	on_unset_presence/4,
	on_packet_send/3, 
	isConnected/1
	]).

start(Host, _Opts) ->
    ?INFO_MSG("mod_sspresence starting", []),
    ejabberd_hooks:add(sm_register_connection_hook, 	Host, ?MODULE, on_register_connection, 50),
    ejabberd_hooks:add(sm_remove_connection_hook, 	Host, ?MODULE, on_remove_connection, 50),
    ejabberd_hooks:add(set_presence_hook, 		Host, ?MODULE, on_presence, 50),
    ejabberd_hooks:add(unset_presence_hook, 		Host, ?MODULE, on_unset_presence, 50),
    ejabberd_hooks:add(user_send_packet, 		Host, ?MODULE, on_packet_send, 50),
    %Reset connected users when module sspresence starts.
    reset_connections(),
    ok.

stop(Host) ->
    ?INFO_MSG("mod_sspresence stopping", []),
    ejabberd_hooks:delete(sm_register_connection_hook, 	Host, ?MODULE, on_register_connection, 50),
    ejabberd_hooks:delete(sm_remove_connection_hook, 	Host, ?MODULE, on_remove_connection, 50),
    ejabberd_hooks:delete(set_presence_hook, 		Host, ?MODULE, on_presence, 50),
    ejabberd_hooks:delete(unset_presence_hook, 		Host, ?MODULE, on_unset_presence, 50),
    ejabberd_hooks:delete(user_send_packet, 		Host, ?MODULE, on_packet_send, 50),
    ok.



on_register_connection(_SID, _JID, _Info) ->
    {_A,User,Domain,_C,_D,_E,_F} = _JID,
    UserJid = string:join([User, Domain ], "@"),
    ?INFO_MSG("mod_sspresence: on_register_connection (~p)", [UserJid]),
    Rest_api_script_path = string:concat(getOptionValue("scripts_path="), "/rest_api_client_script "),
    os:cmd(string:join([Rest_api_script_path, "setConnection", UserJid ], " ")),
    ok.

on_remove_connection(_SID, _JID, _SessionInfo) ->
    {_A,User,Domain,_C,_D,_E,_F} = _JID,
    UserJid = string:join([User, Domain ], "@"),
    ?INFO_MSG("mod_sspresence: on_remove_connection (~p)", [UserJid]),
    Connected = isConnected(UserJid),
    case Connected of
	true -> ok;
	_ -> Rest_api_script_path = string:concat(getOptionValue("scripts_path="), "/rest_api_client_script "),
             os:cmd(string:join([Rest_api_script_path, "unsetConnection", UserJid ], " "))
    end,
    ok.

on_presence(User, Server, _Resource, Packet) ->
     UserJid = string:join([User, Server ], "@"),
     ?INFO_MSG("mod_sspresence: on_presence (~p)", [UserJid]),
     {_xmlelement, Type, _Attr, Subel} = Packet,

    case Type of
	"presence" -> Status = getStatusFromSubel(Subel),
		      Rest_api_script_path = string:concat(getOptionValue("scripts_path="), "/rest_api_client_script "),
		      ?INFO_MSG("mod_sspresence: set_presence_script call with  userJid (~p) and status (~p)", [UserJid,Status]),
    		      os:cmd(string:join([Rest_api_script_path, "setPresence", UserJid , Status], " "));
	_ -> ok
    end,
    ok.

on_unset_presence(User, Server, _Resource, _Status) ->
    UserJid = string:join([User, Server ], "@"),
    ?INFO_MSG("mod_sspresence: on_unset_presence (~p)", [UserJid]),
    _Rest_api_script_path = string:concat(getOptionValue("scripts_path="), "/rest_api_client_script "),
    %% Wait for on_remove_connection
    %% ?INFO_MSG("mod_sspresence: unset_presence_script call with  userJid (~p)", [UserJid]),
    %%os:cmd(string:join([_Rest_api_script_path, "unsetPresence", UserJid], " ")),
    ok.

on_packet_send(_From, _To, {xmlelement, Type, _Attr, _Subel} = _Packet) ->
    case Type of
	"message" ->
               ok;
	_ -> ok
    end.


getStatusFromSubel(Subel) ->	
	try
            %Strophe tuples
	    [{_A,"status",[],[{_B,_StatusStrophe}]},{_C,"show",[],[{_D,ShowStrophe}]}|_R1] = Subel,
	    parseXmlCdata(ShowStrophe)
	catch
		_:Reason ->      
			try
				%Pidgin tuples
				[{_E,"show",[],[{_F,ShowPidgin}]}|_R2] = Subel,
			     	parseXmlCdata(ShowPidgin)
			catch
				_:Reason -> "chat" %Status when parsed failed
			after
				noop
			end
	after
		noop
	end. 


parseXmlCdata(Msg) ->
	MessageString = binary_to_list(list_to_binary(io_lib:format("~p", [Msg]))),
	lists:sublist(MessageString, 4, string:len(MessageString)-6).



%%GETTERS CONFIG VALUES
%%CONFIG FILE: /etc/ejabberd/ssconfig.cfg

getOptionValue(Option) ->
{_, In} = file:open("/etc/ejabberd/ssconfig.cfg", read),
parser(In,Option).


parser(In,Option) ->
  L = io:get_line(In, ''),

  case L of
  	eof -> "Undefined";
  	_ -> {_,S,_} = regexp:gsub(L, "\\n", ""),


	%%IGNORE COMMENTS
	case string:str(S, "#") of
        	0 -> 
			case string:str(S, Option) of
				0 -> ok,
				%% Continue with next line
				parser(In,Option);
		
				%% return path
				_ ->  lists:sublist(S, string:len(Option)+1, string:len(S))	
			end;

        	_ ->  %% Comment: Continue with next line
		     parser(In,Option)
	end
  end. 


%%Check if a user is connected (any active session with Ejabberd server)
isConnected(UserJid) ->

Command = string:concat("ejabberdctl connected-users | grep ", UserJid),
Output = os:cmd(Command),

case Output of
  [] -> false;
  _ -> Sessions = string:tokens(Output, "\n"),

      catch lists:foreach(
		fun(S) ->
		        [Jid|_R] = string:tokens(S, "/"),
			
			case Jid of
			  UserJid -> throw(true);
			  _ -> false
			end                

		end,
		Sessions)
end.



%Reset all connections
reset_connections() ->
	Rest_api_script_path = string:concat(getOptionValue("scripts_path="), "/rest_api_client_script "),
	os:cmd(string:join([Rest_api_script_path, "resetConnection"], " ")),
ok.



