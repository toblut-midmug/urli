/-  *urly
/+  default-agent, dbug, server
/=  index  /app/frontend/index
|%
+$  versioned-state
  $%  state-0
  ==
+$  card  card:agent:gall
++  generate-short-url
  |=  entropy=@
  ^-  short-url
  :: A 29 bit hash in base 58 ... is at most five characters long
  ::
  (crip (c-co:co (shaw 0 29 entropy)))
::
++  ensure-url-scheme
  :: Makes sure a URL has a scheme - adds "https://" if it doesn't.
  :: TODO: replace with proper URL parsing
  ::
  |=  long-url=url
  ^-  url
  =/  scheme-idx  (find "://" (trip long-url))
  ?~  scheme-idx
    `url`(crip (weld "https://" (trip long-url)))
  long-url
::
++  login-redirect
  |=  eyre-id=@ta
  ^-  (list card)
  (give-http eyre-id [307 ['Location' '/~/login?redirect='] ~] ~)
::
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
::
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
      =/  =short-url  (generate-short-url eny.bowl)
      (~(put by url-map.state) short-url (ensure-url-scheme url.action))
        %shorten-custom
      ?:  (~(has by url-map.state) short-url.action)  !!
      (~(put by url-map.state) short-url.action (ensure-url-scheme url.action))
        %delete 
      (~(del by url-map.state) short-url.action)
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
      :: check auth and index page
      ::
      ?~  path
        ?.  authenticated.req
          [(login-redirect eyre-id) state]
        :_  state
        (make-200 eyre-id (index bowl url-map.state))
      :: redirect either to the resolved external url or back to index
      ::
      ?:  .=((lent path) 1) 
        =/  =short-url  (head path) 
        ?.    (~(has by url-map.state) short-url)
           :_  state
           (redirect eyre-id '/urly')
        :_  state
        (redirect eyre-id (~(got by url-map.state) short-url))
      :_  state
      (redirect eyre-id '/urly')
        %'POST'
      =/  body=(unit octs)  body.request.req
      =/  headers=header-list:http  header-list.request.req
      =/  args  (molt (fall ?~(body ~ (rush q.u.body yquy:de-purl:html)) ~))
      :: TODO: beautify argument handling
      ::
      ?.  .=(1 ~(wyt by args))
        [(make-405 eyre-id) state]
      =/  arg  (snag 0 ~(tap by args))
      =^  cards  state
      ?:  .=(p.arg 'delete')
        =/  url-smol  (~(got by args) 'delete') 
          (handle-action [%delete `url`url-smol])
      ?:  .=(p.arg 'shorten')
        =/  url-long  (~(got by args) 'shorten') 
          (handle-action [%shorten `url`url-long])
      [(make-405 eyre-id) state]
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
    :: reslove short URL
    ::
      [%x @ ~]  
    =/  =short-url  i.t.path
    =/  =url  (~(got by url-map.state) short-url)
    ``noun+!>(url)
    :: check short URL availability
    ::
      [%x %free @ ~]  
    =/  =short-url  i.t.t.path
    ``noun+!>(?!((~(has by url-map.state) short-url)))
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

