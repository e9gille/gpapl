:Namespace GP
    ⍝ Chromosome ←→ matrix defining the function train for a solution
    ⍝               [;1] ←→ depth, [;2] ←→ function

      ⍝ GLOBALS
    ⎕RL←⍬ 2
    SELECT_TOURNAMENT←0
    SELECT_PROBABILISTIC←1
    CROSSOVER_LEVEL←0
    CROSSOVER_ANY←1
    MUTATE_NODE←0
    MUTATE_BRANCH←1

      DefaultSettings←{
          s←⎕NS''
          s.CrossOverType←CROSSOVER_LEVEL
          s.FunctionSpace←DefineFunctionSpace ⍬
          s.MaxGenerations←1000
          s.MutationRate←1          ⍝ % probability of mutation
          s.MutationType←MUTATE_NODE
          s.PopulationSize←1000
          s.SelectionType←SELECT_TOURNAMENT
          s
      }

      DefineFunctionSpace←{
          fns←'+-×÷*⍟⌹○!?|⌈⌊⊥⊤⊣⊢=≠≤<>≥≡≢∨∧⍲⍱↑↓⊂⊃⊆⌷⍋⍒⍳⍸∊⍷∪∩~,⍪⍴⌽⊖⍉'
          ops←'¨⍨/⌿\⍀'
          spec←('('∘,,∘')')¨,∘.,⍨'/⌿\⍀'
          spec,,fns∘.,(8/⊂''),ops
      }

      GeneratePopulation←{
        ⍝ ⍺ ←→ function space (vector)
        ⍝ ⍵ ←→ population size
        ⍝ ← ←→ population (vector of chromosomes)
          s←⍵
          ⍺{⍵(∪,)⊂⍺ RandomChromo 0}⍣{s=≢⍺}''
      }

      Init←{
        ⍝ ⍵ ←→ settings
        ⍝ ⍺ ←→ fitness test function (source)
          ⎕THIS.FunctionSpace←⍵.FunctionSpace
          rc←⎕FX ⍺
          ⎕FX GenerateNextGenFn ⍵
      }

      RandomChromo←{
        ⍝ ⍵ ←→ depth
        ⍝ ⍺ ←→ function space
        ⍝ ← ←→ chromosome
          fn←PickOne ⍺
          n←?100
          d←⍵+1
          n≤40+d*2:⍉⍪⍵ fn       ⍝ leaf node
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
        ⍝ ⍵  ←→ settings
        ⍝ ←  ←→ solution
          s←DefaultSettings⍣(0∊⍴⍵)⊢⍵
          ft←⍺⍺
          rc←(⎕NR'ft')Init s
          rc≢'NextGeneration':'Failed fixing evolution function, rc: ',rc
          sz←s.PopulationSize
          pop0←s.FunctionSpace GeneratePopulation sz
          fit0←ft Fitness pop0
          max←s.MaxGenerations
          cnt pop fit←{
              cnt pop fit←⍵
              next_pop←FunctionSpace NextGeneration sz pop fit
              next_fit←ft Fitness next_pop
              (cnt+1)next_pop next_fit
          }⍣{(s.MaxGenerations=⊃⍺)∨(100=⌈/3⊃⍺)}0 pop0 fit0
          best_genoms←pop/⍨fit=best_fit←⌈/fit
          best_solution←RenderChromo PickShortest best_genoms
          cnt best_fit best_solution
      }

      RunII←{
        ⍝ ⍺⍺ ←→ fitness test
        ⍝ ⍺  ←→ isolates
        ⍝ ⍵  ←→ settings
        ⍝ ←  ←→ solution
          s←DefaultSettings⍣(0∊⍴⍵)⊢⍵
          ft←⍺⍺
          iss←⍺
          rc←iss.{≢#.⎕FIX ⍵}⊂⎕SRC ⎕THIS
          rc←(⊂⎕NR'ft')iss.{⍺ #.GP.Init ⍵}s
          ∨/~rc∊⊂'NextGeneration':'Failed fixing evolution function, rc: ',rc
          sz←⌈s.PopulationSize÷≢iss
          pop0 fit0←,⌿↑iss.{{⍵ #.GP.(ft Fitness ⍵)}#.GP.FunctionSpace #.GP.GeneratePopulation ⍵}sz
          cnt pop fit←{
              cnt pop fit←⍵
              next_pop next_fit←,⌿↑iss.{{⍵ #.GP.(ft Fitness ⍵)}#.GP.FunctionSpace #.GP.NextGeneration ⍵}⊂sz pop fit
              (cnt+1)next_pop next_fit
          }⍣{(s.MaxGenerations=⊃⍺)∨(100=⌈/3⊃⍺)}0 pop0 fit0
          best_genoms←pop/⍨fit=best_fit←⌈/fit
          best_solution←RenderChromo PickShortest best_genoms
          cnt best_fit best_solution
      }

      GenerateNextGenFn←{
          m←(MUTATE_NODE MUTATE_BRANCH⍳⍵.MutationType)⊃'MutateNode' 'MutateBranch'
          m,←'⍣(',(⍕⍵.MutationRate),'≥?100)'
          co←(CROSSOVER_LEVEL CROSSOVER_ANY⍳⍵.CrossOverType)⊃'CrossOverLevel' 'CrossOverAny'
          s←(SELECT_TOURNAMENT SELECT_PROBABILISTIC⍳⍵.SelectionType)⊃'SelectTournament' 'SelectProbabilistic'
     
          ∆←,⊂'NextGeneration←{'
          ∆,←⊂'  ⍝ ⍵ ←→ (size)(population)(fitness values)'
          ∆,←⊂'  ⍝ ⍺ ←→ function space'
          ∆,←⊂'    s p f←⍵'
          ∆,←⊂'    ⍺{'
          ∆,←⊂'        new←⍺∘',m,'¨',co,' f ',s,' p'
          ∆,←⊂'        ⍵,new'
          ∆,←⊂'    }⍣{s=≢⍺}⍬'
          ∆,←⊂,'}'
          ∆
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
          f←(⊂i←(10⌈⌊0.01×≢⍺)?≢⍺)⌷⍺
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
          0::1
          f←⍎⍵
          r←','f'ab,,cd,'
          ~dt←0=10|⎕DR↑r:1
          shp←(,2)≡⍴r
          rk←(,1)≡⍴⍴r
          dpth←2=≡r
          t1←'ab' '' 'cd' ''≡r
          t2←'ab' 'bar,'≡',,'f'ab,,bar,'
          2 2 2 2 46 46(+/×)dt rk dpth shp t1 t2
     
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
