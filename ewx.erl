%#!/usr/bin/env escript
%# -*- coding: utf-8 -*-

% "c:\program files\erl7.1\bin\erlc" ewx.erl

-module(ewx).
-export([main/1]).
-export([new/0, destroy/0, create_window/5, loop/1, cons/1]).
-include_lib("wx/include/wx.hrl").
-record(state, {res, ewx, win}).

%-define(ABOUT, ?wxID_ABOUT).
-define(BTN_ABOUT, 123).

new() ->
  Ewx = wx:new(),
  {ok, #state{res=ok, ewx=Ewx, win=nil}}.

destroy() ->
  wx:destroy().

create_window(State, _, Id, Title, Opts) ->
  io:format("~p~n", [Opts]),
  Frm = wxFrame:new(State#state.ewx, Id, Title, Opts),
  SF = wxSizerFlags:new(),
  wxSizerFlags:proportion(SF, 1),
  Pnl01 = wxPanel:new(Frm),
  SzClient = wxBoxSizer:new(?wxHORIZONTAL),
  wxSizer:addSpacer(SzClient, 2),
  Abutton = wxButton:new(Pnl01, ?BTN_ABOUT, [{label, "About"}]),
  wxButton:connect(Abutton, command_button_clicked),
  wxSizer:add(SzClient, Abutton, wxSizerFlags:left(SF)),
  wxSizer:addSpacer(SzClient, 5),
  wxWindow:setSizer(Pnl01, SzClient),
  %wxSizer:fit(SzClient, Frm),
  %wxSizer:setSizeHints(SzClient, Frm),
  {ok, #state{res=ok, ewx=State#state.ewx, win=Frm}}.

% -record(wx, {id, obj, userData, event}).
% %            id :: integer()
% %            obj :: wx:wx_object()
% %            userData :: term()
% %            event :: event()
% -type wx() :: #wx{}.
%
% -record(wxClose, {type}).
% %                 type :: wxCloseEventType()
% %                      %% Callback event: {@link wxCloseEvent}
% -type wxCloseEventType() :: close_window | ... | query_end_session.
% -type wxClose() :: #wxClose{}. %% Callback event: {@link wxCloseEvent}
%
% -record(wxCommand, {type, cmdString, commandInt, extraLong}).
% %                   type :: wxCommandEventType()
% %                        %% Callback event: {@link wxCommandEvent}
% %                   cmdString :: unicode:chardata()
% %                   commandInt :: integer()
% %                   extraLong :: integer()
% -type wxCommandEventType() :: command_button_clicked | ...
%         command_menu_selected | ... | command_enter.
% -type wxCommand() :: #wxCommand{}.
%                   %% Callback event: {@link wxCommandEvent}
%
% -type event() :: wxActivate() | wxAuiManager() | wxAuiNotebook() | ...
%         wxClose() | ... | wxCommand() | wxContextMenu() | ...
%         wxIconize() | wxIdle() | ... | wxMaximize() | wxMenu() | ...
%         wxWindowCreate() | wxWindowDestroy().
% -type wxEventType() :: wxActivateEventType() | ...
%         wxCloseEventType() | ...
%         wxCommandEventType() | wxContextMenuEventType() | ...
%         wxIdleEventType() | ... | wxMenuEventType() | ...
%         wxWindowCreateEventType() | wxWindowDestroyEventType().

loop(Win) ->
  receive
  #wx{event=#wxClose{type=Evt}} when Evt==close_window ->
    %ewx Got event {wx,-31994,{wx_ref,35,wxFrame,[]},[],{wxClose,close_window}}
    io:format("~p Closing window ~p~n", [self(), Evt]),
    ok = wxFrame:setStatusText(Win, "Closing...", []),
    wxWindow:destroy(Win),
    ok;
  #wx{id=?wxID_EXIT, event=#wxCommand{type=Evt}}
    when Evt==command_menu_selected ->
    %ewx Got event {wx,5006,{wx_ref,35,wxFrame,[]},[],
    %               {wxCommand,command_menu_selected,[],-1,0}}
    io:format("~p exit ~p~n", [self(), Evt]),
    wxWindow:destroy(Win),
    ok;
  #wx{id=?wxID_ABOUT, event=#wxCommand{type=Evt}}
    when Evt==command_menu_selected ->
    %ewx Got event {wx,5014,{wx_ref,35,wxFrame,[]},[],
    %               {wxCommand,command_menu_selected,[],-1,0}}
    io:format("~p about ~p~n", [self(), Evt]),
    dialog(?wxID_ABOUT, Win),
    loop(Win);
  #wx{id=?BTN_ABOUT, event=#wxCommand{type=Evt}}
    when Evt==command_button_clicked ->
    %ewx Got event {wx,123,{wx_ref,40,wxButton,[]},[],
    %               {wxCommand,command_button_clicked,[],0,0}}
    io:format("~p Button about ~p~n", [self(), Evt]),
    dialog(?wxID_ABOUT, Win),
    loop(Win);
  Msg ->
    io:format("~p Got event ~p~n", [?MODULE, Msg]),
    loop(Win)
  after 1000 ->
    io:fwrite("."),
    loop(Win)
  end.

dialog(?wxID_ABOUT, Win) ->
  Str = string:join(["Welcome to wxErlang.",
    "日本語",
    "漢字表示申能",
    "This is the minimal wxErlang sample\n",
    "running under ",
    wx_misc:getOsDescription(),
    "."], "\n"),
  MD = wxMessageDialog:new(Win, Str, [
    {style, ?wxOK bor ?wxICON_INFORMATION},
    {caption, "About wxErlang minimal sample"}]),
  wxDialog:showModal(MD),
  wxDialog:destroy(MD).

cons(N) ->
  case N of
  wxID_HELP_CONTENTS -> ?wxID_HELP_CONTENTS;
  wxID_ABOUT -> ?wxID_ABOUT;
  wxID_EXIT -> ?wxID_EXIT;
  wxBITMAP_TYPE_XPM -> ?wxBITMAP_TYPE_XPM;
  wxICON_INFORMATION -> ?wxICON_INFORMATION;
  wxOK -> ?wxOK
  end.

main(_) ->
  {ok, ES} = new(),
  {ok, FS} = create_window(ES, wx:null(), -1, "main/1", [{size, {640, 480}}]),
  Win = FS#state.win,
  wxFrame:connect(Win, close_window),
  Ficon = filename:join(filename:dirname(code:which(?MODULE)), "sample.xpm"),
  wxFrame:setIcon(Win, wxIcon:new(Ficon, [{type, ?wxBITMAP_TYPE_XPM}])),
  wxFrame:createStatusBar(Win, []),
  ok = wxFrame:setStatusText(Win, "Hello 日本語 work!", []),
  wxWindow:show(Win),
  loop(Win),
  destroy().
