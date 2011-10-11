-module(mod_sspresence).

-behavior(gen_mod).

-include("ejabberd.hrl").

-export([start/2, stop/1, on_register_connection/3, on_remove_connection/3, on_presence/4, on_unset_presence/4, isConnected/1, on_packet_send/3]).

start(Host, _Opts) ->
    ?INFO_MSG("mod_sspresence starting", []),
    ejabberd_hooks:add(sm_register_connection_hook, 	Host, ?MODULE, on_register_connection, 50),
    ejabberd_hooks:add(sm_remove_connection_hook, 	Host, ?MODULE, on_remove_connection, 50),
    ejabberd_hooks:add(set_presence_hook, 		Host, ?MODULE, on_presence, 50),
    ejabberd_hooks:add(unset_presence_hook, 		Host, ?MODULE, on_unset_presence, 50),
    ejabberd_hooks:add(user_send_packet, 		Host, ?MODULE, on_packet_send, 50),
    %Uncomment to reset connected users directly when module sspresence starts.
    %reset_connections(),
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
		      Login_path = string:concat(getOptionValue("scripts_path="), "/set_presence_script "),
		      ?INFO_MSG("mod_sspresence: set_presence_script call with  user (~p) and status (~p)", [User,Status]),
    		      os:cmd(string:join([Login_path, User , Status], " "));
	_ -> ok
    end,
    ok.

on_unset_presence(User, _Server, _Resource, _Status) ->
    ?INFO_MSG("mod_sspresence: on_unset_presence (~p)", [User]),
    ok.

on_packet_send(From, _To, {xmlelement, Type, _Attr, Subel} = _Packet) ->
    case Type of
	"message" -> 
		{_SenderJID,Sender,_SenderDomain,_A,_B,_C,_D} = From,
		
		SSlogin = getOptionValue("ss_login="),

		case Sender of
			SSlogin ->
                                Message = getMessageFromSubel(Subel),
				execute(Message);
                   	_ -> ok
                end;
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


getMessageFromSubel(Subel) ->
    [{_I,_J,_K,[{_L,MessageData}]}] = Subel,
    parseXmlCdata(MessageData).


parseXmlCdata(Msg) ->
	MessageString = binary_to_list(list_to_binary(io_lib:format("~p", [Msg]))),
	lists:sublist(MessageString, 4, string:len(MessageString)-6).


execute(Message) ->
    %?INFO_MSG("Message vale: ~p", [Message]),
    [Order|Params] = string:tokens(Message, "&"),

    case Order of
	"AddItemToRoster" -> 
	  	case length(Params) of
			4 -> 	[UserSID,BuddySID,BuddyName,Subscription_type] = Params,
				?INFO_MSG("Execute: ~p with params ~p", [Order,Params]),

				%Command Name: add_rosteritem
				% Needs mod_admin_extra (http://www.ejabberd.im/ejabberd-modules)
				% ejabberdctl add_rosteritem localuser localserver user server nick group subs
				%subs= none, from, to or both",

				%frank-williamson@trapo adds demo@trapo to its roster 
				%ejabberdctl add_rosteritem frank-williamson trapo demo trapo NickName SocialStream from

				%frank-williamson@trapo adds demo@trapo and demo@trapo adds frank-williamson@trapo to its roster
				%ejabberdctl add_rosteritem frank-williamson trapo demo trapo NickName SocialStream both
				
				[ContactName|_R] = string:tokens(BuddyName, " "),
				[UserSlug,UserDomain] = string:tokens(UserSID, "@"),
				[BuddySlug,BuddyDomain] = string:tokens(BuddySID, "@"),

				Command = lists:concat(["ejabberdctl add_rosteritem ", UserSlug , " ", UserDomain, " ", BuddySlug, " ", BuddyDomain , " ", ContactName , " ", 					"SocialStream" , " ", Subscription_type]),
				os:cmd(Command),
				?INFO_MSG("Execute command: ~p", [Command]),
				ok;
			_ -> 	?INFO_MSG("Incorrect parameters", []),
				ok
	  	end,
		ok;

	"Synchronize" ->
	synchronize(),
	ok;

	_ -> ?INFO_MSG("Command not found", []),
		ok
    end.


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


%%Send all connected users to Social Stream Rails Application
synchronize() ->
	Synchronize_path = string:concat(getOptionValue("scripts_path="), "/synchronize_presence_script "),
	os:cmd(Synchronize_path),
ok.


%Reset all connections
%reset_connections() ->
%	Reset_path = string:concat(getOptionValue("scripts_path="), "/reset_connection_script "),
%	os:cmd(Reset_path),
%ok.



