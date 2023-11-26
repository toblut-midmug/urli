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
  ==
 ;body
   ;h1: %urli: A URL shortener 
   ;br;
   ;form(method "post")
     ;input(type "text", name "shorten", placeholder "enter url");
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
  ::  well, sorting the table every time the page is loaded does seem a
  ::  bit wasteful ...
  ::
  =/  sorted-entries  
    %+    sort  
       ~(tap by m)
    |=  [m=[k=short-id v=target-meta] n=[k=short-id v=target-meta]]
    (gth created-last.v.m created-last.v.n)
  ;form(method "post")
    ;button(title "delete", type "submit", name "delete"):"🗑️"   ::"✕"
    ;button(title "activate", type "submit", name "activate"):"▶️ "
    ;button(title "deactivate", type "submit", name "deactivate"):"⏸️"
    ;br;
    ;br;
    ;table
      ;*  %+  turn  sorted-entries 
        |=  [=short-id =target-meta]
        ^-  manx 
        ;tr
          ;td
            ;input(type "checkbox", name "check", id "{(trip short-id)}", value "{(trip short-id)}");
          ==
::          ;td: {(trip short-id)}
         ;td
            ;+  ?:  active.target-meta
                  ;span(title "active"): {(trip short-id)}
                ;s(title "inactive"): {(trip short-id)}
          ==
          ;td
            ;button(title "copy", type "button", onclick "clipboardcopy('{(trip short-id)}')"):"🔗"
          ==
        ;td:  
::          ;td(title "hits"): {(a-co:co hits-total.target-meta)} 👁️
::          ;+  ?:  active.target-meta
::                ;td(title "active"): 🔊
::              ;td(title "inactive"): 🔇
          ;td
            ;a(href "{(trip url.target-meta)}"): {(trip url.target-meta)}
          ==
      ==
    ==
  ==
::
++  script
  '''
  function clipboardcopy(shortid) {
    navigator.clipboard.writeText(window.location.href + "/" + shortid);
  }
  '''
::
--
