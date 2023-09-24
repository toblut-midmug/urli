/-  *urly
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
   ;h1: %urly: A URL shortener 
   ;br;
   ;form(method "post")
     ;input(type "text", name "long-url");
     ;button(type "submit", value "Submit"):"shorten"
   ==
   ;br;
   ;table(class "center")
     ;*  (make-table m)
   ==
 ==
==
::
++  make-table-row
  |=  [=url-alias =url]
  ^-  manx
  ;tr
    ;td
      ;form(method "post")
        ;button(type "submit", name "delete", value "{(trip url-alias)}"):"✕"
       ==
    ==
    ;td: {(trip url-alias)}
    ;td: {(trip url)}
  ==
::
++  make-table
  |=  m=url-map
  ^-  marl
  (turn ~(tap by m) make-table-row)
--
