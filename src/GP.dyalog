:Namespace GP

      DefineFns←{
          fns←'⊢⊣+-×÷⊆⊂⊃∩∪⊥⊤|↓↑≡≢⍳⍸?∊⍷~↓○*⌈⌊<≤=≠≥>⍟∨⍱∧⍲!⍒⍋,⍪⍴⌽⊖⍉'
          ops←'¨⍨/⌿\⍀'
          ,fns∘.,(8/⊂''),ops
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
          n>3:⍉⍪⍺ fn 1              ⍝ leaf node (7/10)
          n=1:⍺ fn 0⍪(d ∇ ⍵)        ⍝ atop      (1/10)
          ⍺ fn 1⍪(d ∇ ⍵)⍪(d ∇ ⍵)    ⍝ train     (2/10)
      }

      RenderGenom←{
        ⍝ ⍵ ←→ genom
        ⍝ ← ←→ train def
          d g t←1⌷⍵
          1=≢⍵:g            ⍝ leaf node
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
          0::0
          f←⍎⍵
          res←0 0 1 1 f¨0 1 0 1
          ~mdt←3=10|⎕DR res:0
          ~∧/scalar←0=≡¨res:0
          ⌊100×1-mse 0 1 1 2-res
      }

      TestPartition←{
          0::1
          f←⍎⍵
          r←','f'ab,bar'
          'ab' 'bar'≡r:100
          ~dt←0=10|⎕DR↑r:1
          shp←(,2)≡⍴r
          rk←(,1)≡⍴⍴r
          dpth←2=≡r
          tnl←∧/'ab' 'bar'∊r
          20 15 15 15 20(+/×)dt rk dpth shp tnl
      }

      TestPartitionWE←{
          f←⍎⍵
          0::0
          100×'ab' '' 'cd' ''≡','f'ab,,cd,'
      }

      TestDTB←{
          f←⍎⍵
          0::0
          r←' 'f'ab bar    '
          'ab bar'≡r:100
          ~mdt←0=10|⎕DR r:0
          rk←(,1)≡⍴⍴r
          tnl←∧/'ab' 'bar'(1∊⍷)¨⊂r
          30(+/×)mdt rk tnl
      }

      Run←{
        ⍝ ⍺⍺ ←→ fitness test
        ⍝ ⍵  ←→ function blocks (matrix)
        ⍝ ←  ←→ solution
          pop0←⍵ GeneratePopulation 2000
          ft←⍺⍺
          max←1000
          cnt←0
          ⍵{
              cnt+←1
              fit←ft Fitness ⍵
              best_genoms←⍵/⍨fit=best_fit←⌈/fit
              best_solution←RenderGenom PickShortest best_genoms
              ⎕←cnt best_fit best_solution
              100=best_fit:best_solution
              max=cnt:best_solution{
                  ↑⍵ ⍺
              }'No result found in',max,'generations. Best fit: ',⌈/fit
              ⍺ ∇ ⍺(fit NextGeneration)⍵
          }pop0
      }

      NextGeneration←{
          s←≢⍵
          p fit←(40>≢¨⍵)∘/¨⍵ ⍺⍺
          ⍺{
              new←⍺∘Mutate¨CrossOver fit Select p
              ⍵,new
          }⍣{s=≢⍺}''
      }

      Mutate←{
          ⍺{
              (⊂PickOne ⍺)@(⊂2,⍨?≢⍵)⊢⍵
          }⍣(50≥?100)⊢⍵
      }

      CrossOver←{
          i1 i2←?≢¨p1 p2←⍵
⍝          d1 d2←⊣/¨p1 p2←⍵
⍝          ~∨/cmn←(0<d1)∧d1∊d2:⍵
⍝          i1←PickOne⍸cmn
⍝          i2←PickOne⍸d2∊i1⊃d1
          (f1 m1 l1)(f2 m2 l2)←i1 i2 SplitByNode¨p1 p2
          d1 d2←⊃¨m1 m2
          m1[;1]+←d2-d1
          m2[;1]+←d1-d2
          (f1⍪m2⍪l1)(f2⍪m1⍪l2)
      }

      SplitByNode←{
          d←⊣/m←¯1⍪⍵⍪¯1
          i←⍺+1
          p←1,2</2⌊+\(d≤i⊃d)∧(i≤⍳≢m)
          1 0 ¯1↓¨p⊂[1]m
      }

      Select←{
          f←(⊂i←100?≢⍺)⌷⍺
          p←⊂{⊃¨⍸¨⍵∘≥¨2?⊃⌽⍵}+\f
          (⊂p⌷i)⌷⍵
      }

    Fitness←{⍺⍺¨RenderGenom¨⍵}

    mse←+.*∘2÷≢

:EndNamespace
