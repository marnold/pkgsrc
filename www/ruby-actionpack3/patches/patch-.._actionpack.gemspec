$NetBSD: patch-.._actionpack.gemspec,v 1.1.2.1 2011/04/06 22:49:42 tron Exp $

Allow depending later version gem of builder.

--- ../actionpack-3.0.6.gemspec.orig	2011-04-06 09:18:37.000000000 +0900
+++ ../actionpack-3.0.6.gemspec	2011-04-06 09:18:37.000000000 +0900
@@ -56,7 +56,7 @@ dependencies: 
   requirement: &id003 !ruby/object:Gem::Requirement 
     none: false
     requirements: 
-    - - ~>
+    - - >=
       - !ruby/object:Gem::Version 
         hash: 15
         segments: 
