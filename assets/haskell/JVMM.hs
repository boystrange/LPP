
type Value = Int
type Var   = Int
type Stack = [Value]
type Frame = [Value]

load :: Var -> Frame -> Value
load _ [] = 0
load 0 (v : _) = v
load n (_ : vs) = load (n - 1) vs

store :: Var -> Value -> Frame -> Frame
store 0 v []       = [v]
store 0 v (_ : vs) = v : vs
store n v []       = 0 : store (n - 1) v []
store n v (w : vs) = w : store (n - 1) v vs

type Code = [Instruction]

data Instruction
  = PUSH Value
  | LOAD Var
  | STORE Var
  | OP (Value -> Value -> Value)
  | IF (Value -> Value -> Bool) Code
  | RETURN
  -- ESTENSIONI
  | DUP
  | SWAP
  | POP
  | NOP
  | UOP (Value -> Value)

run :: Code -> Frame -> Value
run = aux []
  where
    aux :: Stack -> Code -> Frame -> Value
    aux (v : [])     (RETURN : _)  _   = v
    aux vs           (PUSH v : is)  fr = aux (v : vs) is fr
    aux vs           (LOAD x : is)  fr = aux (load x fr : vs) is fr
    aux (v : vs)     (STORE x : is) fr = aux vs is (store x v fr)
    aux (w : v : vs) (OP f : is)    fr = aux (f v w : vs) is fr
    aux (w : v : vs) (IF p is : _)  fr | p v w = aux vs is fr
    aux (_ : _ : vs) (IF _ _ : is)  fr = aux vs is fr
    -- ESTENSIONI
    aux (v : vs)     (DUP : is)     fr = aux (v : v : vs) is fr
    aux (w : v : vs) (SWAP : is)    fr = aux (v : w : vs) is fr
    aux (_ : vs)     (POP : is)     fr = aux vs is fr
    aux vs           (NOP : is)     fr = aux vs is fr
    aux (v : vs)     (UOP f : is)   fr = aux (f v : vs) is fr

fattoriale :: Code
fattoriale = init
  where
    init = PUSH 1 :
           STORE res :
           loop
    loop = LOAD n :
           PUSH 0 :
           IF (==) fine :
           LOAD n :
           LOAD res :
           OP (*) :
           STORE res :
           LOAD n :
           PUSH 1 :
           OP (-) :
           STORE n :
           loop
    fine = LOAD res :
           RETURN : []
    n    = 0
    res  = 1

fibonacci :: Code
fibonacci = init
  where
    init = PUSH 0 :
           STORE m :
           PUSH 1 :
           STORE n :
           loop
    loop = LOAD k :
           PUSH 0 :
           IF (==) fine :
           LOAD n :
           LOAD n :
           LOAD m :
           OP (+) :
           STORE n :
           STORE m :
           LOAD k :
           PUSH 1 :
           OP (-) :
           STORE k :
           loop
    fine = LOAD m :
           RETURN : []
    k    = 0
    m    = 1
    n    = 2

euclide :: Code
euclide = loop
  where
    loop = LOAD m :
           PUSH 0 :
           IF (==) fine :
           LOAD m :
           LOAD n :
           IF (<) less :
           LOAD m :
           LOAD n :
           OP (-) :
           STORE m :
           loop
    less = LOAD m :
           LOAD n :
           STORE m :
           STORE n :
           loop
    fine = LOAD n :
           RETURN : []
    m    = 0
    n    = 1

test_dup :: Code
test_dup = [PUSH 3, DUP, OP (*), RETURN]

test_swap :: Code
test_swap = [PUSH 3, PUSH 6, SWAP, OP div, RETURN]

test_pop_nop :: Code
test_pop_nop = [PUSH 2, DUP, POP, NOP, NOP, RETURN]

test_neg :: Code
test_neg = [PUSH 2, UOP negate, RETURN]
