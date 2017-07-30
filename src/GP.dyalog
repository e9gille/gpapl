:Namespace GP

      DefineDomains←{
          d←(⊃⎕RSI).⎕NS''
          d.fn←'⊢⊣+-×÷'
          d.op←'¨/\⍨'
          d.fns←≢d.fn
          d.ops←≢d.op
          d
      }    
      
      Gen1←{
        ⍝ ⍺ ←→ domain space
        ⍝ ⍵ ←→ population size
        ⍝ ← ←→ dna population
        ⍺ RandomGenom¨⍵↑0
      }

      RandomGenom←{
        ⍝ ⍺ ←→ domain space
        ⍝ ⍵ ←→ 0
        ⍝ ← ←→ dna
          atop←⍺ GetFn 0
          train←⍺ RandomNode 0
          atop train
      }

      RandomNode←{
        ⍝ ⍺ ←→ domain space
        ⍝ ⍵ ←→ 0
          leaf←1≠?10
          fn←⍺ GetFn 0
          leaf:fn
          (⍺ ∇ 0)fn(⍺ ∇ 0)
      }

      GetFn←{
        ⍝ ⍺ ←→ domain space
        ⍝ ⍵ ←→ 0
        ⍝ ← ←→ single fn [operator]
          fn←(?⍺.fns)⊃⍺.fn
          1≠?10:,fn
          fn,(?⍺.ops)⊃⍺.op
      }

      RenderGenom←{
        ⍝ ⍺ ←→ domain space
        ⍝ ⍵ ←→ genom
        ⍝ ← ←→ train def
          1=≢⍵:⊃⍵
          2=≢⍵:(⊃⍵),⍺ ∇ 2⊃⍵ 
          f g h←⍺ ∇¨⍵
          1=≡⊃⍵:f,g,h
          '(',f,')',g,h
      }

:EndNamespace
