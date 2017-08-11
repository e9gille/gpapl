:Namespace SampleTests

    mse←+.*∘2÷≢
    rmse←*∘0.5+.*∘2÷≢

    :Section Addition
      FindAddition←{
          s←#.GP.DefaultSettings 0
          s.SelectionType←#.GP.SELECT_TOURNAMENT
          s.PopulationSize←100
          s.MaxGenerations←10
          s.FunctionSet←,'+-×÷⊢⊣'∘.,'⍨¨',⊂''
          s.TerminateOnFound←0
     
          TestAddition #.GP.Run s
      }

      TestAddition←{
          mse←+.*∘2÷≢
          f←⍎⍵
          res←0 0 1 1 f¨0 1 0 1
          ~mdt←3=10|⎕DR res:1
          ~∧/scalar←0=≡¨res:1
          1⌈⌊100×1-mse 0 1 1 2-res
      }
    :EndSection ⍝ Addition

    :Section Poly
      FindPoly←{
          s←#.GP.DefaultSettings 0
          s.SelectionType←#.GP.SELECT_TOURNAMENT
          s.PopulationSize←2000
          s.MaxGenerations←100
          s.FunctionSet←,'+-×⊢⊣'∘.,'⍨' ''
          s.TerminateOnFound←0
     
          ⍵=1:TestPoly1 #.GP.Run s
          ⍵=2:TestPoly2 #.GP.RunII s
      }

      TestPoly1←{
          f←⍎⍵
          rmse←*∘0.5+.*∘2÷≢
          res←f¨0.1 0.2 0.3
          ~mdt←∨/3 5∊10|⎕DR res:1
          ~scalar←∧/0=≡¨res:1
          err←rmse 0.1111 0.2496 0.4251-res  ⍝ +/x*1 2 3 4
          l←0.01×⌊20÷⍨≢⍵
          1⌈⌊100×1-err+l
      }
⍝      ]runtime "{+/⍵∘.*1 2 3 4}.1 .2 .3" "((⊢+×⍨)××+×⍨).1 .2 .3" -compare
⍝
⍝  {+/⍵∘.*1 2 3 4}.1 .2 .3 → 9.0E¯6 |   0% ⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕
⍝  ((⊢+×⍨)××+×⍨).1 .2 .3   → 4.2E¯6 | -54% ⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕


      TestPoly2←{
          f←⍎⍵
          rmse←*∘0.5+.*∘2÷≢
          res←f¨0.1 0.2 0.3
          ~mdt←∨/3 5∊10|⎕DR res:1
          ~scalar←∧/0=≡¨res:1
          err←rmse 0.0909 0.1664 0.2289-res   ⍝ 1 ¯1 1 ¯1+.×x*1 2 3 4
          l←0.01×⌊20÷⍨≢⍵
          1⌈⌊100×1-err+l
      }   
⍝        ]runtime "{1 ¯1 1 ¯1+.×⍉⍵∘.*1 2 3 4}.1 .2 .3" "(×⍨-⍨⊢+(⊣-×⍨)×⍨×⍨).1 .2 .3" -compare
⍝                                                                                              
⍝  {1 ¯1 1 ¯1+.×⍉⍵∘.*1 2 3 4}.1 .2 .3 → 1.0E¯5 |   0% ⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕ 
⍝  (×⍨-⍨⊢+(⊣-×⍨)×⍨×⍨).1 .2 .3         → 6.1E¯6 | -41% ⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕                 
    :EndSection ⍝ Poly

    :Section RandomDistribution
      FindRandom←{
          s←#.GP.DefaultSettings 0
          s.SelectionType←#.GP.SELECT_TOURNAMENT
          s.PopulationSize←4000
          s.MaxGenerations←100
          s.FunctionSet←,'+-×⊢⊣'∘.,'⍨' ''
     
          TestDist #.GP.Run s
      }

      TestDist←{
          f←⍎⍵
          rmse←*∘0.5+.*∘2÷≢
          res←f 0.1 0.2 0.3 0.4
          ~mdt←∨/3 5∊10|⎕DR res:1
          ~scalar←∧/0=≡¨res:1
          err←rmse 0.8481997398 0.9832955679 0.08414595209 0.5652422895-res   ⍝ 4(?⍴)0
          l←0⍝0.01×⌊20÷⍨≢⍵
          1⌈⌊100×1-err+l
      }         
      :EndSection ⍝ RandomDistribution


      TestPartition←{
          f←⍎⍵
          r←','f'abba,,barbra'
          'abba' 'barbra'≡r:100
          ~dt←0=10|⎕DR↑r:1
          shp←(,2)≡⍴r
          rk←(,1)≡⍴⍴r
          dpth←2=≡r
          tnl←∧/'abba' 'barbra'∊r
          2 2 10 10 20(+/×)dt rk dpth shp tnl
      }

      TestPartitionWE←{
          f←⍎⍵
          r←','f'ab,,cd,'
          ~dt←0=10|⎕DR↑r:1
          shp←(,4)≡⍴r
          rk←(,1)≡⍴⍴r
          dpth←2=≡r
          t1←'ab' '' 'cd' ''≡r
          t2←'ab' 'bar,'≡',,'f'ab,,bar,'
          2 2 10 10 38 38(+/×)dt rk dpth shp t1 t2
     
      }

      TestDTB←{
          f←⍎⍵
          r←' 'f'ab bar    '
          'ab bar'≡r:100
          ~mdt←0=10|⎕DR r:1
          rk←(,1)≡⍴⍴r
          tnl←∧/'ab' 'bar'(1∊⍷)¨⊂r
          2 2 10(+/×)mdt rk tnl
      }

      ⍝ ⊣⊥≠\
      TestImage←{
          f←⍎⍵
          zero←0 1 1 0 1 0 0 1 1 0 0 1 1 0 0 1 0 1 1 0
          one←0 0 1 0 0 0 1 0 0 0 1 0 0 0 1 0 0 0 1 0
          two←0 1 1 0 1 0 0 1 0 0 1 0 0 1 0 0 1 1 1 1
          three←1 1 1 1 0 0 0 1 0 1 1 1 0 0 0 1 1 1 1 1
          four←1 0 0 0 1 0 1 0 1 1 1 1 0 0 1 0 0 0 1 0
          res←f¨zero one two three four
          ~mdt←3=10|⎕DR res:1
          ~scalar←∧/0=≡¨res:1
          1⌈⌊10×10-mse 0 1 2 3 4-res
      }

:EndNamespace
