|%
+$  short-id  @t
+$  url  @t
+$  target-meta
  $:  =url
      active=?
      created-first=@da
      created-last=@da
      hit-last=@da
      hits-total=@ud
  ==
+$  url-map  (map short-id target-meta)
+$  reverse-url-map  (map url short-id)
+$  state-0  [%0 =url-map =reverse-url-map]
+$  action 
  $%  [%shorten =url]
      [%delete =short-id]
      [%activate =short-id]
      [%deactivate =short-id]
  ==
--
