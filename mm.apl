
:Namespace mm
    ⍝ Default settings. The library works optimally with
    ⍝ higher precision arithmetic. Braces were supposed
    ⍝ to make the result shy, but apparently they don't.
    ∇ {r}←setup
        (⎕FR⎕PP)⊢←1287 34
        'ok'
    ∇

    ⍝ Alter to change the precision of operations.
    ⍝ Note: A value too small will carry more error due to
    ⍝       floating point inaccurancy.
    epsilon←0.0000001

    ⍝ d⍺⍺/dx |x=⍵
    derv←{epsilon÷⍨-/⍺⍺¨⍵+epsilon 0}
:EndNamespace
