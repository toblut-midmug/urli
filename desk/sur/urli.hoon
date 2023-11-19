|%
+$  short-url  @t
+$  url  @t
+$  target-meta
  $:  =url
      active=?
      created-first=@da
      created-last=@da
      hit-last=@da
      hits-total=@ud
  ==
+$  url-map  (map short-url target-meta)
+$  reverse-url-map  (map url short-url)
+$  state-0  [%0 =url-map =reverse-url-map]
+$  action 
  $%  [%shorten =url]
      [%shorten-custom =short-url =url]
      [%delete =short-url]
  ==
--
