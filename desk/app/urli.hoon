/-  *urli
/+  default-agent, dbug, server
/=  index  /app/frontend/index
|%
+$  versioned-state
  $%  state-0
  ==
+$  card  card:agent:gall
++  generate-short-id
  |=  entropy=@
  ^-  short-id
  :: Three base 58 digitis give 195.112 possible combinations
  ::
  (crip (c-co:co (~(rad og entropy) 195.112)))
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
++  make-404
  |=  eyre-id=@ta 
  ^-  (list card)
  =/  data=octs
    (as-octs:mimes:html '<h1>404 Not Found</h1>')
  =/  content-length=@t
    (crip ((d-co:co 1) p.data))
  =/  =response-header:http
    :-  404
    :~  ['Content-Length' content-length]
        ['Content-Type' 'text/html']
        ['Allow' 'GET']
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
  %-  (slog leaf+"Attempting to bind /apps/urli" ~)
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
    ?-    -.action
        %shorten 
      =/  long-url  (ensure-url-scheme url.action)  
      =/  short-id  (~(get by reverse-url-map.state) long-url)
      :: if there exists a corresponding short url already, set it to
      :: active and update its timestamp
      ::
      ?.  =(~ short-id)
        :-  ~
        %=    state
            url-map
          %+  ~(jab by url-map)  
            (need short-id)
          |=(=target-meta target-meta(created-last now.bowl, active %.y))
        ==
      :: if there exists no corresponding short url, create a new short
      :: id and update the key-value stores
      ::
      =/  short-id-fresh  (generate-short-id eny.bowl)
      =/  mapping-new
      %+    ~(put by url-map.state)
        short-id-fresh
      :*
        url=long-url 
        active=%.y 
        created-first=now.bowl 
        created-last=now.bowl 
        hit-last=now.bowl 
        hits-total=0
      ==
      :-  ~
      %=  state
        url-map  mapping-new
        reverse-url-map  (~(put by reverse-url-map) long-url short-id-fresh)
      ==
        %delete 
      :-  ~ 
      %=  state
        url-map  (~(del by url-map) short-id.action)
        reverse-url-map  (~(del by reverse-url-map) url:(~(got by url-map) short-id.action))
      ==
        %activate
      :-  ~
      %=  state  url-map
        %+  ~(jab by url-map)  short-id.action
        |=(=target-meta target-meta(active %.y))
      ==
        %deactivate
      :-  ~
      %=  state  url-map
        %+  ~(jab by url-map)  short-id.action
        |=(=target-meta target-meta(active %.n))
      ==
    ==
  ++  handle-http
    |=  [eyre-id=@ta req=inbound-request:eyre]
    ^-  (quip card _state)
    ?+    method.request.req  [(make-405 eyre-id) state]
    ::
        %'GET'
      :: decode path c.f. https://github.com/urbit/docs-examples/blob/main/groups-app/bare-desk/app/squad.hoon#L69-L72
      ::
      =/  =path
        %-  tail
        %-  tail
        %+  rash  url.request.req
        ;~(sfix apat:de-purl:html yquy:de-purl:html)
      :: if the path is empty, check auth and render index page
      ::
      ?~  path
        ?.  authenticated.req
          [(login-redirect eyre-id) state]
        :_  state
        (make-200 eyre-id (index bowl url-map.state))
      :: redirect either to the resolved external url or to 404
      ::
      ?.  .=((lent path) 1)  [(make-404 eyre-id) state] 
      =/  =short-id  (head path) 
      ?.  (~(has by url-map) short-id)  [(make-404 eyre-id) state]
      ?.  active:(~(got by url-map) short-id)  [(make-404 eyre-id) state]
      =/  hits-total  hits-total:(~(got by url-map) short-id)
      :_  %=  state  url-map
        %+  ~(jab by url-map)  short-id
        |=(=target-meta target-meta(hit-last now.bowl, hits-total +(hits-total)))
      ==
      (redirect eyre-id url:(~(got by url-map) short-id))
    ::
        %'POST'
      =/  body=(unit octs)  body.request.req
      =/  headers=header-list:http  header-list.request.req
      =/  kvargs  (fall ?~(body ~ (rush q.u.body yquy:de-purl:html)) ~)
      :: TODO: beautify argument handling
      ::
      =/  arg  (snag 0 kvargs)
      =/  arg-name  `@tas`-.arg
      =/  checked-ids 
        ^-  (list short-id)
        %+  murn  (slag 1 kvargs)
        |=  keyval=(pair @t @t)
        ?:(=(p.keyval 'check') (some q.keyval) ~)
      =^  cards  state
        ?:  |(=(arg-name %delete) =(arg-name %activate) =(arg-name %deactivate))
          %-  tail
          %^    spin  checked-ids  `(quip card _state)`[~ state]
            |=  [smol-id=short-id s=(quip card _state)]
            ^-  [short-id (quip card _state)]
            =.  state  +.s
            =^  cards  state
              ?+  arg-name  !!
                %delete  (handle-action %delete smol-id) 
                %activate  (handle-action %activate smol-id)
                %deactivate  (handle-action %deactivate smol-id)
              ==
            [smol-id [(weld cards -.s) state]]
        ?:  .=(arg-name 'shorten')
          =/  url-long  +.arg 
          :: do nothing if the long url is empty
          ::
          ?:  =(url-long '')  `state
          (handle-action [%shorten `url`url-long])
        [(make-405 eyre-id) state]
      [(weld cards (redirect eyre-id '/urli')) state]
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
    :: reslove short ID
    ::
      [%x @ ~]  
    =/  =short-id  i.t.path
    =/  =url  url:(~(got by url-map.state) short-id)
    ``noun+!>(url)
    :: check short ID availability
    ::
      [%x %free @ ~]  
    =/  =short-id  i.t.t.path
    ``noun+!>(?!((~(has by url-map.state) short-id)))
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

