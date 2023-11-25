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
  ::  well, sorting the table each time the page is loaded does seem a
  ::  bit wasteful ...
  ::
  =/  sorted-entries  
    %+    sort  
       ~(tap by m)
    |=  [m=[k=short-url v=target-meta] n=[k=short-url v=target-meta]]
    (gth created-last.v.m created-last.v.n)
  ;form(method "post")
    ;button(title "delete", type "submit", name "delete"):"🗑️"   ::"✕"
    ;button(title "activate", type "submit", name "activate"):"▶️ "
    ;button(title "deactivate", type "submit", name "deactivate"):"⏸️"
    ;br;
    ;br;
    ;table
      ;*  %+  turn  sorted-entries 
        |=  [=short-url =target-meta]
        ^-  manx 
        ;tr
          ;td
            ;input(type "checkbox", name "check", id "{(trip short-url)}", value "{(trip short-url)}");
          ==
          ;td: {(trip short-url)}
          ;td
            ;button(title "copy", type "button", onclick "clipboardcopy('{(trip short-url)}')"):"🔗"
          ==
          ;td:  
          ;td: {(a-co:co hits-total.target-meta)} 👁️
          ;td
            ;a(href "{(trip url.target-meta)}"): {(trip url.target-meta)}
          ==
      ==
    ==
  ==
::
++  script
  '''
  function clipboardcopy(x) {
    navigator.clipboard.writeText(window.location.href + "/" + x);
  }
  '''
::
--
