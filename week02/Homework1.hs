Skip to content
Search or jump to…

Pull requests
Issues
Marketplace
Explore
 
@zachyking 
input-output-hk
/
plutus-pioneer-program
48
19958
Code
Issues
1
Pull requests
Actions
Projects
Wiki
Security
Insights
plutus-pioneer-program/code/week02/src/Week02/Homework1.hs
@brunjlar
brunjlar finished code for week 2
Latest commit 0e9277b 2 days ago
 History
 1 contributor
85 lines (71 sloc)  3.05 KB
  
{-# LANGUAGE DataKinds           #-}
{-# LANGUAGE FlexibleContexts    #-}
{-# LANGUAGE NoImplicitPrelude   #-}
{-# LANGUAGE OverloadedStrings   #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TemplateHaskell     #-}
{-# LANGUAGE TypeApplications    #-}
{-# LANGUAGE TypeFamilies        #-}
{-# LANGUAGE TypeOperators       #-}

module Week02.Homework1 where

import           Control.Monad        hiding (fmap)
import           Data.Map             as Map
import           Data.Text            (Text)
import           Data.Void            (Void)
import           Plutus.Contract      hiding (when)
import           PlutusTx             (Data (..))
import qualified PlutusTx
import           PlutusTx.Prelude     hiding (Semigroup(..), unless)
import           Ledger               hiding (singleton)
import           Ledger.Constraints   as Constraints
import qualified Ledger.Scripts       as Scripts
import qualified Ledger.Typed.Scripts as Scripts
import           Ledger.Ada           as Ada
import           Playground.Contract  (printJson, printSchemas, ensureKnownCurrencies, stage)
import           Playground.TH        (mkKnownCurrencies, mkSchemaDefinitions)
import           Playground.Types     (KnownCurrency (..))
import           Prelude              (Semigroup (..))
import           Text.Printf          (printf)

{-# INLINABLE mkValidator #-}
-- This should validate if and only if the two Booleans in the redeemer are equal!
mkValidator :: () -> (Bool, Bool) -> ValidatorCtx -> Bool
mkValidator _ _ _ = True -- FIX ME!

data Typed
instance Scripts.ScriptType Typed where
-- Implement the instance!

inst :: Scripts.ScriptInstance Typed
inst = undefined -- FIX ME!

validator :: Validator
validator = undefined -- FIX ME!

valHash :: Ledger.ValidatorHash
valHash = undefined -- FIX ME!

scrAddress :: Ledger.Address
scrAddress = undefined -- FIX ME!

type GiftSchema =
    BlockchainActions
        .\/ Endpoint "give" Integer
        .\/ Endpoint "grab" (Bool, Bool)

give :: (HasBlockchainActions s, AsContractError e) => Integer -> Contract w s e ()
give amount = do
    let tx = mustPayToTheScript () $ Ada.lovelaceValueOf amount
    ledgerTx <- submitTxConstraints inst tx
    void $ awaitTxConfirmed $ txId ledgerTx
    logInfo @String $ printf "made a gift of %d lovelace" amount

grab :: forall w s e. (HasBlockchainActions s, AsContractError e) => (Bool, Bool) -> Contract w s e ()
grab bs = do
    utxos <- utxoAt scrAddress
    let orefs   = fst <$> Map.toList utxos
        lookups = Constraints.unspentOutputs utxos      <>
                  Constraints.otherScript validator
        tx :: TxConstraints Void Void
        tx      = mconcat [mustSpendScriptOutput oref $ Redeemer $ PlutusTx.toData bs | oref <- orefs]
    ledgerTx <- submitTxConstraintsWith @Void lookups tx
    void $ awaitTxConfirmed $ txId ledgerTx
    logInfo @String $ "collected gifts"

endpoints :: Contract () GiftSchema Text ()
endpoints = (give' `select` grab') >> endpoints
  where
    give' = endpoint @"give" >>= give
    grab' = endpoint @"grab" >>= grab

mkSchemaDefinitions ''GiftSchema

mkKnownCurrencies []
© 2021 GitHub, Inc.
Terms
Privacy
Security
Status
Docs
Contact GitHub
Pricing
API
Training
Blog
About
Loading complete