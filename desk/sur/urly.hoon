|%
+$  url-alias  @t
+$  url  @t
+$  url-map  (map url-alias url)
+$  state-0  [%0 =url-map]
+$  action 
  $%  [%shorten =url]
      [%shorten-custom =url-alias =url]
      [%delete =url-alias]
  ==
--
