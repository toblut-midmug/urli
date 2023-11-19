/-  *urli
|=  [=bowl:gall m=url-map]
|^  ^-  octs
%-  as-octs:mimes:html 
%-  crip 
%-  en-xml:html
^-  manx  
;html
 ;head
   ;meta(charset "utf-8", content "width=device-width, initial-scale=1");
   ;style: {(trip style)}
  ==
 ;body
   ;h1: %urli: A URL shortener 
   ;br;
   ;form(method "post")
     ;input(type "text", name "shorten");
     ;button(type "submit", value "long-url"):"shorten"
   ==
   ;br;
   ;+  (make-table m)
   ;script: {(trip script)}
 ==
==
::
++  make-table
  |=  m=url-map
  ^-  manx
  ::  well, sorting the table each time the page is loaded does seem a
  ::  bit wasteful ...
  ::
  =/  sorted-entries  
    %+    sort  
       ~(tap by m)
    |=  [m=[k=short-url v=target-meta] n=[k=short-url v=target-meta]]
    (gth created-last.v.m created-last.v.n)
  ;table
    ;form(method "post")
    ;*  %+  turn  sorted-entries 
      |=  [=short-url =target-meta]
      ^-  manx 
      ;tr
::        ;td
::          ;input(type "checkbox", name "foo", value "{(trip short-url)}");
::        ==
        ;td
          ;div(title "delete")
            ;button(type "submit", name "delete", value "{(trip short-url)}"):"🗑️"   ::"✕"
          ==
        ==
        ;td: {(trip short-url)}
        ;td
          ;div(title "copy")
            ;button(type "button", onclick "clipboardcopy('{(trip short-url)}')"):"🔗"
          ==
        ==
        ;td
          ;a(href "{(trip url.target-meta)}"): {(trip url.target-meta)}
        ==
      ==
    ==
  ==
::
++  style
  '''
  td {
    height: 50px;
    vertical-align: center;
  }
  '''
::
++  script
  '''
  function clipboardcopy(x) {
    navigator.clipboard.writeText(window.location.href + "/" + x);
  }
  '''
::
--
