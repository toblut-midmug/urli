|%
+$  short-url  @t ::TODO: rename to `short-id`; it's not really a URL...
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
      [%delete =short-url]
      [%activate =short-url]
      [%deactivate =short-url]
  ==
--
