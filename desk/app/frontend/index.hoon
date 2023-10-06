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
   ;style: {(trip style)}
  ==
 ;body
   ;h1: %urly: A URL shortener 
   ;br;
   ;form(method "post")
     ;input(type "text", name "shorten");
     ;button(type "submit", value "long-url"):"shorten"
   ==
   ;br;
   ;+  (make-table m)
 ==
==
::
++  make-table-row
  |=  [=short-url =url]
  ^-  manx
  ;tr
    ;td
      ;form(method "post")
        ;button(type "submit", name "delete", value "{(trip short-url)}"):"✕"
      ==
    ==
    ;td: {(trip short-url)}
    ;td
      ;a(href "{(trip url)}"): {(trip url)}
    ==
  ==
::
++  make-table
  |=  m=url-map
  ^-  manx
  ;table
    ;*  (turn ~(tap by m) make-table-row)
  ==
::
++  style
  '''
  td {
    height: 50px;
    vertical-align: center;
  }
  '''
--
