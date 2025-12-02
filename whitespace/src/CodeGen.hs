{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecursiveDo #-}

module CodeGen where

import qualified LLVM.AST as AST
import qualified LLVM.AST.Type as T
import qualified LLVM.AST.Constant as C
import qualified LLVM.AST.IntegerPredicate as IP
import qualified LLVM.AST.Global as G
import qualified LLVM.AST.CallingConvention as CC

import LLVM.AST (Named((:=)))

import qualified Data.ByteString.Char8 as BS
import qualified Data.Map as Map
import Control.Monad.State
import Data.Word

import AbsWhitespace

-- | LLVM code generation state
data CodegenState = CodegenState
  { currentBlock :: AST.Name
  , blocks       :: [BasicBlock]
  , blockCount   :: Int
  , count        :: Word
  , names        :: Names
  , labels       :: Map.Map String AST.Name
  } deriving Show

type Names = [(String, Int)]

data BasicBlock = BasicBlock
  { blockName :: AST.Name
  , blockStack :: [Named AST.Instruction]
  , blockTerm  :: Maybe (Named AST.Terminator)
  } deriving Show

type Codegen = State CodegenState

-- | Generate LLVM module from Whitespace AST
codegenModule :: WS -> AST.Module
codegenModule ws = AST.defaultModule
  { AST.moduleName = "whitespace"
  , AST.moduleDefinitions = [mainDef, putcharDef, getcharDef, printfDef, scanfDef]
  }
  where
    mainDef = AST.GlobalDefinition $ G.functionDefaults
      { G.name = AST.Name "main"
      , G.returnType = T.i32
      , G.basicBlocks = createBlocks $ execCodegen $ do
          entry <- addBlock "entry"
          setBlock entry
          
          -- Allocate stack (10000 elements)
          stack <- alloca (T.ArrayType 10000 T.i64)
          sp <- alloca T.i32  -- Stack pointer
          zero <- iconst 0
          store sp zero
          
          -- Allocate heap (10000 elements)
          heap <- alloca (T.ArrayType 10000 T.i64)
          
          -- Initialize heap to zeros
          heapPtr <- gep heap [zero, zero]
          call (externf "llvm.memset.p0i8.i64" (T.FunctionType T.VoidType [T.ptr T.i8, T.i8, T.i64, T.i1] False))
               [heapPtr, iconst8 0, iconst64 80000, iconst1 0]
          
          -- Generate code for Whitespace program
          codegenWS ws stack sp heap
          
          -- Return 0
          ret (iconst 0)
      }

    putcharDef = AST.GlobalDefinition $ G.functionDefaults
      { G.name = AST.Name "putchar"
      , G.returnType = T.i32
      , G.parameters = ([G.Parameter T.i32 (AST.Name "c") []], False)
      , G.basicBlocks = []
      }

    getcharDef = AST.GlobalDefinition $ G.functionDefaults
      { G.name = AST.Name "getchar"
      , G.returnType = T.i32
      , G.parameters = ([], False)
      , G.basicBlocks = []
      }

    printfDef = AST.GlobalDefinition $ G.functionDefaults
      { G.name = AST.Name "printf"
      , G.returnType = T.i32
      , G.parameters = ([G.Parameter (T.ptr T.i8) (AST.Name "fmt") []], True)
      , G.basicBlocks = []
      }

    scanfDef = AST.GlobalDefinition $ G.functionDefaults
      { G.name = AST.Name "scanf"
      , G.returnType = T.i32
      , G.parameters = ([G.Parameter (T.ptr T.i8) (AST.Name "fmt") []], True)
      , G.basicBlocks = []
      }

-- | Generate LLVM IR for Whitespace program
codegenWS :: WS -> AST.Operand -> AST.Operand -> AST.Operand -> Codegen ()
codegenWS (WSGrammar stms) stack sp heap = mapM_ (codegenStm stack sp heap) stms

-- Stack helpers
pushStack :: AST.Operand -> AST.Operand -> AST.Operand -> Codegen ()
pushStack stack sp value = do
  idx <- load sp
  zero <- iconst 0
  cellPtr <- gep stack [zero, idx]
  store cellPtr value
  one <- iconst 1
  idx' <- add idx one
  store sp idx'

popStack :: AST.Operand -> AST.Operand -> Codegen AST.Operand
popStack stack sp = do
  idx <- load sp
  one <- iconst 1
  idx' <- sub idx one
  store sp idx'
  zero <- iconst 0
  cellPtr <- gep stack [zero, idx']
  load64 cellPtr

peekStack :: AST.Operand -> AST.Operand -> Codegen AST.Operand
peekStack stack sp = do
  idx <- load sp
  one <- iconst 1
  idx' <- sub idx one
  zero <- iconst 0
  cellPtr <- gep stack [zero, idx']
  load64 cellPtr

codegenStm :: AST.Operand -> AST.Operand -> AST.Operand -> Stm -> Codegen ()
codegenStm stack sp heap stm = case stm of
  SPush -> do
    -- Push 0 (simplified - real WS would parse number)
    zero64 <- iconst64 0
    pushStack stack sp zero64

  SDup -> do
    val <- peekStack stack sp
    pushStack stack sp val

  SDiscard -> do
    _ <- popStack stack sp
    return ()

  SAdd -> do
    b <- popStack stack sp
    a <- popStack stack sp
    result <- add a b
    pushStack stack sp result

  SSub -> do
    b <- popStack stack sp
    a <- popStack stack sp
    result <- sub a b
    pushStack stack sp result

  SMul -> do
    b <- popStack stack sp
    a <- popStack stack sp
    result <- mul a b
    pushStack stack sp result

  SDiv -> do
    b <- popStack stack sp
    a <- popStack stack sp
    result <- sdiv a b
    pushStack stack sp result

  SMod -> do
    b <- popStack stack sp
    a <- popStack stack sp
    result <- srem a b
    pushStack stack sp result

  SStore -> do
    value <- popStack stack sp
    addr <- popStack stack sp
    zero <- iconst 0
    addr32 <- trunc64to32 addr
    cellPtr <- gep heap [zero, addr32]
    store cellPtr value

  SRetrieve -> do
    addr <- popStack stack sp
    zero <- iconst 0
    addr32 <- trunc64to32 addr
    cellPtr <- gep heap [zero, addr32]
    value <- load64 cellPtr
    pushStack stack sp value

  SLabel (Ident name) -> do
    labelBlock <- addBlock ("label_" ++ name)
    br labelBlock
    setBlock labelBlock

  SCall (Ident name) -> do
    -- Simplified - would need proper call stack
    return ()

  SJump (Ident name) -> do
    labelBlock <- getOrCreateLabel name
    br labelBlock

  SJZ (Ident name) -> mdo
    val <- popStack stack sp
    zero64 <- iconst64 0
    cond <- icmp64 IP.EQ val zero64
    
    labelBlock <- getOrCreateLabel name
    nextBlock <- addBlock "next"
    
    condBr cond labelBlock nextBlock
    setBlock nextBlock

  SJN (Ident name) -> mdo
    val <- popStack stack sp
    zero64 <- iconst64 0
    cond <- icmp64 IP.SLT val zero64
    
    labelBlock <- getOrCreateLabel name
    nextBlock <- addBlock "next"
    
    condBr cond labelBlock nextBlock
    setBlock nextBlock

  SRet -> do
    -- Would pop return address from call stack
    return ()

  SEnd -> do
    ret (iconst 0)

  SOutChar -> do
    val <- popStack stack sp
    val32 <- trunc64to32 val
    call (externf "putchar" (T.FunctionType T.i32 [T.i32] False)) [val32]
    return ()

  SOutNum -> do
    val <- popStack stack sp
    -- printf("%ld", val)
    fmtStr <- globalStringPtr "%ld"
    call (externf "printf" (T.FunctionType T.i32 [T.ptr T.i8] True)) [fmtStr, val]
    return ()

  SReadChar -> do
    val <- call (externf "getchar" (T.FunctionType T.i32 [] False)) []
    val64 <- sext32to64 val
    addr <- popStack stack sp
    zero <- iconst 0
    addr32 <- trunc64to32 addr
    cellPtr <- gep heap [zero, addr32]
    store cellPtr val64

  SReadNum -> do
    -- scanf("%ld", &heap[addr])
    addr <- popStack stack sp
    zero <- iconst 0
    addr32 <- trunc64to32 addr
    cellPtr <- gep heap [zero, addr32]
    fmtStr <- globalStringPtr "%ld"
    call (externf "scanf" (T.FunctionType T.i32 [T.ptr T.i8] True)) [fmtStr, cellPtr]
    return ()

-- Label management
getOrCreateLabel :: String -> Codegen AST.Name
getOrCreateLabel name = do
  lbls <- gets labels
  case Map.lookup name lbls of
    Just lbl -> return lbl
    Nothing -> do
      lbl <- addBlock ("label_" ++ name)
      modify $ \s -> s { labels = Map.insert name lbl (labels s) }
      return lbl

-- Codegen monad helpers
emptyCodegen :: CodegenState
emptyCodegen = CodegenState (AST.Name "entry") [] 1 0 [] Map.empty

execCodegen :: Codegen a -> CodegenState
execCodegen m = execState m emptyCodegen

freshName :: Codegen Word
freshName = do
  i <- gets count
  modify $ \s -> s { count = i + 1 }
  return i

fresh :: Codegen AST.Name
fresh = AST.UnName <$> freshName

addBlock :: String -> Codegen AST.Name
addBlock bname = do
  bls <- gets blocks
  ix <- gets blockCount
  let new = BasicBlock
        { blockName = AST.Name (BS.pack bname)
        , blockStack = []
        , blockTerm = Nothing
        }
  modify $ \s -> s { blocks = bls ++ [new], blockCount = ix + 1 }
  return (AST.Name (BS.pack bname))

setBlock :: AST.Name -> Codegen ()
setBlock bname = modify $ \s -> s { currentBlock = bname }

modifyBlock :: (BasicBlock -> BasicBlock) -> Codegen ()
modifyBlock f = do
  active <- gets currentBlock
  modify $ \s -> s { blocks = map update (blocks s) }
  where
    update block
      | blockName block == active = f block
      | otherwise = block

instr :: T.Type -> AST.Instruction -> Codegen AST.Operand
instr ty ins = do
  n <- fresh
  let ref = AST.LocalReference ty n
  modifyBlock $ \b -> b { blockStack = blockStack b ++ [n := ins] }
  return ref

terminator :: Named AST.Terminator -> Codegen ()
terminator term = modifyBlock $ \b -> b { blockTerm = Just term }

createBlocks :: CodegenState -> [AST.BasicBlock]
createBlocks s = map makeBlock (blocks s)
  where
    makeBlock (BasicBlock nm stk term) = AST.BasicBlock nm stk (makeTerm term)
    makeTerm (Just x) = x
    makeTerm Nothing = error "Block has no terminator"

-- LLVM instructions
alloca :: T.Type -> Codegen AST.Operand
alloca ty = instr (T.ptr ty) $ AST.Alloca ty Nothing 0 []

store :: AST.Operand -> AST.Operand -> Codegen ()
store ptr val = do
  instr T.VoidType $ AST.Store False ptr val Nothing 0 []
  return ()

load :: AST.Operand -> Codegen AST.Operand
load ptr = instr T.i32 $ AST.Load False ptr Nothing 0 []

load64 :: AST.Operand -> Codegen AST.Operand
load64 ptr = instr T.i64 $ AST.Load False ptr Nothing 0 []

gep :: AST.Operand -> [AST.Operand] -> Codegen AST.Operand
gep addr indices = instr (T.ptr T.i64) $ AST.GetElementPtr False addr indices []

add :: AST.Operand -> AST.Operand -> Codegen AST.Operand
add a b = instr T.i64 $ AST.Add False False a b []

sub :: AST.Operand -> AST.Operand -> Codegen AST.Operand
sub a b = instr T.i64 $ AST.Sub False False a b []

mul :: AST.Operand -> AST.Operand -> Codegen AST.Operand
mul a b = instr T.i64 $ AST.Mul False False a b []

sdiv :: AST.Operand -> AST.Operand -> Codegen AST.Operand
sdiv a b = instr T.i64 $ AST.SDiv False a b []

srem :: AST.Operand -> AST.Operand -> Codegen AST.Operand
srem a b = instr T.i64 $ AST.SRem a b []

icmp64 :: IP.IntegerPredicate -> AST.Operand -> AST.Operand -> Codegen AST.Operand
icmp64 pred a b = instr T.i1 $ AST.ICmp pred a b []

trunc64to32 :: AST.Operand -> Codegen AST.Operand
trunc64to32 val = instr T.i32 $ AST.Trunc val T.i32 []

sext32to64 :: AST.Operand -> Codegen AST.Operand
sext32to64 val = instr T.i64 $ AST.SExt val T.i64 []

call :: AST.Operand -> [AST.Operand] -> Codegen AST.Operand
call fn args = instr T.i32 $ AST.Call Nothing CC.C [] (Right fn) (map (\x -> (x, [])) args) [] []

ret :: AST.Operand -> Codegen ()
ret val = terminator $ AST.Do $ AST.Ret (Just val) []

br :: AST.Name -> Codegen ()
br target = terminator $ AST.Do $ AST.Br target []

condBr :: AST.Operand -> AST.Name -> AST.Name -> Codegen ()
condBr cond tr fl = terminator $ AST.Do $ AST.CondBr cond tr fl []

-- Constants
iconst :: Integer -> Codegen AST.Operand
iconst n = return $ AST.ConstantOperand $ C.Int 32 n

iconst64 :: Integer -> Codegen AST.Operand
iconst64 n = return $ AST.ConstantOperand $ C.Int 64 n

iconst8 :: Integer -> Codegen AST.Operand
iconst8 n = return $ AST.ConstantOperand $ C.Int 8 n

iconst1 :: Integer -> Codegen AST.Operand
iconst1 n = return $ AST.ConstantOperand $ C.Int 1 n

externf :: String -> T.Type -> AST.Operand
externf name ty = AST.ConstantOperand $ C.GlobalReference ty (AST.Name (BS.pack name))

globalStringPtr :: String -> Codegen AST.Operand
globalStringPtr str = return $ AST.ConstantOperand $ 
  C.GetElementPtr False
    (C.GlobalReference (T.ptr (T.ArrayType (fromIntegral $ length str + 1) T.i8)) 
      (AST.Name (BS.pack (".str." ++ str))))
    [C.Int 32 0, C.Int 32 0]
