module Polar.Shader.ParserSpec where

import Data.Either (isLeft)
import qualified Data.Map as M
import Test.Hspec
import Polar.Shader.Types
import Polar.Shader.Parser

spec = describe "Parser" $ do
    it "returns an empty function map when given an empty list" $
        parse []
        `shouldBe` Right M.empty
    it "returns a singleton empty function when given \
             \[IdentifierT \"a\", BraceOpenT, BraceCloseT]" $
        parse [IdentifierT  "a" , BraceOpenT, BraceCloseT]
        `shouldBe` Right (M.singleton "a" (Function "a" [] []))
    it "returns a function with a Literal AST when given \
             \[IdentifierT \"a\", BraceOpenT, LiteralT 1.0, BraceCloseT]" $
        parse [IdentifierT  "a" , BraceOpenT, LiteralT 1.0, BraceCloseT]
        `shouldBe` Right (M.singleton "a" (Function "a" [] [Literal 1.0]))
    it "returns a function with an Identifier AST when given \
             \[IdentifierT \"a\", BraceOpenT, IdentifierT \"asdf\", BraceCloseT]" $
        parse [IdentifierT  "a" , BraceOpenT, IdentifierT  "asdf" , BraceCloseT]
        `shouldBe` Right (M.singleton "a" (Function "a" [] [Identifier "asdf"]))
    it "returns a function with a Swizzle AST when given \
             \[IdentifierT \"a\", BraceOpenT, LiteralT 1.0, LiteralT 2.0, BraceCloseT]" $
        parse [IdentifierT  "a" , BraceOpenT, LiteralT 1.0, LiteralT 2.0, BraceCloseT]
        `shouldBe` Right (M.singleton "a" (Function "a" [] [Swizzle [Literal 1.0, Literal 2.0]]))
    it "returns a function with a Swizzle AST when given \
             \[IdentifierT \"a\", BraceOpenT, LiteralT 1.0, IdentifierT \"asdf\", IdentifierT \"asdf\", BraceCloseT]" $
        parse [IdentifierT  "a" , BraceOpenT, LiteralT 1.0, IdentifierT  "asdf" , IdentifierT  "asdf" , BraceCloseT]
        `shouldBe` Right (M.singleton "a" (Function "a" [] [Swizzle [Literal 1.0, Identifier "asdf", Identifier "asdf"]]))
    it "returns a function with a Swizzle AST when given \
             \[IdentifierT \"a\", BraceOpenT, IdentifierT \"asdf\", LiteralT 1.0, LiteralT 2.0, BraceCloseT]" $
        parse [IdentifierT  "a" , BraceOpenT, IdentifierT  "asdf" , LiteralT 1.0, LiteralT 2.0, BraceCloseT]
        `shouldBe` Right (M.singleton "a" (Function "a" [] [Swizzle [Identifier "asdf", Literal 1.0, Literal 2.0]]))
    it "returns a function with an Assignment AST when given \
             \[IdentifierT \"a\", BraceOpenT, IdentifierT \"var\", EqualsT, IdentifierT \"name\", LiteralT 1.0, LiteralT 2.0, BraceCloseT]" $
        parse [IdentifierT  "a" , BraceOpenT, IdentifierT  "var" , EqualsT, IdentifierT  "name" , LiteralT 1.0, LiteralT 2.0, BraceCloseT]
        `shouldBe` Right (M.singleton "a" (Function "a" [] [Assignment (Identifier "var") $ Swizzle [Identifier "name", Literal 1.0, Literal 2.0]]))
    it "returns two empty functions when given \
             \[IdentifierT \"a\", BraceOpenT, BraceCloseT, IdentifierT \"b\", BraceOpenT, BraceCloseT]" $
        parse [IdentifierT  "a" , BraceOpenT, BraceCloseT, IdentifierT  "b" , BraceOpenT, BraceCloseT]
        `shouldBe` Right (M.fromList [("a", Function "a" [] []), ("b", Function "b" [] [])])
    it "returns two functions with single ASTs when given \
             \[IdentifierT \"a\", BraceOpenT, LiteralT 1.0, BraceCloseT, IdentifierT \"b\", BraceOpenT, LiteralT 2.0, BraceCloseT]" $
        parse [IdentifierT  "a" , BraceOpenT, LiteralT 1.0, BraceCloseT, IdentifierT  "b" , BraceOpenT, LiteralT 2.0, BraceCloseT]
        `shouldBe` Right (M.fromList [("a", Function "a" [] [Literal 1.0]), ("b", Function "b" [] [Literal 2.0])])
    it "returns a singleton function with a single AST when given \
             \[IdentifierT \"a\", BraceOpenT, LiteralT 1.0, BraceCloseT, IdentifierT \"a\", BraceOpenT, LiteralT 2.0, BraceCloseT]" $
        parse [IdentifierT  "a" , BraceOpenT, LiteralT 1.0, BraceCloseT, IdentifierT  "a" , BraceOpenT, LiteralT 2.0, BraceCloseT]
        `shouldBe` Right (M.singleton "a" (Function "a" [] [Literal 2.0]))
    it "returns a function with two ASTs when given \
             \[IdentifierT \"a\", BraceOpenT, LiteralT 1.0, StatementEndT, LiteralT 2.0, BraceCloseT]" $
        parse [IdentifierT  "a" , BraceOpenT, LiteralT 1.0, StatementEndT, LiteralT 2.0, BraceCloseT]
        `shouldBe` Right (M.singleton "a" (Function "a" [] [Literal 1.0, Literal 2.0]))
    it "returns a function with two ASTs when given \
             \[IdentifierT \"a\", BraceOpenT, LiteralT 1.0, NewLineT, LiteralT 2.0, BraceCloseT]" $
        parse [IdentifierT  "a" , BraceOpenT, LiteralT 1.0, NewLineT, LiteralT 2.0, BraceCloseT]
        `shouldBe` Right (M.singleton "a" (Function "a" [] [Literal 1.0, Literal 2.0]))
    it "returns a singleton empty function when given \
             \[NewLineT, IdentifierT \"a\", BraceOpenT, BraceCloseT]" $
        parse [NewLineT, IdentifierT  "a" , BraceOpenT, BraceCloseT]
        `shouldBe` Right (M.singleton "a" (Function "a" [] []))
    it "returns a singleton empty function when given \
             \[NewLineT, NewLineT, IdentifierT \"a\", BraceOpenT, BraceCloseT]" $
        parse [NewLineT, NewLineT, IdentifierT  "a" , BraceOpenT, BraceCloseT]
        `shouldBe` Right (M.singleton "a" (Function "a" [] []))
    it "returns a singleton empty function when given \
             \[IdentifierT \"a\", NewLineT, BraceOpenT, BraceCloseT]" $
        parse [IdentifierT  "a" , NewLineT, BraceOpenT, BraceCloseT]
        `shouldBe` Right (M.singleton "a" (Function "a" [] []))
    it "returns a singleton empty function when given \
             \[IdentifierT \"a\", NewLineT, NewLineT, BraceOpenT, BraceCloseT]" $
        parse [IdentifierT  "a" , NewLineT, NewLineT, BraceOpenT, BraceCloseT]
        `shouldBe` Right (M.singleton "a" (Function "a" [] []))
    it "returns a singleton empty function when given \
             \[IdentifierT \"a\", BraceOpenT, NewLineT, BraceCloseT]" $
        parse [IdentifierT  "a" , BraceOpenT, NewLineT, BraceCloseT]
        `shouldBe` Right (M.singleton "a" (Function "a" [] []))
    it "returns a singleton function when given \
             \[IdentifierT \"a\", BraceOpenT, NewLineT, NewLineT, LiteralT 1.0, BraceCloseT]" $
        parse [IdentifierT  "a" , BraceOpenT, NewLineT, NewLineT, LiteralT 1.0, BraceCloseT]
        `shouldBe` Right (M.singleton "a" (Function "a" [] [Literal 1.0]))
    it "returns an error when given a leading EqualsT" $
        parse [EqualsT]
        `shouldSatisfy` isLeft
    it "returns an error when given a leading BraceOpenT" $
        parse [BraceOpenT]
        `shouldSatisfy` isLeft
    it "returns an error when given a leading BraceCloseT" $
        parse [BraceCloseT]
        `shouldSatisfy` isLeft
    it "returns an error when given a leading StatementEndT" $
        parse [StatementEndT]
        `shouldSatisfy` isLeft
    it "returns an error when given a leading LiteralT" $
        parse [LiteralT 1.0]
        `shouldSatisfy` isLeft
    it "returns an error when given a leading IdentifierT without a following BraceOpenT" $
        parse [IdentifierT "a"]
        `shouldSatisfy` isLeft
    it "returns an error when given a leading IdentifierT without a following BraceOpenT" $
        parse [IdentifierT "a", EqualsT, LiteralT 1.0]
        `shouldSatisfy` isLeft
    it "returns an error when given a leading IdentifierT and BraceOpenT without a trailing BraceCloseT" $
        parse [IdentifierT "a", BraceOpenT]
        `shouldSatisfy` isLeft
    it "returns an error when given a leading IdentifierT and BraceOpenT without a trailing BraceCloseT" $
        parse [IdentifierT "a", BraceOpenT, LiteralT 1.0]
        `shouldSatisfy` isLeft
    it "returns an error when given a function with a leading EqualsT" $
        parse [IdentifierT "a", BraceOpenT, EqualsT, BraceCloseT]
        `shouldSatisfy` isLeft
    it "returns an error when given a function with a leading BraceOpenT" $
        parse [IdentifierT "a", BraceOpenT, BraceOpenT, BraceCloseT]
        `shouldSatisfy` isLeft
    it "returns an error when given a function that assigns to a literal" $
        parse [IdentifierT "a", BraceOpenT, LiteralT 1.0, EqualsT, LiteralT 2.0, BraceCloseT]
        `shouldSatisfy` isLeft
    it "returns an error when given a function that assigns to a swizzle" $
        parse [IdentifierT "a", BraceOpenT, IdentifierT "asdf", LiteralT 1.0, EqualsT, LiteralT 2.0, BraceCloseT]
        `shouldSatisfy` isLeft
    it "returns an error when given an incomplete assignment expression" $
        parse [IdentifierT "a", BraceOpenT, IdentifierT "var", EqualsT, BraceCloseT]
        `shouldSatisfy` isLeft
    it "supports nested assignment expressions" $
        parse [IdentifierT "a", BraceOpenT, IdentifierT "var", EqualsT, IdentifierT "name", EqualsT, LiteralT 2.0, BraceCloseT]
        `shouldBe` Right (M.fromList [("a", Function "a" [] [Assignment (Identifier "var") (Assignment (Identifier "name") (Literal 2.0))])])
