:Namespace GP
    ⍝ Chromosome ←→ matrix defining the function train for a solution
    ⍝               [;1] ←→ depth, [;2] ←→ function

   ⍝ GLOBALS
    ⎕RL←⍬ 2
    SELECT_TOURNAMENT       ←'tournament'
    SELECT_PROBABILISTIC    ←'probabilistic'
    CROSSOVER_LEVEL         ←'level'
    CROSSOVER_ANY           ←'any'
    MUTATE_NODE             ←'node'
    MUTATE_BRANCH           ←'branch'

      DefaultSettings←{
          s←⎕NS''
          s.CrossOverType←CROSSOVER_LEVEL
          s.FunctionSet←DefineFunctionSet ⍬
          s.LogToSession←1
          s.MaxGenerations←1000
          s.MutationRate←.01          ⍝ % probability of mutation
          s.MutationType←MUTATE_NODE
          s.PopulationSize←1000
          s.SelectionType←SELECT_TOURNAMENT
          s.SurvivalRate←.01
          s.TerminalSet←'?10' '?0'
          s.TerminateOnFound←1
          s.TournamentSize←10
          s
      }

      DefineFunctionSet←{
          fns←'+-×÷*⍟⌹○!?|⌈⌊⊥⊤⊣⊢=≠≤<>≥≡≢∨∧⍲⍱↑↓⊂⊃⊆⌷⍋⍒⍳⍸∊⍷∪∩~,⍪⍴⌽⊖⍉'
          ops←'¨⍨/⌿\⍀'
          spec←('('∘,,∘')')¨,'/⌿\⍀'∘.,'/⌿\⍀⍨'
          '(≢⊢)' '(≢⊣)',spec,,fns∘.,ops,⊂''
      }

      GeneratePopulation←{
        ⍝ ⍵ ←→ population size
        ⍝ ← ←→ population (vector of chromosomes)
          s←⍵
          {⍵(∪,)⊂RandomChromo 0}⍣{s=≢⍺}''
      }

      Init←{
        ⍝ ⍵ ←→ settings
        ⍝ ⍺ ←→ fitness test function (source)
          ⎕THIS.FunctionSet←⍵.FunctionSet
          ⎕THIS.TerminalSet←⍵.TerminalSet
          rc←⍵.⎕FX ⍺
          _←⍎'TargetTest←⍵.',rc
          ⎕FX GenerateNextGenFn ⍵
      }

      InitIsolates←{
          _←{0::0 ⋄ r←#.⎕CY ⍵}⍣(0=⊃#.⎕NC'isolate')⊢'isolate'
          #.isolate.New¨(#.isolate.Config'processors')⍴⊂''
      }

      PopulationAndFitness←{
        ⍝ ⍺⍺ ←→ function to generate population
        ⍝ ⍵  ←→ parameters for generator
          pop←⍺⍺ ⍵
          fit←TargetTest CheckFitness pop
          pop fit
      }

      RandomChromo←{
        ⍝ ⍵ ←→ depth
        ⍝ ← ←→ chromosome
          fn←PickOne FunctionSet
          term atop←3 10(0=|)n←?100
          d←⍵+1
          n≤30+d*2:⍉⍪⍵ fn           ⍝ leaf node (f)
          atop:⍵ fn⍪(∇ d)           ⍝ atop      (fg)
          ⍝ A train   (Agh)
          (0<≢TerminalSet)∧term:⍵ fn⍪d(⍕⍎PickOne TerminalSet)⍪(∇ d)
          ⍵ fn⍪(∇ d)⍪(∇ d)          ⍝ F train   (fgh)
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

      Log←{
          ⍺.HallOfFame⍪←l←FindLeader ⍵
⍝          ⍺.Settings.LogToSession:⍺⊣⎕←RenderResult l
⍝          ⍺
          ⍺.Settings.LogToSession=1:⍺⊣⎕←RenderResult l
          ⍺⊣⍞←(⎕PW⍴⎕UCS 8),RenderResult l
      }


      ResultSpace←{
          r←⎕NS''
          r.Settings←r.⎕NS ⍵
          r.HallOfFame←⍉⍪'Generation' 'Fitness' 'Solution'
          r.BestSolutions←⍬
          r
      }

      Run←{
        ⍝ ⍺⍺ ←→ fitness test
        ⍝ ⍵  ←→ settings
        ⍝ ←  ←→ solution
          tt←⍺⍺
          s←DefaultSettings⍣(0∊⍴⍵)⊢⍵
          rc←(⎕NR'tt')Init s
          rc≢'NextGeneration':'Failed fixing evolution function, rc: ',rc
          sz←s.PopulationSize
          pop0 fit0←GeneratePopulation PopulationAndFitness sz
          r←ResultSpace s
          s.TerminateOnFound∧∨/100≤fit0:Summary r Log 1 pop0 fit0
          cnt pop fit←r{
              cnt pop fit←⍵
              _←⍺ Log cnt pop fit
              next_pop next_fit←NextGeneration PopulationAndFitness sz pop fit
              i←∪next_pop⍳next_pop
              (cnt+1)(next_pop[i])(next_fit[i])
              ⍝(cnt+1)next_pop next_fit
          }⍣{(s.MaxGenerations=⊃⍺)∨s.TerminateOnFound∧∨/100≤3⊃⍺}1 pop0 fit0
          Summary r Log cnt pop fit
      }

      RunII←{
        ⍝ ⍺⍺ ←→ fitness test
        ⍝ ⍺  ←→ isolates
        ⍝ ⍵  ←→ settings
        ⍝ ←  ←→ solution
          tt←⍺⍺
          s←DefaultSettings⍣(0∊⍴⍵)⊢⍵
          iss←InitIsolates ⍬
          rc←iss.{≢#.⎕FIX ⍵}⊂⎕SRC ⎕THIS
          rc←(⊂⎕NR'tt')iss.{⍺ #.GP.Init ⍵}s
          ∨/~rc∊⊂'NextGeneration':'Failed fixing evolution function, rc: ',rc
          sz←⌈s.PopulationSize÷≢iss
          pop0 fit0←,⌿↑iss.{#.GP.(GeneratePopulation PopulationAndFitness ⍵)}sz
          r←ResultSpace s
          s.TerminateOnFound∧∨/100≤fit0:Summary r Log 1 pop0 fit0
          cnt pop fit←r{
              cnt pop fit←⍵
              _←⍺ Log cnt pop fit
              next_pop next_fit←,⌿↑iss.{#.GP.(NextGeneration PopulationAndFitness ⍵)}⊂sz pop fit
              i←∪next_pop⍳next_pop
              (cnt+1)(next_pop[i])(next_fit[i])
          }⍣{(s.MaxGenerations=⊃⍺)∨s.TerminateOnFound∧∨/100≤3⊃⍺}1 pop0 fit0
          Summary r Log cnt pop fit
      }

      FindLeader←{
          cnt pop fit←⍵
          best_genoms←pop/⍨fit=best_fit←⌈/fit
          best_solution←RenderChromo PickShortest best_genoms
          cnt best_fit best_solution
      }

      RenderResult←{
          cnt fit sol←⍵
          (,'I11,I9'⎕FMT⍉⍪cnt fit),'  ',sol
      }

      Summary←{
          u←(⊢⍳∪)⍵.HallOfFame[;3]
          b←(⊢=⌈/)1↓⍵.HallOfFame[u;2]
          s←b\(⊢=⌊/)≢¨b/1↓⍵.HallOfFame[u;3]
          ⍵.BestSolutions←(1,s)⌿⍵.HallOfFame[u;]
          ⍵
      }

      GenerateNextGenFn←{
          m←('⍣(',(⍕⍵.MutationRate),'>?0)'){
              ⍵≡MUTATE_NODE:'MutateNode',⍺
              ⍵≡MUTATE_BRANCH:'MutateBranch',⍺
          }⍵.MutationType
          co←{
              ⍵≡CROSSOVER_LEVEL:'CrossOverLevel'
              ⍵≡CROSSOVER_ANY:'CrossOverAny'
          }⍵.CrossOverType
          s←(⍕⍵.TournamentSize){
              ⍵≡SELECT_TOURNAMENT:⍺,' SelectTournament'
              ⍵≡SELECT_PROBABILISTIC:' 2 SelectProbabilistic'
          }⍵.SelectionType
          sr←⍕⍵.SurvivalRate
     
          ∆←,⊂'NextGeneration←{'
          ∆,←⊂'  ⍝ ⍵ ←→ (size)(population)(fitness values)'
          ∆,←⊂'    s p f←⍵'
          ∆,←⊂'    next←(⌊s×',sr,') SelectProbabilistic p f'
          ∆,←⊂'    {'
          ∆,←⊂'        new←',m,'¨',co,' ',s,' p f'
          ∆,←⊂'        new/⍨←50>≢¨new'
          ∆,←⊂'        ⍵,new'
          ∆,←⊂'    }⍣{s≤≢⍺}next'
          ∆,←⊂,'}'
          ∆
      }

    MutateNode←{(⊂PickOne FunctionSet)@(⊂(?≢⍵),2)⊢⍵}
      MutateBranch←{
          f m l←(?≢⍵)SplitByNode ⍵
          d←⊃m
          n←RandomChromo d
          f⍪n⍪l
      }

    CrossOverAny←{0∊i←1-⍨≢¨⍵:⍵ ⋄ (?i)CrossOver ⍵}

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

      SelectProbabilistic←{
        ⍝ ⍵ ←→ (population)(fitness value)
          p f←⍵
          p⌷⍨⊂⍺{⊃¨⍸¨⍵∘≥¨⍺?⊃⌽⍵}+\f
      }

      SelectTournament←{
        ⍝ ⍺ ←→ tournament size
        ⍝ ⍵ ←→ (population)(fitness value)
          pop fit←⍵
          f←(⊂i←⍺(⌊?⊢)≢fit)⌷fit
          (⊂(⊂2↑⍒f)⌷i)⌷pop
      }


      CheckFitness←{
          fns←RenderChromo¨⍵
          ⍺⍺{0::1 ⋄ ⍺⍺ ⍵}¨fns
      }


:EndNamespace
