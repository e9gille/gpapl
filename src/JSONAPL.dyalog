 JSONAPL←{
     enc←{
         t←10|⎕DR ⍵
         isns←9=⎕NC'⍵'
         issc←(0∊⍴⍴⍵)∧0=≡⍵
         isns<issc:,⍣(t=0)⊢⍵
         t=0:(⍴⍴⍵),(⍴⍵),⊂,⍵
         2|t:(⍴⍴⍵),(⍴⍵),,⍵
         ~issc:(⍴⍴⍵),(⍴⍵),∇¨,⍵
         vn fn←⍵.⎕NL¨-(2 9)(3 4)
         0∊⍴vn,fn:⍵
         pn←vn,{0(7162⌶)⍵}¨'∇',¨fn
         vv←vn{0∊⍴⍺:⍺ ⋄ enc¨⍵.⍎¨⍺}⍵
         fv←fn{0∊⍴⍺:⍺ ⋄ enc¨⍵.⎕NR¨⍺}⍵
         x←pn(ns←⎕NS'').{⍎⍺,'←⍵'}¨vv,fv
         ns
     }
     dec←{
         9=⎕NC'⍵':ns ⍵
         t←10|⎕DR ⍵
         (0∊⍴⍴⍵)∧0=≡⍵:⍵
         (1=⍴⍴⍵)∧(1=≡⍵)∧0=t:⍬⍴⍵
         r←⊃⍵ ⋄ s←r↑1↓⍵
         w←(1+r)↓⍵
         v←s⍴⊃⍣(1=≢w)⊢w
         6≠t:v
         ∇¨v
     }
     ns←{
         0∊⍴vn←⍵.⎕NL-2 9:⍵
         vv←dec¨⍵.⍎¨vn
         pn←1(7162⌶)¨vn
         x←⍵.⎕EX↑vn~pn
         ⍵⊣pn ⍵.{'∇'=⊃⍺:⎕FX ⍵ ⋄ ⍎⍺,'←⍵'}¨vv
     }
     ⍺←0=10|⎕DR ⍵
     ⍺:dec ⎕JSON ⍵
     ⎕JSON enc ⍵
 }
⍝)(!JSONAPL!Administrator!2017 9 5 22 25 10 0!0
