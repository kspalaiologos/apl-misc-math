
⍝ apl-misc-math  -  Copyright (C) Kamila Szewczyk, 2022.
⍝ Redistributed under the terms of the AGPLv3 license.
⍝ Load using: ⎕fix'file:///.../apl-misc-math/mm.apl'

⍝ Special thanks to Adám Brudzewsky.

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

    ⍝ d^n⍺⍺/dx^n |x=⍵
    nderv←{⍵⍵=1:⍺⍺ D ⍵ ⋄ ((⍺⍺ D) ∇∇ (⍵⍵-1)) ⍵}

    ⍝ The secant root-finding method. ⍵ is starting x1,x2
    secant←{
        f←⍺⍺⋄⊃⌽{
            dy←-/y1 y2←f¨x1 x2←⍵
            x2,x1-y1×dy÷⍨-/⍵
        }⍣{epsilon>|-/⍺}⍵
    }

    ⍝ Trim insignificant real/imaginary parts.
    ztrim←{+/¯9 ¯11○(⊢×epsilon<|)9 11○⍵}

    ⍝ Durand-Kerner method for finding complex polynomial roots.
    ⍝ 0.4J0.9 was chosen arbitrarily as a starting point. It is
    ⍝ neither a real number nor a de Moivre number.
    durand_kerner←{
        f←⊥∘((⊢÷⊃)⍵)⋄g←{⍵⍪⍉⍪f¨⍵}
        ztrim¨,1↑{
            v←,1↑⍵⋄g{⍺-⍵÷×/0~⍨⍺-v}⌿⍵
        }⍣⍺ g 0.4J0.9*⎕io-⍨⍳1-⍨≢⍵
    }
:EndNamespace
