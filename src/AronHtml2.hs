{-# LANGUAGE QuasiQuotes       #-}

module AronHtml2 where

import Control.Monad
import Data.Char
import qualified Data.List as L
import Data.List.Split
import Data.Time
import Data.Time.Clock.POSIX
import System.Directory
import System.Environment
import System.Exit
import System.FilePath.Posix
import System.IO
import System.Posix.Files
import System.Posix.Unistd
import System.Process
import Text.Read
import Text.Regex
import Text.Regex.Base
import Text.Regex.Base.RegexLike
import Text.Regex.Posix
import Data.IORef 
import Control.Monad (unless, when)
import Control.Concurrent 
-- {-# LANGUAGE QuasiQuotes       #-}
import Text.RawString.QQ (r)         -- Need QuasiQuotes too 

import AronModule


htmlHeadBody::String -> String
htmlHeadBody s = [r|
               <HTML>   
               <HEAD>
		   <style>
		     table {
			 border-collapse: collapse;
		     }
		     td, th {
			 border: 1px solid #999;
			 padding: 0.5rem;
			 text-align: center;
			 font-size:30pt;
		     }
                     span{
                       color:#333333;
                     }
		     .center {
			 margin-left: auto;
			 margin-right: auto;
		     }
		</style>
               <meta charset="utf-8">
               <TITLE>Search Code Snippet</TITLE> 
               <LINK rel="stylesheet" type="text/css" href="mystyle.css">
               <script src="aronlib.js" defer></script>
               </HEAD>
               <BODY>  |] <> s <> [r| <div id="myid">no data</div> </BODY></HTML> |]

htmlBody::String -> String
htmlBody s  = [r|
            <HTML>   
            <HEAD>   
            <meta charset="utf-8">
            <TITLE>Search Code Snippet</TITLE> 
            <LINK rel="stylesheet" type="text/css" href="mystyle.css?rnd=132">
            <LINK rel="stylesheet" type="text/css" href="modifycolor.css?rnd=132"> 
            <script src="aronlib.js" defer></script>
            </HEAD>
            <BODY>  |] <> s <> [r| <div id="searchdata">no data</div> </BODY></HTML> |]
            -- 'searchdata' is used in aronlib.js function delayFun(value)


                  
                  
type HTMLAttr = [String]
type GlobalAttr = String
attrStyle::HTMLAttr -> GlobalAttr
attrStyle cs = if len str > 0 then " style='" ++ str ++ "' " else ""
  where
    str = concatStr cs []

style_::[CSSKV] -> String
style_ cs = if len str > 0 then " style='" ++ str ++ "' " else ""
  where
    str = concatStr (map cssToStr cs) []

{-|
   === style tag

   @
   type CSSKV = (String, String)
   @
-}
styleTag_::[CSSKV] -> String  -- styleTag_ [("color", "#333"), ("background", "#444")]
styleTag_ cs = "<style>" ++ str ++ "/<style>"
  where
    str = concatStr (map cssToStr cs) []

-- id="myid"
attrId::HTMLAttr -> GlobalAttr
attrId cs = " id='" ++ (concatStr cs []) ++ "' "

id_::HTMLAttr -> GlobalAttr
id_ cs = " id='" ++ (concatStr cs []) ++ "' "

attrClass::HTMLAttr -> GlobalAttr
attrClass cs = " class='" ++ (concatStr cs []) ++ "' "

class_::HTMLAttr -> GlobalAttr
class_ cs = " class='" ++ (concatStr cs []) ++ "' "

attr::HTMLAttr -> GlobalAttr
attr cs = concatStr cs " "


attrOndblclick::HTMLAttr -> GlobalAttr
attrOndblclick cs = " ondblclick='" ++ (concatStr cs []) ++ "' "

ondblclick_::HTMLAttr -> GlobalAttr
ondblclick_ cs = " ondblclick='" ++ (concatStr cs []) ++ "' "

                    
{-|                                                            
   Html textarea                                               
   textArea row col string                                     
   textArea 4 5 "dog"                                          
-}
textAreaNew::GlobalAttr -> String-> String                
textAreaNew style s = createTag name attr s
    where                                                      
       name = "textarea"
       attr = concatStr [style] " "

table::GlobalAttr -> String -> String
table style s = createTag name attr s
    where
      name = "table"
      attr = concatStr [style] " "

td::GlobalAttr -> String -> String
td style s = createTag name attr s
  where
    name = "td"
    attr = concatStr [style] " "

tr::GlobalAttr -> String -> String
tr style s = createTag name attr s
  where
    name = "tr"
    attr = concatStr [style] " "

pre_::GlobalAttr -> String -> String
pre_ style s = createTag name attr s
  where
    name = "pre"
    attr = concatStr [style] " "

div_::GlobalAttr -> String -> String
div_ style s = createTag name attr s
  where
    name = "div"
    attr = concatStr [style] " "

label_::GlobalAttr -> String -> String
label_ style s = createTag name attr s
  where
    name = "label"
    attr = concatStr [style] " "

input_::GlobalAttr -> String -> String
input_ style s = createTag tag attr ""
  where
    tag = "input"
    attr = (concatStr [style] " ") ++ " value=" ++ s
    
span_::GlobalAttr -> String -> String
span_ attrStr s = createTag tag attr s
  where
    tag = "span"
    attr = if len attrStr > 0 then attrStr else ""

htmlbr = "<br>"

createTag::String -> String -> String -> String
createTag name attr content = open + content + close
              where
                -- open = "<" ++ name ++ " " ++ attr ++ ">"
                open = concatStr  (filterNonEmpty ["<" + name, attr, ">"]) (if len attr > 0 then " " else [])
                close = concatStr ["</" + name + ">"] []
                (+) = (++)



{-|
    === Generate r row and c col table

   ("background-color", "#" + (cssColor x)),
   ("color", "#" + (cssColor y)           ),
   ("width", "600px"                       ),
   ("height", "100px"                    ),
   ("border", "2px solid green"          ),
   ("margin", "4px"                      ),
   ("white-space", "pre-wrap"            )
-}                
htmlBox::[(String, String)] -> String -> String
htmlBox cs str = div_ (style_ cs) str
                
ccat ls s = concatStr ls s

