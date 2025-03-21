-- !!! Wentworth's version of a program to generate
-- !!! all the expansions of a generalised regular expression
-- !!!
--
-- RJE: Modified so it only outputs the number of characters in the output,
-- rather that the output itself, thus avoiding having to generate such a
-- huge output file to get a reasonable execution time.

module Main (main) where

import Data.Char
import Control.Monad (replicateM_)
import System.Environment
import NofibUtils (hash)

import G2.Symbolic

main = replicateM_ 500 $ do
  regex <- mkSymbolic
  print (hash (concat (expand regex)))

numchars :: [String] -> Int
numchars l = sum $ map length l

expand []	= [""]
expand ('<':x)	= numericRule x
expand ('[':x)	= alphabeticRule x
expand x	= constantRule x

constantRule (c:rest) = [ c:z | z <- expand rest ]

alphabeticRule (a:'-':b:']':rest)
  | a <= b  	= [c:z | c <- [a..b],	      z <- expand rest]
  | otherwise	= [c:z | c <- reverse [b..a], z <- expand rest]

numericRule x
  = [ pad (show i) ++ z
	| i <- if u < v then [u..v] else [u,u-1..v]
	, z <- expand s ]
  where
    (p,_:q) = span (/= '-') x
    (r,_:s) = span (/= '>') q
    (u,v)   = (mknum p, mknum r)
    mknum s = foldl (\ u c -> u * 10 + (ord c - ord '0')) 0 s
    pad s   = [ '0' | i <- [1 .. (width-(length s))]] ++ s
    width   = max (length (show u)) (length (show v))
