:Namespace GP

      DefineFns←{
          fns←'⊢⊣+-×÷⊆⊂≠↓↑'
          ops←'¨⍨'
          ,fns∘.,(⊂''),ops
      }

      GeneratePopulation←{
        ⍝ ⍺ ←→ functions
        ⍝ ⍵ ←→ population size
        ⍝ ← ←→ dna population
          s←⍵
          ⍺{⍵(∪,)⊂0 RandomGenom ⍺}⍣{s=≢⍺}''
      }

      RandomGenom←{
        ⍝ ⍺ ←→ depth
        ⍝ ⍵ ←→ functions
        ⍝ ← ←→ dna
          fn←PickOne ⍵
          n←?10
          d←⍺+1
          n>6:⍉⍪⍺ fn 1              ⍝ leaf node (8/10)
          n>3:⍺ fn 0⍪(d ∇ ⍵)        ⍝ atop      (1/10)
          ⍺ fn 1⍪(d ∇ ⍵)⍪(d ∇ ⍵)    ⍝ train     (1/10)
      }

      RenderGenom←{
        ⍝ ⍵ ←→ genom
        ⍝ ← ←→ train def
          d g t←1⌷⍵
          1=≢⍵:g            ⍝ leaf node
⍝          0=t:g,∇ 1↓⍵       ⍝ atop
          s←((d+1)=⊣/⍵)⊂[1]⍵
          (1=≢s)∧1=≢⊃s:g,∇ 1↓⍵
          1=≢s:g,'(',(∇ 1↓⍵),')'
          f h←∇¨s
          1=≢⊃s:f,g,h
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
          'ab' 'cd'≢','f'ab,cd'
      }



    mse←+.*∘2÷≢

:EndNamespace
