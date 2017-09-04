:Namespace AntSimulator
    ⎕IO←0

      World←{
        ⍝ ⍵ ←→ sizeX [sizeY]
        ⍝ ⍺ ←→ [food_rate] [layers]
          ⍺←0.01
          fr l←2↑⍺,2
          fc←⌈fr×t←×/s←2⍴⍵
          l↑(1,s)⍴fc((⍳⊢)∊⌊?⊢)t
      }

    Rotate←{⊖⍤2⍣(1<⍺)⌽⍤2⍣(⍺∊1 2)⍉⍤2⍣(⍺∊1 3)⊢⍵}  ⍝ rotate 3d matrix ⍵ to point in dir ⍺ (NWSE=0123)
    Area←{((⊂⍳⊃⍴⍵),(1↓⍴⍵)|¨⍺+⊂¯1 0 1)⌷⍵}        ⍝ Area surrounding ⍺ (x y)

    :Section Ant
      NewAnt←{
        ⍝ ⍵ ←→ ⍬ = create new ant, ns = copy ANN and reset
          a←{0∊⍴⍵:#.ANN.New 18 10 2 ⋄ ⎕NS ⍵}⍵
          a.Name←'MyAnt'
          a.Coords←0 0
          a.CoordsVisited←,⊂a.Coords
          a.Dir←3
          a.Food←0
          a
      }
    AntView←{⍺.Dir Rotate ⍺.Coords Area ⍵}      ⍝ Area surrounding ant in facing direction
      ActivateBrain←{
        ⍝ ⍺ ←→ ant
        ⍝ ⍵ ←→ world
          in←,⍺ AntView ⍵               ⍝ get view
          out←2⊥⌊0.5+⍺ #.ANN.Process in ⍝ feed neurons
          out=0:⍵⊣⍺.Dir←4|⍺.Dir+1       ⍝ turn left
          out=1:⍵⊣⍺.Dir←4|⍺.Dir-1       ⍝ turn right
          out=2:⍺ Move ⍵                ⍝ move forward
          out=3:⍺ Mark ⍵                ⍝ toggle marker
      }

    Mark←{~@(⊂1,⍺.Coords)⊢⍵}
      Move←{
          ∆←⍺.Dir⊃(¯1 0)(0 ¯1)(1 0)(0 1)⍝ get ∆ for direction of move
          ⍺.Coords←(1↓⍴⍵)|⍺.Coords+∆    ⍝ move ant
          ⍺.CoordsVisited∪←⊂⍺.Coords
          ⍺.Food+←(fc←⊂0,⍺.Coords)⊃⍵     ⍝ collect food
          0@fc⊢⍵                     ⍝ remove food from map
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
        ⍝ ⍵ ←→ (world)(population)(fitness values)
          ⍺←0.1
          w p f←⍵
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

      Run←{
        ⍝ ⍺ ←→ world
        ⍝ ⍵ ←→ (population size) (steps) (generations) (survival_rate) (mutation_rate)
          w←⍺
          ps st gs sr mr←⍵,(≢⍵)↓10(⊃×/1↓⍴⍺)100 0.01 0.2
          ants←NewAnt¨ps⍴⊂⍬
          ws←ants ActivateBrain⍣st¨⊂w
          r←ResultSpace ⍬
          cnt w ants←r{
              cnt w ants←⍵
              fit←Fitness ants
              _←⍺ Log cnt ants fit
              ng←sr mr NextGeneration w ants fit
              ws←ng ActivateBrain⍣st¨⊂w
              (cnt+1)w ng
          }⍣(gs-1)⊢1 w ants
          fit←Fitness ants
          Summary r Log cnt ants fit
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

    Fitness←{⍵.(+/10 1×Food,≢CoordsVisited)}

      Log←{
          ⍺.HallOfFame⍪←l←FindLeader ⍵
          ⍺⊣⍞←(⎕PW⍴⎕UCS 8),RenderResult l
      }

      FindLeader←{
          cnt pop fit←⍵
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
          r.HallOfFame←⍉⍪'Generation' 'Fitness' 'Solution'
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
              ⍺{⍺.⎕NEW'Circle'(∆,⊂'Points'(hcs×1+2×⍵))}¨⍸0⌷⍵
          }

          Scent←{
            ⍝ ⍺ ←→ form
            ⍝ ⍵ ←→ world
              ∆←('Size'(2/⍺.cs))('FStyle' 0)('FillCol'(0 0 255))
              0∊⍴i←⍸1⌷⍵:⍬
              ⍺{⍺.⎕NEW'Rect'(∆,⊂'Points'(⍺.cs×⍵))}¨i
          }

          World←{
            ⍝ ⍺ ←→ form
            ⍝ ⍵ ←→ world ant
              w a←⍵
              ⍺←⎕NEW'Form'(('Coord' 'Pixel')('Size'(400 400)))
              f←⍺
              f.Caption←a.Name
              f.cs←⌊/f.Size÷1↓⍴w
              f.scent←f Scent w
              f.food←f Food w
              f.ant←f Ant a
              f
          }

          Play←{
            ⍝ ⍺ ←→ ant
            ⍝ ⍵ ←→ (world) (steps) (frame_rate)
            ⍝ ← ←→ world
              a←⍺
              w s fr←⍵
              dl←÷fr
              f←World w a
              1:r←a{
                  _←⎕DL dl
                  w∆←⍺ ##.ActivateBrain ⍵
                  w∆⊣f World w∆ ⍺
              }⍣s⊢w
          }

    :EndNamespace

:EndNamespace
