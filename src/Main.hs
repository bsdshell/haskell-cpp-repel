-- {{{ begin_fold
-- script
-- #!/usr/bin/env runhaskell -i/Users/cat/myfile/bitbucket/haskelllib
-- {-# LANGUAGE OverloadedStrings #-}
-- {-# LANGUAGE DuplicateRecordFields #-} 
-- import Turtle
-- echo "turtle"

{-# LANGUAGE MultiWayIf        #-}
{-# LANGUAGE QuasiQuotes       #-} -- support raw string [r|<p>dog</p> |]
import Text.RawString.QQ       -- Need QuasiQuotes too 


-- import Data.Set   -- collide with Data.List 
import Control.Monad
import Data.Char
import Data.Typeable (typeOf) -- runtime type checker, typeOf "k"
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
import qualified System.Console.Pretty as SCP

import qualified Text.Regex.TDFA as TD

import System.Console.Haskeline
import qualified System.Console.ANSI as AN
import AronModule 

p1 = "/Users/cat/myfile/bitbucket/testfile/test.tex"

-- zo - open
-- za - close


{-|
main :: IO ()
main = runInputT defaultSettings loop
   where
       loop :: InputT IO ()
       loop = do
           minput <- getInputLine "% "
           case minput of
               Nothing -> return ()
               Just "quit" -> return ()
               Just input -> do outputStrLn $ "Input was: " ++ input
                                return $ writeFileListAppend "/tmp/xx2.x" [input]
                                outputStrLn $ "my input => " ++ input
                                loop
-}

mycmd = [
      ":h",
      ":del",
      ":run",
      ":rep",
      ":hsc",
      ":cmd",
      ":cr"
    ]

cppFile = "./cpp.cpp"
conStr = containStr

runCpp::IO()
runCpp = do
      clear
      -- out <- run "cat /tmp/x4.x"
      out <- run $ "cpp_compile.sh " ++ cppFile
      mapM_ putStrLn out
      ss <- getLineFlush
      clear

repFile::[String] -> IO()
repFile cx = do
      replaceFileWithStr "// replaceStr00" ((unlines . reverse) cx) cppFile 

delCode::IO ()
delCode = do
      ls <- readFileStrict cppFile >>= return . lines
      let lss = splitListWhen (\x -> (conStr "BEG_" x) || (conStr "END_" x)) ls
      let h = head lss
      let t = last lss
      writeFileList cppFile $ h ++ ["// BEG_rep", "// replaceStr00", "// END_rep"] ++ t
      str <- readFileStrict cppFile 
      let zls = zipWith(\n s -> (show n) ++ " " ++ s) [1..] $ lines str
      clear
      mapM_ (\x -> putStrLn $ "\t" ++ x) zls 

clearCode::IO ()
clearCode = do
      clear

cmdRun:: String -> IO ()
cmdRun s = do
    clear
    let cmd = drop 5 s
    out <- run $ cmd 
    setCursorPos 10  4 
    mapM_ putStrLn out

cppSnippet:: String -> IO ()
cppSnippet s = do
       clear
       let cmd = trim $ drop 4 s
       stdout <- run $ "hsc " ++ cmd
       setCursorPos 20  4 
       mapM_ putStrLn stdout 

lsCode:: IO ()
lsCode = do
       str <- readFileStrict cppFile 
       let zls = zipWith(\n s -> (show n) ++ " " ++ s) [1..] $ lines str
       clear
       mapM_ (\x -> putStrLn $ "\t" ++ x) zls 

helpMe::IO ()
helpMe = do
    clear        
    setCursorPos 20  4 
    printBox 2 mycmd

main::IO()
main = do
  let x = 3
  let upLine = 20
  clear
  let loop n cx = do
        setCursorPos (40 + n)  4 
        AN.clearFromCursorToLineEnd
        -- AN.cursorForward 4
        s <- getLineFlush >>= return . trim
        -- AN.cursorUp upLine 
        -- putStrLn $ "\t" ++ s
        if | hasPrefix ":run" s -> do
             runCpp
             loop 0 []
           | hasPrefix ":rep" s -> do
             repFile cx
             loop 0 []
           | hasPrefix ":del" s -> do
             delCode             
             loop 0 []
           | hasPrefix ":cr" s -> do
             clearCode             
             loop 0 []
           | hasPrefix ":cmd" s -> do
             cmdRun s
             loop 0 []
           | hasPrefix ":hsc" s -> do
             cppSnippet s 
             loop 0 []
           | hasPrefix ":ls" s -> do
             lsCode 
             loop 0 []
           | hasPrefix ":h" s -> do
             helpMe 
             loop 0 []
           | otherwise -> do 
             loop (n + 1) (s:cx)

  loop 0 []
  print "done"
