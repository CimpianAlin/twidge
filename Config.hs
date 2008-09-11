{- hpodder component
Copyright (C) 2006-2008 John Goerzen <jgoerzen@complete.org>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
-}

{- |
   Module     : Config
   Copyright  : Copyright (C) 2006-2008 John Goerzen
   License    : GNU GPL, version 2 or above

   Maintainer : John Goerzen <jgoerzen@complete.org>
   Stability  : provisional
   Portability: portable

Written by John Goerzen, jgoerzen\@complete.org

-}
module Config where

import System.Directory
import Data.ConfigFile
import Control.Monad
import Data.Either.Utils
import System.Path
import Data.String.Utils(strip, split)

getDefaultCP =
    do return $ forceEither $ 
              do -- cp <- add_section startingcp "general"
                 -- cp <- set cp "general" "showintro" "yes"
                 cp <- set startingcp "DEFAULT" "urlbase" "https://twitter.com"
                 return cp

startingcp = emptyCP {accessfunc = interpolatingAccess 10}

getCPName =
    do appdir <- getUserDocumentsDirectory
       return $ appdir ++ "/.twidgerc"

loadCP cpgiven = 
    do cpname <- case cpgiven of
                   Nothing -> getCPName
                   Just x -> return x
       defaultcp <- getDefaultCP
       dfe <- doesFileExist cpname
       if dfe
          then do cp <- readfile defaultcp cpname
                  return $ forceEither cp
          else do fail $ "No config file found at " ++ cpname

writeCP cp =
    do cpname <- getCPName
       writeFile cpname (to_string cp)

getList :: ConfigParser -> String -> String -> Maybe [String]
getList cp sect key = 
       case get cp sect key of
         Right x -> Just (splitit x)
         Left _ -> Nothing
    where splitit x = filter (/= "") . map strip . split "," $ x
  