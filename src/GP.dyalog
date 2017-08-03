:Namespace GP
    ⍝ Chromosome ←→ matrix defining the function train for a solution
    ⍝               [;1] ←→ depth, [;2] ←→ function

      ⍝ GLOBALS
    :Namespace SELECT
        TOURNAMENT←0
        PROBABILISTIC←1
    :EndNamespace
    :Namespace MUTATE
        NODE←0
        BRANCH←1
    :EndNamespace
    MUTATION_RATE←50    ⍝ percent probability of mutation
    MUTATION_TYPE←MUTATE.NODE
    SELECT_TYPE←SELECT.TOURNAMENT

      DefineFunctionSpace←{
          fns←'+-×÷*⍟⌹○!?|⌈⌊⊥⊤⊣⊢=≠≤<>≥≡≢∨∧⍲⍱↑↓⊂⊃⊆⌷⍋⍒⍳⍸∊⍷∪∩~/\⌿⍀,⍪⍴⌽⊖⍉'
          ops←'¨⍨/⌿\⍀'
          ,fns∘.,(8/⊂''),ops
      }

      GeneratePopulation←{
        ⍝ ⍺ ←→ function space (vector)
        ⍝ ⍵ ←→ population size
        ⍝ ← ←→ population (vector of chromosomes)
          s←⍵
          ⍺{⍵(∪,)⊂⍺ RandomChromo 0}⍣{s=≢⍺}''
      }

      RandomChromo←{
        ⍝ ⍵ ←→ depth
        ⍝ ⍺ ←→ function space
        ⍝ ← ←→ chromosome
          fn←PickOne ⍺
          n←?100
          d←⍵+1
          n≤60+d*2:⍉⍪⍵ fn       ⍝ leaf node
          n>95:⍵ fn⍪(⍺ ∇ d)     ⍝ atop
          ⍵ fn⍪(⍺ ∇ d)⍪(⍺ ∇ d)  ⍝ train
      }

      RenderChromo←{
        ⍝ ⍵ ←→ genom
        ⍝ ← ←→ train def
          d g←1⌷⍵
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

      Run←{
        ⍝ ⍺⍺ ←→ fitness test
        ⍝ ⍺  ←→ function space
        ⍝ ⍵  ←→ max generations
        ⍝ ←  ←→ solution
          pop0←⍺ GeneratePopulation 1000
          ft←⍺⍺
          max←⍵
          cnt←0
          ⍺{
              cnt+←1
              fit←ft Fitness ⍵
              best_genoms←⍵/⍨fit=best_fit←⌈/fit
              best_solution←RenderChromo PickShortest best_genoms
              ⎕←cnt best_fit best_solution
              100=best_fit:best_solution
              max=cnt:best_solution{
                  ↑⍵ ⍺
              }'No result found in',max,'generations. Best fit: ',⌈/fit
              ⍺ ∇ ⍺ NextGeneration ⍵ fit
          }pop0
      }

      NextGeneration←{
        ⍝ ⍵ ←→ (population)(fitness values)
        ⍝ ⍺ ←→ function space
          s←≢⊃p fit←⍵
          ⍺{
              new←⍺∘Mutate¨CrossOverLevel fit Select p
              ⍵,new
          }⍣{s=≢⍺}''
      }

      Mutate←{
        ⍝ ⍺ ←→ function space
        ⍝ ⍵ ←→ chromosome
          ⍺{
              MUTATION_TYPE=MUTATE.NODE:⍺ MutateNode ⍵
              MUTATION_TYPE=MUTATE.BRANCH:⍺ MutateBranch ⍵
          }⍣(MUTATION_RATE≥?100)⊢⍵
      }

    MutateNode←{(⊂PickOne ⍺)@(⊂(?≢⍵),2)⊢⍵}
      MutateBranch←{
          f m l←(?≢⍵)SplitByNode ⍵
          d←⊃m
          n←⍺ RandomChromo d
          f⍪n⍪l
      }

    CrossOverAny←{(?≢¨⍵)CrossOver ⍵}

      CrossOverLevel←{
        ⍝ ⍵ ←→  pair of chromosomes
          d1 d2←⊣/¨⍵
          ~∨/cmn←(0<d1)∧d1∊d2:⍵
          i1←PickOne⍸cmn
          i2←PickOne⍸d2∊i1⊃d1
          i1 i2 CrossOver ⍵
      }

      CrossOver←{
        ⍝ ⍺ ←→ pair of indexes for cross over
        ⍝ ⍵ ←→ pair of chromosomes
          (f1 m1 l1)(f2 m2 l2)←⍺ SplitByNode¨⍵
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
          SELECT_TYPE=SELECT.TOURNAMENT:⍺ SelectTournament ⍵
          SELECT_TYPE=SELECT.PROBABILISTIC:⍺ SelectProbabilistic ⍵
      }

      SelectProbabilistic←{
        ⍝ ⍺ ←→ fitness value
        ⍝ ⍵ ←→ population
          ⍵⌷⍨⊂{⊃¨⍸¨⍵∘≥¨2?⊃⌽⍵}+\⍺
      }

      SelectTournament←{
        ⍝ ⍺ ←→ fitness value
        ⍝ ⍵ ←→ population
          f←(⊂i←(⌊0.1×≢⍺)?≢⍺)⌷⍺
          (⊂(⊂2↑⍒f)⌷i)⌷⍵
      }


    Fitness←{⍺⍺¨RenderChromo¨⍵}

    mse←+.*∘2÷≢

    :Section SampleTests

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

    :EndSection ⍝ SampleTests

:EndNamespace
