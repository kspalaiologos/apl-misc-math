
⍝ apl-misc-math  -  Copyright (C) Kamila Szewczyk, 2022.
⍝ Redistributed under the terms of the AGPLv3 license.
⍝ Load using: ⎕fix'file:///.../apl-misc-math/mm.apl'⋄mm.setup

⍝ Special thanks to Adám Brudzewsky.

:Namespace mm
    ⍝ Default settings. The library works optimally with
    ⍝ higher precision arithmetic.
    ##.(⎕FR⎕PP)←1287 34

    ⍝ Alter to change the precision of operations.
    ⍝ Note: A value too small will carry more error due to
    ⍝       floating point inaccurancy.
    epsilon←0.0000001
    int_prec←0.0001

    ⍝ Braces were supposed to make the result shy, but apparently they don't.
    ∇ {r}←setup
        (_tanh_sinh_pf _tanh_sinh_m2)←↓(○.5)×5 6∘.○int_prec×⍳÷int_prec
        _tanh_sinh_m2×←int_prec
        (_tanh_xk _tanh_wkd)←↓7 6∘.○_tanh_sinh_pf
        _tanh_sinh_m2÷←×⍨_tanh_wkd
        _erf_c←2÷(○1)*.5
        euler_gamma←(+/∘÷∘⍳-⍟) lim_inf 1
        'ok'
    ∇

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
    ztrim←{¯9 ¯11+.○(⊢×epsilon<|)9 11∘.○⍵}

    ⍝ Durand-Kerner method for finding complex polynomial roots.
    ⍝ 0.4J0.9 was chosen arbitrarily as a starting point. It is
    ⍝ neither a real number nor a de Moivre number.
    durand_kerner←{
        f←⊥∘((⊢÷⊃)⍵)⋄g←{⍵⍪⍉⍪f¨⍵}
        ztrim¨,1↑{
            v←,1↑⍵⋄g{⍺-⍵÷×/0~⍨⍺-v}⌿⍵
        }⍣⍺ g 0.4J0.9*⎕io-⍨⍳1-⍨≢⍵
    }

    ⍝ The Faddeev-LeVerrier algorithm for finding the characteristic
    ⍝ polynomial of a square matrix.
    faddeev_leverrier←{
        ⎕io←0⋄(≠/⍴⍵)∨2≠≢⍴⍵:⍬⋄n←≢⍵
        M0←⍵⋄I←n n⍴1↑⍨1+n⋄⊃ {
            ⍵=0:1 I⋄(cp MP)←∇⍵-1⋄X←M0+.×MP
            c←(+/0 0⍉X)÷-⍵⋄(cp,c)(X+I×c)
        } n
    }

    ⍝ An extension to the Faddeev-LeVerrier implementation above that
    ⍝ also keeps track of the matrix used to compute the inverse.
    ⍝ The inverse can be obtained using inv cpoly←... and inv×-÷⊃⌽cpoly
    faddeev_leverrier_ex←{
        ⎕io←0⋄(≠/⍴⍵)∨2≠≢⍴⍵:⍬⋄n←≢⍵⋄inv←⍬
        M0←⍵⋄I←n n⍴1↑⍨1+n⋄cpoly←⊃ {
            ⍵=0:1 I⋄(cp MP)←∇⍵-1⋄X←M0+.×MP
            c←(+/0 0⍉X)÷-⍵
            MC←X+I×c
            _←{⍵=n-1:inv∘←MC⋄0}⍵
            (cp,c)MC
        } n
        inv cpoly
    }

    ⍝ Eigenvector computation.
    eigenvec←{
        ⎕io←0⋄(≠/⍴⍵)∨2≠≢⍴⍵:⍬
        n←≢⍵⋄I←n n⍴1↑⍨1+n⋄s←⍵-⍺×I
        q←1,⍨1↑⍨1-⍨⊃⌽⍴s⋄ztrim¨1,⍨∊⌹⍨∘-/q⊂1↓s
    }

    ⍝ A range function from dfns.
    range←{↑+/⍵{⍵×{⍵-⎕IO}⍳1+0⌈⌊(⍺⍺-⍺)÷⍵+⍵=0}\1 ¯1×-\2↑⍺,⍺+×⍵-⍺}

    ⍝ Simpson integration. Assumes bounds ⍺<⍵.
    simpson←{
        h←(⍵-⍺)÷S←÷int_prec
        (h÷3)×+/(⍺+⍥⍺⍺ ⍵),⍺((⍺⍺⊣+h×⊢)×2×1+2|⊢⍤0)⍳S
    }

    ⍝ Trapezoidal rule.
    trapz←{
        ⍺=⍵:0
        sgn←¯1*⍺>⍵
        a b←⍺(⌊,⌈)⍵
        x←↑2,/(a+0 int_prec)range b
        sgn×+/0.5×int_prec×+/⍺⍺⍤0⊢x
    }

    ⍝ The tanh-sinh quadrature.
    tanh_sinh←{
        ⍺>⍵:-⍵(⍺⍺∇∇)⍺
        ⍺ ⍵≡0 1:+/_tanh_sinh_m2×⍺⍺¨_tanh_xk
        a b←⍺ ⍵⋄g←⍺⍺
        (b-a)×+/_tanh_sinh_m2×{g a+⍵×b-a}¨_tanh_xk
    }

    ⍝ Some APLCart stuff I dislike grabbing over and over again.
    median←2÷⍨1⊥⊢⌷⍨∘⊂⍋⌷⍨∘⊂∘⌈2÷⍨0 1+≢
    stddev←≢÷⍨2*∘÷⍨(≢×+.*∘2)-2*⍨+⌿
    diag←{⍵⊂⍤⊢⌸⍥,⍨+/↑⍳⍴⍵} ⍝ Antidiagonals as a vector of vectors.

    ⍝ Partition a n-element index array according to an invertible
    ⍝ complexity function.
    part_f←{⌽⌽¨(⌽⍳⍵)⊂⍨⍸⍣¯1⌊⍺⍺⍳⌊⍺⍺⍣¯1⊢⍵}

    ⍝ Complexity functions. Used in the partitioning algoithm,
    ⍝ they include an additional n factor.
    Onbang←⊢×!         ⍝ O(n!)
    Onlogn←×⍨×⍟        ⍝ O(n log n)
    Ologn←⊢×⍟          ⍝ O(log n)
    Osqrtn←⊢×(.5*⍨⊢)   ⍝ O(sqrt(n))
    On3←⊢*∘4           ⍝ O(n^3)
    On2←⊢*∘3           ⍝ O(n^2)
    On←×⍨              ⍝ O(n)
    O1←⊢               ⍝ O(1)

    ⍝ A primitive approximation of limits at infinity.
    lim_inf←{0::⍺⍺ ⍵⋄x←⍺⍺¨ 0 1+⍵⋄epsilon<|-/x:⍺⍺∇∇(1+⍵)⋄⊃x} 

    ⍝ The error function.
    erf←{_erf_c×0(*∘-×⍨)simpson⍵}

    ⍝ The sine integrals.
    Si←{0 (1∘○÷⊢)simpson ⍵}
    si←{(mm.Si ⍵)-○.5}

    ⍝ The cosine integrals.
    Cin←{0 {⍵÷⍨1-2○⍵}simpson ⍵}
    Ci←{mm.euler_gamma + (⍟-mm.Cin)⍵}

    ⍝ Offset logarithmic integral.
    Li←{2 (÷∘⍟)mm.simpson ⍵}

    ⍝ Partial derivatives.
    invariant_a←{⍵⍵ ⍺⍺ ⍵}
    invariant_b←{⍵ ⍺⍺ ⍵⍵}
    pderv_a←{epsilon÷⍨-/(⍺⍺ invariant_b ⍵)¨⍺+epsilon 0} ⍝ Partial derivative df/d⍺
    pderv_b←{epsilon÷⍨-/(⍺⍺ invariant_a ⍺)¨⍵+epsilon 0} ⍝ Partial derivative df/d⍵
:EndNamespace
