{-# OPTIONS --guardedness #-}

module PolyfunctorCoalgebras where

open import Level using (_⊔_; suc; Level)
-- open import Category
open import Categories.Category
open import Data.Product using (Σ; Σ-syntax; _,_; _×_) 
-- open import Categories.Category.CartesianClosed using (CartesianClosed) CCC doesn't have coproducts or something
open import Categories.Functor using (Functor; Endofunctor; _∘F_)

import Relation.Binary.PropositionalEquality as Eq
open Eq using (_≡_; refl; sym; trans; cong)

-- open import Categories.Category.BinaryProducts using (BinaryProducts)

open import Categories.Category.Instance.Sets

-- open import Axiom.Extensionality.Propositional using (Extensionality)
-- postulate fun-ext : ∀ {f g} → Extensionality f g

open import Coalgebras
open import FinalCoalgebras
open import Polyfunctor

module _ {o : Level} {I : Set o} (C B : I → Set o) where
   module S = Category (Sets o)
   P : Endofunctor (Sets o)
   P = Polyfunctor C B
   Pcat : Category (suc o) o o
   Pcat = CoalgCat P
   open Functor P renaming (F₀ to P₀; F₁ to P₁)

   -- data M-type {I : Set o} (C B : I → Set o) : Set (suc o) where
   --    inf : (i : I) → C i × (B i → ∞ (M-type C B)) → M-type C B

   pr₁ : {A : Set o} {B : A → Set o} → Σ[ a ∈ A ] B a → A
   pr₁ (fst , snd) = fst
   pr₂ : {A : Set o} {B : A → Set o} → (x : Σ[ a ∈ A ] B a) → B (pr₁ x)
   pr₂ (fst , snd) = snd
   pr₁₂ : {A : Set o} {B C : A → Set o} → (x : Σ[ a ∈ A ] B a × C a) → Σ[ a ∈ A ] B a
   pr₁₂ (fst , snd , trd) = fst , snd
   pr₃ : {A : Set o} {B C : A → Set o} → (x : Σ[ a ∈ A ] B a × C a) → C (pr₁ x)
   pr₃ (fst , snd , trd) = trd

   record M-type {I : Set o} (C B : I → Set o) : Set o where
      coinductive
      constructor inf
      field
         root : Σ[ i ∈ I ] C i
         tree : B (pr₁ root) → M-type C B
   open M-type public

   Pt : (t : M-type C B) → P₀ (M-type C B)
   Pt t = pr₁ (root t) , (pr₂ (root t)) , (λ b → tree t b)

   PolyfunctorFinalCoalgebra : FinalCoalgebra P
   PolyfunctorFinalCoalgebra = record
      { Z        = Z-aux
      ; !        = !-aux
      ; !-unique = λ {record { map = map ; comm = comm }
                   → {!   !}}
      }
      where open Definitions using (CommutativeSquare)
            open import CommSqReasoning
            Z-aux : Coalgebra P
            Z-aux = record
               { X = M-type C B
               ; α = λ t → pr₁ (root t) , (pr₂ (root t)) , (λ b → tree t b)
               }
            module C = Category Pcat
            !-aux : {A : Coalgebra P} → Pcat [ A , Z-aux ]
            !-aux {A} = record
               { map  = map-aux
               ; comm = comm-aux
               }
               where open Coalgebra A
                     open Coalgebra Z-aux renaming (X to Z; α to ζ)
                     map-aux : Sets o [ X , Z ]
                     map-aux x .root   = pr₁₂ (α x)
                     map-aux x .tree b = map-aux (pr₃ (α x) b)

                     open import Categories.Morphism.Reasoning (Sets o)
                     -- open S.HomReasoning
                     comm-aux : CommutativeSquare (Sets o) map-aux α ζ (P₁ map-aux)
                     -- comm-aux {x} with map-aux x | P₁ map-aux (α x) | α x in eq-αx
                     -- ... | p | q | r = {!   !}
                     -- ... | p₁ , p₂ | q₁ , q₂₁ , q₂₂ | r₁ , r₂₁ , r₂₂ rewrite eq-αx = cong (λ y → r₁ , r₂₁ , y) {!   !}
                     comm-aux {x} = refl
                     -- comm-aux {x} = begin
                     --    (ζ ∘ map-aux) x    ≡⟨ {!   !} ⟩
                     --    {!   !}           ≡⟨ {!   !} ⟩
                     --    (P₁ map-aux ∘ α) x ∎
                        where open S
                              open Eq.≡-Reasoning
