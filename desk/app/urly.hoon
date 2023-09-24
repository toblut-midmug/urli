/-  *urly
/+  default-agent, dbug, server
/=  index  /app/urly/index
|%
+$  versioned-state
  $%  state-0
  ==
+$  card  card:agent:gall
++  login-redirect
  |=  eyre-id=@ta
  ^-  (list card)
  (give-http eyre-id [307 ['Location' '/~/login?redirect='] ~] ~)
++  redirect
  |=  [eyre-id=@ta =url]
  ^-  (list card)
  =/  =response-header:http  [302 ~[['Location' url]]]
  (give-http eyre-id response-header `(as-octs:mimes:html ~))
::
++  make-200
  |=  [eyre-id=@ta data=octs]
  ^-  (list card)
  =/  content-length=@t
    (crip ((d-co:co 1) p.data))
  =/  =response-header:http
    :-  200
    :~  ['Content-Length' content-length]
        ['Content-Type' 'text/html']
    ==
  (give-http eyre-id response-header `data)
++  make-405
  |=  eyre-id=@ta 
  ^-  (list card)
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
      :: hash the long url to create a short one:
      :: A 29 bit hash in base 58 ... is at most five characters long
      ::
      =/  =url-alias  (crip (c-co:co (shaw 0 29 now.bowl)))
      (~(put by url-map.state) url-alias url.action)
        %shorten-custom
      ?:  (~(has by url-map.state) url-alias.action)  !!
      (~(put by url-map.state) url-alias.action url.action)
        %delete 
      (~(del by url-map.state) url-alias.action)
    ==
    `state(url-map mapping-new)
  ++  handle-http
    |=  [eyre-id=@ta req=inbound-request:eyre]
    ^-  (quip card _state)
    ?+    method.request.req  [(make-405 eyre-id) state]
        %'GET'
      :: decode path c.f. https://github.com/urbit/docs-examples/blob/main/groups-app/bare-desk/app/squad.hoon#L69-L72
      ::
      =/  =path
        %-  tail
        %-  tail
        %+  rash  url.request.req
        ;~(sfix apat:de-purl:html yquy:de-purl:html)
      ~&  path
      :: check auth and index page
      ::
      ?~  path
        ?.  authenticated.req
          [(login-redirect eyre-id) state]
        :_  state
        (make-200 eyre-id (index bowl url-map.state))
      :: redirect either to resolved external url or back to index
      ::
      ?:  .=((lent path) 1) 
        =/  =url-alias  (head path) 
        ?.    (~(has by url-map.state) url-alias)
           :_  state
           (redirect eyre-id '/urly')
        :_  state
        (redirect eyre-id (~(got by url-map.state) url-alias))
      :_  state
      (redirect eyre-id '/urly')
        %'POST'
      =/  body=(unit octs)  body.request.req
      =/  headers=header-list:http  header-list.request.req
      =/  args  (molt (fall ?~(body ~ (rush q.u.body yquy:de-purl:html)) ~))
      =/  url-smol=(unit url-alias)  
            (~(get by args) 'delete') 
      ~&  url-smol
      ?~  url-smol
        [(redirect eyre-id '/urly') state]
      =^  cards  state
        (handle-action [%delete `url`(need url-smol)])
      [(weld cards (redirect eyre-id '/urly')) state]
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
    =/  =url  (~(got by url-map.state) url-alias)
    ``noun+!>(url)
    :: check short URL availability
    ::
      [%x %free @ ~]  
    =/  =url-alias  i.t.t.path
    ``noun+!>(?!((~(has by url-map.state) url-alias)))
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

