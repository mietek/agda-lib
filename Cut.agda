
open import Prelude hiding (⊥)
open import Foc

module Cut where

cut⁺ : ∀{A U Γ Ω}
  → Γ suspnormalΓ
  → U suspnormalR 
  → Value Γ A
  → Term Γ (A :: Ω) U
  → Term Γ Ω U

cut⁻ : ∀{U A Γ} 
  → Γ suspnormalΓ
  → U suspstable
  → Term Γ [] (Inv A)
  → Spine Γ A U
  → Term Γ [] U

rsubst : ∀{Γ A Form} (Γ' : Ctx)
  → (Γ' ++ Γ) suspnormalΓ
  → Form suspnormalF 
  → Term (Γ' ++ Γ) [] (Inv A)
  → Exp (Γ' ++ (Pers A) :: Γ) Form
  → Exp (Γ' ++ Γ) Form

lsubst : ∀{Γ U L A} 
  → Γ suspnormalΓ
  → U suspstable
  → Exp Γ (Left L (True A))
  → Term Γ [ A ] U 
  → Exp Γ (Left L U)

-- Positive principal substitution
cut⁺ {A} pfΓ pf (id⁺ x) N with pfΓ x
cut⁺ {a Q .⁺} pfΓ pf (id⁺ x) (η⁺ N) | <> = wk (LIST.SET.sub-cntr x) N
cut⁺ {↓ A} pfΓ pf (id⁺ x) N | ()
cut⁺ {⊥} pfΓ pf (id⁺ x) N | ()
cut⁺ {A ∨ B} pfΓ pf (id⁺ x) N | ()
cut⁺ {⊤⁺} pfΓ pf (id⁺ x) N | ()
cut⁺ {A ∧⁺ B} pfΓ pf (id⁺ x) N | ()
cut⁺ pfΓ pf (↓R N) (↓L N') = rsubst [] pfΓ pf N N'
cut⁺ pfΓ pf (∨R₁ V) (∨L N₁ N₂) = cut⁺ pfΓ pf V N₁
cut⁺ pfΓ pf (∨R₂ V) (∨L N₁ N₂) = cut⁺ pfΓ pf V N₂
cut⁺ pfΓ pf ⊤⁺R (⊤⁺L N) = N
cut⁺ pfΓ pf (∧⁺R V₁ V₂) (∧⁺L N) = cut⁺ pfΓ pf V₂ (cut⁺ pfΓ pf V₁ N)

-- Negative principle substitution
cut⁻ pfΓ pf (focusL () x Sp') Sp 
cut⁻ pfΓ pf (η⁻ N) id⁻ = N
cut⁻ pfΓ (_ , ()) N (id⁻ {↑ A}) 
cut⁻ pfΓ (_ , ()) N (id⁻ {A ⊃ B})
cut⁻ pfΓ (_ , ()) N (id⁻ {⊤⁻})
cut⁻ pfΓ (_ , ()) N (id⁻ {A ∧⁻ B})
cut⁻ pfΓ pf (↑R N) (↑L N') = lsubst pfΓ pf N N'
cut⁻ pfΓ pf (⊃R N) (⊃L V Sp) = cut⁻ pfΓ pf (cut⁺ pfΓ <> V N) Sp
cut⁻ pfΓ pf (∧⁻R N₁ N₂) (∧⁻L₁ Sp) = cut⁻ pfΓ pf N₁ Sp
cut⁻ pfΓ pf (∧⁻R N₁ N₂) (∧⁻L₂ Sp) = cut⁻ pfΓ pf N₂ Sp

-- Substitution into values
rsubst Γ' pfΓ pf N (id⁺ x) with fromctx Γ' x 
... | Inl () 
... | Inr x' = id⁺ x'
rsubst Γ' pfΓ pf N (↓R N') = ↓R (rsubst Γ' pfΓ pf N N')
rsubst Γ' pfΓ pf N (∨R₁ V) = ∨R₁ (rsubst Γ' pfΓ pf N V)
rsubst Γ' pfΓ pf N (∨R₂ V) = ∨R₂ (rsubst Γ' pfΓ pf N V)
rsubst Γ' pfΓ pf N ⊤⁺R = ⊤⁺R
rsubst Γ' pfΓ pf N (∧⁺R V₁ V₂) = 
  ∧⁺R (rsubst Γ' pfΓ pf N V₁) (rsubst Γ' pfΓ pf N V₂)

-- Substitution into terms
rsubst Γ' pfΓ pf N (focusR V) = focusR (rsubst Γ' pfΓ pf N V)
rsubst Γ' pfΓ pf N (focusL pf⁻ x Sp) with fromctx Γ' x
... | Inl Refl = cut⁻ pfΓ (pf⁻ , pf) N (rsubst Γ' pfΓ pf N Sp)
... | Inr x' = focusL pf⁻ x' (rsubst Γ' pfΓ pf N Sp)
rsubst Γ' pfΓ pf N (η⁺ N') = η⁺ (rsubst (_ :: Γ') (cons <> pfΓ) pf (wken N) N')
rsubst Γ' pfΓ pf N (η⁻ N') = η⁻ (rsubst Γ' pfΓ pf N N')
rsubst Γ' pfΓ pf N (↓L N') = ↓L (rsubst (_ :: Γ') (cons <> pfΓ) pf (wken N) N')
rsubst Γ' pfΓ pf N (↑R N') = ↑R (rsubst Γ' pfΓ pf N N')
rsubst Γ' pfΓ pf N ⊥L = ⊥L
rsubst Γ' pfΓ pf N (∨L N₁ N₂) =
  ∨L (rsubst Γ' pfΓ pf N N₁) (rsubst Γ' pfΓ pf N N₂)
rsubst Γ' pfΓ pf N (⊤⁺L N') = ⊤⁺L (rsubst Γ' pfΓ pf N N')
rsubst Γ' pfΓ pf N (∧⁺L N') = ∧⁺L (rsubst Γ' pfΓ pf N N')
rsubst Γ' pfΓ pf N (⊃R N') = ⊃R (rsubst Γ' pfΓ pf N N')
rsubst Γ' pfΓ pf N ⊤⁻R = ⊤⁻R
rsubst Γ' pfΓ pf N (∧⁻R N₁ N₂) = 
  ∧⁻R (rsubst Γ' pfΓ pf N N₁) (rsubst Γ' pfΓ pf N N₂)

-- Substitution into spines
rsubst Γ' pfΓ pf N id⁻ = id⁻
rsubst Γ' pfΓ pf N (↑L N') = ↑L (rsubst Γ' pfΓ pf N N')
rsubst Γ' pfΓ pf N (⊃L V Sp) = ⊃L (rsubst Γ' pfΓ <> N V) (rsubst Γ' pfΓ pf N Sp)
rsubst Γ' pfΓ pf N (∧⁻L₁ Sp) = ∧⁻L₁ (rsubst Γ' pfΓ pf N Sp)
rsubst Γ' pfΓ pf N (∧⁻L₂ Sp) = ∧⁻L₂ (rsubst Γ' pfΓ pf N Sp)

-- Substitution out of terms
lsubst pfΓ pf (focusR V) N = cut⁺ pfΓ (snd pf) V N
lsubst pfΓ pf (focusL pf⁻ x Sp) N = focusL (fst pf) x (lsubst pfΓ pf Sp N)
lsubst pfΓ pf (η⁺ N) N' = η⁺ (lsubst (cons <> pfΓ) pf N (wken N'))
lsubst pfΓ pf (↓L N) N' = ↓L (lsubst (cons <> pfΓ) pf N (wken N'))
lsubst pfΓ pf ⊥L N = ⊥L
lsubst pfΓ pf (∨L N₁ N₂) N = ∨L (lsubst pfΓ pf N₁ N) (lsubst pfΓ pf N₂ N)
lsubst pfΓ pf (⊤⁺L N) N' = ⊤⁺L (lsubst pfΓ pf N N')
lsubst pfΓ pf (∧⁺L N) N' = ∧⁺L (lsubst pfΓ pf N N')

-- Substitution out of spines 
lsubst pfΓ pf (↑L N) N' = ↑L (lsubst pfΓ pf N N')
lsubst pfΓ pf (⊃L V Sp) N = ⊃L V (lsubst pfΓ pf Sp N)
lsubst pfΓ pf (∧⁻L₁ Sp) N = ∧⁻L₁ (lsubst pfΓ pf Sp N)
lsubst pfΓ pf (∧⁻L₂ Sp) N = ∧⁻L₂ (lsubst pfΓ pf Sp N)