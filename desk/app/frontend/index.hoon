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
   ;script: {(trip script)}
 ==
==
::
++  make-table
  |=  m=url-map
  ^-  manx
  ;table
    ;form(method "post")
    ;*  %+  turn  ~(tap by m)
      |=  [=short-url =url]
      ^-  manx 
      ;tr
::        ;td
::          ;input(type "checkbox", name "foo", value "{(trip short-url)}");
::        ==
        ;td
          ;button(type "submit", name "delete", value "{(trip short-url)}"):"✕"
        ==
        ;td: {(trip short-url)}
        ;td
          ;button(type "button", onclick "clipboardcopy('{(trip short-url)}')"):"copy"
        ==
        ;td
          ;a(href "{(trip url)}"): {(trip url)}
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
