$NetBSD: patch-.._activemodel.gemspec,v 1.1.2.1 2011/04/06 22:49:41 tron Exp $

Allow depending later version gem of builder.

--- ../activemodel-3.0.6.gemspec.orig	2011-04-06 16:09:09.000000000 +0900
+++ ../activemodel-3.0.6.gemspec	2011-04-06 16:09:46.000000000 +0900
@@ -40,7 +40,7 @@ dependencies: 
   requirement: &id002 !ruby/object:Gem::Requirement 
     none: false
     requirements: 
-    - - ~>
+    - - >=
       - !ruby/object:Gem::Version 
         hash: 15
         segments: 
