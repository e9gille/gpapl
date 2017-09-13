:Namespace AntSimulator
    ⎕IO←0
    ⎕RL←⍬2

⍝ # How to run
⍝    w←.01 #.AntSimulator.World 10 10           ⍝ Create a 10x10 world
⍝    r←w #.AntSimulator.Run 10 200 1000         ⍝ run evolution (pop=10)(steps=200)(gens=1000)
⍝    a←#.AntSimulator.NewAnt r.Winner           ⍝ copy the winner
⍝    a #.AntSimulator.Render.Play w 400 30      ⍝ run the simulator on winner

     ⍝ Layers
    LF LO LS LV←⍳L←4

      World←{
        ⍝ ⍵ ←→ sizeX [sizeY]
        ⍝ ⍺ ←→ [food_rate][obstacle_rate]
          ⍺←0.01
⍝          fc←⌈⍺×t←×/s←2⍴⍵
⍝          L↑(1,s)⍴fc((⍳⊢)∊⌊?⊢)t
          cnts←2⍴⌈⍺×t←×/s←2⍴⍵
          map←(cnts/1 2)@(1+(+/cnts)?t-1)⊢t⍴0   ⍝ place food and obstacles, avoid ind=0 where ant is placed
          L↑(2,s)⍴⊖2 2⊤map                      ⍝ reshape into 3d world
      }

    Rotate←{⊖⍤2⍣(1<⍺)⌽⍤2⍣(⍺∊1 2)⍉⍤2⍣(⍺∊1 3)⊢⍵}  ⍝ rotate 3d matrix ⍵ to point in dir ⍺ (NWSE=0123)
    Area←{((⊂⍳⊃⍴⍵),(1↓⍴⍵)|¨⍺+⊂¯1 0 1)⌷⍵}        ⍝ Area surrounding ⍺ (x y)

    :Section Ant
      NewAnt←{
        ⍝ ⍵ ←→ ⍬ = create new ant, ns = copy ANN and reset
          a←{0∊⍴⍵:#.ANN.New 27 10 2 ⋄ ⎕NS ⍵}⍵
          a.Name←'MyAnt'
          a.Coords←0 0
          a.Dir←3
          a.Food←0
          a
      }
    AntView←{⍺.Dir Rotate ⍺.Coords Area ⍵}      ⍝ Area surrounding ant in facing direction
      ActivateBrain←{
        ⍝ ⍺ ←→ ant
        ⍝ ⍵ ←→ world
          in←,⍺ AntView(⊂LF LO LS)⌷⍵    ⍝ get view
          out←2⊥⌊0.5+⍺ #.ANN.Process in ⍝ feed neurons
          out=0:⍵⊣⍺.Dir←4|⍺.Dir+1       ⍝ turn left
          out=1:⍵⊣⍺.Dir←4|⍺.Dir-1       ⍝ turn right
          out=2:⍺ Move ⍵                ⍝ move forward
          out=3:⍺ Mark ⍵                ⍝ toggle marker
      }

    Mark←{~@(⊂LS,⍺.Coords)⊢⍵}
      Move←{
          ∆←⍺.Dir⊃(¯1 0)(0 ¯1)(1 0)(0 1)⍝ get ∆ for direction of move
          nc←(1↓⍴⍵)|⍺.Coords+∆          ⍝ new cell
          (⊂LO,nc)⊃⍵:⍵                  ⍝ if obstacle, don't move
          fc vc←⊂¨LF LV,¨⊂⍺.Coords
          ⍺.Coords←nc                   ⍝ set new pos
          ⍺.Food+←fc⊃⍵                  ⍝ collect food
          0 1@fc vc⊢⍵                   ⍝ remove food from map and mark visited
      }

    :EndSection

    :Section Evolution
    CrossANN←{m←1=?2⍴⍨⍴⍵ ⋄ ((,m)/,⍺)@(⍸m)⊢⍵}¨
      CrossOver←{
        ⍝ ⍺ ←→ world
        ⍝ ⍵ ←→ parents
          p1 p2←⍵
          child←NewAnt p1
          child.weights←p1.weights CrossANN p2.weights
          child.biases←p1.biases CrossANN p2.biases
          child
      }

      Mutate←{
          ant←⍵
          wb←ant.(weights biases)
          i←⍬{0=⍴⍴⍵:⍺ ⋄ (⍺,i)∇(i←⊂?⍴⍵)⊃⍵}wb       ⍝ pick random gene index
          ant.(weights biases)←(2-4×?0)×@(⊂i)⊢wb  ⍝ modify gene by factor (¯2,2)
          ant
      }

      MutateGenes←{
          ant←⍵
          ant.(weights biases)←⍺{
              ⍺>?0:¯1⌈1⌊⍵×2-4×?0
              ⍵
          }¨¨¨ant.(weights biases)
          ant
      }

      NextGeneration←{
        ⍝ ⍺ ←→ [survival_rate] [mutation_rate]
        ⍝ ⍵ ←→ (population)
          ⍺←0.1
          p f←⍵ ⍵.Fitness
          f+←1
          s←≢p
          sr mr←2⍴⍺
          next←NewAnt¨(⌈sr×s)SelectElite p f
          {
              parents←2 SelectProbabilistic p f
              child←CrossOver parents
⍝              new←Mutate⍣(mr>?0)⊢child
              new←mr MutateGenes child
              ⍵,new
          }⍣{s≤≢⍺}next
      }

      DefaultSettings←{
          s←⎕NS''
          s.MaxGenerations←1000
          s.MutationRate←0.2
          s.PopulationSize←1000
          s.SimulationSteps←100
          s.SurvivalRate←0.01
          s.TerminationThreshold←⌊/⍬
          s
      }

      Run←{
        ⍝ ⍺ ←→ world
        ⍝ ⍵ ←→ [Settings ns]
          s←DefaultSettings⍣(0∊⍴⍵)⊢⍵
          sr mr←s.SurvivalRate s.MutationRate
          ants←NewAnt¨s.PopulationSize⍴⊂⍬
          r←ResultSpace ⍬
          r.world←⍺
          ws←ants ActivateBrain⍣s.SimulationSteps¨⊂r.world
          ants.Fitness←ws Fitness ants
          cnt ants←r{
              cnt ants←⍵
              _←⍺ Log cnt ants
              ng←sr mr NextGeneration ants
              ws←ng ActivateBrain⍣s.SimulationSteps¨⊂⍺.world
              ng.Fitness←ws Fitness ng
              (cnt+1)ng
          }⍣{
              gens ants←⍺
              s.MaxGenerations≤gens:1
              s.TerminationThreshold<⌈/ants.Fitness
          }1 ants
          Summary r Log cnt ants
      }

      RunII←{
          iss←InitIsolates ⍬
          rc←iss.{≢#.⎕FIX¨⍵}⊂⎕SRC¨⎕THIS #.ANN
          res←(⊂⍺)iss.{(⍺ #.AntSimulator.Run ⍵).Winner}⊂⍵
          r←ResultSpace ⍬
          ants←⊃¨res
          r.HallOfFame⍪←⍉↑(⍳≢ants)ants.Fitness ants
          Summary r
      }

      InitIsolates←{
          _←{0::0 ⋄ r←#.⎕CY ⍵}⍣(0=⊃#.⎕NC'isolate')⊢'isolate'
          #.isolate.New¨(#.isolate.Config'processors')⍴⊂''
      }


      SelectElite←{
        ⍝ ⍵ ←→ (population)(fitness value)
          p f←⍵
          p⌷⍨⊂⍺↑⍒f
      }

      SelectProbabilistic←{
        ⍝ ⍵ ←→ (population)(fitness value)
          p f←⍵
          p⌷⍨⊂⍺{⊃¨⍸¨⍵∘≥¨⍺?⊃⌽⍵}+\f
      }

    Fitness←{0⌈(20×⍵.Food)++/¨,¨LV⌷¨⍺}

      Log←{
          ⍺.HallOfFame⍪←l←FindLeader ⍵
          ⍺⊣⍞←(⎕PW⍴⎕UCS 8),RenderResult l
      }

      FindLeader←{
          cnt pop←⍵
          fit←pop.Fitness
          best_sol←pop⊃⍨fit⍳best_fit←⌈/fit
          cnt best_fit best_sol
      }

      RenderResult←{
          cnt fit sol←⍵
          ,'I11,I9'⎕FMT⍉⍪cnt fit
      }

      Summary←{
          b←(⊢=⌈/)1↓⍵.HallOfFame[;1]
          ⍵.BestSolutions←(1,b)⌿⍵.HallOfFame
          ⎕←⊃bf ⍵.Winner←⍵.BestSolutions[1;1 2]
          ⍵
      }


      ResultSpace←{
          r←⎕NS''
          ⎕←r.HallOfFame←⍉⍪'Generation' 'Fitness' 'Solution'
          r.BestSolutions←⍬
          r
      }

    :EndSection

    :Namespace Render
          Ant←{
            ⍝ ⍺ ←→ form
            ⍝ ⍵ ←→ ant space
              n←(1 0 1 1)(0 0.5 1 0)
              w←(0 1 0.5 0)(1 1 0 1)
              s←(0 0 1 0)(0 1 0.5 0)
              e←(0 0.5 1 0)(0 1 0 0)
              points←⍺.cs×⍵.Coords+⍵.Dir⊃n w s e
              ⍺.⎕NEW'Poly'(('Points'points)('FStyle' 0)('FillCol'(255 0 0)))
          }

          Food←{
            ⍝ ⍺ ←→ form
            ⍝ ⍵ ←→ world
              hcs←⍺.cs÷2
              ∆←('Radius'hcs)('FStyle' 0)('FillCol'(0 255 0))
              ⍺{⍺.⎕NEW'Circle'(∆,⊂'Points'(hcs×1+2×⍵))}¨⍸⍵
          }

          Obstacle←{
            ⍝ ⍺ ←→ form
            ⍝ ⍵ ←→ world
              hcs←⍺.cs÷2
              ∆←('Radius'hcs)('FStyle' 0)('FillCol'(3/100))
              ⍺{⍺.⎕NEW'Circle'(∆,⊂'Points'(hcs×1+2×⍵))}¨⍸⍵
          }

          Scent←{
            ⍝ ⍺ ←→ form
            ⍝ ⍵ ←→ world
              ∆←('Size'(2/⍺.cs))('FStyle' 0)('FillCol'(0 0 255))
              0∊⍴i←⍸⍵:⍬
              ⍺{⍺.⎕NEW'Rect'(∆,⊂'Points'(⍺.cs×⍵))}¨i
          }

          Visited←{
            ⍝ ⍺ ←→ form
            ⍝ ⍵ ←→ world
              ∆←('Size'(2/⍺.cs))('FStyle' 0)('FillCol'(3/200))('LStyle' 5)
              0∊⍴i←⍸⍵:⍬
              ⍺{⍺.⎕NEW'Rect'(∆,⊂'Points'(⍺.cs×⍵))}¨i
          }

          World←{
            ⍝ ⍺ ←→ form
            ⍝ ⍵ ←→ world ant
              w a←⍵
              ⍺←⎕NEW'Form'(('Coord' 'Pixel')('Size'(400 400)))
              f←⍺
              f.(World Ant)←w a
              f.cs←⌊/f.Size÷1↓⍴w
              f.edge←f.⎕NEW'Rect'(('Points'(0 0))('Size'(f.cs×1↓⍴w)))
              f.visited←f Visited ##.LV⌷w
              f.scent←f Scent ##.LS⌷w
              f.food←f Food ##.LF⌷w
              f.obst←f Obstacle ##.LO⌷w
              f.ant←f Ant a
              f
          }

          EnterFrame←{
              f←(⊃⍵).##
              f.World←f.Ant ##.ActivateBrain f.World
              f.steps+←1
              f.Caption←f.Ant.Name,' - Steps: ',⍕f.steps
              f World f.World f.Ant
          }
        TogglePlayPause←{(⊃⍵).tmr.Active=←0}

          Play←{
            ⍝ ⍺ ←→ ant
            ⍝ ⍵ ←→ (world) (steps) (frame_rate)
            ⍝ ← ←→ world
              a←⍺
              w s fr←⍵
              dl←÷fr
              f←World w a
              f.steps←0
              f.onMouseDown←'TogglePlayPause'
              f.tmr←f.⎕NEW'Timer'(('Interval' (⌈1000÷fr))('Active' 0))
              f.tmr.onTimer←'EnterFrame'
              f.Caption←a.Name
              f.Wait
⍝              1:r←a{
⍝                  _←⎕DL dl
⍝                  w∆←⍺ ##.ActivateBrain ⍵
⍝                  f.steps+←1
⍝                  f.Caption←⍺.Name,' - Steps: ',⍕f.steps
⍝                  w∆⊣f World w∆ ⍺
⍝              }⍣s⊢w
          }

    :EndNamespace

:EndNamespace
