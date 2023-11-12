|%
+$  short-url  @t
+$  url  @t
::+$  target-meta
::  $:  target-url=url
::      active=?
::      created-first=@da
::      created-last=@da
::      hit-last=@da
::      hits-total=@ud
::  ==
+$  url-map  (map short-url url)
+$  state-0  [%0 =url-map]
+$  action 
  $%  [%shorten =url]
      [%shorten-custom =short-url =url]
      [%delete =short-url]
  ==
--
