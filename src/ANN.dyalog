:Namespace ANN
⍝ Artificial Neural Network
⍝ Feed-Forward with Back Propagation
    ⎕RL←⍬ 2

      New←{
         ⍝ ⍵ ←→ dimensions
         ⍝ ← ←→ network
          n←⎕NS''
          n.weights←1-2×2{⍺ ⍵(?⍴)0}/⍵
          n.biases←1-2×1↓⍵(?⍴)¨0
          n.learning_rate←0.5
          n.training_iterations←1000
          n.error_threshold←0.001
          n
      }

      Process←{
        ⍝ ⍺ ←→ network
        ⍝ ⍵ ←→ input
        ⍝ ← ←→ output
          ⊃⌽⍺.(weights biases)outputs ⍵
      }

      Train←{
        ⍝ ⍺ ←→ network
        ⍝ ⍵ ←→ patterns (vec of input target pairs)
          wb e←⊃{
              wb e←(⊃⍵)trainSingle ⍺
              wb(e,⊃⌽⍵)
          }/⍵,⊂⍺.(weights biases)⍬
          ⍺.(weights biases)←wb
          ⍺.training_iterations-←1
          ⍺.training_iterations<0:
          ⍺.error_threshold>mse e:
          ⍺ ∇ ⍵
      }

    mse←+.*∘2÷≢

    sigmoid←{÷1+*-⍵}

      outputs←{
        ⍝ ⍺ ←→ (weights) (biases)
        ⍝ ⍵ ←→ input
        ⍝ ← ←→ outputs
          1↓⊃{
              w b←⍺
              ⍵,⊂sigmoid b+(⊃⌽⍵)+.×w
          }/⌽(⊂⊂⍵),↓⍉↑⍺
      }


      trainSingle←{
        ⍝ ⍺ ←→ (weights) (biases)
        ⍝ ⍵ ←→ (inputs) (target)
        ⍝ ← ←→ (adjusted weights) (errors)
          w b←⍺
          in t←⍵
          n←1   ⍝ learning rate
          out←⍺ outputs in
          ∆o←out×1-out
          ∆e←t-⊃⌽out
          ∆←∆e×⊃⌽∆o
          ∆bp←⊃{w o←⍺
              ⍵,⍨⊂o×w+.×⊃⍵
          }/(↓⍉↑(1↓w)(¯1↓∆o)),⊂⊂∆
          wp←w+n×((⊂in),¯1↓out)∘.×¨∆bp
          wb←b+n×∆bp
          (wp wb)∆e
      }

:EndNamespace
