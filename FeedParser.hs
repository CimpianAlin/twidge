{- hspod component
Copyright (C) 2006 John Goerzen <jgoerzen@complete.org>

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
   Module     : FeedParser
   Copyright  : Copyright (C) 2006 John Goerzen
   License    : GNU GPL, version 2 or above

   Maintainer : John Goerzen <jgoerzen@complete.org>
   Stability  : provisional
   Portability: portable

Written by John Goerzen, jgoerzen\@complete.org

-}
module FeedParser(parse) where

import Types
import Text.XML.HaXml

parse :: FilePath -> IO Feed
parse fp = 
    do c <- readFile fp
       let doc = getContent $ xmlParse fp c
       let title = getTitle doc
       let feeditems = [] -- getEnclosures doc
       return (Feed {channeltitle = title, items = feeditems})
       where getContent (Document _ _ e _) = CElem e

getTitle doc =
    strofm "title" (children `o` channel $ doc)

channel =
    tag "channel" `o` children `o` tag "rss"
--------------------------------------------------
-- Utilities
--------------------------------------------------

attrofelem :: String -> Content -> AttValue
attrofelem attrname (CElem (Elem name al _)) =
    case lookup attrname al of
       Just x -> x
       Nothing -> error $ "attrofelem: no " ++ attrname ++ " in " ++ name
attrofelem _ _ =
    error "attrofelem: called on something other than a CElem"

-- Finds the literal children of the named tag, and returns it/them
tagof :: String -> CFilter
tagof x = keep /> tag x /> txt

-- Retruns the literal string that tagof would fine
strof :: String -> Content -> String
strof x y = verbatim $ tagof x $ y

strofm x y = concat . map (strof x) $ y