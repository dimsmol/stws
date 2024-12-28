{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE OverloadedStrings #-}

module Main (main) where

import Network.Wai.Middleware.RequestLogger (logStdoutDev)
import Network.Wai.Middleware.Static (addBase, staticPolicy)
import System.Directory (getCurrentDirectory)
import System.Environment (getArgs)
import System.Exit (exitSuccess)
import System.FilePath ((</>))
import Web.Scotty (middleware, scotty)

main :: IO ()
main = do
  args <- getArgs
  maybePrintHelpAndExit args
  let parsedArgs = parseArgs defaultArgs args
  runScotty parsedArgs

runScotty :: Args -> IO ()
runScotty args = do
  currDir <- getCurrentDirectory
  scotty args.port $ do
    middleware logStdoutDev
    middleware $ staticPolicy $ addBase $ currDir </> args.dirPath

maybePrintHelpAndExit :: [String] -> IO ()
maybePrintHelpAndExit ("-h" : _) = printHelpAndExit
maybePrintHelpAndExit ("--help" : _) = printHelpAndExit
maybePrintHelpAndExit _ = pure ()

printHelpAndExit :: IO ()
printHelpAndExit = do
  putStrLn "Usage: stsw [options] [dir]"
  putStrLn ""
  putStrLn "Options:"
  putStrLn "-p port - port, default is 3000"
  putStrLn "-d dir - dir to serve, default is current dir"
  exitSuccess

data Args = Args
  { port :: Int,
    dirPath :: FilePath
  }

defaultArgs :: Args
defaultArgs = Args {port = 3000, dirPath = ""}

parseArgs :: Args -> [String] -> Args
parseArgs args [] = args
parseArgs args ("-p" : portStr : rest) = parseArgs (args {port = read portStr}) rest
parseArgs args ("-d" : dir : rest) = parseArgs (args {dirPath = dir}) rest
parseArgs args (dir : rest) = parseArgs (args {dirPath = dir}) rest
