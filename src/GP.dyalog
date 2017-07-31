:Namespace GP

      DefineFns←{
          fns←'⊢⊣+-×÷⊆⊂≠'
          ops←'¨⍨'
          ,fns∘.,(⊂''),ops
      }

      GeneratePopulation←{
        ⍝ ⍺ ←→ functions
        ⍝ ⍵ ←→ population size
        ⍝ ← ←→ dna population
          s←⍵
          ⍺{⍵(∪,)⊂RandomGenom ⍺}⍣{s=≢⍺}''
      }

      RandomGenom←{
        ⍝ ⍵ ←→ functions
        ⍝ ← ←→ dna
          fn←PickOne ⍵
          n←?10
          n>2:fn            ⍝ leaf node (8/10)
          n=2:fn(∇ ⍵)       ⍝ atop      (1/10)
          (∇ ⍵)fn(∇ ⍵)      ⍝ train     (1/10)
      }

      RenderGenom←{
        ⍝ ⍵ ←→ genom
        ⍝ ← ←→ train def
          1=≡⍵:⍵
          2=≢⍵:(⊃⍵),∇ 2⊃⍵
          f g h←∇¨⍵
          1=≡⊃⍵:f,g,h
          '(',f,')',g,h
      }

    PickOne←(?≢)⊃⊢
    PickShortest←(≢¨⍳(⌊/≢¨))⊃⊢  

    FitnessTest←{
        ⍝ ⍵  ←→ candidate functions
        ⍝ ⍺⍺  ←→ test function
        ⍝ ← ←→ fitness rating (0 is match)
        res←⍺⍺¨fns←RenderGenom¨⍵
        m←res=0
        ∨/m:PickShortest m/fns
        ∘∘∘
    }   
    
    TestSum←{
        f←⍎⍵
        0::1
        mse 0 1 1 2-0 0 1 1 f¨0 1 0 1
    }      
    
    TestPartition←{
        f←⍎⍵
        0::1 
       'ab' 'cd'≢ ','f'ab,cd'
    }      
    

    
    mse←+.*∘2÷≢

:EndNamespace
