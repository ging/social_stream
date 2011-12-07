%%%-------------------------------------------------------------------
%%% File    : mod_sspresence.erl
%%% Author  : Aldo
%%% Contact:  < social-stream@dit.upm.es >
%%% Purpose : Process events and hooks for Social Stream Presence: http://social-stream.dit.upm.es/
%%% Created : 1 Oct 2011
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
    {_A,User,_B,_C,_D,_E,_F} = _JID,
    ?INFO_MSG("mod_sspresence: on_register_connection (~p)", [User]),
    Login_path = string:concat(getOptionValue("scripts_path="), "/set_connection_script "),
    os:cmd(string:join([Login_path, User ], " ")),
    ok.

on_remove_connection(_SID, _JID, _SessionInfo) ->
    {_A,User,_B,_C,_D,_E,_F} = _JID,
    ?INFO_MSG("mod_sspresence: on_remove_connection (~p)", [User]),
    Connected = isConnected(User),
    case Connected of
	true -> ok;
	_ -> Logout_path = string:concat(getOptionValue("scripts_path="), "/unset_connection_script "),
             os:cmd(string:join([Logout_path, User ], " "))
    end,
    ok.

on_presence(User, _Server, _Resource, Packet) ->
     ?INFO_MSG("mod_sspresence: on_presence (~p)", [User]),
     {_xmlelement, Type, _Attr, Subel} = Packet,

    case Type of
	"presence" -> Status = getStatusFromSubel(Subel),
		      Presence_path = string:concat(getOptionValue("scripts_path="), "/set_presence_script "),
		      ?INFO_MSG("mod_sspresence: set_presence_script call with  user (~p) and status (~p)", [User,Status]),
    		      os:cmd(string:join([Presence_path, User , Status], " "));
	_ -> ok
    end,
    ok.

on_unset_presence(User, _Server, _Resource, _Status) ->
    ?INFO_MSG("mod_sspresence: on_unset_presence (~p)", [User]),
    _UPresence_path = string:concat(getOptionValue("scripts_path="), "/unset_presence_script "),
    %% Wait for on_remove_connection
    %% ?INFO_MSG("mod_sspresence: unset_presence_script call with  user (~p)", [User]),
    %%os:cmd(string:join([UPresence_path, User , Status], " "));
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
isConnected(User) ->

Command = string:concat("ejabberdctl connected-users | grep ", User),
Output = os:cmd(Command),

case Output of
  [] -> false;
  _ -> Sessions = string:tokens(Output, "\n"),

      catch lists:foreach(
		fun(S) ->
		        [Slug|_R] = string:tokens(S, "@"),
		        %User.slug connected = Slug
			
			case Slug of
			  User -> throw(true);
			  _ -> false
			end                

		end,
		Sessions)
end.



%Reset all connections
reset_connections() ->
	Reset_path = string:concat(getOptionValue("scripts_path="), "/reset_connection_script "),
	os:cmd(Reset_path),
ok.



