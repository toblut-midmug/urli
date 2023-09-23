/-  *urly
/+  default-agent, dbug, server
|%
+$  versioned-state
  $%  state-0
  ==
+$  card  card:agent:gall
++  make-landing
  |=  eyre-id=@ta 
    ^-  (list card:agent:gall)
    =/  sail-data=manx
      ;html
        ;head
          ;meta(charset "utf-8", content "width=device-width, initial-scale=1");
         ==
        ;body
          ;h1: Hi ... 
          ;br;
          ;br;
        ==
      ==
    =/  data=octs
      (as-octs:mimes:html (crip (en-xml:html sail-data)))
    =/  content-length=@t
      (crip ((d-co:co 1) p.data))
    =/  =response-header:http
      :-  200
      :~  ['Content-Length' content-length]
          ['Content-Type' 'text/html']
      ==
    (give-http eyre-id response-header `data)
++  redirect
  |=  [eyre-id=@ta =url]
    ^-  (list card:agent:gall)
    =/  =response-header:http
      :-  301
      :~  ['Location' url]
      ==
    (give-http eyre-id response-header `(as-octs:mimes:html ~))
::
++  make-405
  |=  eyre-id=@ta 
  ^-  (list card:agent:gall)
  =/  data=octs
    (as-octs:mimes:html '<h1>405 Method Not Allowed</h1>')
  =/  content-length=@t
    (crip ((d-co:co 1) p.data))
  =/  =response-header:http
    :-  405
    :~  ['Content-Length' content-length]
        ['Content-Type' 'text/html']
        ['Allow' 'GET']
    ==
  (give-http eyre-id response-header `data)
::
++  give-http
  |=  [eyre-id=@ta =response-header:http data=(unit octs)]
  ^-  (list card)
  :~
    [%give %fact [/http-response/[eyre-id]]~ %http-response-header !>(response-header)]
    [%give %fact [/http-response/[eyre-id]]~ %http-response-data !>(data)]
    [%give %kick [/http-response/[eyre-id]]~ ~]
  ==
::
--
%-  agent:dbug
=|  state-0
=*  state  -
^-  agent:gall
|_  =bowl:gall
+*  this  .
    def  ~(. (default-agent this %.n) bowl)
::
++  on-init
  ^-  (quip card _this)
  %-  (slog leaf+"Attempting to bind /apps/urly" ~)
  :_  this
  [%pass /eyre/connect %arvo %e %connect [~ /[dap.bowl]] dap.bowl]~
::
++  on-save
  ^-  vase
  !>(state)
::
++  on-load 
  |=  old-state=vase
  ^-  (quip card _this)
  =/  old  !<(versioned-state old-state)
  ?-  -.old
    %0  `this(state old)
  ==
::
++  on-poke
  |=  [=mark =vase]
  |^ 
  ^-  (quip card _this)
  =^  cards  state
    ?+  mark  (on-poke:def mark vase)
      %action  (handle-action !<(action vase))
      %handle-http-request  (handle-http !<([@ta inbound-request:eyre] vase))
    ==
  [cards this]
  ++  handle-action
    |=  =action
    ^-  (quip card _state)
    :: only the host ship can manage URLs for now
    ::
    ?>  .=(our.bowl src.bowl)
    =/  mapping-new
    ?-    -.action
        %shorten 
      =/  =url-alias  (crip (c-co:co (shaw 0 29 now.bowl)))
      (~(put by mapping.state) url-alias url.action)
        %shorten-custom
      ?:  (~(has by mapping.state) url-alias.action)  !!
      (~(put by mapping.state) url-alias.action url.action)
        %delete 
      (~(del by mapping.state) url-alias.action)
    ==
    `state(mapping mapping-new)
  ++  handle-http
    |=  [id=@ta req=inbound-request:eyre]
    ^-  (quip card _state)
    ?+    method.request.req
        :_  state
        (make-405 id)
        %'GET'
       =/  =url-alias  (crip q:(trim (lent "/urly/") (trip url.request.req))) 
       ?.    (~(has by mapping.state) url-alias)
          :_  state
          (make-landing id)
        :_  state
        (redirect id (~(got by mapping.state) url-alias))
    ==
  --
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?+    path
    (on-watch:def path)
  ::
      [%http-response *]
    `this
  ==
++  on-leave  on-leave:def
::
++  on-peek
  |=  =path  
  ^-  (unit (unit cage))
  ?+    path  (on-peek:def path)
    :: reslove URL
    ::
      [%x @ ~]  
    =/  =url-alias  i.t.path
    =/  =url  (~(got by mapping.state) url-alias)
    ``noun+!>(url)
    :: check short URL availability
    ::
      [%x %free @ ~]  
    =/  =url-alias  i.t.t.path
    ``noun+!>(?!((~(has by mapping.state) url-alias)))
  ==
++  on-agent  on-agent:def
::
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card _this)
  ?+  sign-arvo  (on-arvo:def wire sign-arvo)
      [%eyre %bound *]
    ~?  !accepted.sign-arvo
      [dap.bowl 'eyre bind rejected!' binding.sign-arvo]
    [~ this]
  ==
::
++  on-fail  on-fail:def
--

