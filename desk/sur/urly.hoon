|%
+$  short-url  @t
+$  url  @t
+$  url-map  (map short-url url)
+$  state-0  [%0 =url-map]
+$  action 
  $%  [%shorten =url]
      [%shorten-custom =short-url =url]
      [%delete =short-url]
  ==
--
